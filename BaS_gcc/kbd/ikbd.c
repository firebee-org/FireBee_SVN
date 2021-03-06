/*

  https://www.kernel.org/doc/Documentation/input/atarikbd.txt

  ikbd ToDo:

  Feature                      Example using/needing it    impl. tested
  ---------------------------------------------------------------------
  mouse y at bottom            Bolo                         X     X
  mouse button key events      Goldrunner/A_008             X     X
  joystick interrogation mode  Xevious/A_004                X     X
  Absolute mouse mode          Backlash/A_008, A-Ball/A50
  disable mouse                ?                            X
  disable joystick             ?                            X
  Joysticks also generate      Goldrunner                   X     X
  mouse button events!
  Pause (cmd 0x13)             Wings of Death/A_427

 */

#include <bas_types.h>
#include "bas_printf.h"
#include "bas_string.h"

#include "user_io.h"
//#include "hardware.h"
#include "ikbd.h"

#include "debug.h"

// atari ikbd stuff
#define IKBD_STATE_JOYSTICK_EVENT_REPORTING  0x01
#define IKBD_STATE_MOUSE_Y_BOTTOM            0x02
#define IKBD_STATE_MOUSE_BUTTON_AS_KEY       0x04   // mouse buttons act like keys
#define IKBD_STATE_MOUSE_DISABLED            0x08
#define IKBD_STATE_MOUSE_ABSOLUTE            0x10

#define IKBD_DEFAULT IKBD_STATE_JOYSTICK_EVENT_REPORTING

#define QUEUE_LEN 16        // power of 2!
static unsigned char tx_queue[QUEUE_LEN];
static unsigned char wptr = 0, rptr = 0;

// structure to keep track of ikbd state
static struct
{
    unsigned char cmd;
    unsigned char state;
    unsigned char expect;

    // joystick state
    unsigned char joystick[2];

    // mouse state
    unsigned short mouse_pos_x, mouse_pos_y;
    unsigned char mouse_buttons;
} ikbd;

// #define IKBD_DEBUG

void ikbd_init()
{
    // reset ikbd state
    memset(&ikbd, 0, sizeof(ikbd));
    ikbd.state = IKBD_DEFAULT;
}

static void enqueue(unsigned char b)
{
    if (((wptr + 1)&(QUEUE_LEN-1)) == rptr)
    {
        xprintf("IKBD: !!!!!!! tx queue overflow !!!!!!!!!\n");
        return;
    }

    tx_queue[wptr] = b;
    wptr = (wptr + 1) & (QUEUE_LEN - 1);
}

// convert internal joystick format into atari ikbd format
static unsigned char joystick_map2ikbd(unsigned in)
{
    unsigned char out = 0;

    if (in & JOY_UP)    out |= 0x01;
    if (in & JOY_DOWN)  out |= 0x02;
    if (in & JOY_LEFT)  out |= 0x04;
    if (in & JOY_RIGHT) out |= 0x08;
    if (in & JOY_BTN1)  out |= 0x80;

    return out;
}

// process inout from atari core into ikbd
void ikbd_handle_input(unsigned char cmd)
{
    // expecting a second byte for command
    if (ikbd.expect)
    {
        ikbd.expect--;

        // last byte of command received
        if (!ikbd.expect)
        {
            switch(ikbd.cmd)
            {
                case 0x07: // set mouse button action
                    xprintf("IKBD: mouse button action = %x\n", cmd);

                    // bit 2: Mouse buttons act like keys (LEFT=0x74 & RIGHT=0x75)
                    if(cmd & 0x04) ikbd.state |=  IKBD_STATE_MOUSE_BUTTON_AS_KEY;
                    else           ikbd.state &= ~IKBD_STATE_MOUSE_BUTTON_AS_KEY;

                    break;

                case 0x80: // ibkd reset
                    // reply "everything is ok"
                    enqueue(0xf0);
                    break;

                default:
                    break;
            }
        }

        return;
    }

    ikbd.cmd = cmd;

    switch(cmd)
    {
        case 0x07:
            xprintf("IKBD: Set mouse button action");
            ikbd.expect = 1;
            break;

        case 0x08:
            xprintf("IKBD: Set relative mouse positioning");
            ikbd.state &= ~IKBD_STATE_MOUSE_DISABLED;
            ikbd.state &= ~IKBD_STATE_MOUSE_ABSOLUTE;
            break;

        case 0x09:
            xprintf("IKBD: Set absolute mouse positioning");
            ikbd.state &= ~IKBD_STATE_MOUSE_DISABLED;
            ikbd.state |=  IKBD_STATE_MOUSE_ABSOLUTE;
            ikbd.expect = 4;
            break;

        case 0x0b:
            xprintf("IKBD: Set Mouse threshold");
            ikbd.expect = 2;
            break;

        case 0x0f:
            xprintf("IKBD: Set Y at bottom");
            ikbd.state |= IKBD_STATE_MOUSE_Y_BOTTOM;
            break;

        case 0x10:
            xprintf("IKBD: Set Y at top");
            ikbd.state &= ~IKBD_STATE_MOUSE_Y_BOTTOM;
            break;

        case 0x12:
            xprintf("IKBD: Disable mouse");
            ikbd.state |= IKBD_STATE_MOUSE_DISABLED;
            break;

        case 0x14:
            xprintf("IKBD: Set Joystick event reporting");
            ikbd.state |= IKBD_STATE_JOYSTICK_EVENT_REPORTING;
            break;

        case 0x15:
            xprintf("IKBD: Set Joystick interrogation mode");
            ikbd.state &= ~IKBD_STATE_JOYSTICK_EVENT_REPORTING;
            break;

        case 0x16: // interrogate joystick
            // send reply
            enqueue(0xfd);
            enqueue(joystick_map2ikbd(ikbd.joystick[0]));
            enqueue(joystick_map2ikbd(ikbd.joystick[1]));
            break;

        case 0x1a:
            xprintf("IKBD: Disable joysticks");
            ikbd.state &= ~IKBD_STATE_JOYSTICK_EVENT_REPORTING;
            break;

        case 0x1c:
            xprintf("IKBD: Interrogate time of day");

            enqueue(0xfc);
            enqueue(0x13);  // year bcd
            enqueue(0x03);  // month bcd
            enqueue(0x07);  // day bcd
            enqueue(0x20);  // hour bcd
            enqueue(0x58);  // minute bcd
            enqueue(0x00);  // second bcd
            break;


        case 0x80:
            xprintf("IKBD: Reset");
            ikbd.expect = 1;
            ikbd.state = IKBD_DEFAULT;
            break;

        default:
            xprintf("IKBD: unknown command: %x\n", cmd);
            break;
    }
}

