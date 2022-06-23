/***********************
*  Filename      : SRAM2RW32x16.v                                       *
*  SRAM name     : SRAM2RW32x16                                         *
*  Word width    : 16    bits                                        *
*  Word number   : 32                                                *
*  Adress width  : 5     bits                                        *
************************/

`timescale 1ns/100fs

`define numAddr 32
`define numWords 32
`define wordLength 16



module SRAM2RW32x16 (A1,A2,CE1,CE2,WEB1,WEB2,OEB1,OEB2,CSB1,CSB2,I1,I2,O1,O2);

input 				CE1;
input 				CE2;
input 				WEB1;
input 				WEB2;
input 				OEB1;
input 				OEB2;
input 				CSB1;
input 				CSB2;

input 	[`numAddr-1:0] 		A1;
input 	[`numAddr-1:0] 		A2;
input 	[`wordLength-1:0] 	I1;
input 	[`wordLength-1:0] 	I2;
output 	[`wordLength-1:0] 	O1;
output 	[`wordLength-1:0] 	O2;

/*reg   [`wordLength-1:0]   	memory[`numWords-1:0];*/
/*reg  	[`wordLength-1:0]	data_out1;*/
/*reg  	[`wordLength-1:0]	data_out2;*/
wire 	[`wordLength-1:0] 	O1;
wire  	[`wordLength-1:0]	O2;
	
wire 				RE1;
wire 				RE2;	
wire 				WE1;	
wire 				WE2;

SRAM2RW32x16_1bit sram_IO0 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[0], I2[0], O1[0], O2[0]);
SRAM2RW32x16_1bit sram_IO1 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[1], I2[1], O1[1], O2[1]);
SRAM2RW32x16_1bit sram_IO2 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[2], I2[2], O1[2], O2[2]);
SRAM2RW32x16_1bit sram_IO3 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[3], I2[3], O1[3], O2[3]);
SRAM2RW32x16_1bit sram_IO4 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[4], I2[4], O1[4], O2[4]);
SRAM2RW32x16_1bit sram_IO5 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[5], I2[5], O1[5], O2[5]);
SRAM2RW32x16_1bit sram_IO6 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[6], I2[6], O1[6], O2[6]);
SRAM2RW32x16_1bit sram_IO7 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[7], I2[7], O1[7], O2[7]);
SRAM2RW32x16_1bit sram_IO8 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[8], I2[8], O1[8], O2[8]);
SRAM2RW32x16_1bit sram_IO9 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[9], I2[9], O1[9], O2[9]);
SRAM2RW32x16_1bit sram_IO10 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[10], I2[10], O1[10], O2[10]);
SRAM2RW32x16_1bit sram_IO11 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[11], I2[11], O1[11], O2[11]);
SRAM2RW32x16_1bit sram_IO12 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[12], I2[12], O1[12], O2[12]);
SRAM2RW32x16_1bit sram_IO13 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[13], I2[13], O1[13], O2[13]);
SRAM2RW32x16_1bit sram_IO14 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[14], I2[14], O1[14], O2[14]);
SRAM2RW32x16_1bit sram_IO15 ( CE1, CE2, WEB1, WEB2,  A1, A2, OEB1, OEB2, CSB1, CSB2, I1[15], I2[15], O1[15], O2[15]);


endmodule


module SRAM2RW32x16_1bit (CE1_i, CE2_i, WEB1_i, WEB2_i,  A1_i, A2_i, OEB1_i, OEB2_i, CSB1_i, CSB2_i, I1_i, I2_i, O1_i, O2_i);

input 	CSB1_i, CSB2_i;
input 	OEB1_i, OEB2_i;
input 	CE1_i, CE2_i;
input 	WEB1_i, WEB2_i;

input 	[`numAddr-1:0] 	A1_i, A2_i;
input 	[0:0] I1_i, I2_i;

output 	[0:0] O1_i, O2_i;

reg 	[0:0] O1_i, O2_i;
reg    	[0:0]  	memory[`numWords-1:0];
reg  	[0:0]	data_out1, data_out2;


wire RE1;
wire WE1;
wire RE2;
wire WE2;
and u1 (RE1, ~CSB1_i,  WEB1_i);
and u2 (WE1, ~CSB1_i, ~WEB1_i);
and u3 (RE2, ~CSB2_i,  WEB2_i);
and u4 (WE2, ~CSB2_i, ~WEB2_i);

//Primary ports

always @ (posedge CE1_i) 
	if (RE1)
		data_out1 = memory[A1_i];
always @ (posedge CE1_i) 
	if (WE1)
		memory[A1_i] = I1_i;
		

always @ (data_out1 or OEB1_i)
	if (!OEB1_i) 
		O1_i = data_out1;
	else
		O1_i =  1'bz;

//Dual ports	
always @ (posedge CE2_i)
  	if (RE2)
		data_out2 = memory[A2_i];
always @ (posedge CE2_i)
	if (WE2)
		memory[A2_i] = I2_i;
		
always @ (data_out2 or OEB2_i)
	if (!OEB2_i) 
		O2_i = data_out2;
	else
		O2_i = 1'bz;

endmodule