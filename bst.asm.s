### AUTHOR: Chance Krueger
### 
### DESCRIPTION: The program in the file bst implements basic operations on a Binary Search Tree 
### (BST) in MIPS assembly language. It includes functions to initialize a BST node (bst_init_node), 
### search for a key in the tree (bst_search), count the total number of nodes (bst_count), delete a 
### node from the tree (bst_delete), and traverse the tree in-order and pre-order (bst_in_order_traversal 
### and bst_pre_order_traversal). The program uses recursion and basic branching to perform these operations, 
### manipulating pointers and keys within a binary tree structure. The code also includes appropriate stack 
### handling and function epilogues to ensure correct execution in the MIPS environment.
###


# void bst_init_node(BSTNode *node, int key)
# {
#	node->key = key;
#	node->left = NULL;
#	node->right = NULL;
# }
## REGISTERS:
## 	$a0 - Holds the base address of the input node (function parameter).
## 	$a1 - Holds the key to initialize the node with (function parameter).
## 	$t0 - Temporary register to hold the address of the node.
## 	$t1 - Temporary register to hold the key value.
## 	$zero - Used to initialize the left and right child pointers to NULL.
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.

.globl  bst_init_node

 bst_init_node: 
 
	# PROLOGUE
	addiu $sp, $sp, -24
	sw    $ra, 4($sp)
	sw    $fp, 0($sp)
	addiu $fp, $sp, 20
	
	
	addi  $t0, $a0, 0				# t0 = &node
	addi  $t1, $a1, 0				# t1 = &key

	
	sw    $t1, 0($t0)				# t1(node->key) = key
	
	sw    $zero, 4($t0)				# node->left = NULL;
	sw    $zero, 8($t0)				# node->right = NULL;
	
	
	# Epilogue
	lw    $ra, 4($sp)         			# Restore return address
	lw    $fp, 0($sp)         			# Restore frame pointer
	addiu $sp, $sp, 24        			# Clean up the stack
	jr    $ra                 			# Return

	

# BSTNode *bst_search(BSTNode *node, int key)
# {
#	BSTNode *cur = node;
#	while (cur != NULL)
#	{
#		if (cur->key == key)
#			return cur;
#		if (key < cur->key)
#			cur = cur->left;
#		else
#			cur = cur->right;
#	}	
#	return NULL;
# }	
## REGISTERS:
## 	$a0 - Holds the base address of the input array (function parameter).
## 	$a1 - Holds the length of the array (function parameter).
## 	$t0 - Current node pointer (points to the node being checked).
## 	$t1 - Holds the key of the current node.
## 	$t2 - Temporary register for comparison results.
## 	$v0 - Return value (pointer to the found node or NULL if not found).
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.
	
.globl bst_search

bst_search:

	# PROLOGUE
	addiu $sp, $sp, -24
	sw    $ra, 4($sp)
	sw    $fp, 0($sp)
	addiu $fp, $sp, 20
 
	
	addi  $t0, $a0, 0 				# t0 (*cur) = a0(node)
	
# The while loop in the bst_search function performs a standard binary search in a Binary Search Tree 
# (BST). It starts at the given node (cur) and iterates through the tree, comparing the key with the 
# current node's key. If the key is found, the current node (cur) is returned. If the key is less than 
# the current node's key, the search moves to the left child (cur = cur->left), and if greater, it 
# moves to the right child (cur = cur->right). The loop continues until the key is found or the 
# search reaches a NULL node, returning NULL if the key isn't found. In the assembly code, the loop 
# follows the same logic, using comparison and branching to navigate the tree and search for the key.

