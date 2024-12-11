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



FILE *adc_file;
#define CH0_OFFSET 0x0

FILE *pwm_file;
#define RED_OFFSET 0x0
#define GREEN_OFFSET 0x4
#define BLUE_OFFSET 0x8
#define PERIOD_OFFSET 0xC

//FILE *kb_file;
//#define BUFFER_OFFSET 0x0

FILE *lcd_file;
#define CTL_OFFSET 0x0
#define DATA_OFFSET 0x4
FILE *lcd_msg_file;



/**
 * ctlc_handler() - 
 */
void ctlc_handler(int sig)
{
	signal(sig, SIG_IGN);
	printf("\n\n\n");
	
	fclose(adc_file);
	fclose(pwm_file);
	//fclose(kb_file);
	
	fclose(lcd_file);
	fclose(lcd_msg_file);
	
	exit(0);
}



/**
 * cos() - 
 */
float cos(float angle)
{
	float ret;
	float angle2;
	float angle4;
	float angle6;
	float angle8;
	
	if (angle < -3.14159 || angle > 3.14159)
	{
		angle2 = (angle * angle) - (12.56637 * angle) + 39.47842; // f(-x + 2*pi)
	}
	else
	{	
		angle2 = angle * angle;
	}
	
	angle4 = angle2 * angle2;
	angle6 = angle4 * angle2;
	angle8 = angle6 * angle2;
	ret = 1 - (angle2 / 2) + (angle4 / 24) - (angle6 / 720) + (angle8 / 40320);
	
	return ret;
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
	// Open ADC device file
	adc_file = fopen("/dev/adc", "rb+");
	if (adc_file == NULL)
	{
		printf("Failed to open /dev/adc.\n");
		return 1;
	}
	uint32_t adc_val;
	
	// Open PWM RGB LED device file
	pwm_file = fopen("/dev/pwm", "rb+");
	if (pwm_file == NULL)
	{
		printf("Failed to open /dev/pwm.\n");
		return 1;
	}
	unsigned int pwm_red;
	unsigned int pwm_green;
	unsigned int pwm_blue;
	unsigned int pwm_period;
	
	// Open keyboard device file
	// keyboard_file = fopen("/dev/keyboard", "rb+");
	
	// Open lcd device file
	lcd_file = fopen("/dev/lcd", "rb+");
	if (lcd_file == NULL)
	{
		printf("Failed to open /dev/lcd.\n");
		return 1;
	}	
	uint32_t lcd_ctl;
	uint32_t lcd_data;
	
	// If an argument was given, open that message file, otherwise simply open init file
	if (argc > 1)
	{
		lcd_msg_file = fopen(argv[1], "r");
	}
	else
	{
		lcd_msg_file = fopen("/home/soc/bb-calc/lcd/init", "r");
	}

	// If message file doesn't exist
	if (lcd_msg_file == NULL)
	{
		printf("Failed to open message file.\n");
		return 1;
	}
	
	// Read from file and write directly to LCD device file
	int line_count = 0;
	uint32_t val;
	while(fscanf(lcd_msg_file, "%X", &val) != EOF)
	{
		lcd_data = val;
		fseek(lcd_file, DATA_OFFSET, SEEK_SET);
		fwrite(&lcd_data, 4, 1, lcd_file);
		fflush(lcd_file);
		usleep(1000);
		
		// If no file was given, assume a control file is being read from
		// If a file was given, assume it's only characters
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
	
	int print_count = 0;
	while (true)
	{
		fseek(adc_file, CH0_OFFSET, SEEK_SET);
		fread(&adc_val, 4, 1, adc_file);
		fflush(adc_file);
		
		pwm_red   = (unsigned int) (1024 * (1 + cos(0.0015332 * adc_val)));
		pwm_green = (unsigned int) (1024 * (1 + cos(0.0015332 * (adc_val - 1365))));
		pwm_blue  = (unsigned int) (1024 * (1 + cos(0.0015332 * (adc_val - 2731))));
		
		fseek(pwm_file, RED_OFFSET, SEEK_SET);
		fwrite(&pwm_red, 4, 1, pwm_file);
		fflush(pwm_file);
		
		fseek(pwm_file, GREEN_OFFSET, SEEK_SET);
		fwrite(&pwm_green, 4, 1, pwm_file);
		fflush(pwm_file);
	
		fseek(pwm_file, BLUE_OFFSET, SEEK_SET);
		fwrite(&pwm_blue, 4, 1, pwm_file);
		fflush(pwm_file);
		
		usleep(1000);
		
		if (print_count == 1000)
		{
			printf("%u\n", adc_val);
			print_count = 0;
		}
		print_count++;
	}
	
	return 0;
}
