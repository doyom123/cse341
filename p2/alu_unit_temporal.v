// 1 bit adder
module fulladder(sum, cout, a, b, cin);
	input a, b, cin;
	output sum, cout;
	wire w1, w2, w3;
	xor #1 x1(w1, a, b),
		x2(sum, w1, cin);
	and #1 a1(w2, w1, cin),
		a2(w3, a, b);
	or #1 o1(cout, w2, w3);
endmodule

// 4 bit carry look ahead bloooooock
module clablock(sum, cout, a, b, cin);
	input [3:0] a, b;
	input cin;
	output [3:0] sum;
	output cout;
	wire [3:0] g, p;
	wire gp0, gp1, gp2, gp3, gp4, gpout;
	wire p0, p1, pout;
	wire c0;
	wire [3:0]cout2;
	//Generate
	and #1 a0(g[0], a[0], b[0]),
		a1(g[1], a[1], b[1]),
		a2(g[2], a[2], b[2]),
		a3(g[3], a[3], b[3]);
	or  #1 o0(p[0], a[0], b[0]),
		o1(p[1], a[1], b[1]),
		o2(p[2], a[2], b[2]),
		o3(p[3], a[3], b[3]);
	and #1 a4(gp0, g[0], p[1]);
	or  #1 o4(gp1, gp0, g[1]);
	and #1 a5(gp2, gp1, p[2]);
	or  #1 o5(gp3, gp2, g[2]);
	and #1 a6(gp4, gp3, p[3]);
	or  #1 o6(gpout, gp4, g[3]);
	//Propagate
	and #1 a7(p0, p[0], p[1]),
		a8(p1, p0, p[2]),
		a9(pout, p1, p[3]);
	//cout = g+p*cin
	and #1 a10(c0, cin, pout);
	or  #1 o7(cout, gpout, c0);
	fulladder f1(sum[0], cout2[0], a[0], b[0], cin),
	 		  f2(sum[1], cout2[1], a[1], b[1], cout2[0]),
			  f3(sum[2], cout2[2], a[2], b[2], cout2[1]),
			  f4(sum[3], cout2[3], a[3], b[3], cout2[2]);
endmodule

// 32 bit carry look ahead adder
module cla(sum, cout, a, b, cin);
	input [31:0] a, b;
	input cin;
	output [31:0] sum;
	output cout;
	wire c0, c1, c2, c3, c4, c5, c6;
	clablock cb1(sum[3:0], c0, a[3:0], b[3:0], cin),
			 cb2(sum[7:4], c1, a[7:4], b[7:4], c0),
			 cb3(sum[11:8], c2, a[11:8], b[11:8], c1),
			 cb4(sum[15:12], c3, a[15:12], b[15:12], c2),
			 cb5(sum[19:16], c4, a[19:16], b[19:16], c3),
			 cb6(sum[23:20], c5, a[23:20], b[23:20], c4),
			 cb7(sum[27:24], c6, a[27:24], b[27:24], c5),
			 cb8(sum[31:28], cout, a[31:28], b[31:28], c6);
endmodule

// Not's input - useless
module notter(out, in);
	input [31:0] in;
	output [31:0] out;
	not n1(out[0],   in[0]),  n2(out[1],   in[1]),  n3(out[2],   in[2]),  n4(out[3],   in[3]),
		n5(out[4],   in[4]),  n6(out[5],   in[5]),  n7(out[6],   in[6]),  n8(out[7],   in[7]),
		n9(out[8],   in[8]),  n10(out[9],  in[9]),  n11(out[10], in[10]), n12(out[11], in[11]),
		n13(out[12], in[12]), n14(out[13], in[13]), n15(out[14], in[14]), n16(out[15], in[15]),
		n17(out[16], in[16]), n18(out[17], in[17]), n19(out[18], in[18]), n20(out[19], in[19]),
		n21(out[20], in[20]), n22(out[21], in[21]), n23(out[22], in[22]), n24(out[23], in[23]),
		n25(out[24], in[24]), n26(out[25], in[25]), n27(out[26], in[26]), n28(out[27], in[27]),
		n29(out[28], in[28]), n30(out[29], in[29]), n31(out[30], in[30]), n32(out[31], in[31]);
