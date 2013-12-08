/*
 * Copyright (c) 2007-2008, Juniper Networks, Inc.
 * Copyright (c) 2008, Excito Elektronik i Skåne AB
 * Copyright (c) 2008, Michael Trimarchi <trimarchimichael@yahoo.it>
 *
 * All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation version 2 of
 * the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */


#include "util.h"		/* for endian conversions */
#include "bas_printf.h"	/* for diagnostics */
#include "wait.h"
#include "cache.h"
#include "usb.h"
#include "ehci.h"

//extern xQueueHandle queue_poll_hub;

#undef DEBUG
#undef SHOW_INFO

char ehci_inited;
static int rootdev;

static uint16_t portreset, companion;

struct descriptor {
	struct usb_hub_descriptor hub;
	struct usb_device_descriptor device;
	struct usb_linux_config_descriptor config;
	struct usb_linux_interface_descriptor interface;
	struct usb_endpoint_descriptor endpoint;
} __attribute__ ((packed));

static struct descriptor rom_descriptor = {
	{
		0x8,		/* bDescLength */
		0x29,		/* bDescriptorType: hub descriptor */
		2,		/* bNrPorts -- runtime modified */
		0,		/* wHubCharacteristics */
		0xff,		/* bPwrOn2PwrGood */
		0,		/* bHubCntrCurrent */
		{},		/* Device removable */
		{}		/* at most 7 ports! XXX */
	},
	{
		0x12,		/* bLength */
		1,		/* bDescriptorType: UDESC_DEVICE */
		0x0002,		/* bcdUSB: v2.0 */
		9,		/* bDeviceClass: UDCLASS_HUB */
		0,		/* bDeviceSubClass: UDSUBCLASS_HUB */
		1,		/* bDeviceProtocol: UDPROTO_HSHUBSTT */
		64,		/* bMaxPacketSize: 64 bytes */
		0x0000,		/* idVendor */
		0x0000,		/* idProduct */
		0x0001,		/* bcdDevice */
		1,		/* iManufacturer */
		2,		/* iProduct */
		0,		/* iSerialNumber */
		1		/* bNumConfigurations: 1 */
	},
	{
		0x9,
		2,		/* bDescriptorType: UDESC_CONFIG */
		(0x19 << 8), /* cpu_to_le16(0x19), */
		1,		/* bNumInterface */
		1,		/* bConfigurationValue */
		0,		/* iConfiguration */
		0x40,		/* bmAttributes: UC_SELF_POWER */
		0		/* bMaxPower */
	},
	{
		0x9,		/* bLength */
		4,		/* bDescriptorType: UDESC_INTERFACE */
		0,		/* bInterfaceNumber */
		0,		/* bAlternateSetting */
		1,		/* bNumEndpoints */
		9,		/* bInterfaceClass: UICLASS_HUB */
		0,		/* bInterfaceSubClass: UISUBCLASS_HUB */
		0,		/* bInterfaceProtocol: UIPROTO_HSHUBSTT */
		0		/* iInterface */
	},
	{
		0x7,		/* bLength */
		5,		/* bDescriptorType: UDESC_ENDPOINT */
		0x81,		/* bEndpointAddress: UE_DIR_IN | EHCI_INTR_ENDPT */
		3,		/* bmAttributes: UE_INTERRUPT */
		8, 0,		/* wMaxPacketSize */
		255		/* bInterval */
	},
};

#if defined(CONFIG_EHCI_IS_TDI)
#define ehci_is_TDI()	(1)
#else
#define ehci_is_TDI()	(0)
#endif

