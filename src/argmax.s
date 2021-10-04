.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 57
# =================================================================
argmax:
    add t1 x0 x0 #t1 will be the current index
    add t2 x0 x0 #t2 will be the current largest value index
    lw t3 0(a0) #t3 will be the current largest value
    bge x0 a1 error
    j loop_start
    # t1 will be the index we are tracking
    # Prologue

error:
    addi a1 x0 57
    call exit2

loop_start:
    bge t1 a1 loop_end
    lw t4 0(a0)
    bge t3 t4 loop_continue
    add t3 t4 x0
    add t2 t1 x0
    j loop_continue

loop_continue:
    addi t1 t1 1
    addi a0 a0 4
    j loop_start

loop_end:
    add a0 t2 x0

    # Epilogue


    ret
