# MCU-Based-on-Verilog
Aims to have better performance than Cortex-M4F or Cortex-M33F
Support RV32IMCF standard instruction set. 
No need to support A instruction set, since I do not think mcu level application does not need lock between processors.
Single issue with limited dual issue capability.
Automatically context switch to help have low power and speedup.
Support interrupt preempt, tail-chaining, and derived exceptions.
Support Machine and User Mode.
