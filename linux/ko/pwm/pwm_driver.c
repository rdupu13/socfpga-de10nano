/**
 * PWM RGB LED Platform Device Driver
 * 
 * Ryan Dupuis
 */

#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/types.h>
#include <linux/fs.h>
#include <linux/kstrtox.h>



#define RED_DC_OFFSET 0x20
#define GREEN_DC_OFFSET 0x24
#define BLUE_DC_OFFSET 0x28
#define PERIOD_OFFSET 0x2C

#define BYTE_SIZE 16


/**
 * Define the compatible property used for matching devices to this driver,
 * then add out device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same
 * compatible string as defined here.
 */
static const struct of_device_id pwm_of_match[] =
{
	{.compatible = "dupuis,pwm",},
	{}
};

/**
 * struct pwm_dev - Private pwm device struct.
 * @base_addr:        Pointer to the component's base address
 * @red_duty_cycle:   Address of the red_duty_cycle register
 * @green_duty_cycle: Address of the green_duty_cycle register
 * @blue_duty_cycle:  Address of the blue_duty_cycle register
 * @period:           Address of the period register
 * @miscdev:          miscdevice used to create a character device
 * @lock:             mutex used to prevent concurrent writes to memory
 *
 * pwm_dev struct gets created for each pwm component.
 */
struct pwm_dev
{
	void __iomem *base_addr;
	void __iomem *red_duty_cycle;
	void __iomem *green_duty_cycle;
	void __iomem *blue_duty_cycle;
	void __iomem *period;
	struct miscdevice miscdev;
	struct mutex lock;
};



// ATTRIBUTES -----------------------------------------------------------------

/**
 * red_duty_cycle_show() - Return the red_duty_cycle value to userspace via sysfs.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t red_duty_cycle_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int red_duty_cycle;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	red_duty_cycle = ioread32(priv->red_duty_cycle);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", red_duty_cycle);
}

/**
 * red_duty_cycle_store() - Store the red_duty_cycle value.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the red_duty_cycle value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t red_duty_cycle_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int red_duty_cycle;
	int ret;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as an unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &red_duty_cycle);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(red_duty_cycle, priv->red_duty_cycle);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



/**
 * green_duty_cycle_show() - Return the green_duty_cycle value to userspace via sysfs.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t green_duty_cycle_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int green_duty_cycle;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	green_duty_cycle = ioread32(priv->green_duty_cycle);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", green_duty_cycle);
}

/**
 * green_duty_cycle_store() - Store the green_duty_cycle value.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the green_duty_cycle value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t green_duty_cycle_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int green_duty_cycle;
	int ret;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as a unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &green_duty_cycle);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(green_duty_cycle, priv->green_duty_cycle);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



/**
 * blue_duty_cycle_show() - Return the blue_duty_cycle value to userspace via sysfs.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t blue_duty_cycle_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int blue_duty_cycle;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	blue_duty_cycle = ioread32(priv->blue_duty_cycle);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", blue_duty_cycle);
}

/**
 * blue_duty_cycle_store() - Store the blue_duty_cycle value.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the blue_duty_cycle value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t blue_duty_cycle_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int blue_duty_cycle;
	int ret;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as an unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &blue_duty_cycle);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(blue_duty_cycle, priv->blue_duty_cycle);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



/**
 * period_show() - Return the period value to userspace via sysfs.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t period_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int period;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	period = ioread32(priv->period);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", period);
}

/**
 * period_store() - Store the period value.
 * @dev:  Device structure for the pwm component. This is embedded
 *        in the pwm's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the period value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t period_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int period;
	int ret;
	struct pwm_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as an unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &period);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(period, priv->period);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



// Define sysfs attributes
static DEVICE_ATTR_RW(red_duty_cycle);
static DEVICE_ATTR_RW(green_duty_cycle);
static DEVICE_ATTR_RW(blue_duty_cycle);
static DEVICE_ATTR_RW(period);

// Create an attribute group so the device core can export attributes for us
static struct attribute *pwm_attrs[] =
{
	&dev_attr_red_duty_cycle.attr,
	&dev_attr_green_duty_cycle.attr,
	&dev_attr_blue_duty_cycle.attr,
	&dev_attr_period.attr,
	NULL,
};
ATTRIBUTE_GROUPS(pwm);

// END OF ATTRIBUTES ----------------------------------------------------------



// FILE OPERATIONS ------------------------------------------------------------

/**
 * pwm_read() - Read method for the pwm char device
 * @file:   Pointer to the char device file struct.
 * @buf:    User-space buffer to read the value into.
 * @count:  The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */
