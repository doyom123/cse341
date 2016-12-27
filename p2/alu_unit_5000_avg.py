#!/usr/bin/python
######################################
# alu_unit_5000_avg.py 				 #
# Average time of delay              #
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

def main():
	call('iverilog -t vvp alu_unit_5000.v -o alu_unit_5000', shell=True)
	avg = check_output('./alu_unit_5000')

	lines = avg.splitlines()
	prev_time = 20
	line_count = 0
	times = []
	success = True
	start_time = 0
	end_time = 0

	prev_i = 0

	for line in lines[2:]:
		currLine = line.split()
		time = int(currLine[0])
		i = int(currLine[2])

		try:
			result = int(currLine[10])
		except ValueError:
			result = 0
		
		if i == prev_i:
			end_time = time
		else:
			diff = end_time - start_time

			if diff < 0:
				times.append(1)
			elif diff == 0:
				pass
			else:
				times.append(diff)
			start_time = time
		prev_i = i
		
	# Print Summary
	print ''
	print '________alu_unit_5000.v'
	print len(times), 'tests run'
	print 'Total Time = ', sum(times)
	print 'Average Time =', float(sum(times))/len(times)

if __name__ == '__main__':
	main()