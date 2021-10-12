.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 89
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 90
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 92
# ==============================================================================
write_matrix:
	#save a bunch of s registers so you can restore them later
    addi sp sp -20
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw ra 16(sp)
    
    #store all of the arguments as s registers
    add s0 a0 x0
    add s1 a1 x0
    add s2 a2 x0
    add s3 a3 x0
    
    # Prologue
    # fopen a new file
    add a1 s0 x0
    addi a2 x0 1
    
    jal ra fopen
    
    addi t0 x0 -1
    beq a0 t0 error89
    
    #store filename descriptor into s0
    add s0 a0 x0
    
    # malloc 4 bytes, insert number of rows, and fwrite that
    addi a0 x0 4
    
    jal ra malloc
    
    sw s2 0(a0)
    #change s2 to the pointer to memory containing number of rows
    add s2 a0 x0
    
    add a1 s0 x0
    add a2 s2 x0
    addi a3 x0 1
    addi a4 x0 4
    
    jal ra fwrite
    
    addi t0 x0 1
    bne a0 t0 error92
    
    
    # malloc 4 bytes, insert number of columns, and fwrite that
    addi a0 x0 4
    
    jal ra malloc
    
    sw s3 0(a0)
    #change s3 to the pointer to memory containing number of columns
    add s3 a0 x0
    
    add a1 s0 x0
    add a2 s3 x0
    addi a3 x0 1
    addi a4 x0 4
    
    jal ra fwrite
    
    addi t0 x0 1
    bne a0 t0 error92
    
    # malloc rxcx4 bytes, insert the data of the matrix
    lw t0 0(s2)
    lw t1 0(s3)
    
    add a1 s0 x0
    add a2 s1 x0
    mul a3 t0 t1
    addi a4 x0 4
    
    jal ra fwrite
    
    lw t0 0(s2)
    lw t1 0(s3)
    mul t0 t0 t1
    
    bne t0 a0 error92
    
    # fclose that shit

	add a1 s0 x0
    
    jal ra fclose
    
    bne a0 x0 error90

    # Epilogue
	# restore all the s registers

    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw ra 16(sp)
    addi sp sp 20

    ret
error89:
	addi a1 x0 89
    call exit2
error90:
	addi a1 x0 90
    call exit2
error92:
	addi a1 x0 92
    call exit2