endmodule

// 1 bit input MUX for subtraction
module submux(out, b, op);
	input b, op;
	output out;
	wire notb, notop, w1, w2;
	not #1 n1(notb, b);
	not #1 n2(notop, op);
	and #1 a1(w1, b, notop);
	and #1 a2(w2, notb, op);
	or #1 o1(out, w1, w2);
endmodule

// 32 bit input MUX for subtraction
module submuxfull(out, op, b);
	input [31:0] b;
	input op;
	output [31:0] out;
	submux s0(out[0],   b[0],  op), s1(out[1],   b[1],  op),
	 	   s2(out[2],   b[2],  op), s3(out[3],   b[3],  op),
		   s4(out[4],   b[4],  op), s5(out[5],   b[5],  op), 
		   s6(out[6],   b[6],  op), s7(out[7],   b[7],  op),
		   s8(out[8],   b[8],  op), s9(out[9],   b[9],  op),
		   s10(out[10], b[10], op), s11(out[11], b[11], op),
		   s12(out[12], b[12], op), s13(out[13], b[13], op), 
		   s14(out[14], b[14], op), s15(out[15], b[15], op),
		   s16(out[16], b[16], op), s17(out[17], b[17], op),
		   s18(out[18], b[18], op), s19(out[19], b[19], op),
		   s20(out[20], b[20], op), s21(out[21], b[21], op), 
		   s22(out[22], b[22], op), s23(out[23], b[23], op),
		   s24(out[24], b[24], op), s25(out[25], b[25], op),
		   s26(out[26], b[26], op), s27(out[27], b[27], op),
		   s28(out[28], b[28], op), s29(out[29], b[29], op), 
		   s30(out[30], b[30], op), s31(out[31], b[31], op);
endmodule

// 32 bit ZERO check
module zero(out, in);
	input [31:0] in;
	output out;
	wire [31:0] w;
	or #1 o0 (w[0] , in[0], in[1]) , o1 (w[1] , w[0] , in[2]) , o2 (w[2] , w[1],  in[3]) , o3 (w[3] , w[2] , in[4]),
	   o4 (w[4] , w[3] , in[5]) , o5 (w[5] , w[4] , in[6]) , o6 (w[6] , w[5],  in[7]) , o7 (w[7] , w[6] , in[8]),
	   o8 (w[8] , w[7] , in[9]) , o9 (w[9] , w[8] , in[10]), o10(w[10], w[9],  in[11]), o11(w[11], w[10], in[12]),
	   o12(w[12], w[11], in[13]), o13(w[13], w[12], in[14]), o14(w[14], w[13], in[15]), o15(w[15], w[14], in[16]),
	   o16(w[16], w[15], in[17]), o17(w[17], w[16], in[18]), o18(w[18], w[17], in[19]), o19(w[19], w[18], in[20]),
	   o20(w[20], w[19], in[21]), o21(w[21], w[20], in[22]), o22(w[22], w[21], in[23]), o23(w[23], w[22], in[24]),
	   o24(w[24], w[23], in[25]), o25(w[25], w[24], in[26]), o26(w[26], w[25], in[27]), o27(w[27], w[26], in[28]),
	   o28(w[28], w[27], in[29]), o29(w[29], w[28], in[30]), o30(w[30], w[29], in[31]);
	not #1 n1(out, w[30]);
endmodule