struct pci_device_id ehci_usb_pci_table[] = 
{
	{
		PCI_VENDOR_ID_NEC,
		PCI_DEVICE_ID_NEC_USB_2,
		PCI_ANY_ID,
		PCI_ANY_ID,
		PCI_CLASS_SERIAL_USB_EHCI,
		0,
		0
	}, /* NEC PCI OHCI module ids */
	{
		PCI_VENDOR_ID_PHILIPS,
		PCI_DEVICE_ID_PHILIPS_ISP1561_2,
		PCI_ANY_ID,
		PCI_ANY_ID,
		PCI_CLASS_SERIAL_USB_EHCI,
		0,
		0
	}, /* Philips 1561 PCI OHCI module ids */
	/* Please add supported PCI OHCI controller ids here */
	{
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
};

static struct ehci {
	/* ------- common part -------- */
	long handle;              /* PCI BIOS */
	const struct pci_device_id *ent;
	int usbnum;
  /* ---- end of common part ---- */
	int big_endian;           /* PCI BIOS */
	struct ehci_hccr *hccr;	/* R/O registers, not need for volatile */
	volatile struct ehci_hcor *hcor;
	struct QH *qh_list_unaligned;
	struct QH *qh_list;
	struct QH *qh_unaligned;
	struct QH *qh;
	struct qTD *td_unaligned[3];
	struct qTD *td[3];
	struct descriptor *descriptor;
	int irq;
	uint32_t dma_offset;
	const char *slot_name;
} gehci;

//#define DEBUG
//#define SHOW_INFO

#ifdef DEBUG
#define debug(format, arg...) xprintf("DEBUG: " format "\r\n", ## arg)
#else
#define debug(format, arg...) do {} while (0)
#endif /* DEBUG */
#define err xprintf
#ifdef SHOW_INFO
#define info(format, arg...) xprintf("INFO: " format "\r\n", ## arg)
#else
#define info(format, arg...) do {} while (0)
#endif


static void cache_qtd(struct qTD *qtd, int flush)
{
	flush_and_invalidate_caches();
}

static inline struct QH *qh_addr(struct QH *qh)
{
	return (struct QH *)((uint32_t)qh & 0xffffffe0);
}

static void cache_qh(struct QH *qh, int flush)
{
	struct qTD *qtd;
	struct qTD *next;
	static struct qTD *first_qtd;
	/* Walk the QH list and flush/invalidate all entries */
	while(1)
	{
		flush_and_invalidate_caches();
		if ((uint32_t)qh & QH_LINK_TYPE_QH)
			break;
		qh = qh_addr(qh);
		qh = (struct QH *)(swpl(qh->qh_link) + gehci.dma_offset);
	}
	qh = qh_addr(qh);
	/* Save first qTD pointer, needed for invalidating pass on this QH */
	if (flush)
	{
		qtd = (struct qTD *)(swpl(*(uint32_t *)&qh->qh_overlay) & 0xffffffe0);
		if (qtd != NULL)
			qtd = (struct qTD *)(gehci.dma_offset + (uint32_t)qtd);
		first_qtd = qtd;
	}
	else
		qtd = first_qtd;
	/* Walk the qTD list and flush/invalidate all entries */
	while(1)
	{
		if (qtd == NULL)
			break;
		cache_qtd(qtd, flush);
		next = (struct qTD *)((uint32_t)swpl(qtd->qt_next) & 0xffffffe0);
		if (next != NULL)
			next = (struct qTD *)(gehci.dma_offset + (uint32_t)next);
		if (next == qtd)
			break;
		qtd = next;
	}
}

static inline void ehci_flush_dcache(struct QH *qh)
{
	cache_qh(qh, 1);
}

static inline void ehci_invalidate_dcache(struct QH *qh)
{
	cache_qh(qh, 0);
}

static int handshake(uint32_t *ptr, uint32_t mask, uint32_t done, int usec)
{
	uint32_t result;

	do
	{
		result = ehci_readl(ptr);
		if (result == ~(uint32_t)0)
			return -1;
		result &= mask;
		if (result == done)
			return 0;
		wait(1);
		usec--;
	}
	while(usec > 0);
	return -1;
}

static void ehci_free(void *p, size_t sz)
{
}

static int ehci_reset(void)
{
	uint32_t cmd;
	uint32_t tmp;
	uint32_t *reg_ptr;
	int ret = 0;
	if ((gehci.ent->vendor == PCI_VENDOR_ID_NEC)
				&& (gehci.ent->device == PCI_DEVICE_ID_NEC_USB_2))
	{
		debug("ehci_reset set 48MHz clock\r\n");
	 	pci_write_config_longword(gehci.handle, 0xE4, 0x20); // oscillator
	}
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	debug("cmd: 0x%08x\r\n", cmd);
	cmd |= CMD_RESET;
	ehci_writel(&gehci.hcor->or_usbcmd, cmd);
	ret = handshake((uint32_t *)&gehci.hcor->or_usbcmd, CMD_RESET, 0, 250 * 1000);
	if (ret < 0)
	{
		err("EHCI fail to reset");
		goto out;
	}
	if (ehci_is_TDI())
	{
		reg_ptr = (uint32_t *)((u8 *)gehci.hcor + USBMODE);
		tmp = ehci_readl(reg_ptr);
		tmp |= USBMODE_CM_HC;
		tmp |= USBMODE_BE;
		ehci_writel(reg_ptr, tmp);
	}
out:
	return ret;
}

static void *ehci_alloc(size_t sz, size_t align)
{
	static int ntds;
	void *p;
	switch(sz)
	{
		case sizeof(struct QH):
			p = gehci.qh;
			ntds = 0;
			break;
		case sizeof(struct qTD):
			if (ntds == 3)
			{
				debug("out of TDs\r\n");
				return NULL;
			}
			p = gehci.td[ntds];
			ntds++;
			break;
		default:
			debug("unknown allocation size\r\n");
			return NULL;
	}
	memset(p, sz, 0);
	return p;
}

static int ehci_td_buffer(struct qTD *td, void *buf, size_t sz)
{
	uint32_t addr, delta, next;
	int idx;
	addr = (uint32_t)buf;
	idx = 0;
	while(idx < 5)
	{
		td->qt_buffer[idx] = swpl(addr - gehci.dma_offset);
		next = (addr + 4096) & ~4095;
		delta = next - addr;
		if (delta >= sz)
			break;
		sz -= delta;
		addr = next;
		idx++;
	}
	if (idx == 5)
	{
		debug("out of buffer pointers (%u bytes left)\r\n", sz);
		return -1;
	}
	return 0;
}

static int ehci_submit_async(struct usb_device *dev, uint32_t pipe, void *buffer, int length, struct devrequest *req)
{
	struct QH *qh;
	struct qTD *td;
	volatile struct qTD *vtd;
	uint32_t ts;
	uint32_t *tdp;
	uint32_t endpt, token, usbsts;
	uint32_t c, toggle;
	uint32_t cmd;
	int ret = 0;
	debug("dev=%p, pipe=%lx, buffer=%p, length=%d, req=%p\r\n", dev, pipe, buffer, length, req);
	if (req != NULL)
		debug("ehci_submit_async req=%u (%#x), type=%u (%#x), value=%u (%#x), index=%u\r\n",
		 req->request, req->request, req->requesttype, req->requesttype, swpw(req->value), swpw(req->value), swpw(req->index));
	qh = ehci_alloc(sizeof(struct QH), 32);
	if (qh == NULL)
	{
		debug("unable to allocate QH\r\n");
		return -1;
	}
	qh->qh_link = swpl(((uint32_t)gehci.qh_list - gehci.dma_offset) | QH_LINK_TYPE_QH);
	c = (usb_pipespeed(pipe) != USB_SPEED_HIGH && usb_pipeendpoint(pipe) == 0) ? 1 : 0;
	endpt = (8 << 28) | (c << 27) | (usb_maxpacket(dev, pipe) << 16) | (0 << 15) | (1 << 14) | (usb_pipespeed(pipe) << 12) | (usb_pipeendpoint(pipe) << 8) | (0 << 7) | (usb_pipedevice(pipe) << 0);
	qh->qh_endpt1 = swpl(endpt);
	endpt = (1 << 30) | (dev->portnr << 23) | (dev->parent->devnum << 16) | (0 << 8) | (0 << 0);
	qh->qh_endpt2 = swpl(endpt);
	qh->qh_overlay.qt_next = swpl(QT_NEXT_TERMINATE);
	qh->qh_overlay.qt_altnext = swpl(QT_NEXT_TERMINATE);
	td = NULL;
	tdp = &qh->qh_overlay.qt_next;
	toggle = usb_gettoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe));
	if (req != NULL)
	{
		td = ehci_alloc(sizeof(struct qTD), 32);
		if (td == NULL)
		{
			debug("unable to allocate SETUP td\r\n");
			goto fail;
		}
		td->qt_next = swpl(QT_NEXT_TERMINATE);
		td->qt_altnext = swpl(QT_NEXT_TERMINATE);
		token = (0 << 31) | (sizeof(*req) << 16) | (0 << 15) | (0 << 12) | (3 << 10) | (2 << 8) | (0x80 << 0);
		td->qt_token = swpl(token);
		if (ehci_td_buffer(td, req, sizeof(*req)) != 0)
		{
			debug("unable construct SETUP td\r\n");
			ehci_free(td, sizeof(*td));
			goto fail;
		}
		*tdp = swpl((uint32_t)td - gehci.dma_offset);
		tdp = &td->qt_next;
		toggle = 1;
	}
	if (length > 0 || req == NULL)
	{
		td = ehci_alloc(sizeof(struct qTD), 32);
		if (td == NULL)
		{
			debug("unable to allocate DATA td\r\n");
			goto fail;
		}
		td->qt_next = swpl(QT_NEXT_TERMINATE);
		td->qt_altnext = swpl(QT_NEXT_TERMINATE);
		token = (toggle << 31) | (length << 16) | ((req == NULL ? 1 : 0) << 15) | (0 << 12) | (3 << 10) | ((usb_pipein(pipe) ? 1 : 0) << 8) | (0x80 << 0);
		td->qt_token = swpl(token);
		if (ehci_td_buffer(td, buffer, length) != 0)
		{
			debug("unable construct DATA td\r\n");
			ehci_free(td, sizeof(*td));
			goto fail;
		}
		*tdp = swpl((uint32_t)td - gehci.dma_offset);
		tdp = &td->qt_next;
	}
	if (req != NULL)
	{
		td = ehci_alloc(sizeof(struct qTD), 32);
		if (td == NULL)
		{
			debug("unable to allocate ACK td\r\n");
			goto fail;
		}
		td->qt_next = swpl(QT_NEXT_TERMINATE);
		td->qt_altnext = swpl(QT_NEXT_TERMINATE);
		token = (toggle << 31) | (0 << 16) | (1 << 15) | (0 << 12) | (3 << 10) | ((usb_pipein(pipe) ? 0 : 1) << 8) | (0x80 << 0);
		td->qt_token = swpl(token);
		*tdp = swpl((uint32_t)td - gehci.dma_offset);
		tdp = &td->qt_next;
	}
	gehci.qh_list->qh_link = swpl(((uint32_t)qh - gehci.dma_offset) | QH_LINK_TYPE_QH);
	/* Flush dcache */
	ehci_flush_dcache(gehci.qh_list);
	usbsts = ehci_readl(&gehci.hcor->or_usbsts);
	ehci_writel(&gehci.hcor->or_usbsts, (usbsts & 0x3f));
	/* Enable async. schedule. */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	cmd |= CMD_ASE;
	ehci_writel(&gehci.hcor->or_usbcmd, cmd);
	ret = handshake((uint32_t *)&gehci.hcor->or_usbsts, STD_ASS, STD_ASS, 100 * 1000);
	if (ret < 0)
	{
		err("EHCI fail timeout STD_ASS set (usbsts=%#x)", ehci_readl(&gehci.hcor->or_usbsts));
		goto fail;
	}
	/* Wait for TDs to be processed. */
	ts = 0;
	vtd = td;
	do
	{
		/* Invalidate dcache */
		ehci_invalidate_dcache(gehci.qh_list);
		token = swpl(vtd->qt_token);
		if (!(token & 0x80))
			break;
		wait(1 * 1000);
		ts++;
	}
	while(ts < 1000);
	/* Disable async schedule. */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	cmd &= ~CMD_ASE;
	ehci_writel(&gehci.hcor->or_usbcmd, cmd);
	ret = handshake((uint32_t *)&gehci.hcor->or_usbsts, STD_ASS, 0, 100 * 1000);
	if (ret < 0)
	{
		err("EHCI fail timeout STD_ASS reset (usbsts=%#x)", ehci_readl(&gehci.hcor->or_usbsts));
		goto fail;
	}
	gehci.qh_list->qh_link = swpl(((uint32_t)gehci.qh_list - gehci.dma_offset) | QH_LINK_TYPE_QH);
	token = swpl(qh->qh_overlay.qt_token);
	if (!(token & 0x80))
	{
		debug("TOKEN=%#x\r\n", token);
		switch(token & 0xfc)
		{
			case 0:
				toggle = token >> 31;
				usb_settoggle(dev, usb_pipeendpoint(pipe), usb_pipeout(pipe), toggle);
				dev->status = 0;
				break;
			case 0x40:
				dev->status = USB_ST_STALLED;
				break;
			case 0xa0:
			case 0x20:
				dev->status = USB_ST_BUF_ERR;
				break;
			case 0x50:
			case 0x10:
				dev->status = USB_ST_BABBLE_DET;
				break;
			default:
				dev->status = USB_ST_CRC_ERR;
				break;
		}
		dev->act_len = length - ((token >> 16) & 0x7fff);
	}
	else
	{
		dev->act_len = 0;
		debug("dev=%u, usbsts=%#x, p[1]=%#x, p[2]=%#x\r\n",
		 dev->devnum, ehci_readl(&gehci.hcor->or_usbsts), ehci_readl(&gehci.hcor->or_portsc[0]), ehci_readl(&gehci.hcor->or_portsc[1]));
	}
	return (dev->status != USB_ST_NOT_PROC) ? 0 : -1;
