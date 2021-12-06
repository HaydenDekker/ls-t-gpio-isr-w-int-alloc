# ESP32 HLI Issue

## Expected output by applying 3.3v (High) to Pin 18 and then to Pin 19.

VECTOR INTERRUPT VAL 2147581952.
VECTOR INTENABLE value 2466250820.
GPIO_STATUS_REG. 262144.
DPORT_APP_GPIO_INTERRUPT_MAP_REG. 31.
ISR runs total 679.

VECTOR INTERRUPT VAL 2147581952.
VECTOR INTENABLE value 2466250820.
GPIO_STATUS_REG. 524288.
DPORT_APP_GPIO_INTERRUPT_MAP_REG. 31.
ISR runs total 694.


## Then removing a section of highint5.S

movi    a14, isr_runs_total
    l32i    a15, a14, 0
    addi    a15, a15, 1
    s32i    a15, a14, 0
   	memw

Once the above is removed the program breaks. 
The HLI ISR does not set the variables to the expected memory state.

Any ideas??