static ssize_t pwm_read(struct file *file, char __user *buf,
	size_t count, loff_t *offset)
{
	u32 val;
	
	/*
	 * Get the device's private data from the file struct's private_data
	 * field. The private_data field is equal to the miscdev field in the
	 * pwm_dev struct. container_of returns the pwm_dev struct that contains
	 * the miscdev in private_data.
	 */
	struct pwm_dev *priv = container_of(file->private_data,
		struct pwm_dev, miscdev);
	
	if (*offset < 0)
	{
		return -EINVAL;
	}
	if (*offset >= BYTE_SIZE)
	{
		return 0;
	}
	if ((*offset % 0x4) != 0)
	{
		pr_warn("pwm_read: unaligned access.\n");
		return -EFAULT;
	}
	
	val = ioread32(priv->base_addr + *offset);
	
	// Copy the value to userspace.
	size_t ret = copy_to_user(buf, &val, sizeof(val));
	if (ret == sizeof(val))
	{
		pr_warn("pwm_read: nothing copied.\n");
		return -EFAULT;
	}
	
	// Increment the file offset by the number of bytes we read.
	*offset = *offset + sizeof(val);
	
	return sizeof(val);
}



/**
 * pwm_write() - Write method for the pwm char device
 * @file:   Pointer to the char device file struct.
 * @buf:    User-space buffer to read the value from.
 * @count:  The number of bytes being written.
 * @offset: The byte offset in the file being written to.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */
static ssize_t pwm_write(struct file *file, const char __user *buf,
	size_t count, loff_t *offset)
{
	u32 val;
	
	/*
	 * Get the device's private data from the file struct's private_data
	 * field. The private_data field is equal to the miscdev field in the
	 * pwm_dev struct. container_of returns the pwm_dev struct that contains
	 * the miscdev in private_data.
	 */
	struct pwm_dev *priv = container_of(file->private_data,
		struct pwm_dev, miscdev);
	
	if (*offset < 0)
	{
		return -EINVAL;
	}
	if (*offset >= BYTE_SIZE)
	{
		return 0;
	}
	if ((*offset % 0x4) != 0)
	{
		pr_warn("led_patterns_write: unaligned access\n");
		return -EFAULT;
	}
	
	mutex_lock(&priv->lock);
	
	// Get the value from userspace.
	size_t ret = copy_from_user(&val, buf, sizeof(val));
	if (ret != sizeof(val))
	{
		iowrite32(val, priv->base_addr + *offset);
		
		// Increment the file offset by the number of bytes we wrote.
		*offset = *offset + sizeof(val);
		
		// Return the number of bytes we wrote.
		ret = sizeof(val);
	}
	else
	{
		pr_warn("pwm_write: nothing copied from userspace.\n");
		ret = -EFAULT;
	}
	
	mutex_unlock(&priv->lock);
	
	return ret;
}



/**
 * pwm_fops - File operations supported by the pwm driver
 * @owner:  The pwm driver owns the file operations; this ensures
 *          that the driver can't be removed while the character device is
 *          still in use.
 * @read:   The read function.
 * @write:  The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows users
 *          to change what position they are writing/reading to/from.
 */
static const struct file_operations pwm_fops =
{
	.owner = THIS_MODULE,
	.read = pwm_read,
	.write = pwm_write,
	.llseek = default_llseek,
};

// END OF FILE OPERATIONS -----------------------------------------------------



// PROBE AND REMOVE -----------------------------------------------------------