WHILE_BST_SEARCH:

	beq   $t0, $zero, RETURN_NULL_IN_SEARCH		# if (t0(cur) == NULL) -> return NULL
	
	lw    $t1, 0($t0)				# t1 (key) = t0(cur->key)
	
	beq   $t1, $a1, RETURN_CUR_IN_SEARCH		# if (t1(key) == a1(key)) -> return cur
	
	slt   $t2, $a1, $t1				# t2 = a1(key) < t1(cur->key) 
	
	bne   $t2, $zero, SEARCH_LEFT_SIDE		# if (a1(key) < t1(cur->key)) -> go left 
	
	j     SEARCH_RIGHT_SIDE				# else -> go right
	

SEARCH_LEFT_SIDE: 	
	
	lw   $t0, 4($t0)				# t0(cur) = cur->left
	
	j     WHILE_BST_SEARCH				# jump back to top of while loop
	
SEARCH_RIGHT_SIDE:
	
	lw   $t0, 8($t0)				# t0(cur) = cur->right
	
	j     WHILE_BST_SEARCH				# jump back to top of while loop
	
RETURN_CUR_IN_SEARCH:

	addi  $v0, $t0, 0				# return t0(*cur)
	
	j     FINISH_SEARCH				# jump to end search
 
 
RETURN_NULL_IN_SEARCH:
	
	addi  $v0, $zero, 0				# return NULL($zero)
 
 
FINISH_SEARCH:
 
	# Epilogue
	lw    $ra, 4($sp)         			# Restore return address
	lw    $fp, 0($sp)         			# Restore frame pointer
	addiu $sp, $sp, 24        			# Clean up the stack
	jr    $ra                 			# Return
	


# int bst_count(BSTNode *node)
# {
#	if (node == NULL)
#		return 0;
#	return bst_count(node->left) + 1 + bst_count(node->right);
# }
			
.globl bst_count

.data

	CUR_COUNT: 	.word 0

.text


bst_count: 
	la    $t2, CUR_COUNT				# t2 = &CUR_COUNT
	sw    $zero, 0($t2)				# CUR_COUNT = 0 (reset)
	
bst_count_start:	

	# PROLOGUE
	addiu $sp, $sp, -24
	sw    $ra, 4($sp)
	sw    $fp, 0($sp)
	addiu $fp, $sp, 20

	addi  $t0, $a0, 0				# t0 = &a0(node)
	
	addiu $sp, $sp, -4				# save t0 into stack
	sw    $t0, 0($sp)
	
	beq   $t0, $zero, RETURN_ZERO			# if (t0(node) == NULL($zero)) -> return 0
	
	
	lw    $a0, 4($t0)				# node = (node->left)
	
	jal   bst_count_start				# bst_count(node->left)
	
	la    $t2, CUR_COUNT				# t2 = &CUR_COUNT
	lw    $t1, 0($t2)				# t1 = *CUR_COUNT
	addi  $t1, $t1, 1				# CUR_COUNT++
	sw    $t1, 0($t2)				# CUR_COUNT = t1
	
	lw    $t0, 0($sp)				# load back t0 from stack
	addiu $sp, $sp, 4
	
	lw    $a0, 8($t0)				# node = (node->right)
	
	jal   bst_count_start				# bst_count(node->right)
	
	la    $t1, CUR_COUNT				# t1 = &CUR_COUNT
	lw    $t1, 0($t1)				# t1 = *CUR_COUNT
	addi  $v0, $t1, 0				# CUR_COUNT++
	
	j     FINISH_COUNT				# jump to return final count
	
	
RETURN_ZERO:

	addiu $sp, $sp, 4				# get rid of data from stack, since it's NULL

	addi  $v0, $zero, 0				# return 0
	
	
FINISH_COUNT:

	# Epilogue
	lw    $ra, 4($sp)         			# Restore return address
	lw    $fp, 0($sp)         			# Restore frame pointer
	addiu $sp, $sp, 24        			# Clean up the stack
	jr    $ra

# void bst_in_order_traversal(BSTNode *node)
# {
#	if (node == NULL)
#		return;
#	bst_in_order_traversal(node->left);
#	printf("%d\n", node->key);
#	bst_in_order_traversal(node->right);
# }	
## REGISTERS:
## 	$a0 - Holds the base address of the input array (function parameter).
## 	$t0 - Current node pointer.
## 	$t1 - Temporary register to hold the current count value.
## 	$t2 - Temporary register to hold the address of CUR_COUNT.
## 	$v0 - Return value (total count of nodes).
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.