/*
 * FIXME: temporarily provide function prototypes for unimplemented functions here to make compiler happy
 */

extern int GetTimer(int);
extern int CheckTimer(int);
extern void EnableIO(void);
extern void DisableIO(void);
extern int SPI(int);

void ikbd_poll(void)
{
    static int mtimer = 0;
    if (CheckTimer(mtimer))
    {
        mtimer = GetTimer(10);

        // check for incoming ikbd data
        EnableIO();
        SPI(UIO_IKBD_IN);

        while(SPI(0))
            ikbd_handle_input(SPI(0));

        DisableIO();
    }

    // send data from queue if present
    if(rptr == wptr) return;

    // transmit data from queue
    EnableIO();
    SPI(UIO_IKBD_OUT);
    SPI(tx_queue[rptr]);
    DisableIO();

    rptr = (rptr + 1) & (QUEUE_LEN - 1);
}

void ikbd_joystick(unsigned char joystick, unsigned char map)
{
    // todo: suppress events for joystick 0 as long as mouse
    // is enabled?

    if (ikbd.state & IKBD_STATE_JOYSTICK_EVENT_REPORTING)
    {
#ifdef IKBD_DEBUG
        xprintf("IKBD: joy %d %x\n", joystick, map);
#endif

        // only report joystick data for joystick 0 if the mouse is disabled
        if ((ikbd.state & IKBD_STATE_MOUSE_DISABLED) || (joystick == 1))
        {
            enqueue(0xfe + joystick);
            enqueue(joystick_map2ikbd(map));
        }

        if (!(ikbd.state & IKBD_STATE_MOUSE_DISABLED))
        {
            // the fire button also generates a mouse event if
            // mouse reporting is enabled
            if ((map & JOY_BTN1) != (ikbd.joystick[joystick] & JOY_BTN1))
            {
                // generate mouse event (ikbd_joystick_buttons is evaluated inside
                // user_io_mouse)
                ikbd.joystick[joystick] = map;
                ikbd_mouse(0, 0, 0);
            }
        }
    }
#ifdef IKBD_DEBUG
    else
        xprintf("IKBD: no monitor, drop joy %d %x\n", joystick, map);
#endif

    // save state of joystick for interrogation mode
    ikbd.joystick[joystick] = map;
}

void ikbd_keyboard(unsigned char code)
{
#ifdef IKBD_DEBUG
    xprintf("IKBD: send keycode %x%s\n", code&0x7f, (code&0x80)?" BREAK":"");
#endif
    enqueue(code);
}

void ikbd_mouse(uint8_t b, int8_t x, int8_t y)
{
    if (ikbd.state & IKBD_STATE_MOUSE_DISABLED)
        return;

    // joystick and mouse buttons are wired together in
    // atari st
    b |= (ikbd.joystick[0] & JOY_BTN1)?1:0;
    b |= (ikbd.joystick[1] & JOY_BTN1)?2:0;

    static unsigned char b_old = 0;
    // monitor state of two mouse buttons
    if (b != b_old)
    {
        // check if mouse buttons are supposed to be treated like keys
        if (ikbd.state & IKBD_STATE_MOUSE_BUTTON_AS_KEY)
        {
            // Mouse buttons act like keys (LEFT=0x74 & RIGHT=0x75)

            // handle left mouse button
            if((b ^ b_old) & 1) ikbd_keyboard(0x74 | ((b&1)?0x00:0x80));
            // handle right mouse button
            if((b ^ b_old) & 2) ikbd_keyboard(0x75 | ((b&2)?0x00:0x80));
        }
        b_old = b;
    }

#if 0
    if(ikbd.state & IKBD_STATE_MOUSE_BUTTON_AS_KEY)
    {
        b = 0;
        // if mouse position is 0/0 quit here
        if(!x && !y) return;
    }
#endif

    if (ikbd.state & IKBD_STATE_MOUSE_ABSOLUTE)
    {
    }
    else
    {
        // atari has mouse button bits swapped
        enqueue(0xf8|((b&1)?2:0)|((b&2)?1:0));
        enqueue(x);
        enqueue((ikbd.state & IKBD_STATE_MOUSE_Y_BOTTOM)?-y:y);
    }
}