fail:
	td = (void *)swpl(qh->qh_overlay.qt_next);
	if (td != (void *)QT_NEXT_TERMINATE)
		td = (struct qTD *)(gehci.dma_offset + (uint32_t)td);
	while(td != (void *)QT_NEXT_TERMINATE)
	{
		qh->qh_overlay.qt_next = td->qt_next;
		ehci_free(td, sizeof(*td));
		td = (void *)swpl(qh->qh_overlay.qt_next);
		if (td != (void *)QT_NEXT_TERMINATE)
			td = (struct qTD *)(gehci.dma_offset + (uint32_t)td);
	}
	ehci_free(qh, sizeof(*qh));
	if (ehci_readl(&gehci.hcor->or_usbsts) & STS_HSE) /* Host System Error */
	{
		unsigned short status = pci_read_config_word(gehci.handle, PCISR);
		err("EHCI Host System Error, controller usb-%s disabled\r\n(SR:0x%04X%s%s%s%s%s%s)", gehci.slot_name, status & 0xFFFF,
		 status & 0x8000 ? ", Parity error" : "", status & 0x4000 ? ", Signaled system error" : "", status & 0x2000 ? ", Received master abort" : "",
		 status & 0x1000 ? ", Received target abort" : "", status & 0x800 ? ", Signaled target abort" : "", status & 0x100 ? ", Data parity error" : "");
	}
	return -1;
}