// 32 bit AND operation
module andfull(out, a, b);
	input [31:0] a, b;
	output [31:0] out;
	and #1 a0 (out[0],  a[0],  b[0]),  a1(out[1],  a[1],  b[1]),  a2(out[2],  a[2],  b[2]),  a3(out[3],  a[3],   b[3]),
		a4 (out[4],  a[4],  b[4]),  a5(out[5],  a[5],  b[5]),  a6(out[6],  a[6],  b[6]),  a7(out[7],  a[7],   b[7]),
		a8 (out[8],  a[8],  b[8]),  a9(out[9],  a[9],  b[9]),  a10(out[10], a[10], b[10]), a11(out[11], a[11], b[11]),
		a12(out[12], a[12], b[12]), a13(out[13], a[13], b[13]), a14(out[14], a[14], b[14]), a15(out[15], a[15], b[15]),
		a16(out[16], a[16], b[16]), a17(out[17], a[17], b[17]), a18(out[18], a[18], b[18]), a19(out[19], a[19], b[19]),
		a20(out[20], a[20], b[20]), a21(out[21], a[21], b[21]), a22(out[22], a[22], b[22]), a23(out[23], a[23], b[23]),
		a24(out[24], a[24], b[24]), a25(out[25], a[25], b[25]), a26(out[26], a[26], b[26]), a27(out[27], a[27], b[27]),
		a28(out[28], a[28], b[28]), a29(out[29], a[29], b[29]), a30(out[30], a[30], b[30]), a31(out[31], a[31], b[31]);
endmodule

// 32 bit OR operation
module orfull(out, a, b);
	input [31:0] a, b;
	output [31:0] out;
	or  #1 a0 (out[0],  a[0],  b[0]),  a1(out[1],  a[1],  b[1]),  a2(out[2],  a[2],  b[2]),  a3(out[3],  a[3],  b[3]),
		a4 (out[4],  a[4],  b[4]),  a5(out[5],  a[5],  b[5]),  a6(out[6],  a[6],  b[6]),  a7(out[7],  a[7],  b[7]),
		a8 (out[8],  a[8],  b[8]),  a9(out[9],  a[9],  b[9]),  a10(out[10], a[10], b[10]), a11(out[11], a[11], b[11]),
		a12(out[12], a[12], b[12]), a13(out[13], a[13], b[13]), a14(out[14], a[14], b[14]), a15(out[15], a[15], b[15]),
		a16(out[16], a[16], b[16]), a17(out[17], a[17], b[17]), a18(out[18], a[18], b[18]), a19(out[19], a[19], b[19]),
		a20(out[20], a[20], b[20]), a21(out[21], a[21], b[21]), a22(out[22], a[22], b[22]), a23(out[23], a[23], b[23]),
		a24(out[24], a[24], b[24]), a25(out[25], a[25], b[25]), a26(out[26], a[26], b[26]), a27(out[27], a[27], b[27]),
		a28(out[28], a[28], b[28]), a29(out[29], a[29], b[29]), a30(out[30], a[30], b[30]), a31(out[31], a[31], b[31]);
endmodule

// 4 to 1 MUX
module alumux(out, a, b, c, d, op);
	// and - 00
	// or  - 01
	// add - 10
	input [1:0] op;
	input a, b, c, d;
	output out;
	wire notop0, notop1;
	wire w1, w2, w3, w4;
	wire w11, w22, w33, w44;
	wire w111, w222;
	not #1 n1(notop0, op[0]);
	not #1 n2(notop1, op[1]);
	
	and #1 a1(w1, a, notop1);
	and #1 a2(w11, w1, notop0);

	and #1 a3(w2, b, notop1);
	and #1 a4(w22, w2, op[0]);

	and #1 a5(w3, c, op[1]);
	and #1 a5(w33, w3, notop0);

	and #1 a6(w4, d, op[1]);
	and #1 a6(w44, w4, op[0]);

	or #1 o1(w111, w11, w22);
	or #1 o2(w222, w111, w33);
	or #1 o3(out, w222, w44);
endmodule

