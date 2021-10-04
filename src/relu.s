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
    bge a1 x0 error
    lw a2 0(a0)
    j loop_start

error:
    call exit2

loop_start:
    bge a1 zero loop_end
	bge a2, 1, loop_continue
	sub a2, x0, a2
    j loop_continue



loop_continue:
    addi a1 a1 -1
    sw a2 0(a0)
    addi a0 a0 4
    j loop_start


loop_end:


    # Epilogue


	ret
