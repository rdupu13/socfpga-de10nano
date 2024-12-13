ifneq ($(KERNELRELEASE),)
# kbuild part of makefile
obj-m := pwm_driver.o

else
# normal makefile

# Path to kernel directory
KDIR ?= /home/rdupu/documents/git-repos/linux-socfpga

default:
	$(MAKE) -C $(KDIR) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- M=$(PWD)

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

endif
