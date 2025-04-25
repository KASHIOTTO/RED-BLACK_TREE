.data
# testing msg if node search found or did not find something
node_found_msg: .asciiz "Node found\n"
not_found_msg:  .asciiz "Not found\n"
pointer_msg:  .asciiz " Is at Address: 0x"


# for testing purposes only with prebuilt tree (since dont have insert yet) (bottom-up)
# Level 3 leaves
node1: .word 1, 0, 0, 0, node3 # black leaf
node4: .word 4, 0, 0, 0, node3 # black leaf
node6: .word 6, 0, 0, 0, node8 # black leaf
node9: .word 10, 0, 0, 0, node8 # black leaf

# Level 2 internal
node3: .word 3, node1, node4, 1, root # red internal node
node8: .word 8, node6, node9, 1, root # red internal node

# Level 1 (root)
root: .word 5, node3, node8, 0, 0# root, MUST be black

.text
.globl main
# Function: main
main:
    la $a0, root
    jal print_tree

    li $v0, 4
    la $a0, extra_newline
    syscall

    la $a0, root
    li $a1, 1 #  Found: 1,3,4,5,6,8,9 | Not Found: Any ℤ ∉ Found
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

    j search_done

search_not_found:
    li $v0, 4
    la $a0, not_found_msg
    syscall

search_done:
    li $v0, 10
    syscall


.data
.asciiz "This is Professor Benz's extra space that is being used for preserving memory contents to avoid losing data"
# The below file contains your search and print functions
.include "../hw4.asm"

