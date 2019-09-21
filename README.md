# MCU-Based-on-Verilog
Aims to have better performance than Cortex-M4F or Cortex-M33F. 

The following feature will be supported (including but not limited):
a. Support RV32IMCF standard instruction set. 

b. No need to support A instruction set, since I do not think mcu level application does not need lock between processors.

c. Single issue with limited dual issue capability.

d. Automatically context switch to help have low power and speedup.

e. Support interrupt preempt, tail-chaining, and derived exceptions.

f. Support Machine and User Mode.
