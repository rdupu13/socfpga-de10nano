/**
 * Calculator Keyboard Platform Device Driver
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



#define BYTE_SIZE 16


/**
 * Define the compatible property used for matching devices to this driver,
 * then add out device id structure to the kernel's device table. For a device
 * to be matched with this driver, its device tree node must use the same
 * compatible string as defined here.
 */
static const struct of_device_id keyboard_of_match[] =
{
	{.compatible = "dupuis,keyboard",},
	{}
};

/**
 * struct keyboard_dev - Private keyboard device struct.
 * @base_addr:        Pointer to the component's base address
 * @kb_buffer:        Address of the control register
 * @miscdev:          miscdevice used to create a character device
 * @lock:             mutex used to prevent concurrent writes to memory
 *
 * keyboard_dev struct gets created for each keyboard component.
 */
struct keyboard_dev
{
	void __iomem *base_addr;
	void __iomem *kb_buffer;
	struct miscdevice miscdev;
	struct mutex lock;
};



// FILE OPERATIONS ------------------------------------------------------------

/**
 * keyboard_read() - Read method for the keyboard char device
 * @file:   Pointer to the char device file struct.
 * @buf:    User-space buffer to read the value into.
 * @count:  The number of bytes being requested.
 * @offset: The byte offset in the file being read from.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */
static ssize_t keyboard_read(struct file *file, char __user *buf, size_t count, loff_t *offset)
{
	u32 val;
	
	/*
	 * Get the device's private data from the file struct's private_data
	 * field. The private_data field is equal to the miscdev field in the
	 * keyboard_dev struct. container_of returns the keyboard_dev struct
	 * that contains the miscdev in private_data.
	 */
	struct keyboard_dev *priv = container_of(file->private_data, struct keyboard_dev, miscdev);
	
	if (*offset < 0)
	{
		return -EINVAL;
	}
	
	val = ioread32(priv->kb_buffer);
	
	// Copy the value to userspace.
	size_t ret = copy_to_user(buf, &val, sizeof(val));
	
	if (ret == sizeof(val))
	{
		pr_warn("keyboard_read: Zero bytes copied to userspace.\n");
		return -EFAULT;
	}
	
	// Increment the file offset by the number of bytes we read.
	*offset = *offset + sizeof(val);
	
	return sizeof(val);
}



/**
 * keyboard_write() - Write method for the keyboard char device
 * @file:   Pointer to the char device file struct.
 * @buf:    User-space buffer to read the value from.
 * @count:  The number of bytes being written.
 * @offset: The byte offset in the file being written to.
 *
 * Return: On success, the number of bytes written is returned and the
 * offset @offset is advanced by this number. On error, a negative error
 * value is returned.
 */ 
static ssize_t keyboard_write(struct file *file, const char __user *buf, size_t count, loff_t *offset)
{
	pr_info("No write performed on read-only device.");
	return 0;
}



/**
 * keyboard_fops - File operations supported by the keyboard driver
 * @owner:  The keyboard driver owns the file operations; this ensures
 *          that the driver can't be removed while the character device is
 *          still in use.
 * @read:   The read function.
 * @write:  The write function.
 * @llseek: We use the kernel's default_llseek() function; this allows users
 *          to change what position they are writing/reading to/from.
 */
static const struct file_operations keyboard_fops =
{
	.owner = THIS_MODULE,
	.read = keyboard_read,
	.write = keyboard_write,
	.llseek = default_llseek,
};

// END OF FILE OPERATIONS -----------------------------------------------------



// PROBE AND REMOVE -----------------------------------------------------------

/**
 * keyboard_probe() - Initialize keyboard device when a match is found.
 * @pdev: Platform device structure associated with keyboard device;
 *        pdev is automatically created by the driver core based upon
 *        the device tree node.
 *
 * It's called by the kernel when a keyboard device is found in the device tree.
 */
static int keyboard_probe(struct platform_device *pdev)
{
	pr_info("keyboard_probe\n");
	
	/**
	 * Allocate kernel memory for the keyboard device and set it to 0.
	 * GFP_KERNEL specifies that we are allocating normal kernel RAM;
	 * see the kmalloc documentation for more info. The allocated memory
	 * is automatically freed when the device is removed.
	 */
	struct keyboard_dev *priv;
	priv = devm_kzalloc(&pdev->dev, sizeof(struct keyboard_dev), GFP_KERNEL);
	if (!priv)
	{
		pr_err("Failed to allocate kernel memory.\n");
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
	priv->kb_buffer = priv->base_addr;
	
	// Initialze the misc device parameters
	priv->miscdev.minor = MISC_DYNAMIC_MINOR;
	priv->miscdev.name = "keyboard";
	priv->miscdev.fops = &keyboard_fops;
	priv->miscdev.parent = &pdev->dev;
	
	// Register the misc device; this creates a char dev at /dev/lcd
	size_t ret = misc_register(&priv->miscdev);
	if (ret)
	{
		pr_err("Failed to register misc device.");
		return ret;
	}
	
	/**
	 * Attach the keybaord's private data to the platform device's struct.
	 * This is so we can access our state container in the other functions.
	 */
	platform_set_drvdata(pdev, priv);
	
	pr_info("keyboard_probe successful! :)\n");
	return 0;
}



/**
 * keyboard_remove() - Remove an keyboard device.
 * @pdev: Platform device structure associated with our keyboard device.
 * 
 * It's called when an pwm device is removed or the driver is removed.
 */
static int keyboard_remove(struct platform_device *pdev)
{	
	pr_info("keyboard_remove\n");
	
	// Get the keyboard's private data from the platform device.
	struct keyboard_dev *priv = platform_get_drvdata(pdev);
	
	// Deregister the misc device and remove the /dev/keyboard file.
	misc_deregister(&priv->miscdev);
	
	pr_info("keyboard_remove successful! :)\n");
	return 0;
}

// END OF PROBE AND REMOVE ----------------------------------------------------



/**
 * struct keyboard_driver - Platform driver struct for this driver
 * @probe:                 Pointer to function called when device is found
 * @remove:                Pointer to function called when device is removed
 * @fops:                  Pointer to file operations struct
 * @driver.owner:          Which module owns this driver
 * @driver.name:           Name of driver
 * @driver.of_match_table: Device tree match table
 */
static struct platform_driver keyboard_driver = {
	.probe = keyboard_probe,
	.remove = keyboard_remove,
	.driver = {
		.owner = THIS_MODULE,
		.name = "keyboard",
		.of_match_table = keyboard_of_match,
	},
};



module_platform_driver(keyboard_driver);

MODULE_DEVICE_TABLE(of, keyboard_of_match);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Ryan Dupuis");
MODULE_DESCRIPTION("keyboard driver");