.globl bst_in_order_traversal

.data

	NEW_LINE: 	.asciiz "\n"

.text


bst_in_order_traversal:

	# PROLOGUE
	addiu $sp, $sp, -24
	sw    $ra, 4($sp)
	sw    $fp, 0($sp)
	addiu $fp, $sp, 20
	
	addi  $t0, $a0, 0				# t0(node) = a0(*node)
	
	beq   $t0, $zero, RETURN_NULL_IN_TRAV		# if (t0(node) == NULL) -> return
	
	addiu $sp, $sp, -4
	sw    $t0, 0($sp)				# save t0 into stack
	
	lw    $a0, 4($t0)				# a0(param) = node->left
	
	jal   bst_in_order_traversal			# recursive call
	
		
	lw    $t0, 0($sp)				# t0 = &node
	addiu $sp, $sp, 4
	
	lw    $t1, 0($t0)				# t1(key) = 0(t0) -> node[key]
	
	addi  $v0, $zero, 1
	addi  $a0, $t1, 0				# print_int(key)
	syscall
	
	addi  $v0, $zero, 4
	la    $a0, NEW_LINE				# print_str('\n')
	syscall
	
	lw    $a0, 8($t0)				# a0(param) = node->right
	
	jal   bst_in_order_traversal			# recursive call
	
RETURN_NULL_IN_TRAV:

    	# EPILOGUE
    	lw    $ra, 4($sp)                		# Restore return address
    	lw    $fp, 0($sp)                		# Restore frame pointer
    	addiu $sp, $sp, 24               		# Clean up the stack
    	jr    $ra                        		# Return to caller


# void bst_pre_order_traversal(BSTNode *node)
# {
#	if (node == NULL)
#		return;
#	printf("%d\n", node->key);
#	bst_pre_order_traversal(node->left);
#	bst_pre_order_traversal(node->right);
# }
## REGISTERS:
## 	$a0 - Holds the base address of the input array (function parameter).
## 	$t0 - Current node pointer.
## 	$t1 - Holds the key of the current node.
## 	$v0 - Used for system call codes.
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.

.globl bst_pre_order_traversal

bst_pre_order_traversal:

	# PROLOGUE
	addiu $sp, $sp, -24
	sw    $ra, 4($sp)
	sw    $fp, 0($sp)
	addiu $fp, $sp, 20
	
	addi  $t0, $a0, 0				# t0(node) = a0(*node)
	
	beq   $t0, $zero, RETURN_NULL_PRE_TRAV		# if (t0(node) == NULL) -> return
	
	addiu $sp, $sp, -4				# save t0 into stack
	sw    $t0, 0($sp)
		
	lw    $t1, 0($t0)				# t1(key) = 0(t0) -> node[key]
	
	addi  $v0, $zero, 1
	addi  $a0, $t1, 0				# print_int(key)
	syscall
	
	addi  $v0, $zero, 4
	la    $a0, NEW_LINE				# print_str('\n')
	syscall
	
	lw    $a0, 4($t0)				# a0(param) = node->left
	
	jal   bst_pre_order_traversal			# recursive call
	
		
	lw    $t0, 0($sp)				# t0 = &node
	addiu $sp, $sp, 4
	
	lw    $a0, 8($t0)				# a0(param) = node->right
	
	jal   bst_pre_order_traversal			# recursive call
	
RETURN_NULL_PRE_TRAV:

    	# EPILOGUE
    	lw    $ra, 4($sp)                		# Restore return address
    	lw    $fp, 0($sp)                		# Restore frame pointer
    	addiu $sp, $sp, 24               		# Clean up the stack
    	jr    $ra                     			# Return to caller

