/**
 * Breadboard Calculator Program
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#define CTL_OFFSET 0x0
#define DATA_OFFSET 0x4

FILE *adc_file;
//FILE *pwm_file;
//FILE *kb_file;

FILE *lcd_file;
FILE *lcd_msg_file;



/**
 * ctlc_handler() - 
 */
void ctlc_handler(int sig)
{
	signal(sig, SIG_IGN);
	printf("\n\n\n");
	
	fclose(adc_file);
	//fclose(pwm_file);
	//fclose(kb_file);
	
	fclose(lcd_file);
	fclose(lcd_msg_file);
	
	exit(0);
}



/**
 * main() - 
 * @argc: 
 * @argv: 
 * 
 * 
 */
int main (int argc, char **argv)
{
	adc_file = fopen("/dev/adc", "rb+");
	//pwm_file = fopen("/dev/pwm", "rb+");
	//keyboard_file = fopen("/dev/keyboard", "rb+");
	lcd_file = fopen("/dev/lcd", "rb+");
	
	uint32_t lcd_ctl;
	uint32_t lcd_data;
	
	// Open lcd device file
	lcd_file = fopen("/dev/lcd", "rb+");
	if (lcd_file == NULL)
	{
		printf("Failed to open /dev/lcd.\n");
		return 1;
	}
	
	// Initialize LCD
	if (argc > 1)
	{
		lcd_msg_file = fopen(argv[1], "r");
	}
	else
	{
		lcd_msg_file = fopen("/home/soc/bb-calc/lcd/init", "r");
	}

	if (lcd_msg_file == NULL)
	{
		printf("Failed to open message file.\n");
		return 1;
	}
	
	int line_count = 0;
	uint32_t val;
	while(fscanf(lcd_msg_file, "%X", &val) != EOF)
	{
		lcd_data = val;
		fseek(lcd_file, DATA_OFFSET, SEEK_SET);
		fwrite(&lcd_data, 4, 1, lcd_file);
		fflush(lcd_file);
		usleep(1000);
		
		if (argc > 1)
		{
			lcd_ctl = 0x00000005; // LCD char
		}
		else
		{
			lcd_ctl = 0x00000001; // LCD instruction
		}
		fseek(lcd_file, CTL_OFFSET, SEEK_SET);
		fwrite(&lcd_ctl, 4, 1, lcd_file);
		fflush(lcd_file);
		usleep(1000);
		
		lcd_ctl = 0x00000000;
		fseek(lcd_file, CTL_OFFSET, SEEK_SET);
		fwrite(&lcd_ctl, 4, 1, lcd_file);
		fflush(lcd_file);
		usleep(1000);
	}
		
	return 0;
}
