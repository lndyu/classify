.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 59
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 59
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 59
# =======================================================
matmul:
	bge x0 a1 error
    bge x0 a2 error
    bge x0 a4 error
    bge x0 a5 error
    bne a2 a4 error
    # Error checks
    
    #saving s0-s6 so I can restore them later.
    addi sp sp -40
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw ra 36(sp)
    
    add s0 x0 a0 #s0 becomes pointer to m0
    add s1 x0 a1 #s1 becomes # of rows in m0
    add s2 x0 a2 #s2 becomes # of columns in m0
    add s3 x0 a3 #s3 becomes pointer to m1
    add s4 x0 a4 #s4 becomes # of rows in m1
    add s5 x0 a5 #s5 becomes # of columns in m1
    add s6 x0 a6 #s6 becomes pointer to start of d
    add s7 x0 x0 #s7 becomes the number of rows traversed
    add s8 x0 x0 #s8 becomes number of columns traversed
	
    j outer_loop_start
    # Prologue


error:
	addi a1 x0 59
    call exit2

outer_loop_start:
	bge s7 s1 outer_loop_end #when we look at all the rows, break
    jal inner_loop_start #call inner loop
    addi s7 s7 1 #increment the index for the current row
    slli t0 s2 2 #get to the index of the first element in the next row of m0
    add s0 s0 t0 #first element of next row of m0
    j outer_loop_start



inner_loop_start:
	bge s8 s5 inner_loop_end #break if all values have been looked at
    add a0 s0 x0 #first element of the current row
    add a1 s3 x0 #current element in second matrix
    add a2 s2 x0 #load number of elements
    addi a3 x0 1 #stride of first matrix is 1
    add a4 s5 x0 #stride of second matrix is the number of columns
    
    addi sp sp -4
    sw ra 0(sp)
    jal ra dot
    lw ra 0(sp)
    addi sp sp 4
    
    sw a0 0(s6) #put result into array
    addi s6 s6 4 #increment array index
    addi s3 s3 4 #increment array pointer
    addi s8 s8 1 #increment counter
    j inner_loop_start
    
    
inner_loop_end:
	slli t0 s5 2
    sub s3 s3 t0
	add s8 x0 x0 #turn the current column back to 0
	jr ra


outer_loop_end:
	#restore all the s values
    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw ra 36(sp)
	addi sp sp 40

    # Epilogue
    ret
