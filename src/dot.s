.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 58
# =======================================================
dot:
    bge x0 a2 exit57
    bge x0 a3 exit58
    bge x0 a4 exit58
    slli a3 a3 2 #a3 is the actual stride of v0
    slli a4 a4 2 #a4 is the actual stride of v1
    add t4 x0 x0 #t3 is our current index
    add t5 x0 x0 #t5 will be our aggregate value. 
    
    j loop_start
    # Prologue

exit57:
	addi a1 x0 57
    call exit2
    
exit58:
	addi a1 x0 58
    call exit2

loop_start:
	bge t4 a2 loop_end
    lw t0 0(a0)
    lw t1 0(a1)
    mul t3 t0 t1
    addi t4 t4 1
    add t5 t5 t3
    add a0 a0 a3
    add a1 a1 a4
    j loop_start

loop_end:
	addi a0 t5 0
    # Epilogue


    ret
