# C Style Guide

This style guide is taken mostly from [Harvard's CS50 style guide](https://cs50.readthedocs.io/style/c/) and the
[Linux kernel coding style](https://www.kernel.org/doc/html/v4.10/process/coding-style.html) guide. There are
discrepancies between the two style guides which are not necessarily reflected here. When writing kernel code, I
will follow the kernel style guide more closely. When writing non-kernel code, I will follow this style guide (which
is mix of the CS50 and kernel style guides).

This style guide is not nearly as exhaustive as some you will come across in industry (see [Google's C++ style guide](https://google.github.io/styleguide/cppguide.html), for instance).

> [!IMPORTANT]
> You will be (somewhat lightly) graded based upon your adherence to this style guide.

## Naming Conventions
### Filenames
File names should be `snake_case` or `kebab-case`

### Constants
Constants should be `ALL_CAPS` to distinguish them from normal signals.

### Variables
Variables should be `snake_case`, as this is the most common convention in C.

### Functions
Function names should be `snake_case`.

## Comments

Comments are good, but there is also a danger of over-commenting.  NEVER
try to explain HOW your code works in a comment: it's much better to
write the code so that the **working** is obvious, and it's a waste of
time to explain badly written code.

Generally, you want your comments to tell WHAT your code does, not HOW.
Also, try to avoid putting comments inside a function body: if the
function is so complex that you need to separately comment parts of it,
you should probably go back to chapter 6 for a while.  You can make
small comments to note or warn about something particularly clever (or
ugly), but try to avoid excess.  Instead, put the comments at the head
of the function, telling people what it does, and possibly WHY it does
it.

The preferred style for long (multi-line) comments is:

```c
/*
 * This is the preferred style for multi-line
 * comments in the Linux kernel source code.
 * Please use it consistently.
 *
 * Description:  A column of asterisks on the left side,
 * with beginning and ending almost-blank lines.
 */
```

It's also important to comment data, whether they are basic types or derived
types.  To this end, use just one data declaration per line (no commas for
multiple data declarations).  This leaves you room for a small comment on each
item, explaining its use.

### Function documentation
To document our functions, we'll use Linux
[kernel-doc comments](https://www.kernel.org/doc/html/v4.10/doc-guide/kernel-doc.html#writing-kernel-doc-comments).
The format is quite similar to [Doxygen](https://doxygen.nl/index.html) comments. 



The general format of a function and function-like macro kernel-doc comment is::
```c
/**
 * function_name() - Brief description of function.
 * @arg1: Describe the first argument.
 * @arg2: Describe the second argument.
 *        One can provide multiple line descriptions
 *        for arguments.
 *
 * A longer description, with more discussion of the function function_name()
 * that might be useful to those using or modifying it. Begins with an
 * empty comment line, and may include additional embedded empty
 * comment lines.
 *
 * The longer description may have multiple paragraphs.
 *
 * Return: Describe the return value of foobar.
 *
 * The return value description can also have multiple paragraphs, and should
 * be placed at the end of the comment block.
 */
```

The brief description following the function name may span multiple lines, and
ends with an `@argument:` description, a blank comment line, or the end of the
comment block.

The kernel-doc function comments describe each parameter to the function, in
order, with the `@argument:` descriptions. The `@argument:` descriptions
must begin on the very next line following the opening brief function
description line, with no intervening blank comment lines. The `@argument:`
descriptions may span multiple lines. The continuation lines may contain
indentation. If a function parameter is `...` (varargs), it should be listed
in kernel-doc notation as: `@...:`.

The return value, if any, should be described in a dedicated section at the end
of the comment starting with "Return:".


## Formatting

### Indentation
In general, I prefer using 4 spaces for indentation. However, the Linux kernel prefers hard-tabs instead of spaces;
they also prefer their editor's tab width to be set to 8 spaces. 

For general C code, I will use 4 spaces for indentation. For kernel code and device trees, I will use hard-tabs
(with my editor's tab-stop set to 8 spaces). You may choose to do the same or you may choose to stick to one of the
two conventions.

Here's some nicely indented code:

```c
// Print command-line arguments one per line
printf("\n");
for (int i = 0; i < argc; i++)
{
    for (int j = 0, n = strlen(argv[i]); j < n; j++)
    {
        printf("%c\n", argv[i][j]);
    }
    printf("\n");
}
```

### Line Length

By convention the maximum length of a line of code is 80 characters long in C, with that being historically
grounded in standard-sized monitors on older computer terminals, which could display 24 lines vertically and 80
characters horizontally. Though modern technology has obsoleted the need to keep lines capped at 80 characters,
it is still a guideline that should be considered a "soft stop." A line of 100 characters should really be the
longest you write in C, else readers will generally need to scroll. If you need more than 100 characters, it may
be time to rethink either your variable names or your overall design!

### Bracket placement
Brackets should be placed on their own line, for example: 

```c
if (x > 0)
{
    printf("x is positive\n");
}
else if (x < 0)
{
    printf("x is negative\n");
}
else
{
    printf("x is zero\n");
}
```

This makes the scope / nesting-level very easy to see.


### Conditional statements 

Conditions should be styled as follows:

```c
if (x > 0)
{
    printf("x is positive\n");
}
else if (x < 0)
{
    printf("x is negative\n");
}
else
{
    printf("x is zero\n");
}
```

Notice how:

- the curly braces line up nicely, each on its own line, making perfectly clear what's inside the branch;
- there's a single space after each `if`;
- each call to `printf` is indented with 4 spaces;
- there are single spaces around the `>` and around the `<`; and
- there isn't any space immediately after each `(` or immediately before each `)`.

To save space, some programmers like to keep the first curly brace on the same line as the condition itself, but
we don't recommend, as it's harder to read, so don't do this:

```c
if (x < 0) {
    printf("x is negative\n");
} else if (x < 0) {
    printf("x is negative\n");
}
```

And definitely don't do this:

```c
if (x < 0)
    {
    printf("x is negative\n");
    }
else
    {
    printf("x is negative\n");
    }
```

### Switches

Declare a `switch` as follows:

```c
switch (n)
{
    case -1:
        printf("n is -1\n");
        break;

    case 1:
        printf("n is 1\n");
        break;

    default:
        printf("n is neither -1 nor 1\n");
        break;
}
```

Notice how:

- each curly brace is on its own line;
- there's a single space after `switch`;
- there isn't any space immediately after each `(` or immediately before each `)`;
- the switch's cases are indented with 4 spaces;
- the cases' bodies are indented further with 4 spaces; and
- each `case` (including `default`) ends with a `break`.

### Functions

In accordance with [C99](http://en.wikipedia.org/wiki/C99), be sure to declare `main` with:

```c
int main(void)
{

}
```

or with:

```c
int main(int argc, char *argv[])
{

}
```

or even with:

```c
int main(int argc, char **argv)
{

}
```

Do not declare `main` with:

```c
int main()
{

}
```

or with:

```c
void main()
{

}
```

or with:

```c
main()
{

}
```

As for your own functions, be sure to define them similiarly, with each curly brace on its own line and with the
return type on the same line as the function's name, just as we've done with `main`.



### Loops

#### for

Whenever you need temporary variables for iteration, use `i`, then `j`, then `k`, unless more specific names would
make your code more readable:

```c
for (int i = 0; i < LIMIT; i++)
{
    for (int j = 0; j < LIMIT; j++)
    {
        for (int k = 0; k < LIMIT; k++)
        {
            // Do something
        }
    }
}
```

If you need more than three variables for iteration, it might be time to rethink your design!

#### while

Declare `while` loops as follows:

```c
while (condition)
{
    // Do something
}
```

Notice how:

- each curly brace is on its own line;
- there's a single space after `while`;
- there isn't any space immediately after the `(` or immediately before the `)`; and
- the loop's body (a comment in this case) is indented with 4 spaces.

#### do ... while

Declare `do ... while` loops as follows:

```c
do
{
    // Do something
}
while (condition);
```

Notice how:

- each curly brace is on its own line;
- there's a single space after `while`;
- there isn't any space immediately after the `(` or immediately before the `)`; and
- the loop's body (a comment in this case) is indented with 4 spaces.

### Pointers

When declaring a pointer, write the `*` next to the variable, as in:

```c
int *p;
```

Don't write it next to the type, as in:

```c
int* p;
```

## Functions
Functions should be short and sweet, and do just one thing.  They should
fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
as we all know), and do one thing and do that well.

The maximum length of a function is inversely proportional to the
complexity and indentation level of that function.  So, if you have a
conceptually simple function that is just one long (but simple)
case-statement, where you have to do lots of small things for a lot of
different cases, it's OK to have a longer function.

However, if you have a complex function, and you suspect that a
less-than-gifted first-year high-school student might not even
understand what the function is all about, you should adhere to the
maximum limits all the more closely.  Use helper functions with
descriptive names (you can ask the compiler to in-line them if you think
it's performance-critical, and it will probably do a better job of it
than you would have done).

Another measure of the function is the number of local variables.  They
shouldn't exceed 5-10, or you're doing something wrong.  Re-think the
function, and split it into smaller pieces.  A human brain can
generally easily keep track of about 7 different things, anything more
and it gets confused.  You know you're brilliant, but maybe you'd like
to understand what you did 2 weeks from now.

In source files, separate functions with one blank line.  If the function is
exported, the **EXPORT** macro for it should follow immediately after the
closing function brace line.  E.g.:

```c
	int system_is_up(void)
	{
		return system_state == SYSTEM_RUNNING;
	}
	EXPORT_SYMBOL(system_is_up);
```

In function prototypes, include parameter names with their data types.
Although this is not required by the C language, it is preferred in Linux
because it is a simple way to add valuable information for the reader.
