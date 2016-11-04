// 1 bit adder
module fulladder(sum, cout, a, b, cin);
	input a, b, cin;
	output sum, cout;

	wire w1, w2, w3;
	xor x1(w1, a, b),
		x2(sum, w1, cin);

	and a1(w2, w1, cin),
		a2(w3, a, b);
	or o1(cout, w2, w3);
endmodule

// 4 bit carry look ahead block
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
	and a0(g[0], a[0], b[0]),
		a1(g[1], a[1], b[1]),
		a2(g[2], a[2], b[2]),
		a3(g[3], a[3], b[3]);
	or  o0(p[0], a[0], b[0]),
		o1(p[1], a[1], b[1]),
		o2(p[2], a[2], b[2]),
		o3(p[3], a[3], b[3]);
	and a4(gp0, g[0], p[1]);
	or  o4(gp1, gp0, g[1]);
	and a5(gp2, gp1, p[2]);
	or  o5(gp3, gp2, g[2]);
	and a6(gp4, gp3, p[3]);
	or  o6(gpout, gp4, g[3]);
	//Propate
	and a7(p0, p[0], p[1]),
		a8(p1, p0, p[2]),
		a9(pout, p1, p[3]);
	//cout = g+p*cin
	and a10(c0, cin, pout);
	or  o7(cout, gpout, c0);


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

module tb();
	// inputs to DUT are reg
	reg[31:0] a, b;
	reg cin;
	reg i,j;
	// outputs from DUT are wire
	wire[31:0] sum;
	wire cout;
	// instantiate DUT
	cla c(sum, cout, a, b, cin);
	initial
	begin
		$monitor($time,,"a=%d, b=%d, c=%b, s=%d, cout=%b", a, b, cin, sum, cout);
		$display($time,,"a=%d, b=%d, c=%b, s=%d, cout=%b", a, b, cin, sum, cout);
		for(a=0; a < 1000; a=a+1) begin
			for(b=0; b < 1000; b=b+1)
				#20 cin = 0;
		end
		#20
		$display($time,,"a=%d, b=%d, c=%b, s=%d, cout=%b", a, b, cin, sum, cout);
	end
endmodule