# BSTNode *bst_insert(BSTNode *root, BSTNode *newNode)
# {
#	if (root == NULL)
#		return newNode;
#	if (newNode->key < root->key)
#		root->left = bst_insert(root->left, newNode);
#	else
#		root->right = bst_insert(root->right, newNode);
#	return root;
# }
## REGISTERS:
## 	$a0 - Holds the base address of the root node (function parameter).
## 	$a1 - Holds the base address of the new node to be inserted (function parameter).
## 	$t0 - Holds the key of the root node.
## 	$t1 - Holds the key of the new node.
## 	$t2 - Temporary register for comparison results.
## 	$t3 - Temporary register to hold addresses of left or right children.
## 	$v0 - Return value (pointer to the inserted node or the root node).
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.

.globl bst_insert

bst_insert:

    	# PROLOGUE
    	addiu $sp, $sp, -24
    	sw    $ra, 4($sp)
    	sw    $fp, 0($sp)
    	addiu $fp, $sp, 20

CONTINUE_BST_SEARCH:

    	beq   $a0, $zero, RETURN_NEW_IN_SEARCH      	# If root == NULL, return newNode

    	lw    $t0, 0($a0)                           	# Load root->key into $t0
    	lw    $t1, 0($a1)                           	# Load newNode->key into $t1

    	slt   $t2, $t1, $t0                         	# $t2 = (newNode->key < root->key)
    	bne   $t2, $zero, SEARCH_LEFT_SIDE_INSERT   	# If newNode->key < root->key, go left

SEARCH_RIGHT_SIDE_INSERT:

    	lw    $t3, 8($a0)                           	# Load root->right
    	beq   $t3, $zero, INSERT_AT_RIGHT           	# If root->right == NULL, insert newNode
    	addi  $a0, $t3, 0                              	# Else, continue searching on the right
    	j     CONTINUE_BST_SEARCH

SEARCH_LEFT_SIDE_INSERT:

    	lw    $t3, 4($a0)                           	# Load root->left
    	beq   $t3, $zero, INSERT_AT_LEFT            	# If root->left == NULL, insert newNode
    	addi  $a0, $t3, 0                              	# Else, continue searching on the left
    	j     CONTINUE_BST_SEARCH

INSERT_AT_RIGHT:

    	sw    $a1, 8($a0)                           	# root->right = newNode
    	j     EPILOGUE_SEARCH

INSERT_AT_LEFT:

    	sw    $a1, 4($a0)                           	# root->left = newNode
    	j     EPILOGUE_SEARCH

RETURN_NEW_IN_SEARCH:

    	addi  $v0, $a1, 0                           	# Return newNode as the new root

EPILOGUE_SEARCH:

    	# EPILOGUE
    	lw    $ra, 4($sp)                           	# Restore return address
    	lw    $fp, 0($sp)                           	# Restore frame pointer
    	addiu $sp, $sp, 24                          	# Clean up the stack
    	jr    $ra                                   	# Return to caller

# BSTNode *bst_delete(BSTNode *root, int key)
# {
#	if (root == NULL)
#		return NULL;
#
#	if (key < root->key) {
#		root->left = bst_delete(root->left, key);
#		return root;
#	}
#
#	if (root->key < key) {
#		root->right = bst_delete(root->right, key);
#		return root;
#	}
#
#	// delete, case 1: node is a leaf.
#	if (root->left == NULL && root->right == NULL)
#		return NULL;
#
#	// delete, case 2: node has a single child
#	if (root->left == NULL)
#		return root->right;
#	if (root->right == NULL)
#		return root->left;
#
#	// delete, case 3: the node has two children
#	BSTNode *replace = root->right;
#	while (replace->left != NULL)
#		replace = replace->left;
#
#	root->right = bst_delete(root->right, replace->key); // could be changed
#
#	replace->left = root->left;
#	replace->right = root->right;
#
#	return replace;
# }
## REGISTERS:
## 	$a0 - Holds the base address of the root node (function parameter).
## 	$a1 - Holds the key to be deleted (function parameter).
## 	$t0 - Temporary register to hold the address of the current root node.
## 	$t1 - Holds the key of the current root node.
## 	$t2 - Holds the address of the left child of the current root node.
## 	$t3 - Holds the address of the right child of the current root node.
## 	$t4 - Temporary register to hold the address of the replacement node.
## 	$t5 - Temporary register for the left child of the replacement node.
## 	$t6 - Holds the key of the replacement node.
##      $t9 - Temporary register for comparison results.
## 	$v0 - Return value (pointer to the new root node).
## 	$ra - Return address for the function call.
## 	$fp - Frame pointer for stack frame management.