static inline int min3(int a, int b, int c)
{
	if (b < a)
		a = b;
	if (c < a)
		a = c;
	return a;
}

static int ehci_submit_root(struct usb_device *dev, uint32_t pipe, void *buffer, int length, struct devrequest *req)
{
	uint8_t tmpbuf[4];
	u16 typeReq;
	void *srcptr = NULL;
	int len, srclen;
	uint32_t reg;
	uint32_t *status_reg;
	if (swpw(req->index) > CONFIG_SYS_USB_EHCI_MAX_ROOT_PORTS)
	{
		err("The request port(%d) is not configured", swpw(req->index) - 1);
		return -1;
	}
	status_reg = (uint32_t *)&gehci.hcor->or_portsc[swpw(req->index) - 1];
	srclen = 0;
	debug("ehci_submit_root req=%u (%#x), type=%u (%#x), value=%u, index=%u\r\n",
	 req->request, req->request, req->requesttype, req->requesttype, swpw(req->value), swpw(req->index));
	typeReq = req->request | req->requesttype << 8;
	switch(typeReq)
	{
		case DeviceRequest | USB_REQ_GET_DESCRIPTOR:
			switch(swpw(req->value) >> 8)
			{
				case USB_DT_DEVICE:
					debug("USB_DT_DEVICE request\r\n");
					srcptr = &gehci.descriptor->device;
					srclen = 0x12;
					break;
				case USB_DT_CONFIG:
					debug("USB_DT_CONFIG config\r\n");
					srcptr = &gehci.descriptor->config;
					srclen = 0x19;
					break;
				case USB_DT_STRING:
					debug("USB_DT_STRING config\r\n");
					switch(swpw(req->value) & 0xff)
					{
						case 0:	/* Language */
							srcptr = "\4\3\1\0";
							srclen = 4;
							break;
						case 1:	/* Vendor */
							srcptr = "\2\3";
							srclen = 2;
							break;
						case 2:	/* Product */
							srcptr = "\34\3E\0H\0C\0I\0 \0R\0o\0o\0t\0 \0H\0u\0b\0";
							srclen = 28;
							break;
						default:
							debug("unknown value DT_STRING %x\r\n",
							swpw(req->value));
							goto unknown;
					}
					break;
				default:
					debug("unknown value %x\r\n", swpw(req->value));
					goto unknown;
			}
			break;
		case USB_REQ_GET_DESCRIPTOR | ((USB_DIR_IN | USB_RT_HUB) << 8):
			switch(swpw(req->value) >> 8)
			{
				case USB_DT_HUB:
					debug("USB_DT_HUB config\r\n");
					srcptr = &gehci.descriptor->hub;
					srclen = 0x8;
					break;
				default:
					debug("unknown value %x\r\n", swpw(req->value));
					goto unknown;
			}
			break;
		case USB_REQ_SET_ADDRESS | (USB_RECIP_DEVICE << 8):
			debug("USB_REQ_SET_ADDRESS\r\n");
			rootdev = swpw(req->value);
			break;
		case DeviceOutRequest | USB_REQ_SET_CONFIGURATION:
			debug("USB_REQ_SET_CONFIGURATION\r\n");
			/* Nothing to do */
			break;
		case USB_REQ_GET_STATUS | ((USB_DIR_IN | USB_RT_HUB) << 8):
			tmpbuf[0] = 1;	/* USB_STATUS_SELFPOWERED */
			tmpbuf[1] = 0;
			srcptr = tmpbuf;
			srclen = 2;
			break;
		case USB_REQ_GET_STATUS | ((USB_RT_PORT | USB_DIR_IN) << 8):
			memset(tmpbuf, 0, 4);
			reg = ehci_readl(status_reg);	
			if ((reg & EHCI_PS_PR) && (portreset & (1 << swpw(req->index))))
			{
				int ret;
				/* force reset to complete */
				reg = reg & ~(EHCI_PS_PR | EHCI_PS_CLEAR);
				ehci_writel(status_reg, reg);
				ret = handshake(status_reg, EHCI_PS_PR, 0, 2 * 1000);
				if (!ret)
				{
					tmpbuf[0] |= USB_PORT_STAT_RESET;
          reg = ehci_readl(status_reg);
				}
				else
					err("port(%d) reset error", swpw(req->index) - 1);
			}
			if (reg & EHCI_PS_CS)
				tmpbuf[0] |= USB_PORT_STAT_CONNECTION;
			if (reg & EHCI_PS_PE)
				tmpbuf[0] |= USB_PORT_STAT_ENABLE;
			if (reg & EHCI_PS_SUSP)
				tmpbuf[0] |= USB_PORT_STAT_SUSPEND;
			if (reg & EHCI_PS_OCA)
				tmpbuf[0] |= USB_PORT_STAT_OVERCURRENT;
			if (reg & EHCI_PS_PP)
				tmpbuf[1] |= USB_PORT_STAT_POWER >> 8;
			if (ehci_is_TDI())
			{
				switch((reg >> 26) & 3)
				{
					case 0: break;
					case 1: tmpbuf[1] |= USB_PORT_STAT_LOW_SPEED >> 8; break;
					case 2:
					default: tmpbuf[1] |= USB_PORT_STAT_HIGH_SPEED >> 8; break;
				}
			}
			else
				tmpbuf[1] |= USB_PORT_STAT_HIGH_SPEED >> 8;    	
			if (reg & EHCI_PS_CSC)
				tmpbuf[2] |= USB_PORT_STAT_C_CONNECTION;
			if (reg & EHCI_PS_PEC)
				tmpbuf[2] |= USB_PORT_STAT_C_ENABLE;
			if (reg & EHCI_PS_OCC)
				tmpbuf[2] |= USB_PORT_STAT_C_OVERCURRENT;
			if (portreset & (1 << swpw(req->index)))
				tmpbuf[2] |= USB_PORT_STAT_C_RESET;
			srcptr = tmpbuf;
			srclen = 4;
			break;
		case USB_REQ_SET_FEATURE | ((USB_DIR_OUT | USB_RT_PORT) << 8):
			reg = ehci_readl(status_reg);
			reg &= ~EHCI_PS_CLEAR;
			switch(swpw(req->value))
			{
				case USB_PORT_FEAT_ENABLE:
					reg |= EHCI_PS_PE;
					ehci_writel(status_reg, reg);
					break;
				case USB_PORT_FEAT_POWER:
					if (HCS_PPC(ehci_readl(&gehci.hccr->cr_hcsparams)))
					{
						reg |= EHCI_PS_PP;
						ehci_writel(status_reg, reg);
					}
					break;
				case USB_PORT_FEAT_RESET:
					if ((reg & (EHCI_PS_PE | EHCI_PS_CS)) == EHCI_PS_CS && !ehci_is_TDI() && EHCI_PS_IS_LOWSPEED(reg))
					{
						/* Low speed device, give up ownership. */
						debug("port %d low speed --> companion\r\n", swpw(req->index));
						reg |= EHCI_PS_PO;
						ehci_writel(status_reg, reg);
						companion |= (1 << swpw(req->index));
						break;
					}
					else
					{
						reg |= EHCI_PS_PR;
						reg &= ~EHCI_PS_PE;
						ehci_writel(status_reg, reg);
						/*
						 * caller must wait, then call GetPortStatus
						 * usb 2.0 specification say 50 ms resets on root
						 */
						wait(50 * 1000);
						portreset |= (1 << swpw(req->index));
					}
					break;
				default:
					debug("unknown feature %x\r\n", swpw(req->value));
					goto unknown;
			}
			/* unblock posted writes */
			(void)ehci_readl(&gehci.hcor->or_usbcmd);
			break;
		case USB_REQ_CLEAR_FEATURE | ((USB_DIR_OUT | USB_RT_PORT) << 8):
			reg = ehci_readl(status_reg);
			switch(swpw(req->value))
			{
				case USB_PORT_FEAT_ENABLE:
					reg &= ~EHCI_PS_PE;
					break;
				case USB_PORT_FEAT_C_ENABLE:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_PE;
					break;
				case USB_PORT_FEAT_POWER:
					if (HCS_PPC(ehci_readl(&gehci.hccr->cr_hcsparams)))
						reg = reg & ~(EHCI_PS_CLEAR | EHCI_PS_PP);
				case USB_PORT_FEAT_C_CONNECTION:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_CSC;
					break;
				case USB_PORT_FEAT_OVER_CURRENT:
					reg = (reg & ~EHCI_PS_CLEAR) | EHCI_PS_OCC;
					break;
				case USB_PORT_FEAT_C_RESET:
					portreset &= ~(1 << swpw(req->index));
					break;
				default:
					debug("unknown feature %x\r\n", swpw(req->value));
					goto unknown;
			}
			ehci_writel(status_reg, reg);
			/* unblock posted write */
			(void)ehci_readl(&gehci.hcor->or_usbcmd);
			break;
		default:
			debug("Unknown request\r\n");
			goto unknown;
	}
	wait(1 * 1000);
	len = min3(srclen, swpw(req->length), length);
	if (srcptr != NULL && len > 0)
		memcpy(buffer, srcptr, len);
	else
		debug("Len is 0\r\n");
	dev->act_len = len;
	dev->status = 0;
	return 0;
unknown:
	debug("requesttype=%x, request=%x, value=%x, index=%x, length=%x\r\n",
	 req->requesttype, req->request, swpw(req->value), swpw(req->index), swpw(req->length));
	dev->act_len = 0;
	dev->status = USB_ST_STALLED;
	return -1;
}

