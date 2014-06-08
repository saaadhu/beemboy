#ifndef FREERTOS_CONFIG_H
#define FREERTOS_CONFIG_H

#include <stdint.h>

#define configUSE_PREEMPTION      1
#define configUSE_IDLE_HOOK       0
#define configUSE_TICK_HOOK       0

#define configCPU_CLOCK_HZ        ( FOSC0 ) /* Hz clk gen */
#define configPBA_CLOCK_HZ        ( FOSC0 )

#define configTICK_RATE_HZ        ( ( portTickType ) 1000 )
#define configMAX_PRIORITIES      ( ( unsigned portBASE_TYPE ) 8 )
#define configMINIMAL_STACK_SIZE  ( ( unsigned portSHORT ) 256 )
#define configTOTAL_HEAP_SIZE     ( ( size_t ) ( 1024*25 ) )
#define configMAX_TASK_NAME_LEN   ( 16 )
#define configUSE_TRACE_FACILITY  0
#define configUSE_16_BIT_TICKS    0
#define configIDLE_SHOULD_YIELD   1

/* Co-routine definitions. */
#define configUSE_CO_ROUTINES     0
#define configMAX_CO_ROUTINE_PRIORITIES ( 1 )

/* Set the following definitions to 1 to include the API function, or zero
to exclude the API function. */

#define INCLUDE_vTaskPrioritySet            1
#define INCLUDE_uxTaskPriorityGet           1
#define INCLUDE_vTaskDelete                 1
#define INCLUDE_vTaskCleanUpResources       0
#define INCLUDE_vTaskSuspend                1
#define INCLUDE_vTaskDelayUntil             1
#define INCLUDE_vTaskDelay                  1
#define INCLUDE_xTaskGetCurrentTaskHandle   0
#define INCLUDE_xTaskGetSchedulerState      1

/* configTICK_USE_TC is a boolean indicating whether to use a Timer Counter or
   the CPU Cycle Counter for the tick generation.
   Both methods will generate an accurate tick.
   0: Use of the CPU Cycle Counter.
   1: Use of the Timer Counter (configTICK_TC_CHANNEL is the TC channel). */
#define configTICK_USE_TC             0
#define configTICK_TC_CHANNEL         2

/* configHEAP_INIT is a boolean indicating whether to initialize the heap with
   0xA5 in order to be able to determine the maximal heap consumption. */
#define configHEAP_INIT               0

#  define barrier()        asm volatile("" ::: "memory")

#  define cpu_irq_enable()                             \
	do {                                           \
		barrier();                             \
		__builtin_csrf(AVR32_SR_GM_OFFSET);    \
	} while (0)

#  define cpu_irq_disable()                            \
	do {                                           \
		__builtin_ssrf(AVR32_SR_GM_OFFSET);    \
		barrier();                             \
	} while (0)

#define Disable_global_interrupt  cpu_irq_disable
#define Enable_global_interrupt  cpu_irq_enable

#define sysreg_write(reg, val)         __builtin_mtsr(reg, val)
#define Get_system_register(reg)         sysreg_read(reg)
#define Set_system_register(reg, val)    sysreg_write(reg, val)
#define sysreg_read(reg)               __builtin_mfsr(reg)
#define Enable_global_exception()           ({__asm__ __volatile__ ("csrf\t%0" :  : "i" (AVR32_SR_EM_OFFSET));})
typedef void (*__int_handler)(void);

#define FOSC0           12000000                              //!< Osc0 frequency: Hz.


#define false     0
#define true      1
#define PASS      0
#define FAIL      1
#define LOW       0
#define HIGH      1

#define clz(u)              __builtin_clz(u)
#define Max(a, b)           (((a) > (b)) ?  (a) : (b))
#endif /* FREERTOS_CONFIG_H */