.globl bst_delete

bst_delete:

    	# PROLOGUE
    	addiu $sp, $sp, -24
    	sw    $ra, 4($sp)
    	sw    $fp, 0($sp)
    	addiu $fp, $sp, 20

	beq   $a0, $zero, RETURN_NULL_DELETION 		# if (a0(root) == NULL) -> return NULL
	
	addi  $t0, $a0, 0				# t0 = root
	
	lw    $t1, 0($t0)				# t1 = root's key
	
	lw    $t2, 4($t0)				# t2 = root->left
	lw    $t3, 8($t0)				# t3 = root->right
	
	slt   $t9, $a1, $t1				# t9 = a1(key) < t1(root->key)
	bne   $t9, $zero, CHECK_LEFT_DELETION		# if (key < root->key) -> bst_delete(root->left, key)
	
	slt   $t9, $t1, $a1				# t9 = t1(root->key) < a1(key)
	bne   $t9, $zero, CHECK_RIGHT_DELETION		# if (root->key < key) -> bst_delete(root->right, key)
	
	# delete, case 1: node is a leaf.
	beq   $t2, $zero, CHECK_RIGHT_NULL		# if (t2(root->left) == NULL) -> check right child for NULL
	
	j     INDIVIDUAL_NULLS				# else -> check for individual NULLS
	
CHECK_RIGHT_NULL: 

	bne   $t3, $zero, INDIVIDUAL_NULLS		# if (t3(root->right) != NULL) -> check for individual NULLS
								
	j     RETURN_NULL_DELETION			# else return NULL -> (left && right children == NULL)
	
	
INDIVIDUAL_NULLS:
	
	# delete, case 2: node has a single child.
	beq   $t2, $zero, RETURN_RIGHT_CHILD		# if (t2(root->left) == NULL) -> return root->right
	
	beq   $t3, $zero, RETURN_LEFT_CHILD		# if (t3(root->right) == NULL) -> return root->left
	
	
	# delete, case 3: the node has two children
	
	lw    $t4, 8($t0)				# t4(replace) = root->right

# The while loop in the bst_delete function finds the in-order successor of the node being deleted, which is the 
# smallest node in the right subtree. It starts at the right child of the node to be deleted (replace) and 
# repeatedly moves left (replace = replace->left) until it reaches the leftmost node (i.e., the smallest node). 
# This node will replace the deleted node in the BST to maintain its structure. The loop stops when it finds a node 
# with no left child, signaling the in-order successor.

WHILE_DELETION:

	lw    $t5, 4($t4)				# t5 = replace->left
	
	beq   $t5, $zero, EXIT_WHILE_DELETION		# if (t5(replace->left) == null) -> exit while loop
	
	addi  $t4, $t5, 0				# t4(replace) = replace->left
	
	j     WHILE_DELETION				# jump to top of while loop
	
