#!/bin/sh
Orange='\033[1;33m'
Cyan='\033[1;36m'
Green='\033[1;32m'
Red='\033[1;31m'
NoC='\033[0m' # No Color


printf "${Orange}Welcome to Momen Bazzar and Ameer Bazzar Stack\nYou can save, edit, evaluate elements${Cyan}\n"

printf "press 1 if u want to read from data.txt file\n"
printf "press 2 if u want to read from terminal\n"

# reader is a variable to check where to read commands from
reader=
printf ">> "
read -r reader

cp data.txt /tmp/datatemp.txt # we copy data to a temp file so we don't change anythig on the main file

while [ "$reader" != '1' -a "$reader" != '2' ]
do
	printf "press 1 if u want to read from data.txt file\n"
	printf "press 2 if u want to read from terminal\n"
	reader=
	printf ">> "
	read -r reader
done
# if the user reach this line that means he chose a valid data input

command="" # a variable to save every command

displayList() # this function displays the list of valid commands when needed
{
	# here we tell the user what are the valid commands
	printf "\n${Cyan}The allowed Commands are:\n" # change the color to Cyan
	printf "Integer\t: Any Unsigned Integer Number\n"
	printf "   +\t: To do arithmetic addition to the top 2 numbers in the stack\n"
	printf "   &\t: To do the AND oparation to the top 2 numbers in the stack\n"
	printf "   |\t: To do the OR oparation to the top 2 numbers in the stack\n"
	printf "   ^\t: To do the XOR oparation to the top 2 numbers in the stack\n"
	printf "   s\t: To Swap the top 2 elements in the stack\n"
	printf "   d\t: To delete the top element in the stack\n"
	printf "   e\t: To evaluate above commands if they are the top element of stack\n"
	printf "   u\t: To undo the last evaluated command\n"
	printf "   p\t: To print all elements in the stack\n"
	printf "   c\t: To clear the stack\n"
	printf "   x\t: To exit the Program${NoC}\n" # after that we don't need colors
}

displayList

