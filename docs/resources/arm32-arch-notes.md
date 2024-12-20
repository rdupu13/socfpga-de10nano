# ARM 32-bit CPU architecture

## Registers
- R0       : 
- R1       : 
- R2       : 
- R3       : 
- R4       : 
- R5       : 
- R6       : 
- R7       : 
- R8       : 
- R9       : 
- R10      : 
- R11      : 
- R12      : 
- R13 (SP) : Stack Pointer (Banked for each CPU mode)
- R14 (LR) : Link Register (Banked for each CPU mode)
- R15 (PC) : Program Counter
- CPSR     : Current Processor Status Register
- 

### CPSR Register

31----------24 23-----16 15-------8 7---------0
N Z C V Q HH J DDDD GGGG HHHHHH E A I F T MMMMM

N : Negative / Less Than
Z : Zero
C : Carry / Borrow / Extend
V : Overflow
Q : Sticky Overflow
J : Java State
D : Do Not Modify (Nibble)
G : Greater-Than-Or-Equal-To (Nibble)
H : If-Then State (Byte)
E : Data Endianness
A : Imprecise Data Abort Disable
I : IRQ Disable
F : FIRQ Disable
T : Thumb State
M : Processor Mode (5 bits)


#### Processor Modes (CPSR bits 4:0)
- usr : User Mode (Not privileged)
- fiq : Fast Interrupt Request Mode
- irq : Interrupt Request Mode
- svc : Supervisor Mode
- abt : Abort Mode
- und : Undefined Mode


