.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

# red-black data
lparen: .asciiz "("
rparen_space: .asciiz ") "
color_red: .asciiz "R"
color_black: .asciiz "B"

.text
.globl print_tree 
.globl search_node
.globl insert_node

# Function: print_tree
# Print all the values and colors with in-order traversal (format: value, left, right, color)
# Arguments: 
#   $a0 - pointer to root
# Returns: void

print_tree:
    # Prologue

print_tree_end:
    # Epilogue
    jr $ra # return

# Function: search_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to find
# Returns:
#   $v0 : -1 if not found, else pointer to node

search_node:
    # Function prologue
	
	
search_node_end:	
	#Function Epilogue
	jr $ra

# Function: insert_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to insert
# Returns: 
#	$v0 - pointer to root

insert_node:
	# Function prologue

insert_node_done:
	#Function Epilogue
    jr $ra