from subprocess import call, check_output
import re

call('iverilog -t vvp alu_zero.v', shell=True)
avg = check_output('./a.out')

total_time = 0.0
line_count = 1

lines = avg.splitlines()
for line in lines:
	#Get time
	total += int(re.search(r'\d+',line).group())
	line_count += 1

print(avg)

print(total)
print(line_count)
print(total / line_count)