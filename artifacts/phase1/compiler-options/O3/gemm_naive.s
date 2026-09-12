	.file	"gemm_naive.cpp"
	.intel_syntax noprefix
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"incompatible GEMM matrix dimensions"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB2:
	.text
.LHOTB2:
	.p2align 4
	.globl	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.type	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", @function
"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_":
.LFB3334:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3334
	sub	rsp, 136
	.cfi_def_cfa_offset 144
	mov	rax, rdi
	mov	QWORD PTR [rsp+88], rbx
	.cfi_offset 3, -56
	mov	rbx, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+64], rdi
	mov	QWORD PTR [rsp+72], rsi
	cmp	QWORD PTR [rsi], rbx
	jne	.L2
	mov	rdi, rsi
	mov	rsi, QWORD PTR [rax]
	mov	QWORD PTR [rsp+56], rsi
	cmp	QWORD PTR [rdx], rsi
	jne	.L2
	mov	rax, QWORD PTR [rdx+8]
	mov	rcx, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+48], rax
	cmp	rax, rcx
	jne	.L2
	test	rsi, rsi
	je	.L1
	test	rax, rax
	je	.L1
	mov	QWORD PTR [rsp+96], rbp
	.cfi_offset 6, -48
	mov	rbp, rbx
	mov	r8, rax
	lea	rdi, [rax+rax*2]
	shr	rbp, 2
	mov	QWORD PTR [rsp+104], r12
	sal	r8, 4
	mov	rax, rbp
	mov	QWORD PTR [rsp+112], r13
	sal	rdi, 2
	mov	QWORD PTR [rsp+128], r15
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 15, -16
	mov	r15, QWORD PTR [rdx+16]
	sal	rax, 4
	lea	rdx, [rbx-1]
	mov	QWORD PTR [rsp+120], r14
	sal	rbp, 2
	mov	QWORD PTR [rsp+8], rax
	mov	QWORD PTR [rsp+24], 0
	mov	QWORD PTR [rsp+40], r15
	mov	QWORD PTR [rsp+32], 0
	mov	QWORD PTR [rsp+16], rdx
	xor	edx, edx
	.cfi_offset 14, -24
	.p2align 4
	.p2align 3
.L4:
	mov	rax, QWORD PTR [rsp+40]
	mov	rsi, QWORD PTR [rsp+32]
	xor	r10d, r10d
	lea	r13, [rax+rsi*4]
	test	rbx, rbx
	jne	.L33
.L12:
	mov	DWORD PTR [r13+0+r10*4], 0x00000000
	add	r10, 1
	cmp	rcx, r10
	jne	.L12
	.p2align 4
	.p2align 3
.L7:
	add	QWORD PTR [rsp+24], 1
	mov	r14, QWORD PTR [rsp+48]
	add	rdx, rbx
	add	QWORD PTR [rsp+32], r14
	mov	rax, QWORD PTR [rsp+24]
	cmp	rax, QWORD PTR [rsp+56]
	jne	.L4
	mov	rbp, QWORD PTR [rsp+96]
	.cfi_restore 6
	mov	r12, QWORD PTR [rsp+104]
	.cfi_restore 12
	mov	r13, QWORD PTR [rsp+112]
	.cfi_restore 13
	mov	r14, QWORD PTR [rsp+120]
	.cfi_restore 14
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
.L1:
	mov	rbx, QWORD PTR [rsp+88]
	add	rsp, 136
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L33:
	.cfi_def_cfa_offset 144
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	mov	rax, QWORD PTR [rsp+64]
	lea	r14, [0+rdx*4]
	mov	r12, QWORD PTR [rax+16]
	mov	rax, QWORD PTR [rsp+72]
	mov	r11, QWORD PTR [rax+16]
.L13:
	cmp	QWORD PTR [rsp+16], 2
	jbe	.L16
.L35:
	mov	rax, rbp
.L8:
	mov	r15, QWORD PTR [rsp+8]
	lea	r9, [r12+r14]
	lea	rsi, [r11+r10*4]
	pxor	xmm1, xmm1
	add	r15, r9
	.p2align 4
	.p2align 3
