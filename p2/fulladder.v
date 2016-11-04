// 1 bit adder
module fulladder(a, b, cin, sum, cout);
	input a, b, cin;
	output sum, cout;

	wire w1, w2, w3;
	xor x1(w1, a, b);
		x2(sum, w1, cin);

	and a1(w2, w1, cin);
		a2(w3, a, b);
	or o1(cout, w2, w3);
endmodule;

// 4 bit carry look ahead block
module clablock(a, b, cin, sum, cout);
	input [3:0] a, b;
	input c;
	output [3:0] sum;
	output cout;
	wire [3:0] g, p;
	wire gp0, gp1, gp2, gp3, gp4, gpout;
	wire p0, p1, pout;
	wire c0;
	//Generate
	and a0(g[0], a[0], b[0]);
		a1(g[1], a[1], b[1]);
		a2(g[2], a[2], b[2]);
		a3(g[3], a[3], b[3]);
	or  o0(p[0], a[0], b[0]);
		o1(p[1], a[1], b[1]);
		o2(p[2], a[2], b[2]);
		o3(p[3], a[3], b[3]);
	and a4(gp0, g[0], p[0]);
	or  o4(gp1, gp0, g[1]);
	and a5(gp2, gp1, p[2]);
	or  o5(gp3, gp2, g[2]);
	and a6(gp4, gp3, p[3]);
	or  o6(gpout, gp4, g[3]);
	//Propate
	and a7(p0, p[0], p[1]);
		a8(p1, p0, p[2]);
		a9(pout, p1, p[3]);
	//cout = g+p*cin
	and a10(c0, cin, pout);
	or  o7(cout, gout, c0);


	fulladder f1(sum[0], a[0], b[0]);
	fulladder f2(sum[1], a[1], b[1]);
	fulladder f3(sum[2], a[2], b[2]);
	fulladder f4(sum[3], a[3], b[3]);
endmodule;