/* an interrupt happens */
static int hc_interrupt(struct ehci *ehci)
{
	uint32_t status = ehci_readl(&ehci->hcor->or_usbsts);
	if (status & STS_PCD) /* port change detect */
	{
		uint32_t reg = ehci_readl(&ehci->hccr->cr_hcsparams);
		uint32_t i = HCS_N_PORTS(reg);
		while(i)
		{
			uint32_t pstatus = ehci_readl(&ehci->hcor->or_portsc[i-1]);
			if (pstatus & EHCI_PS_PO)
			{
				i--;
				continue;
			}
			if (companion & (1 << i))
			{
				/* Low speed device, give up ownership. */
				pstatus |= EHCI_PS_PO;
				ehci_writel(&ehci->hcor->or_portsc[i-1], pstatus);
			}
			i--;
		}
	} 
  ehci_writel(&ehci->hcor->or_usbsts, status);
	return(1); /* interrupt was from this card */
}

void ehci_usb_enable_interrupt(int enable)
{
	if (enable);
}

static int handle_usb_interrupt(struct ehci *ehci)
{
	return(hc_interrupt(ehci));
}

static void hc_free_buffers(struct ehci *ehci)
{
	int i;
	if (ehci->descriptor != NULL)
	{
		usb_free(ehci->descriptor);
		ehci->descriptor = NULL;
	}
	for (i = 0; i < 3; i++)
	{
		if (ehci->td_unaligned[i] != NULL)
		{
			usb_free(ehci->td_unaligned[i]);
			ehci->td_unaligned[i] = NULL;
		}
	}
	if (ehci->qh_unaligned != NULL)
	{
		usb_free(ehci->qh_unaligned);
		ehci->qh_unaligned = NULL;
	}
	if (ehci->qh_list_unaligned != NULL)
	{
		usb_free(ehci->qh_list_unaligned);
		ehci->qh_list_unaligned = NULL;
	}
}

