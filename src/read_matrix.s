.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 89
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 90
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91
# ==============================================================================
read_matrix:
	addi sp sp -16
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw ra 12(sp)
    
    add s0 a0 x0
    add s1 a1 x0
    add s2 a2 x0
    # Prologue
    
    #open file
    add a1 s0 x0
    add a2 x0 x0
    
    jal ra fopen
    
    #check to make sure descriptor != -1
    addi t0 x0 -1
    beq a0 t0 error89
    add s0 a0 x0 # s0 is now the file descriptor
    
    #allocate 4 bytes for length, fread, and store value
    
    #fread 4 bytes
    add a1 s0 x0
    add a2 s1 x0
    addi a3 x0 4
    
    jal ra fread
    
    addi t0 x0 4
    bne a0 t0 error91
    
    #allocate 4 bytes for width, fread, and store value
    
    #fread 4 bytes
    add a1 s0 x0
    add a2 s2 x0
    addi a3 x0 4
    
    jal ra fread
    
    addi t0 x0 4
    bne a0 t0 error91
    
    #using length and wdith, read rest of file
    
    lw t0 0(s1)
    lw t1 0(s2)
    
	mul a0 t0 t1
    slli a0 a0 2
    jal ra malloc
    beq a0 x0 error88 #a0 is now the new memory address for the rest of the matrix
    
    lw t0 0(s1)
    lw t1 0(s2)
    mul t0 t0 t1
    
    #fread lxw bytes
    add a1 s0 x0
    add a2 a0 x0
    slli a3 t0 2
    
    addi sp sp -4
    sw a2 0(sp) # store memory pointer into stack
    
    jal ra fread
    
    lw t0 0(s1)
    lw t1 0(s2)
    mul t0 t0 t1
    slli t0 t0 2
    bne a0 t0 error91
    
    #store everything correctly and close
    add a1 s0 x0
    jal ra fclose
    
    bne a0 x0 error90
    lw a0 0(sp)
    addi sp sp 4


    # Epilogue
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw ra 12(sp)
	addi sp sp 16

    ret

error88:
	addi a1 x0 88
    call exit2
error89:
	addi a1 x0 89
    call exit2
error90:
	addi a1 x0 90
    call exit2
error91:
	addi a1 x0 91
    call exit2