while true
do
	if [ "$reader" = "1" ]
	then
		command=$(sed -n '1p' /tmp/datatemp.txt)
		sed -i '1d' /tmp/datatemp.txt
		if [ -z "$command" ]
		then
			printf "${Orange}there is no more elements in your file\n you will start reading from terminal now${NoC}\n"
			reader="2"
			printf "> " 
			read -r command
		fi
			
	else if [ "$reader" = "2" ]
	then
		printf "> " # Every command starts with this symbol >
		read -r command # -r is used to read the command in the same line as the symbol >
	fi
	fi
	
	echo "$command" | grep -q "^[0-9]*$"
	validNum="$?" # if the command is integer then validNum is 0, else it's 1
	
	# now we check if the input command is a valid command or not
	while  ! [ "$command" = '+' -o "$command" = '&' -o "$command" = '|' -o "$command" = '^' -o "$command" = 's' -o "$command" = 'e' -o "$command" = 'p' -o "$command" = 'd' -o "$command" = 'x' -o "$command" = 'u' -o "$command" = 'c' -o "$validNum" -eq 0 ]
	do
        	displayList
		if [ "$reader" = '1' ]
		then
			command=$(sed -n '1p' /tmp/datatemp.txt)
			sed -i '1d' /tmp/datatemp.txt
		else if [ "$reader" = '2' ]
		then
			printf "> " # Every command starts with this symbol >
			read -r command # -r is used to read the command in the same line as the symbol >
		fi
		fi
        	echo "$command" | grep -q "^[0-9]*$"
         	validNum="$?"
	done
	
	# if the user reach this line that mean he input a valid command
	# we add the command to the stack elements
      	echo "$command" >> stack.txt
      	
      	# now we check if the user input e to evaluate the top of the stack
  	if [ "$command" = 'e' ]
  	then
  		# first we print the stack with e command inside it
		lines=$(wc -l stack.txt | cut -d' ' -f1 )
		while [ "$lines" -ne 0 ]
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "\n"
		
		sed -i '$d' stack.txt # remove the top element from the stack (e)
		cat /dev/null > /tmp/stack2.txt # make the backup stack emply
		cp stack.txt /tmp/stack2.txt # copy the stack to the backup stack
		var1=$(tail -1  stack.txt ) # var1 is the top element of the stack
		
		# now we check if the top element is evaluatable or not
		case "$var1"
			in
			"+" )	# do addition if possible
				sed -i '$d' stack.txt # remove the top element from the stack (+)
                      		number1=$(tail -1  stack.txt ) # number1 is the top element of the stack
                      		echo "$number1" | grep -q "^[0-9]*$"
                      		valid1="$?" # if number1 is integer then valid1 is 0, else it's 1
                     		sed -i '$d' stack.txt # remove the top element from the stack (number1)
                     		
                     		# same happens with number2
                    		number2=$(tail -1  stack.txt )
                    		echo "$number2" | grep -q "^[0-9]*$"
                    		valid2="$?"
                    		sed -i '$d' stack.txt
                    		
                      		if [ "$valid1" = 0 -a "$valid2" = 0 -a ! -z  "$number2" ]
                      		then 
                      			# if number1 and number2 are valid numbers and not null values we do the addition
                         		result=$(expr $number1 + $number2)
                           		echo "$result" >> stack.txt # we add the result to the stack elements
                     		elif [ "$valid1" != 0 -o "$valid2" != 0 ]
                     		then
                     			# if element1 or 2 on the stack are not integers return stack to backup
                     			printf "${Red}Make sure the first and second elements after + are integers${NoC}\n"
                          		cp /tmp/stack2.txt stack.txt
                   		elif [ -z "$number2" ]
                   		then
                   			# if there is not enough commands to use the addition on return stack to backup
                   			printf "${Red}Make sure you have at least 2 numbers after + in stack${NoC}\n"
                        		cp /tmp/stack2.txt stack.txt
                   		fi;;
                   	"&" )	# do logical AND if possible
				sed -i '$d' stack.txt # remove the top element from the stack (&)
                      		number1=$(tail -1  stack.txt ) # number1 is the top element of the stack
                      		echo "$number1" | grep -q "^[0-9]*$"
                      		valid1="$?" # if number1 is integer then valid1 is 0, else it's 1
                     		sed -i '$d' stack.txt # remove the top element from the stack (number1)
                     		
                     		# same happens with number2
                    		number2=$(tail -1  stack.txt )
                    		echo "$number2" | grep -q "^[0-9]*$"
                    		valid2="$?"
                    		sed -i '$d' stack.txt
                    		
                      		if [ "$valid1" = 0 -a "$valid2" = 0 -a ! -z  "$number2" ]
                      		then 
                      			# if number1 and number2 are valid numbers and not null values we do the operation
                         		result=$(( $number1 & $number2 ))
                           		echo "$result" >> stack.txt # we add the result to the stack elements
                     		elif [ "$valid1" != 0 -o "$valid2" != 0 ]
                     		then
                     			# if element1 or 2 on the stack are not integers return stack to backup
                     			printf "${Red}Make sure the first and second elements after & are integers${NoC}\n"
                          		cp /tmp/stack2.txt stack.txt
                   		elif [ -z "$number2" ]
                   		then
                   			# if there is not enough commands to use the AND on, return stack to backup
                   			printf "${Red}Make sure you have at least 2 numbers after & in stack${NoC}\n"
                        		cp /tmp/stack2.txt stack.txt
                   		fi;;
                   		
                   	"|" )	# do logical OR if possible
				sed -i '$d' stack.txt # remove the top element from the stack (|)
                      		number1=$(tail -1  stack.txt ) # number1 is the top element of the stack
                      		echo "$number1" | grep -q "^[0-9]*$"
                      		valid1="$?" # if number1 is integer then valid1 is 0, else it's 1
                     		sed -i '$d' stack.txt # remove the top element from the stack (number1)
                     		
                     		# same happens with number2
                    		number2=$(tail -1  stack.txt )
                    		echo "$number2" | grep -q "^[0-9]*$"
                    		valid2="$?"
                    		sed -i '$d' stack.txt
                    		
                      		if [ "$valid1" = 0 -a "$valid2" = 0 -a ! -z  "$number2" ]
                      		then 
                      			# if number1 and number2 are valid numbers and not null values we do the operation
                         		result=$(( $number1 | $number2 ))
                           		echo "$result" >> stack.txt # we add the result to the stack elements
                     		elif [ "$valid1" != 0 -o "$valid2" != 0 ]
                     		then
                     			# if element1 or 2 on the stack are not integers return stack to backup
                     			printf "${Red}Make sure the first and second elements after | are integers${NoC}\n"
                          		cp /tmp/stack2.txt stack.txt
                   		elif [ -z "$number2" ]
                   		then
                   			# if there is not enough commands to use the OR on, return stack to backup
                   			printf "${Red}Make sure you have at least 2 numbers after | in stack${NoC}\n"
                        		cp /tmp/stack2.txt stack.txt
                   		fi;;
                   		
                   	"^" )	# do logical OR if possible
				sed -i '$d' stack.txt # remove the top element from the stack (|)
                      		number1=$(tail -1  stack.txt ) # number1 is the top element of the stack
                      		echo "$number1" | grep -q "^[0-9]*$"
                      		valid1="$?" # if number1 is integer then valid1 is 0, else it's 1
                     		sed -i '$d' stack.txt # remove the top element from the stack (number1)
                     		
                     		# same happens with number2
                    		number2=$(tail -1  stack.txt )
                    		echo "$number2" | grep -q "^[0-9]*$"
                    		valid2="$?"
                    		sed -i '$d' stack.txt
                    		
                      		if [ "$valid1" = 0 -a "$valid2" = 0 -a ! -z  "$number2" ]
                      		then 
                      			# if number1 and number2 are valid numbers and not null values we do the operation
                         		result=$(( $number1 ^ $number2 ))
                           		echo "$result" >> stack.txt # we add the result to the stack elements
                     		elif [ "$valid1" != 0 -o "$valid2" != 0 ]
                     		then
                     			# if element1 or 2 on the stack are not integers return stack to backup
                     			printf "${Red}Make sure the first and second elements after ^ are integers${NoC}\n"
                          		cp /tmp/stack2.txt stack.txt
                   		elif [ -z "$number2" ]
                   		then
                   			# if there is not enough commands to use the OR on, return stack to backup
                   			printf "${Red}Make sure you have at least 2 numbers after ^ in stack${NoC}\n"
                        		cp /tmp/stack2.txt stack.txt
                   		fi;;
                   		
			"d" )	# delete the d and the element after it
				cp stack.txt /tmp/stack2.txt # if the user wants undo later
				sed -i '$d' stack.txt
                      		sed -i '$d' stack.txt;;
               
			"s" )	# swap the top 2 elements if possible
				sed -i '$d' stack.txt # remove the top element from the stack (s)
				line1=$(tail -1  stack.txt) # line1 is the top element of the stack
				sed -i '$d' stack.txt # remove the top element from the stack (line1)
				line2=$(tail -1  stack.txt) # line2 is the top element of the stack
				sed -i '$d' stack.txt # remove the top element from the stack (line2)
				if [ -z  "$line2" ]
				then
					# if line2 is null then we can not do swap
					printf "${Red}Make sure you have at least 2 elements after s in stack${NoC}\n"
					cp /tmp/stack2.txt stack.txt
                    		else
                    			# else we add line1 and line2 swaped to stack
                    			echo "$line1" >> stack.txt
                    			echo "$line2" >> stack.txt
              			fi;;
         	esac
         	
         	# print the result stack here
         	printf "\n${Green}Your Stack is: "
		
		# print the stack after removing p
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "${NoC}\n"
	fi
	
	# if the user input u to undo the last thing he evaluated
	if [ "$command" = 'u' -a "$reader" = '2' ]
	then
		# print the stack before undo
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		sed -i '$d' stack.txt # remove the top element from the stack (u)
		
		# here we swap the default stack with the backup stack so the next undo can redo the command
		cp stack.txt temp
		cp /tmp/stack2.txt stack.txt
		cp temp /tmp/stack2.txt
		
		# print the stack after undo
		printf "\n${Green}Your stack is: "
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "${NoC}\n"
	fi
	
	if [ "$command" = 'u' -a "$reader" = '1' ]
	then
		printf "can't use undo command from file\n"
		sed -i '$d' stack.txt # remove the top element from the stack (u)
	fi
	
	# if the user input p to print the stack
	if [ "$command" = 'p' ]
	then
		# print the stack before removing p
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "\n${Green}Your Stack is: "
		sed -i '$d' stack.txt # remove the top element from the stack (p)
		
		# print the stack after removing p
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "${NoC}\n"
	fi
	
	# if the user input x to end the the program 
	if [ "$command" = 'x' ]
	then     
		printf "${Green}Your stack is: "
		sed -i '$d' stack.txt # remove the top element from the stack (x)
		
		# print the stack
         	lines=$(wc -l stack.txt | cut -d' ' -f1 ) # to get the number of lines in stack file
		while [ "$lines" -ne 0 ] # while loop to print every line of the stack
		do
			line=$(sed -n "$lines"p stack.txt)
			printf "%s " $line
			lines=$(expr $lines - 1)
		done
		printf "\n${Green}Thanks for using the program${NoC}\n"
		exit 0
	fi
	
	# if the user input c to claer the stack
	if [ "$command" = 'c' ]
	then
		cat /dev/null > stack.txt # this will make the stack file empty
		printf "${Orange}Your stack is empty now${NoC}\n"  
	fi        
done