int ehci_usb_lowlevel_init(long handle, const struct pci_device_id *ent, void **priv)
{
	int i;
	uint32_t reg;
	uint32_t cmd;
	uint32_t usb_base_addr = 0xFFFFFFFF;
	struct pci_rd *pci_rsc_desc;
	pci_rsc_desc = pci_get_resource(handle); /* USB EHCI */
	if (handle && (ent != NULL))
	{
		memset(&gehci, 0, sizeof(struct ehci));
		gehci.handle = handle;
		gehci.ent = ent;
	}
	else if (!gehci.handle) /* for restart USB cmd */
		return(-1);	
	gehci.qh_list_unaligned = (struct QH *)usb_malloc(sizeof(struct QH) + 32);
	if (gehci.qh_list_unaligned == NULL)
	{
		debug("QHs malloc failed");
		hc_free_buffers(&gehci);
		return(-1);
	}
	gehci.qh_list = (struct QH *)(((uint32_t)gehci.qh_list_unaligned + 31) & ~31);
	memset(gehci.qh_list, 0, sizeof(struct QH));
	gehci.qh_unaligned = (struct QH *)usb_malloc(sizeof(struct QH) + 32);
	if (gehci.qh_unaligned == NULL)
	{
		debug("QHs malloc failed");
		hc_free_buffers(&gehci);
		return(-1);
	}
	gehci.qh = (struct QH *)(((uint32_t)gehci.qh_unaligned + 31) & ~31);
	memset(gehci.qh, 0, sizeof(struct QH));
	for (i = 0; i < 3; i++)
	{
		gehci.td_unaligned[i] = (struct qTD *)usb_malloc(sizeof(struct qTD) + 32);
		if (gehci.td_unaligned[i] == NULL)
		{
			debug("TDs malloc failed");
			hc_free_buffers(&gehci);
			return(-1);
		}
		gehci.td[i] = (struct qTD *)(((uint32_t)gehci.td_unaligned[i] + 31) & ~31);
		memset(gehci.td[i], 0, sizeof(struct qTD));	
	}
	gehci.descriptor = (struct descriptor *)usb_malloc(sizeof(struct descriptor));
	if (gehci.descriptor == NULL)
	{
		debug("decriptor malloc failed");
		hc_free_buffers(&gehci);
		return(-1);
	}
	memcpy(gehci.descriptor, &rom_descriptor, sizeof(struct descriptor));
	if ((long) pci_rsc_desc >= 0)
	{
		unsigned short flags;
		do
		{
			debug("PCI USB descriptors (at %p): flags 0x%04x start 0x%08lx \r\n offset 0x%08lx dmaoffset 0x%08lx length 0x%08lx\r\n", pci_rsc_desc,
			 pci_rsc_desc->flags, pci_rsc_desc->start, pci_rsc_desc->offset, pci_rsc_desc->dmaoffset, pci_rsc_desc->length);
			if (!(pci_rsc_desc->flags & FLG_IO))
			{
				if (usb_base_addr == 0xFFFFFFFF)
				{
					usb_base_addr = pci_rsc_desc->start;
					gehci.hccr = (struct ehci_hccr *)(pci_rsc_desc->offset + pci_rsc_desc->start);
					gehci.dma_offset = pci_rsc_desc->dmaoffset;
					if ((pci_rsc_desc->flags & FLG_ENDMASK) == ORD_MOTOROLA)
						gehci.big_endian = 0; /* host bridge make swapping intel -> motorola */
					else
						gehci.big_endian = 1; /* driver must swapping intel -> motorola */
				}
			}
			flags = pci_rsc_desc->flags;
			pci_rsc_desc = (struct pci_rd *)((uint32_t)pci_rsc_desc->next + (uint32_t)pci_rsc_desc);
		}
		while(!(flags & FLG_LAST));
	}
	else
	{
		hc_free_buffers(&gehci);
		return(-1); /* get_resource error */
	}
	if (usb_base_addr == 0xFFFFFFFF)
	{
		hc_free_buffers(&gehci);
		return(-1);
	}
	if (handle && (ent != NULL))
	{
		switch(ent->vendor)
		{
			case PCI_VENDOR_ID_NEC: gehci.slot_name = "uPD720101"; break;
			case PCI_VENDOR_ID_PHILIPS: gehci.slot_name = "isp1561"; break;
			default: gehci.slot_name = "generic"; break;
		}
	}
	gehci.hcor = (struct ehci_hcor *)((uint32_t)gehci.hccr + HC_LENGTH(ehci_readl(&gehci.hccr->cr_capbase)));
	xprintf("EHCI usb-%s, regs address 0x%08X, PCI handle 0x%X\r\n", gehci.slot_name, gehci.hccr, handle);

	/* EHCI spec section 4.1 */
	if (ehci_reset() != 0)
	{
		hc_free_buffers(&gehci);
		return(-1);
	}
	/* Set head of reclaim list */
	gehci.qh_list->qh_link = swpl(((uint32_t)gehci.qh_list - gehci.dma_offset) | QH_LINK_TYPE_QH);
	gehci.qh_list->qh_endpt1 = swpl((1 << 15) | (USB_SPEED_HIGH << 12));
	gehci.qh_list->qh_curtd = swpl(QT_NEXT_TERMINATE);
	gehci.qh_list->qh_overlay.qt_next = swpl(QT_NEXT_TERMINATE);
	gehci.qh_list->qh_overlay.qt_altnext = swpl(QT_NEXT_TERMINATE);
	gehci.qh_list->qh_overlay.qt_token = swpl(0x40);
	/* Set async. queue head pointer. */
	ehci_writel(&gehci.hcor->or_asynclistaddr, (uint32_t)gehci.qh_list - gehci.dma_offset);
	reg = ehci_readl(&gehci.hccr->cr_hcsparams);
	gehci.descriptor->hub.bNbrPorts = HCS_N_PORTS(reg);
	info("Register %x NbrPorts %d", reg, gehci.descriptor->hub.bNbrPorts);
	/* Port Indicators */
	if (HCS_INDICATOR(reg))
		gehci.descriptor->hub.wHubCharacteristics |= 0x80;
	/* Port Power Control */
	if (HCS_PPC(reg))
		gehci.descriptor->hub.wHubCharacteristics |= 0x01;
	/* Start the host controller. */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	/*
	 * Philips, Intel, and maybe others need CMD_RUN before the
	 * root hub will detect new devices (why?); NEC doesn't
	 */
	cmd &= ~(CMD_LRESET|CMD_IAAD|CMD_PSE|CMD_ASE|CMD_RESET);
	cmd |= CMD_RUN;
	ehci_writel(&gehci.hcor->or_usbcmd, cmd);
	/* take control over the ports */
	ehci_writel(&gehci.hcor->or_configflag, FLAG_CF);
	/* unblock posted write */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	wait(5 * 1000);
	reg = HC_VERSION(ehci_readl(&gehci.hccr->cr_capbase));
	info("USB EHCI %x.%02x", reg >> 8, reg & 0xff);
  /* turn on interrupts */
	pci_hook_interrupt(handle, handle_usb_interrupt, &gehci);
	ehci_writel(&gehci.hcor->or_usbintr, INTR_PCDE);
	rootdev = 0;
	if (priv != NULL)
		*priv = (void *)&gehci;
	ehci_inited = 1;
	return(0);
}