// 32 bit 4 to 1 MUX
module alumuxfull(out, a, b, c, d, op);
	input [31:0] a, b, c, d;
	input [1:0] op;
	output [31:0] out;
	alumux a0 (out[0],  a[0],  b[0],  c[0],  d[0],  op), a1(out[1],   a[1],  b[1],  c[1],  d[1],  op),
	       a2 (out[2],  a[2],  b[2],  c[2],  d[2],  op), a3(out[3],   a[3],  b[3],  c[3],  d[3],  op),
	       a4 (out[4],  a[4],  b[4],  c[4],  d[4],  op), a5(out[5],   a[5],  b[5],  c[5],  d[5],  op),
	       a6 (out[6],  a[6],  b[6],  c[6],  d[6],  op), a7(out[7],   a[7],  b[7],  c[7],  d[7],  op),
	       a8 (out[8],  a[8],  b[8],  c[8],  d[8],  op), a9(out[9],   a[9],  b[9],  c[9],  d[9],  op),
	       a10(out[10], a[10], b[10], c[10], d[10], op), a11(out[11], a[11], b[11], c[11], d[11], op),
	       a12(out[12], a[12], b[12], c[12], d[12], op), a13(out[13], a[13], b[13], c[13], d[13], op),
	       a14(out[14], a[14], b[14], c[14], d[14], op), a15(out[15], a[15], b[15], c[15], d[15], op),
	       a16(out[16], a[16], b[16], c[16], d[16], op), a17(out[17], a[17], b[17], c[17], d[17], op),
	       a18(out[18], a[18], b[18], c[18], d[18], op), a19(out[19], a[19], b[19], c[19], d[19], op),
	       a20(out[20], a[20], b[20], c[20], d[20], op), a21(out[21], a[21], b[21], c[21], d[21], op),
	       a22(out[22], a[22], b[22], c[22], d[22], op), a23(out[23], a[23], b[23], c[23], d[23], op),
	       a24(out[24], a[24], b[24], c[24], d[24], op), a25(out[25], a[25], b[25], c[25], d[25], op),
	       a26(out[26], a[26], b[26], c[26], d[26], op), a27(out[27], a[27], b[27], c[27], d[27], op),
	       a28(out[28], a[28], b[28], c[28], d[28], op), a29(out[29], a[29], b[29], c[29], d[29], op),
	       a30(out[30], a[30], b[30], c[30], d[30], op), a31(out[31], a[31], b[31], c[31], d[31], op);
endmodule

module overflow(out,a31, b31, result31);
	input a31, b31, result31;
	output out;
	wire w1, w2, w3, w4;
	wire nota31, notb31, notresult31;
	not #1 n1(nota31, a31);
	not #1 n2(notb31, b31);
	not #1 n3(notresult31, result31);
	and #1 a1(w1, notresult31, b31);
	and #1 a2(w2, w1, a31);
	and #1 a3(w3, result31, notb31);
	and #1 a4(w4, w3, nota31);
	or #1 o1(out, w2, w4);
endmodule

module alu(result, cout, zero, set, overflow, a, b, op);
	input [31:0] a, b;
	input [2:0] op;
	output [31:0] result;
	output cout, zero, overflow, set;
	wire[31:0] andout, orout, bin, bin2, addout, subout;
	wire cout1;
	andfull a1(andout, a, b); 
	orfull o1(orout, a, b);   
	submuxfull s1(bin, op[2], b);
	cla c1(addout, cout, a, bin, op[2]);
	zero z1(zero, addout);
	buf b1(set, addout[31]);
	overflow of1(overflow, a[31], b[31], addout[31]);
	alumuxfull amux(result, andout, orout, addout, 1'b0, op[1:0]);
endmodule

module tb();
	// inputs to DUT are reg
	parameter MAX_32 = 2147483647;
	// parameter MAX_32 = 10;
	parameter MIN_32 = -2147483648;
	reg signed [31:0] a, b;
	reg [2:0] op;
	reg [31:0] i;
	// outputs from DUT are wire
	wire signed [31:0] result;
	wire cout, zero, overflow, set;
	// instantiate DUT
	alu a1(result, cout, zero, set, overflow, a, b, op);
	initial
	begin
		$monitor($time,,"a= %d b= %d op= %b result= %d of= %b set= %b cout= %b zero= %b",
						 a,b,op,result,overflow,set,cout, zero);

		// AND result = 311608
		#50 a = 512312;
			b = 312312;
			op = 3'b000;
		// OR result = 513016
		#50 a = 512312;
			b = 312312;
			op = 3'b001;
		// ADD result = 8210834
		#50 a = MAX_32;
			b = 318902;
			op = 3'b010;
		// SUB result = 7573030 
		#50 a = 7891932;
			b = 318902;
			op = 3'b110;
		// BEQ
		#50 a = 65512;
			b = 65512;
			op = 3'b100;
		// SLT
		#50 a = -123213;
			b = 412412;
			op = 3'b111;	
	end

endmodule





