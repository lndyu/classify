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
	bge s7 s1 outer_loop_end 
    jal inner_loop_start
    addi s7 s7 1
    slli t0 s2 2
    add s0 s0 t0
    j outer_loop_start



inner_loop_start:
	bge s8 s4 inner_loop_end #break if all values have been looked at
    slli t0 s8 2 #incrememnt value is index * 4
    add a0 s0 x0
    add a1 s3 t0 #add incrememnt to pointer to m1
    add a2 s2 x0 #load stride
    addi a3 x0 1
    add a4 s5 x0
    
    addi sp sp -4 #save ra
    sw ra 0(sp)
    
    jal dot
    
    lw ra 0(sp)
    addi sp sp 4 #load ra
    
    sw a0 0(s6) #put result into array
    addi s6 s6 4 #increment array index
    addi s8 s8 1 #increment counter
    j inner_loop_start
    
    
inner_loop_end:
	add s8 x0 x0
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
