#!/usr/bin/python
######################################
# alu_zero_tester.py 				 #
# Checks output of testbench results #
######################################
from subprocess import call, check_output
import re

MAX_32 = 2147483647
MIN_32 = -2147483648

ops = {'000':'&',\
	   '001':'|',\
	   '010':'+',\
	   '110':'-',\
	   '100':'BEQ',\
	   '111':'SLT',\
	   '011':'@', '101':'@'}

# checks python int for overflow
def overflow(n):
	if n >= 0:
		return 1 if n > MAX_32 else 0
	else:
		return 1 if n < MIN_32 else 0

# converts python int to int32
def int32(n):
	if n >= 0:
		return -(MAX_32+2) + (n - MAX_32)
	else:
		return -(MIN_32) + (n - MIN_32)

# checks BEQ, zero output to ALU
def zero_t(a, b):
	return 1 if a==b else 0

# checks SLT, set output to ALU
def slt(a, b):
	return 1 if a < b else 0

def main():
	call('iverilog -t vvp alu_zero.v', shell=True)
	avg = check_output('./a.out')
	success = True
	errors = 0
	correct = 0

	lines = avg.splitlines()
	for line in lines[1:]:
		currLine = line.split()
		a = int(currLine[4])
		b = int(currLine[6])
		op = currLine[8]
		result = int(currLine[10])
		of = currLine[12]
		set = int(currLine[14])
		cout = currLine[16]
		zero = int(currLine[18])

		set_t = slt(a,b)
		zerot = zero_t(a,b)

		# AND
		if(op == '000'):
			result_t = a & b
			if result_t != result:
				print 'AND FAIL'
				error += 1
				success = False
			else:
				correct += 1
		# OR
		elif(op == '001'):
			result_t = a | b
			if result_t != result:
				print 'OR FAIL'
				error += 1
				success = False
			else:
				correct += 1
		# ADD
		elif(op == '010'):
			result_t = a + b
			of_t = overflow(result_t)
			if of_t:
				result_t = int32(result_t)
			if result_t != result:
				print 'ADD FAIL'
				error += 1
				success = False
			else:
				correct += 1
		# SUB
		elif(op == '110'):
			result_t = a - b
			of_t = overflow(result_t)
			if of_t:
				result_t = int32(result_t)
			if result_t != result:
				print 'SUB FAIL'
				error += 1
				success = False
			else:
				correct += 1
		# BEQ
		elif(op == '100'):
			if zerot != zero:
				print 'BEQ FAIL'
				error += 1
				success = False
			else:
				correct += 1
		# SLT
		elif(op == '111'):
			result_t = a - b
			of_t = overflow(result_t)
			if of_t:
				set_t = set
				correct += 1
			else:
				if set != set_t:
					print 'SLT FAIL'
					error += 1
					success = False
				else:
					correct += 1

		else:
			result_t = result
			correct += 1

	# Print results
	print ''
	print '________alu_zero.v'
	print len(lines)-1, 'tests run'
	print errors, 'errors'
	print correct, 'correct'
	print 'SUCCESS =', success

if __name__ == '__main__':
	main()
