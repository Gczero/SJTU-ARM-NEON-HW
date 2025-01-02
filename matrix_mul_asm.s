	.text
	.global matrix_mul_asm

matrix_mul_asm:
    // Please write your code below that will implement:
    //       int matrix_mul_asm(Matrix* results, Matrix* source1, Matrix* source2);
    //x0,x1,x2分别存放result,source1,source2的首地址
    MOV w3,#4//存放常数4
    MOV w4,#0//存放循环变量i
    MOV w5,#0//存放循环变量j
    MOV w6,#0//存放循环变量k

    LDR w8,[x1,#4]//存放column of source1
    LDR w9,[x2]//存放row of source2
    CMP w8,w9
    BNE EXIT2//不相等则跳转返回

    UDIV w8,w8,w3//存放column of source1/4
    LDR w9,[x1]//存放row of source1
    UDIV w9,w9,w3//row1/4
    LDR w10,[x2,#4]//存放column of source2
    UDIV w10,w10,w3//column2/4

    LDR x0,[x0,#8]//得到result矩阵的首地址
    LDR x1,[x1,#8]//得到source1矩阵的首地址
    LDR x2,[x2,#8]//得到source2矩阵的首地址

    MOV w12,#0//存偏移量for source1 and result
    MOV w13,#0//存偏移量for source2

    LSL w14,w10,#4//存储一行所占字节数，便于后续偏移(对于source2)
    LSL w15,w8,#4//(对于source1)

LOOP1:
    CMP w4,w10//i<column2/4
    BGE EXIT1
LOOP2:
    CMP w5,w9//j<row1/4
    BGE FINISH_FOR_LOOP1
LOOP3:
    CMP w6,w8//k<column1/4
    BGE FINISH_FOR_LOOP2
    //计算第一个4*4矩阵的位置
    MUL w12,w5,w8
    MUL w12,w12,w3
    ADD w12,w12,w6//j*column1+k
    LSL w12,w12,#4//*16(4个int,16字节)
    ADD x7,x1,x12
    LD1 {V0.4S},[x7],x15
    LD1 {V1.4S},[x7],x15
    LD1 {V2.4S},[x7],x15
    LD1 {V3.4S},[x7],x15//递增到下一行
    //计算第二个4*4矩阵的位置
    MUL w13,w6,w10
    MUL w13,w13,w3
    ADD w13,w13,w4//k*column2+i
    LSL w13,w13,#4//同上
    ADD x7,x2,x13
    LD1 {V4.4S},[x7],x14
    LD1 {V5.4S},[x7],x14
    LD1 {V6.4S},[x7],x14
    LD1 {V7.4S},[x7],x14//同上
    //计算结果存放矩阵位置
    MUL w12,w5,w10
    MUL w12,w12,w3
    ADD w12,w12,w4//j*column2+i
    LSL w12,w12,#4//同上
    ADD x7,x0,x12
    LD1 {V8.4S},[x7],x14
    LD1 {V9.4S},[x7],x14
    LD1 {V10.4S},[x7],x14
    LD1 {V11.4S},[x7],x14//同上
    //计算结果(采用中间向量辅助)计算一组4*4矩阵和4*4矩阵乘法
    MUL V12.4S,V4.4S,V0.S[0]
    ADD V8.4S,V8.4S,V12.4S

    MUL V12.4S,V4.4S,V1.S[0]
    ADD V9.4S,V9.4S,V12.4S

    MUL V12.4S,V4.4S,V2.S[0]
    ADD V10.4S,V10.4S,V12.4S

    MUL V12.4S,V4.4S,V3.S[0]
    ADD V11.4S,V11.4S,V12.4S

    MUL V12.4S,V5.4S,V0.S[1]
    ADD V8.4S,V8.4S,V12.4S

    MUL V12.4S,V5.4S,V1.S[1]
    ADD V9.4S,V9.4S,V12.4S

    MUL V12.4S,V5.4S,V2.S[1]
    ADD V10.4S,V10.4S,V12.4S

    MUL V12.4S,V5.4S,V3.S[1]
    ADD V11.4S,V11.4S,V12.4S

    MUL V12.4S,V6.4S,V0.S[2]
    ADD V8.4S,V8.4S,V12.4S

    MUL V12.4S,V6.4S,V1.S[2]
    ADD V9.4S,V9.4S,V12.4S

    MUL V12.4S,V6.4S,V2.S[2]
    ADD V10.4S,V10.4S,V12.4S

    MUL V12.4S,V6.4S,V3.S[2]
    ADD V11.4S,V11.4S,V12.4S

    MUL V12.4S,V7.4S,V0.S[3]
    ADD V8.4S,V8.4S,V12.4S

    MUL V12.4S,V7.4S,V1.S[3]
    ADD V9.4S,V9.4S,V12.4S

    MUL V12.4S,V7.4S,V2.S[3]
    ADD V10.4S,V10.4S,V12.4S

    MUL V12.4S,V7.4S,V3.S[3]
    ADD V11.4S,V11.4S,V12.4S
    //存储结果
    SUB x7,x7,x14
    ST1 {V11.4S},[x7]
    SUB x7,x7,x14
    ST1 {V10.4S},[x7]
    SUB x7,x7,x14
    ST1 {V9.4S},[x7]
    SUB x7,x7,x14
    ST1 {V8.4S},[x7]
    ADD w6,w6,#1
    B       LOOP3
FINISH_FOR_LOOP1:
    ADD w4,w4,#1
    MOV w5,#0
    B       LOOP1//递增循环
FINISH_FOR_LOOP2:
    ADD w5,w5,#1
    MOV w6,#0
    B       LOOP2//同上
EXIT1:
    MOV x0,#0//返回0代表乘法成功
EXIT2:
    MOV x0,#1//返回1代表乘法失败
	
    RET