/**
 * pwm_probe() - Initialize pwm device when a match is found.
 * @pdev: Platform device structure associated with pwm device;
 *        pdev is automatically created by the driver core based upon
 *        the device tree node.
 *
 * It's called by the kernel when a pwm device is found in the device tree.
 */
static int pwm_probe(struct platform_device *pdev)
{
	pr_info("pwm_probe\n");
	
	/**
	 * Allocate kernel memory for the pwm device and set it to 0.
	 * GFP_KERNEL specifies that we are allocating normal kernel RAM;
	 * see the kmalloc documentation for more info. The allocated memory
	 * is automatically freed when the device is removed.
	 */
	struct pwm_dev *priv;
	priv = devm_kzalloc(&pdev->dev, sizeof(struct pwm_dev),
		GFP_KERNEL);
	if (!priv)
	{
		pr_err("Failed to allocate memory.\n");
		return -ENOMEM;
	}
	
	/**
	 * Request and remap the device's memory region. Requesting the region
	 * make sure nobody else can use that memory. The memory is remapped
	 * into the kernel's virtual address space because we don't have access
	 * to physical memory locations.
	 */
	priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
	if (IS_ERR(priv->base_addr))
	{
		pr_err("Failed to request/remap platform device resource.\n");
		return PTR_ERR(priv->base_addr);
	}
	
	// Set the memory addresses for each register.
	priv->red_duty_cycle = priv->base_addr + RED_DC_OFFSET;
	priv->green_duty_cycle = priv->base_addr + GREEN_DC_OFFSET;
	priv->blue_duty_cycle = priv->base_addr + BLUE_DC_OFFSET;
	priv->period = priv->base_addr + PERIOD_OFFSET;
	
	// Initialize registers to show white
	iowrite32(0x00000800, priv->red_duty_cycle);
	iowrite32(0x00000800, priv->green_duty_cycle);
	iowrite32(0x00000800, priv->blue_duty_cycle);
	iowrite32(0x00000008, priv->period);
	
	// Initialize the misc device parameters
	priv->miscdev.minor = MISC_DYNAMIC_MINOR;
	priv->miscdev.name = "pwm";
	priv->miscdev.fops = &pwm_fops;
	priv->miscdev.parent = &pdev->dev;
	
	// Register the misc device; this creates a char dev at /dev/pwm
	size_t ret = misc_register(&priv->miscdev);
	if (ret)
	{
		pr_err("Failed to register misc device.\n");
		return ret;
	}
	
	/**
	 * Attach the pwm's private data to the platform device's struct.
	 * This is so we can access our state container in the other functions.
	 */
	platform_set_drvdata(pdev, priv);
	
	pr_info("pwm_probe successful! :)\n");
	return 0;
}



/**
 * pwm_remove() - Remove an pwm device.
 * @pdev: Platform device structure associated with our pwm device.
 * 
 * It's called when an pwm device is removed or the driver is removed.
 */
static int pwm_remove(struct platform_device *pdev)
{
	pr_info("pwm_remove\n");
	
	// Get the pwm's private data from the platform device.
	struct pwm_dev *priv = platform_get_drvdata(pdev);
	
	// Deregister the misc device and remove the /dev/pwm file.
	misc_deregister(&priv->miscdev);
	
	pr_info("pwm_remove successful! :)\n");
	return 0;
}

// END OF PROBE AND REMOVE ----------------------------------------------------



/**
 * struct pwm_driver - Platform driver struct for this driver
 * @probe:                 Pointer to function called when device is found
 * @remove:                Pointer to function called when device is removed
 * @driver.owner:          Which module owns this driver
 * @driver.name:           Name of driver
 * @driver.of_match_table: Device tree match table
 */
static struct platform_driver pwm_driver = {
	.probe = pwm_probe,
	.remove = pwm_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name = "pwm",
		.of_match_table = pwm_of_match,
		.dev_groups = pwm_groups,
	},
};



module_platform_driver(pwm_driver);

MODULE_DEVICE_TABLE(of, pwm_of_match);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Ryan Dupuis");
MODULE_DESCRIPTION("pwm driver");
