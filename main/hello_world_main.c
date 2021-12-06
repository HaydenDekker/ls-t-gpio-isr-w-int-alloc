#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_intr_alloc.h"
#include "driver/gpio.h"
#include "freertos/queue.h"
#include "driver/timer.h"

/* See "interrupt cpu using table" in esp-idf/components/soc/esp32/include/soc/soc.h */
/* We could use 26 or 31 for an level 5 interrupt */
#define INTR_NUM 31
#define CPU_CORE 1
#define GPIO_NUM 18
#define GPIO_NUM_2 19

volatile uint32_t gpio_status = 0;
volatile uint32_t app_gpio_int_map = 0;
volatile uint32_t gpio_vector_interrupt = 0;
volatile uint32_t gpio_vector_intenable = 0;
volatile uint32_t isr_runs_total = 0;

static void cpu1_task(void *arg) {

    gpio_config_t io_conf = {
        .intr_type = GPIO_PIN_INTR_NEGEDGE,
        .pin_bit_mask = (1ULL << GPIO_NUM) | (1ULL << GPIO_NUM_2),
        .mode = GPIO_MODE_INPUT,
        .pull_down_en = GPIO_PULLDOWN_ENABLE,
        .pull_up_en = GPIO_PULLUP_DISABLE
    };

    printf("gpio bitmask set as %llu \n", io_conf.pin_bit_mask);

    gpio_config(&io_conf);
    gpio_intr_enable(GPIO_NUM);
    gpio_intr_enable(GPIO_NUM_2);
    printf("pin 18 intEn value = %i", GPIO.pin[18].int_ena);

#if 1
    ESP_INTR_DISABLE(INTR_NUM);
    intr_matrix_set(CPU_CORE, ETS_GPIO_INTR_SOURCE, INTR_NUM);
    ESP_INTR_ENABLE(INTR_NUM);
#else
    /* Should be the proper way, but doesn't work  */
    esp_intr_alloc(ETS_GPIO_INTR_SOURCE, ESP_INTR_FLAG_LEVEL5 | ESP_INTR_FLAG_IRAM, NULL, NULL, NULL);
#endif



    while (1) {

    	vTaskDelay(300);
    	printf("VECTOR INTERRUPT VAL %u.\n", gpio_vector_interrupt);
    	printf("VECTOR INTENABLE value %u.\n", gpio_vector_intenable);
    	printf("GPIO_STATUS_REG. %u.\n", gpio_status);
        printf("DPORT_APP_GPIO_INTERRUPT_MAP_REG. %u.\n", app_gpio_int_map);
        printf("ISR runs total %u. \n", isr_runs_total);
        printf("\n");

    }
}

void app_main()
{

    xTaskCreatePinnedToCore(cpu1_task, "cpu1_task", 2048, NULL, 10, NULL, 1);

}

