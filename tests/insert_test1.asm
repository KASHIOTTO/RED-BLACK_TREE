.data
# testing msg if node search found or did not find something
node_found_msg: .asciiz "Node found\n"
not_found_msg:  .asciiz "Not found\n"
pointer_msg:  .asciiz " Is at Address: 0x"


#base
#       8
#   5       15
#         12  19
#        9 13  23
#expected
#       12B
#   8R       15R
#  5B 9B    13B 19B
#     10R         23R

# Level 4 leaves
node9: .word 9, 0, 0, 1, node12 # red leaf
node13: .word 13, 0, 0, 1, node12 # red leaf
node23: .word 23, 0, 0, 1, node19 # red leaf

# Level 3 internal
node12: .word 12, node9, node13, 0, node15 # black leaf
node19: .word 19, 0, node23, 0, node15 # black leaf

# Level 2 internal
node5: .word 5, 0, 0, 0, root # black internal node
node15: .word 15, node12, node19, 1, root # red internal node

# Level 1 (root)
root: .word 8, node5, node15, 0, 0 # root, MUST be black

.text
.globl main
# Function: main
main:
    la $a0, root
    jal print_tree

    la $a0, root
    li $a1, 10
    jal insert_node

    move $s6 $v0

    li $v0, 4
    la $a0, extra_newline
    syscall

    move $a0, $s6 
    jal print_tree

    li $v0, 4
    la $a0, extra_newline
    syscall

    la $a0, root
    li $a1, 2
    jal search_node

    li $t1, -1
    beq $v0, $t1, search_not_found

    move $s0, $v0 # save found node pointer

    li $v0, 4
    la $a0, node_found_msg
    syscall

    lw $t0, 0($s0)
    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, pointer_msg
    syscall

    li $v0,34 #print hex value
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    j debug_done

search_not_found:
    li $v0, 4
    la $a0, not_found_msg
    syscall

debug_done:
    # Exit program
    li $v0, 10
    syscall


.data
.asciiz "This is Professor Benz's extra space that is being used for preserving memory contents to avoid losing data"
# The below file will contain your print and insert functions
.include "../hw4.asm"

