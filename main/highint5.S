#include <xtensa/coreasm.h>
#include <xtensa/corebits.h>
#include <xtensa/config/system.h>
#include "freertos/xtensa_context.h"
#include "esp_private/panic_reason.h"
#include "sdkconfig.h"
#include "soc/soc.h"
#include "soc/gpio_reg.h"
#include "soc/dport_reg.h"
#include "soc/timer_group_reg.h"


// 12 bytes 4 bytes per reg, 3 regs saveable
#define L5_INTR_STACK_SIZE  12
#define LX_INTR_A15_OFFSET 0
#define LX_INTR_A14_OFFSET 4
#define LX_INTR_A13_OFFSET 8
#define UART0_DATA_REG                      (0x3FF40078)

    .data
_l5_intr_stack:
    .space      L5_INTR_STACK_SIZE

    .section .iram1,"ax"
    .global     xt_highint5
    .type       xt_highint5,@function
    .align      4
xt_highint5:

	/* store reg values */
	movi    a0, _l5_intr_stack // assuming a0 saved restored by EXCSAVE_5 at the end of this
    s32i    a15, a0, LX_INTR_A15_OFFSET
    s32i    a14, a0, LX_INTR_A14_OFFSET
    s32i    a13, a0, LX_INTR_A13_OFFSET

 	rsr		a15, INTERRUPT
    movi    a14, gpio_vector_interrupt
    s32i	a15, a14, 0
    memw

    rsr		a15, INTENABLE
    movi    a14, gpio_vector_intenable
    s32i	a15, a14, 0
    memw

    movi	a15, DPORT_APP_GPIO_INTERRUPT_MAP_REG
    l32i	a13, a15, 0
    memw

    movi    a14, app_gpio_int_map
    s32i	a13, a14, 0
    memw

    movi	a15, GPIO_STATUS_REG
    l32i	a13, a15, 0 // will hold PIN 18 or 19, which should clear the ISR.
    memw

    movi    a14, gpio_status
    s32i	a13, a14, 0
    memw

    /* Clear interupt on GPIO18 and GPIO19 */
    movi    a14, GPIO_STATUS_W1TC_REG
    // movi    a15, (1 << 18) | (1 << 19)
    s32i    a13, a14, 0
    memw

    //movi    a14, isr_runs_total
    //l32i    a15, a14, 0
    //addi    a15, a15, 1
    //s32i    a15, a14, 0
   	//memw

   	// restore regs
   	l32i    a15, a0, LX_INTR_A15_OFFSET
    l32i    a14, a0, LX_INTR_A14_OFFSET
    l32i    a13, a0, LX_INTR_A13_OFFSET

    rsr     a0, EXCSAVE_5 // restore a0
    rfi     5

/* The linker has no reason to link in this file; all symbols it exports are already defined
   (weakly!) in the default int handler. Define a symbol here so we can use it to have the
   linker inspect this anyway. */

    .global ld_include_xt_highint5
ld_include_xt_highint5:
