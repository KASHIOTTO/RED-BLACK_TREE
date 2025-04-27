.data
space: .asciiz " "    # Space character for printing between numbers
newline: .asciiz "\n" # Newline character
extra_newline: .asciiz "\n\n" # Extra newline at end

# red-black data
lparen: .asciiz "("
rparen_space: .asciiz ") "
color_red: .asciiz "R"
color_black: .asciiz "B"
#struct{
# value 0-3 bytes
# left_child 4-7 bytes
# rigt_child 8-11 bytes
# color 12-15 bytes 0=black 1=red
# parent_node 16-19 bytes 
# 
# }
#
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
    addi $sp, $sp, -8 #make space for data
    sw $ra, 4($sp) #save return address
    sw $s0, 0($sp) #save $s0 for node*

    beqz $a0, print_tree_end #if NULL do nothing

    move $s0, $a0 #address of 'root'/current node saved into $s0

    #print_tree left
    lw $a0, 4($s0) #arg is now left child pointer
    jal print_tree #run print on left tree first recursively(inorder)

    #print_tree current node value(parentval color)
    #val
    lw $t0, 0($s0) #temp0 is node value
    li $v0, 1 #printing int call set
    move $a0, $t0 #move val into arg 
    syscall #prints
    
    #(
    li $v0, 4 #printing string call set
    la $a0, lparen #arg is now "("
    syscall #prints
    
    #parent val
    lw $t1, 16($s0) #temp1 is now parent pointer
    beqz $t1, print_root_parent #if parent is NULL (root) branch to print '0'

    lw $t2, 0($t1) #temp2 is now parent p
    li $v0, 1 #printing an int 
    move $a0, $t2 #args is now parent val
    syscall #prints
    j print_color #skip special case root parent

print_root_parent:
    li $v0, 1 #printing int
    li $a0, 0 #args is now 0
    syscall #prints

print_color:
    lw $t3, 12($s0) #temp3 is now color
    beqz $t3, node_color_black #if val=0 black 'B'
    li $v0, 4 #RED, printing string 'R'
    la $a0, color_red #args is now 'R'/color
    syscall #prints
    j close_parens #close parens

node_color_black:
    li $v0, 4 #printing a string
    la $a0, color_black #args is now 'B'
    syscall #prints

close_parens:
    li $v0, 4 #printing a string
    la $a0, rparen_space #args is now ") "
    syscall #prints

    #print_tree right 
    lw $a0, 8($s0) #args is now right child pointer
    jal print_tree # run print on right tree first recursively(inorder)

print_tree_end:
    lw $s0, 0($sp) #restore $s0
    lw $ra, 4($sp) #restore $ra
    addi $sp, $sp, 8 #restore stack
    jr $ra #return

# Function: search_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to find
# Returns:
#   $v0 : -1 if not found, else pointer to node

search_node:
    addi $sp, $sp, -4 #space for return address
    sw $ra, 0($sp) # $ra stored

    move $t1, $a0 #arrg 0 now in temp1

search_loop:
    beqz $t1, node_not_found #if Null past leaf

    lw $t0, 0($t1) #temp0 is value of current node
    beq $t0, $a1, node_found #if equal to target found

    blt $a1, $t0, go_left #key < current, then left subtree
    #else key > current = right subtree
    lw $t1, 8($t1) #temp1 is now right child pointer
    j search_loop #search right subtree

go_left:
    lw $t1, 4($t1) #temp1 is now left child
    j search_loop #search left subtree

node_found:
    move $v0, $t1 #$v0 : ...else pointer to node
    j search_node_end #return pointer

node_not_found:
    li $v0, -1 #$v0 : -1 if not found
	
search_node_end:	
	lw $ra, 0($sp) #restoring $ra
    addi $sp, $sp, 4 #closing out stack
    jr $ra #return

# Function: insert_node
# Arguments: 
#   $a0 - pointer to root
#   $a1 - value to insert
# Returns: 
#	$v0 - pointer to root

insert_node:
	addi $sp, $sp, -16 #space for ra, current, parent, new node
    sw $ra, 12($sp) #store return address
    sw $s0, 8($sp) #store s0 address for current node
    sw $s1, 4($sp) #store s1 for parent
    sw $s2, 0($sp) #store s2 for new node

#empty tree
    beqz $a0, new_root #if no root add black root

#normal insert
    move $s0, $a0 #$s0 is at root (current)
    move $s1, $zero #s1 is null (parent)

find_spot: 
    beqz $s0, spot_found #reached null for insertion under parent s1
    move $s1, $s0 #parent = current
    lw $t0, 0($s0) #temp0 is now current value
    blt $a1, $t0, move_left #if insertion value < parent(current) goes left
    #else go right
    lw $s0, 8($s0) #current = right child (current was changed to parent)
    j find_spot #repeat until leaf position
move_left:
    lw $s0, 4($s0) #current = left child
    j find_spot #until leaf position aquired

spot_found: 
    #allocate new node (red)
    li $v0, 9 #sbrk for heap
    li $a0, 20 #20 bytes on heap
    syscall #$v0 return pointer to fresh memory
    move $s2, $v0 #$s2 = new node ptr

    #Initialize fields
    sw $a1, 0($s2) #value = key to insert
    sw $zero, 4($s2) #left = null
    sw $zero, 8($s2) #right = null
    li $t1, 1 #1 for red
    sw $t1, 12($s2) #R red saved
    sw $s1, 16($s2) #parent = $s1 (found above)

    #Link new node under parent
    lw $t0, 0($s1) #t0 = parents value
    blt $a1, $t0, attach_left #choose side
    #is right child
    sw $s2, 8($s1) #parents right child is the new node
    j call_fixup 
attach_left:
    sw $s2, 4($s1) #parents left child is the new node

call_fixup:
    move $a0, $s2 #a0 = new node pointer N
    jal fix_insert #fix RB tree, returns root in v0
    j insert_node_done #done

#tree was empty -> root
new_root:
    li $v0, 9 #sbrk
    li $a0, 20
    syscall #v0 = memory
    move $s0, $v0 #s0 = root ptr

    sw $a1, 0($s0) #value = key
    sw $zero, 4($s0) #left child null
    sw $zero, 8($s0) #right child null
    sw $zero, 16($s0) #no parent = 0
    sw $zero, 12($s0) #black root
    move $v0, $s0 #returning new root
    j insert_node_done #done
     
insert_node_done:
	lw $s2, 0($sp) #restore s2
    lw $s1, 4($sp) #restore s1
    lw $s0, 8($sp) #restore s0
    lw $ra, 12($sp) #restore return address
    addi $sp, $sp, 16 #restore stack
    jr $ra #return

fix_insert: 
    addi $sp, $sp, -8 #make space on stack
    sw $ra, 4($sp) #save return address
    sw $s0, 0($sp) #save s0 for n

    move $s0, $a0 #s0 is N 

fix_loop:
    lw $t0, 16($s0) #t0 = P
    beqz $t0, after_fix #reached root so done
    lw $t1, 12($t0) #parent color
    beqz $t1, after_fix #parent black, good, done

    lw $t2, 16($t0) #t2 = G
    beqz $t2, after_fix #branch if t2 = 0 

    #Determine side of parent relative to grandparent
    lw $t3, 4($t2) #t3 = grandparent left child
    beq $t3, $t0, parent_is_left #if parent is left child

    #parent is right child
    lw $t4, 4($t2) #t4 = U (G's lc)
    beqz $t4, uncle_black_r #if null treat as black
    lw $t5, 12($t4) #t5 = U color
    bnez $t5, case1_r #if U red case 1

uncle_black_r:
    # U is black: 2 and 3
    lw $t6, 4($t0) #check if N lc
    bne $t6, $s0, skip_case2_r #if N rc case 3 ONLY
    #case 2: N is lc, P is rc, rotate right on P
    move $a0, $t0 #rotate around P
    jal right_rotate
    move $s0, $t0 #N now P after rot
    lw $t0, 16($s0) #update P ptr
    lw $t2, 16($t0) #update G ptr
    #beqz $t2, fix_continue
skip_case2_r: 
    lw $t0, 16($s0) #compute parent
    lw $t2, 16($t0) #compute G
    #beqz $t2, fix_continue
    li $t7, 0
    sw $t7, 12($t0) # P is black
    li $t7, 1
    sw $t7, 12($t2) # G is red
    move $a0, $t2 #argument is G
    jal left_rotate
    j fix_continue


case1_r:
    #case 1: P and U both red -> recolor and check G
    li $t7, 0 
    sw $t7, 12($t0) #P now black
    sw $t7, 12($t4) #U now black
    li $t7, 1
    sw $t7, 12($t2) #G is red
    move $s0, $t2 #continue fix with G as N
    j fix_loop

#P is lc of G
parent_is_left:
    lw $t4, 8($t2) #t4 = U rc of G
    beqz $t4, uncle_black_l #null treat as black
    lw $t5, 12($t4) 
    bnez $t5, case1_l #U red -> case 1

uncle_black_l:
    #cases 2/3 mirror right-side logic
    lw   $t6,8($t0) # N rc P?
    bne  $t6,$s0,skip_case2_l
    # Case 2: N is rc, P is lc -> rot left on P
    move $a0,$t0 # rot around P
    jal  left_rotate
    move $s0,$t0 # N <- P
    lw   $t0,16($s0) # refresh P
    lw   $t2,16($t0) # refresh G
    #beqz $t2, fix_continue
skip_case2_l:
    # Case 3: recolor -> rot right on G
    lw $t0, 16($s0) #compute parent
    lw $t2, 16($t0) #compute G
    #beqz $t2, fix_continue
    li $t7, 0
    sw $t7, 12($t0) # P is black
    li $t7, 1
    sw $t7, 12($t2) # G is red
    move $a0, $t2 #argument is G
    jal right_rotate
    j fix_continue

case1_l:
    # Case 1 mirror: recolor and up
    li   $t7,0
    sw   $t7,12($t0)
    sw   $t7,12($t4)
    li   $t7,1
    sw   $t7,12($t2)
    move $s0,$t2 # continue w/ G
    j    fix_loop

fix_continue:
    j fix_loop # again until root or P black

after_fix:
    #root must be black check
    move $t0, $s0 #climb
find_root:
    lw $t1, 16($t0)
    beqz $t1, root_found
    move $t0, $t1
    j find_root
root_found: 
    li $t2, 0
    sw $t2, 12($t0) #force root black
    move $v0, $t0 #return ptr to root

    lw $s0, 0($sp) #restore
    lw $ra, 4($sp) 
    addi $sp, $sp, 8 #restore stack
    jr $ra

#left_rotate
left_rotate:
    addi $sp, $sp, -8 #space on stack
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0 # s0 = x (pivot)
    lw   $t0, 8($s0) # t0 = y = x -> right
    beqz $t0, exit_left # no rot if rc NULL

    # x -> right = y -> left
    lw   $t1, 4($t0) # t1 = y -> left
    sw   $t1, 8($s0) # assign
    beqz $t1, skip_parent_left
    sw   $s0, 16($t1) # y -> left -> parent = x (if exists)
skip_parent_left:
    # y -> parent = x -> parent
    lw   $t2, 16($s0) # t2 = og parent of x
    sw   $t2, 16($t0) # y -> parent = t2

    # Fix grandparent link
    beqz $t2, update_root_left # if x was root for update
    lw   $t3, 4($t2) #G points left or right to x
    beq  $t3, $s0, link_left_left
    sw   $t0, 8($t2) # else G -> right = y
    j    link_done_left
link_left_left:
    sw   $t0, 4($t2) # G -> left = y
link_done_left:

update_root_left:
    # y -> left = x
    sw   $s0, 4($t0)
    sw   $t0, 16($s0) # x -> P = y
    lw $t5, 8($s0)
    beqz $t5, skip_fix_right_child
    sw $s0, 16($t5)
skip_fix_right_child:

exit_left:
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra
#right_rotate
right_rotate:
    addi $sp, $sp, -8 #stack
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)

    move $s0, $a0 # s0 = y
    lw   $t0, 4($s0) # t0 = x = y -> left
    beqz $t0, exit_right # no rot if lc NULL

    # y -> left = x -> right
    lw   $t1, 8($t0) # t1 = x -> right
    sw   $t1, 4($s0)
    beqz $t1, skip_parent_right
    sw   $s0, 16($t1) # x -> right ->  P = y
skip_parent_right:
    # x -> P = y -> P
    lw   $t2, 16($s0) # t2 = G
    sw   $t2, 16($t0) # x -> P = t2

    # Fix G ptr
    beqz $t2, update_root_right
    lw   $t3, 8($t2) # y side
    beq  $t3, $s0, link_right_right
    sw   $t0, 4($t2) # G -> left = x
    j    link_done_right
link_right_right:
    sw   $t0, 8($t2) # G -> right = x
link_done_right:

update_root_right:
    # x -> right = y
    sw   $s0, 8($t0)
    sw   $t0, 16($s0) # y -> parent = x
    lw $t5, 4($s0)
    beqz $t5, skip_fix_left_child
    sw $s0, 16($t5)
skip_fix_left_child:

exit_right:
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra