	.file	"gemm_naive.cpp"
	.intel_syntax noprefix
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC1:
	.string	"incompatible GEMM matrix dimensions"
	.text
	.globl	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.type	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", @function
"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_":
.LFB3334:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3334
	lea	rsp, [rsp-40]
	.cfi_def_cfa_offset 48
	mov	r10, QWORD PTR [rdi+8]
	cmp	QWORD PTR [rsi], r10
	jne	.L18
	mov	QWORD PTR [rsp+8], rbx
	mov	QWORD PTR [rsp+24], r12
	mov	r11, rdi
	.cfi_remember_state
	.cfi_offset 3, -40
	.cfi_offset 12, -24
	mov	rbx, rsi
	mov	r9, rdx
	mov	r12, QWORD PTR [rdi]
	cmp	QWORD PTR [rdx], r12
	jne	.L19
	mov	QWORD PTR [rsp+16], rbp
	.cfi_offset 6, -32
	mov	rbp, QWORD PTR [rsi+8]
	cmp	QWORD PTR [rdx+8], rbp
	jne	.L20
	mov	r8d, 0
	test	r12, r12
	je	.L1
	mov	QWORD PTR [rsp+32], r13
	.cfi_offset 13, -16
	jmp	.L3
.L18:
	.cfi_restore_state
	mov	QWORD PTR [rsp+8], rbx
	.cfi_offset 3, -40
.L2:
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	rbx, rax
	mov	esi, OFFSET FLAT:.LC1
	mov	rdi, rax
.LEHB0:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE0:
	jmp	.L23
.L19:
	.cfi_offset 12, -24
	mov	r12, QWORD PTR [rsp+24]
	.cfi_restore 12
	jmp	.L2
.L20:
	.cfi_offset 6, -32
	.cfi_offset 12, -24
	mov	rbp, QWORD PTR [rsp+16]
	.cfi_restore 6
	mov	r12, QWORD PTR [rsp+24]
	.cfi_restore 12
	jmp	.L2
.L23:
	mov	QWORD PTR [rsp+16], rbp
	mov	QWORD PTR [rsp+24], r12
	mov	QWORD PTR [rsp+32], r13
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
.LEHB1:
	.cfi_offset 6, -32
	.cfi_offset 12, -24
	.cfi_offset 13, -16
	call	"__cxa_throw"
.L24:
	mov	rsi, r8
	imul	rsi, QWORD PTR [r11+8]
	mov	r13, QWORD PTR [r11+16]
	lea	rax, [r13+0+rsi*4]
	mov	rcx, QWORD PTR [rbx+8]
	sal	rcx, 2
	mov	rdx, QWORD PTR [rbx+16]
	lea	rdx, [rdx+rdi*4]
	add	rsi, r10
	lea	rsi, [r13+0+rsi*4]
	pxor	xmm1, xmm1
	.p2align 5
.L5:
	movss	xmm0, DWORD PTR [rax]
	mulss	xmm0, DWORD PTR [rdx]
	addss	xmm1, xmm0
	add	rax, 4
	add	rdx, rcx
	cmp	rax, rsi
	jne	.L5
.L8:
	mov	rax, r8
	imul	rax, QWORD PTR [r9+8]
	add	rax, rdi
	mov	rdx, QWORD PTR [r9+16]
	movss	DWORD PTR [rdx+rax*4], xmm1
	add	rdi, 1
	cmp	rbp, rdi
	je	.L6
.L9:
	pxor	xmm1, xmm1
	test	r10, r10
	jne	.L24
	jmp	.L8
.L6:
	add	r8, 1
	cmp	r8, r12
	je	.L22
.L3:
	mov	edi, 0
	test	rbp, rbp
	jne	.L9
	jmp	.L6
.L13:
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	mov	QWORD PTR [rsp+16], rbp
	mov	QWORD PTR [rsp+24], r12
	mov	QWORD PTR [rsp+32], r13
	.cfi_offset 6, -32
	.cfi_offset 12, -24
	.cfi_offset 13, -16
	mov	rbp, rax
	mov	rdi, rbx
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE1:
.L22:
	mov	r13, QWORD PTR [rsp+32]
	.cfi_restore 13
.L1:
	mov	rbx, QWORD PTR [rsp+8]
	.cfi_restore 3
	mov	rbp, QWORD PTR [rsp+16]
	.cfi_restore 6
	mov	r12, QWORD PTR [rsp+24]
	.cfi_restore 12
	lea	rsp, [rsp+40]
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE3334:
	.section	.gcc_except_table,"a",@progbits
.LLSDA3334:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3334-.LLSDACSB3334
.LLSDACSB3334:
	.uleb128 .LEHB0-.LFB3334
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L13-.LFB3334
	.uleb128 0
	.uleb128 .LEHB1-.LFB3334
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSE3334:
	.text
	.size	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", .-"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
