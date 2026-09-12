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
	sub	rsp, 104
	.cfi_def_cfa_offset 112
	mov	QWORD PTR [rsp+72], r12
	.cfi_offset 12, -40
	mov	r12, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+32], rdi
	mov	QWORD PTR [rsp+40], rsi
	cmp	QWORD PTR [rsi], r12
	jne	.L2
	mov	rax, QWORD PTR [rdi]
	mov	QWORD PTR [rsp+16], rax
	cmp	QWORD PTR [rdx], rax
	jne	.L2
	mov	QWORD PTR [rsp+96], r15
	mov	r11, QWORD PTR [rsi+8]
	.cfi_offset 15, -16
	mov	r15, QWORD PTR [rdx+8]
	cmp	r15, r11
	jne	.L23
	test	rax, rax
	je	.L1
	test	r15, r15
	je	.L1
	mov	QWORD PTR [rsp+56], rbx
	lea	rax, [0+r12*4]
	lea	rsi, [0+r15*4]
	mov	QWORD PTR [rsp+64], rbp
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	xor	ebp, ebp
	mov	QWORD PTR [rsp+80], r13
	.cfi_offset 13, -32
	xor	r13d, r13d
	mov	QWORD PTR [rsp+88], r14
	.cfi_offset 14, -24
	mov	r14, QWORD PTR [rdx+16]
	mov	rdx, r15
	mov	QWORD PTR [rsp+24], rax
	xor	eax, eax
	.p2align 4
	.p2align 3
.L10:
	lea	r9, [r14+rax*4]
	xor	r8d, r8d
	test	r12, r12
	jne	.L25
.L20:
	mov	DWORD PTR [r9+r8*4], 0x00000000
	add	r8, 1
	cmp	r11, r8
	jne	.L20
	.p2align 4
	.p2align 3
.L7:
	add	rbp, 1
	add	rax, rdx
	add	r13, r12
	cmp	QWORD PTR [rsp+16], rbp
	jne	.L10
	mov	rbx, QWORD PTR [rsp+56]
	.cfi_restore 3
	mov	rbp, QWORD PTR [rsp+64]
	.cfi_restore 6
	mov	r13, QWORD PTR [rsp+80]
	.cfi_restore 13
	mov	r14, QWORD PTR [rsp+88]
	.cfi_restore 14
.L1:
	mov	r15, QWORD PTR [rsp+96]
	.cfi_restore 15
	mov	r12, QWORD PTR [rsp+72]
	add	rsp, 104
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L25:
	.cfi_def_cfa_offset 112
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	mov	rcx, QWORD PTR [rsp+32]
	mov	rdi, QWORD PTR [rsp+24]
	mov	QWORD PTR [rsp+8], r13
	lea	rbx, [0+r13*4]
	mov	r10, QWORD PTR [rcx+16]
	mov	rcx, QWORD PTR [rsp+40]
	add	rdi, rbx
	mov	r15, QWORD PTR [rcx+16]
	add	rdi, r10
	.p2align 4
	.p2align 3
.L6:
	lea	rcx, [r10+rbx]
	lea	r13, [r15+r8*4]
	pxor	xmm1, xmm1
	.p2align 5
	.p2align 4
	.p2align 3
.L5:
	movss	xmm0, DWORD PTR [rcx]
	mulss	xmm0, DWORD PTR [r13+0]
	add	rcx, 4
	add	r13, rsi
	addss	xmm1, xmm0
	cmp	rdi, rcx
	jne	.L5
	movss	DWORD PTR [r9+r8*4], xmm1
	add	r8, 1
	cmp	r11, r8
	jne	.L6
	mov	r13, QWORD PTR [rsp+8]
	jmp	.L7
.L23:
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 13
	.cfi_restore 14
	mov	r15, QWORD PTR [rsp+96]
	.cfi_restore 15
	jmp	.L2
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
	.cfi_def_cfa_offset 112
	.cfi_offset 12, -40
	mov	edi, 16
	mov	QWORD PTR [rsp+56], rbx
	.cfi_offset 3, -56
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
	mov	QWORD PTR [rsp+64], rbp
	mov	QWORD PTR [rsp+80], r13
	mov	QWORD PTR [rsp+88], r14
	mov	QWORD PTR [rsp+96], r15
.LEHB1:
	.cfi_offset 6, -48
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L13:
	.cfi_restore 6
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	QWORD PTR [rsp+64], rbp
	mov	rdi, rbx
	.cfi_offset 6, -48
	mov	rbp, rax
	mov	QWORD PTR [rsp+80], r13
	mov	QWORD PTR [rsp+88], r14
	mov	QWORD PTR [rsp+96], r15
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
	.uleb128 .L13-.LCOLDB2
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
