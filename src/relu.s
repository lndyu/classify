.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# ==============================================================================
relu:
    # Prologue
    bge x0 a1 error
    j loop_start

error:
	addi a1 x0 57
    call exit2

loop_start:
    bge x0 a1 loop_end
    lw t0 0(a0)
	bge t0 x0 loop_continue
    sw x0 0(a0)
    j loop_continue



loop_continue:
    addi a1 a1 -1
    addi a0 a0 4
    j loop_start


loop_end:


    # Epilogue


	ret