int ehci_usb_lowlevel_stop(void *priv)
{
	uint32_t cmd;
	if (priv);
	if (!ehci_inited)
		return(0);
  /* turn off interrupts */
	ehci_writel(&gehci.hcor->or_usbintr, 0);
	pci_unhook_interrupt(gehci.handle);
	/* stop the controller */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);
	cmd &= ~CMD_RUN;
	ehci_writel(&gehci.hcor->or_usbcmd, cmd);
	/* turn off all ports => todo */
	/* use the companions */
	ehci_writel(&gehci.hcor->or_configflag, 0);
	/* unblock posted write */
	cmd = ehci_readl(&gehci.hcor->or_usbcmd);		
	ehci_reset();
	hc_free_buffers(&gehci);
	ehci_inited = 0;
	return(0);
}

int ehci_submit_bulk_msg(struct usb_device *dev, uint32_t pipe, void *buffer, int length)
{
	if (usb_pipetype(pipe) != PIPE_BULK)
	{
		debug("non-bulk pipe (type=%lu)", usb_pipetype(pipe));
		return -1;
	}
	return ehci_submit_async(dev, pipe, buffer, length, NULL);
}

int ehci_submit_control_msg(struct usb_device *dev, uint32_t pipe, void *buffer, int length, struct devrequest *setup)
{
	if (usb_pipetype(pipe) != PIPE_CONTROL)
	{
		debug("non-control pipe (type=%lu)", usb_pipetype(pipe));
		return -1;
	}
	if (usb_pipedevice(pipe) == rootdev)
	{
		if (rootdev == 0)
			dev->speed = USB_SPEED_HIGH;
		return ehci_submit_root(dev, pipe, buffer, length, setup);
	}
	return ehci_submit_async(dev, pipe, buffer, length, setup);
}

int ehci_submit_int_msg(struct usb_device *dev, uint32_t pipe, void *buffer, int length, int interval)
{
	debug("submit_int_msg dev=%p, pipe=%lu, buffer=%p, length=%d, interval=%d", dev, pipe, buffer, length, interval);
	return -1;
}

