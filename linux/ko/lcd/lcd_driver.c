/**
 * LCD Display Module Platform Device Driver
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



#define CONTROL_OFFSET 0x0
#define DATA_OFFSET 0x4

#define BYTE_SIZE 16


/**
 * Define the compatible property used for matching devices to this driver,
 * then add out device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same
 * compatible string as defined here.
 */
static const struct of_device_id lcd_of_match[] =
{
	{.compatible = "dupuis,lcd",},
	{}
};

/**
 * struct lcd_dev - Private lcd device struct.
 * @base_addr:        Pointer to the component's base address
 * @control:          Address of the control register
 * @data:             Address of the data register
 * @lock:             mutex used to prevent concurrent writes to memory
 *
 * lcd_dev struct gets created for each lcd component.
 */
struct lcd_dev
{
	void __iomem *base_addr;
	void __iomem *control;
	void __iomem *data;
	struct mutex lock;
};



// ATTRIBUTES -----------------------------------------------------------------

/**
 * control_show() - Return the control value to userspace via sysfs.
 * @dev:  Device structure for the lcd component. This is embedded
 *        in the lcd's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t control_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int control;
	struct lcd_dev *priv = dev_get_drvdata(dev);
	
	control = ioread32(priv->control);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", control);
}

/**
 * control_store() - Store the control value.
 * @dev:  Device structure for the lcd component. This is embedded
 *        in the lcd's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the control value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t control_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int control;
	int ret;
	struct lcd_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as an unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &control);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(control, priv->control);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



/**
 * data_show() - Return the data value to userspace via sysfs.
 * @dev:  Device structure for the lcd component. This is embedded
 *        in the lcd's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that gets returned to userspace.
 * 
 * Return: The number of bytes read.
 */
static ssize_t data_show(struct device *dev,
	struct device_attribute *attr, char *buf)
{
	unsigned int data;
	struct lcd_dev *priv = dev_get_drvdata(dev);
	
	data = ioread32(priv->data);
	
	return scnprintf(buf, PAGE_SIZE, "%u\n", data);
}

/**
 * data_store() - Store the data value.
 * @dev:  Device structure for the lcd component. This is embedded
 *        in the lcd's platform device struct.
 * @attr: Unused.
 * @buf:  Buffer that contains the data value being written.
 * @size: The number of bytes being written.
 * 
 * Return: The number of bytes stored.
 */
static ssize_t data_store(struct device *dev,
	struct device_attribute *attr, const char *buf, size_t size)
{
	unsigned int data;
	int ret;
	struct lcd_dev *priv = dev_get_drvdata(dev);
	
	// Parse the string we received as a unsigned int
	// See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L213
	ret = kstrtouint(buf, 0, &data);
	if (ret < 0)
	{
		return ret;
	}
	
	iowrite32(data, priv->data);
	
	// Write was successful, so we return the number of bytes we wrote.
	return size;
}



// Define sysfs attributes
static DEVICE_ATTR_RW(control);
static DEVICE_ATTR_RW(data);

// Create an attribute group so the device core can export attributes for us
static struct attribute *lcd_attrs[] =
{
	&dev_attr_control.attr,
	&dev_attr_data.attr,
	NULL,
};
ATTRIBUTE_GROUPS(lcd);

// END OF ATTRIBUTES ----------------------------------------------------------



// PROBE AND REMOVE -----------------------------------------------------------

/**
 * lcd_probe() - Initialize lcd device when a match is found.
 * @pdev: Platform device structure associated with lcd device;
 *        pdev is automatically created by the driver core based upon
 *        the device tree node.
 *
 * It's called by the kernel when a lcd device is found in the device tree.
 */
static int lcd_probe(struct platform_device *pdev)
{
	pr_info("lcd_probe\n");
	
	/**
	 * Allocate kernel memory for the lcd device and set it to 0.
	 * GFP_KERNEL specifies that we are allocating normal kernel RAM;
	 * see the kmalloc documentation for more info. The allocated memory
	 * is automatically freed when the device is removed.
	 */
	struct lcd_dev *priv;
	priv = devm_kzalloc(&pdev->dev, sizeof(struct lcd_dev),
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
	priv->control = priv->base_addr + CONTROL_OFFSET;
	priv->data = priv->base_addr + DATA_OFFSET;
	
	// Initialize registers to zeros
	iowrite32(0x00000000, priv->control);
	iowrite32(0x00000000, priv->data);
	
	/**
	 * Attach the lcd's private data to the platform device's struct.
	 * This is so we can access our state container in the other functions.
	 */
	platform_set_drvdata(pdev, priv);
	
	pr_info("lcd_probe successful! :)\n");
	return 0;
}



/**
 * lcd_remove() - Remove an lcd device.
 * @pdev: Platform device structure associated with our lcd device.
 * 
 * It's called when an pwm device is removed or the driver is removed.
 */
static int lcd_remove(struct platform_device *pdev)
{	
	pr_info("lcd_remove successful! :)\n");
	return 0;
}

// END OF PROBE AND REMOVE ----------------------------------------------------



/**
 * struct lcd_driver - Platform driver struct for this driver
 * @probe:                 Pointer to function called when device is found
 * @remove:                Pointer to function called when device is removed
 * @driver.owner:          Which module owns this driver
 * @driver.name:           Name of driver
 * @driver.of_match_table: Device tree match table
 */
static struct platform_driver lcd_driver = {
	.probe = lcd_probe,
	.remove = lcd_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name = "lcd",
		.of_match_table = lcd_of_match,
		.dev_groups = lcd_groups,
	},
};



module_platform_driver(lcd_driver);

MODULE_DEVICE_TABLE(of, lcd_of_match);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Ryan Dupuis");
MODULE_DESCRIPTION("lcd driver");