.L6:
	movss	xmm0, DWORD PTR [rsi+rdi]
	movss	xmm2, DWORD PTR [rsi+rcx*8]
	add	r9, 16
	movss	xmm3, DWORD PTR [rsi+rcx*4]
	movups	xmm4, XMMWORD PTR [r9-16]
	unpcklps	xmm2, xmm0
	movss	xmm0, DWORD PTR [rsi]
	add	rsi, r8
	unpcklps	xmm0, xmm3
	movlhps	xmm0, xmm2
	mulps	xmm0, xmm4
	addss	xmm1, xmm0
	movaps	xmm2, xmm0
	shufps	xmm2, xmm0, 85
	addss	xmm2, xmm1
	movaps	xmm1, xmm0
	unpckhps	xmm1, xmm0
	shufps	xmm0, xmm0, 255
	addss	xmm1, xmm2
	addss	xmm1, xmm0
	cmp	r9, r15
	jne	.L6
	cmp	rbx, rbp
	je	.L34
.L5:
	mov	rsi, rcx
	lea	r15, [rax+rdx]
	imul	rsi, rax
	movss	xmm0, DWORD PTR [r12+r15*4]
	lea	r9, [rsi+r10]
	mulss	xmm0, DWORD PTR [r11+r9*4]
	lea	r9, [rax+1]
	addss	xmm0, xmm1
	cmp	r9, rbx
	jnb	.L30
	add	rsi, rcx
	add	r9, rdx
	add	rax, 2
	lea	r15, [rsi+r10]
	movss	xmm1, DWORD PTR [r12+r9*4]
	mulss	xmm1, DWORD PTR [r11+r15*4]
	addss	xmm1, xmm0
	cmp	rax, rbx
	jnb	.L11
	add	rsi, rcx
	add	rax, rdx
	add	rsi, r10
	movss	xmm0, DWORD PTR [r11+rsi*4]
	mulss	xmm0, DWORD PTR [r12+rax*4]
	addss	xmm0, xmm1
.L30:
	movss	DWORD PTR [r13+0+r10*4], xmm0
	add	r10, 1
	cmp	rcx, r10
	je	.L7
	cmp	QWORD PTR [rsp+16], 2
	ja	.L35
.L16:
	xor	eax, eax
	pxor	xmm1, xmm1
	jmp	.L5
	.p2align 4,,10
	.p2align 3
.L34:
	movss	DWORD PTR [r13+0+r10*4], xmm1
	add	r10, 1
	cmp	rcx, r10
	jne	.L8
	jmp	.L7
	.p2align 4,,10
	.p2align 3
.L11:
	movss	DWORD PTR [r13+0+r10*4], xmm1
	add	r10, 1
	cmp	rcx, r10
	jne	.L13
	jmp	.L7
	.section	.gcc_except_table,"a",@progbits
.LLSDA3334:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3334-.LLSDACSB3334
.LLSDACSB3334:
.LLSDACSE3334:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3334
	.type	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_.cold", @function
"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_.cold":
.LFSB3334:
.L2:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -56
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC1
	mov	rdi, rax
	mov	rbx, rax
.LEHB0:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE0:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+96], rbp
	mov	QWORD PTR [rsp+104], r12
	mov	QWORD PTR [rsp+112], r13
	mov	QWORD PTR [rsp+120], r14
	mov	QWORD PTR [rsp+128], r15
.LEHB1:
	.cfi_remember_state
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L17:
	.cfi_restore_state
	mov	QWORD PTR [rsp+96], rbp
	mov	rdi, rbx
	.cfi_offset 6, -48
	mov	rbp, rax
	mov	QWORD PTR [rsp+104], r12
	mov	QWORD PTR [rsp+112], r13
	mov	QWORD PTR [rsp+120], r14
	mov	QWORD PTR [rsp+128], r15
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE1:
	.cfi_endproc
.LFE3334:
	.section	.gcc_except_table
.LLSDAC3334:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3334-.LLSDACSBC3334
.LLSDACSBC3334:
	.uleb128 .LEHB0-.LCOLDB2
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L17-.LCOLDB2
	.uleb128 0
	.uleb128 .LEHB1-.LCOLDB2
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSEC3334:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", .-"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.section	.text.unlikely
	.size	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_.cold", .-"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_.cold"
.LCOLDE2:
	.text
.LHOTE2:
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
