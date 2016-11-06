from subprocess import call, check_output
import re

ops = {'000':'&', '001':'|', '010':'+',\
	   '100':'&', '101':'|', '110':'-',\
	   '011':'@', '111':'@'}

call('iverilog -t vvp alu_zero.v', shell=True)
avg = check_output('./a.out')

lines = avg.splitlines()
for line in lines[1:]:
	currLine = line.split();
	i = int(currLine[2])
	a = int(currLine[4])
	b = int(currLine[6])
	op = currLine[8]
	result = int(currLine[10])
	of = currLine[12]
	set = currLine[14]
	cout = currLine[16]

	if(op == '000'):
		result_t = a & b
	elif(op == '001'):
		result_t = a | b
	elif(op == '010'):
		result_t = a + b
	elif(op == '100'):
		result_t = a & (-1*b)
	elif(op == '101'):
		result_t = a | (-1*b)
	elif(op == '110'):
		result_t = a - b
	else:
		result_t = result

	if result==result_t:
		print 'O',
		print a, ops[op], b, '=', result, '=', result_t, '\n'

	else:
		print 'X'
		print a, ops[op], b, '=', result, '=', result_t, '\n'
	