EXIT_WHILE_DELETION: 
	
	lw    $t6, 0($t4)				# t6 = repalce->key
	
	addi  $a0, $t3, 0				# a0(param0) = root->right
	addi  $a1, $t6, 0				# a1(param1) = repalce->key
	
	addiu $sp, $sp, -28				# save t-registers 0-6 onto stack
	sw    $t0, 0($sp)
	sw    $t1, 4($sp)
	sw    $t2, 8($sp)
	sw    $t3, 12($sp)
	sw    $t4, 16($sp)
	sw    $t5, 20($sp)
	sw    $t6, 24($sp)
	
	jal   bst_delete				# recursive call
	
	lw    $t0, 0($sp)				# load t-registers 0-6 from stack
	lw    $t1, 4($sp)
	lw    $t2, 8($sp)
	lw    $t3, 12($sp)
	lw    $t4, 16($sp)
	lw    $t5, 20($sp)
	lw    $t6, 24($sp)
	addiu $sp, $sp, 28
	
	sw    $v0, 8($t0)				# root->right = bst_delete(root->right, replace->key)

	sw    $t2, 4($t4)				# replace->left = root->left
	sw    $t3, 8($t4)				# replace->right = root->right
	
	addi  $v0, $t4, 0				# return replace
	
	j     EPILOGUE_DELETION				# jump to end of function to epilogue


CHECK_LEFT_DELETION:

	addi  $a0, $t2, 0				# a0(param) = t2(root->left)
	
	addiu $sp, $sp, -28				# save t-registers 0-6 onto stack
	sw    $t0, 0($sp)
	sw    $t1, 4($sp)
	sw    $t2, 8($sp)
	sw    $t3, 12($sp)
	sw    $t4, 16($sp)
	sw    $t5, 20($sp)
	sw    $t6, 24($sp)
	
	jal   bst_delete				# recursive call
	
	lw    $t0, 0($sp)				# load t-registers 0-6 from stack
	lw    $t1, 4($sp)
	lw    $t2, 8($sp)
	lw    $t3, 12($sp)
	lw    $t4, 16($sp)
	lw    $t5, 20($sp)
	lw    $t6, 24($sp)
	addiu $sp, $sp, 28
	
	sw    $v0, 4($t0)				# root->left = bst_delete(root->left, key)
	
	addi  $v0, $t0, 0				# return root
	
	j     EPILOGUE_DELETION				# jump to end of function to epilogue

CHECK_RIGHT_DELETION:

	addi  $a0, $t3, 0				# a0(param) = t2(root->right)

	addiu $sp, $sp, -28				# save t-registers 0-6 onto stack
	sw    $t0, 0($sp)
	sw    $t1, 4($sp)
	sw    $t2, 8($sp)
	sw    $t3, 12($sp)
	sw    $t4, 16($sp)
	sw    $t5, 20($sp)
	sw    $t6, 24($sp)
	
	jal   bst_delete				# recursive call
	
	lw    $t0, 0($sp)				# load t-registers 0-6 from stack
	lw    $t1, 4($sp)
	lw    $t2, 8($sp)
	lw    $t3, 12($sp)
	lw    $t4, 16($sp)
	lw    $t5, 20($sp)
	lw    $t6, 24($sp)
	addiu $sp, $sp, 28
	
	sw    $v0, 8($t0)				# root->right = bst_delete(root->right, key)
	
	addi  $v0, $t0, 0				# return root
	
	j     EPILOGUE_DELETION				# jump to end of function to epilogue
	
RETURN_RIGHT_CHILD:	

	addi  $v0, $t3, 0				# return root->right
	j     EPILOGUE_DELETION				# jump to end of function to epilogue

RETURN_LEFT_CHILD:

	addi  $v0, $t2, 0				# return root->left
	j     EPILOGUE_DELETION				# jump to end of function to epilogue
	
RETURN_NULL_DELETION:
		
	addi  $v0, $zero, 0				# return NULL
	j     EPILOGUE_DELETION				# jump to end of function to epilogue
		
EPILOGUE_DELETION:

	# EPILOGUE
    	lw    $ra, 4($sp)                           	# Restore return address
    	lw    $fp, 0($sp)                           	# Restore frame pointer
    	addiu $sp, $sp, 24                          	# Clean up the stack
    	jr    $ra                                   	# Return to caller