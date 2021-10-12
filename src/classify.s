.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero,
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 72
    # - If malloc fails, this function terminates the program with exit code 88
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
    
    # error for incorrect number of arguments
    addi t0 x0 5
    bne a0 t0 error72
    
	#save a bunch of s registers so you can restore them later
    addi sp sp -52
    sw s0 0(sp)
    sw s1 4(sp)
    sw s2 8(sp)
    sw s3 12(sp)
    sw s4 16(sp)
    sw s5 20(sp)
    sw s6 24(sp)
    sw s7 28(sp)
    sw s8 32(sp)
    sw s9 36(sp)
    sw s10 40(sp)
    sw s11 44(sp)
    sw ra 48(sp)


	#load the arguments into s registers
    # s6 -> a1 -> array of arguments
	# s7 -> a2 -> print or no print (0 means print)
    add s6 x0 a1
    add s7 x0 a2


	# =====================================
    # LOAD MATRICES
    # =====================================
	
    #malloc all the dimensions that we need for the matrices
    
    #malloc 6 different pointers and save them in s registers
    
    #key
	# s0 num of rows in m0
    # s1 num of columns in m0
    # s2 num of rows in m1
    # s3 num of columns in m1
    # s4 num of rows in input matrix
    # s5 num of columns in input matrix
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s0 x0 a0
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s1 x0 a0
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s2 x0 a0
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s3 x0 a0
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s4 x0 a0
    
    addi a0 x0 4
    jal ra malloc
    beq a0 x0 error88
    add s5 x0 a0


    # Load pretrained m0
	lw a0 4(s6)
    add a1 x0 s0
    add a2 x0 s1
    
    jal ra read_matrix
    
    add s8 x0 a0 #m0 stored in s8


    # Load pretrained m1
	lw a0 8(s6)
    add a1 x0 s2
    add a2 x0 s3
    
    jal ra read_matrix
    
    add s9 x0 a0 #m1 stored in s9

    # Load input matrix
	lw a0 12(s6)
    add a1 x0 s4
    add a2 x0 s5
    
    jal ra read_matrix
    
    add s10 x0 a0 #input stored in s10





    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

	#malloc 1 more space for the product and store in s11
    lw t0 0(s0)
    lw t1 0(s5)
    mul t0 t0 t1
    
	slli a0 t0 2
    jal ra malloc
    beq a0 x0 error88
    add s11 x0 a0
    
    # Calculate m0 * input and store it in the malloc data in s11
    
    #store them in registers first
    lw t0 0(s0)
    lw t1 0(s1)
    lw t4 0(s4)
    lw t5 0(s5)
    
	add a0 x0 s8
    add a1 x0 t0
    add a2 x0 t1
    add a3 x0 s10
    add a4 x0 t4
    add a5 x0 t5
    add a6 x0 s11
    
    jal ra matmul
    
    # the product is now stored in s11 and it has the dimensions s0 x s5
    # calculate ReLU(m0 * input)
    
    lw t0 0(s0)
    lw t1 0(s5)
    
    add a0 x0 s11
    mul a1 t0 t1
    
    jal ra relu
    
    # the ReLU(m0 * input) is now stored in s11
    
    #free s1 real quick
	add a0 x0 s1
    jal ra free
    
    #malloc 1 more space for the product and store in s11
    lw t0 0(s0)
    lw t1 0(s5)
    mul t0 t0 t1
    
	slli a0 t0 2
    jal ra malloc
    beq a0 x0 error88
    add s1 x0 a0
    
    # Calculate m1 * ReLU(m0 * input) and store it in the malloc data in s1
    
    #store the numbers into registers first
    lw t2 0(s2)
    lw t3 0(s3)
    lw t0 0(s0)
    lw t5 0(s5)
    
	add a0 x0 s9
    add a1 x0 t2
    add a2 x0 t3
    add a3 x0 s11
    add a4 x0 t0
    add a5 x0 t5
    add a6 x0 s1
    
    jal ra matmul
    

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
	
    # fetch the output pointer
    lw a0 16(s6)
    add a1 x0 s1
    lw a2 0(s2)
    lw a3 0(s5)
    
    jal ra write_matrix


    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    
    #free s11 (we don't need it anymore)
    add a0 x0 s11
    
    jal ra free
	
    #load the number of elements
    lw t0 0(s2)
    lw t1 0(s5)
    
    add a0 x0 s1
    mul a1 t0 t1
    
    jal ra argmax
    
    add s11 x0 a0 # store this in s11 for now

    # Print classification
    
	beq s7 x0 print_value
    j continue
    
continue:
    # free remaining mallocs
    add a0 x0 s0
    jal ra free
    
    add a0 x0 s1
    jal ra free
    
    add a0 x0 s2
    jal ra free
    
    add a0 x0 s3
    jal ra free
    
    add a0 x0 s4
    jal ra free
    
    add a0 x0 s5
    jal ra free
    
    #return a0 as s11
    add a0 x0 s11


    lw s0 0(sp)
    lw s1 4(sp)
    lw s2 8(sp)
    lw s3 12(sp)
    lw s4 16(sp)
    lw s5 20(sp)
    lw s6 24(sp)
    lw s7 28(sp)
    lw s8 32(sp)
    lw s9 36(sp)
    lw s10 40(sp)
    lw s11 44(sp)
    lw ra 48(sp)
    addi sp sp 52

    ret
    
    
print_value:
	add a1 s11 x0
	jal print_int
    addi a1 x0 10
    jal print_char
    j continue
    
error88:
	addi a1 x0 88
    call exit2
error72:
	addi a1 x0 72
    call exit2
