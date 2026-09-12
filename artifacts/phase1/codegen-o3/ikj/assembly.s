	.file	"gemm_ikj.cpp"
	.intel_syntax noprefix
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"incompatible GEMM matrix dimensions"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB1:
	.text
.LHOTB1:
	.p2align 4
	.globl	"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_"
	.type	"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_", @function
"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_":
.LFB3340:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3340
	sub	rsp, 136
	.cfi_def_cfa_offset 144
	mov	rax, rdi
	mov	rdi, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+48], rdi
	cmp	rdi, QWORD PTR [rsi]
	jne	.L45
	mov	QWORD PTR [rsp+112], r13
	.cfi_offset 13, -32
	mov	r13, rdx
	mov	QWORD PTR [rsp+128], r15
	.cfi_offset 15, -16
	mov	r15, QWORD PTR [rax]
	cmp	r15, QWORD PTR [rdx]
	jne	.L46
	mov	QWORD PTR [rsp+88], rbx
	mov	rdi, QWORD PTR [rdx+8]
	.cfi_offset 3, -56
	mov	rbx, QWORD PTR [rsi+8]
	mov	QWORD PTR [rsp+40], rdi
	cmp	rdi, rbx
	jne	.L47
	test	r15, r15
	je	.L1
	test	rdi, rdi
	je	.L1
	mov	QWORD PTR [rsp+16], rax
	mov	QWORD PTR [rsp+96], rbp
	.cfi_offset 6, -48
	xor	ebp, ebp
	mov	QWORD PTR [rsp+104], r12
	.cfi_offset 12, -40
	mov	r12, rsi
	mov	QWORD PTR [rsp+120], r14
	.cfi_offset 14, -24
	lea	r14, [0+rdi*4]
	mov	QWORD PTR [rsp+8], rbx
	mov	rbx, rbp
	.p2align 4
	.p2align 3
.L6:
	mov	rdi, QWORD PTR [r13+16]
	mov	rdx, r14
	xor	esi, esi
	add	rbx, 1
	add	rdi, rbp
	add	rbp, r14
	call	"memset"
	cmp	r15, rbx
	jne	.L6
	mov	rdi, QWORD PTR [rsp+48]
	mov	rbx, QWORD PTR [rsp+8]
	mov	rax, QWORD PTR [rsp+16]
	test	rdi, rdi
	je	.L49
	mov	rax, QWORD PTR [rax+16]
	lea	rsi, [rbx-1]
	mov	QWORD PTR [rsp+72], r15
	xor	ecx, ecx
	mov	QWORD PTR [rsp+16], rsi
	mov	r9, QWORD PTR [r12+16]
	xor	r11d, r11d
	mov	QWORD PTR [rsp+56], rax
	lea	rax, [rax+rdi*4]
	mov	rbp, QWORD PTR [r13+16]
	xor	r13d, r13d
	mov	QWORD PTR [rsp+64], rax
	mov	rax, rbx
	shr	rax, 2
	mov	QWORD PTR [rsp+24], rax
	sal	rax, 4
	mov	rdx, rax
	.p2align 4
	.p2align 3
.L5:
	mov	rax, QWORD PTR [rsp+56]
	mov	QWORD PTR [rsp+32], rcx
	xor	edi, edi
	xor	r8d, r8d
	lea	r12, [0+rcx*4]
	lea	rsi, [r12+rax]
	add	r12, QWORD PTR [rsp+64]
	lea	rax, [rbp+0+r13*4]
.L20:
	movss	xmm2, DWORD PTR [rsi]
	cmp	rbx, 1
	je	.L9
	mov	r15, r11
.L8:
	lea	r10, [r9+4+rdi]
	mov	rcx, rax
	sub	rcx, r10
	cmp	rcx, 8
	jbe	.L40
	cmp	QWORD PTR [rsp+16], 2
	jbe	.L22
	movaps	xmm1, xmm2
	lea	r10, [r9+rdi]
	xor	ecx, ecx
	shufps	xmm1, xmm1, 0
	.p2align 5
	.p2align 4
	.p2align 3
.L11:
	movups	xmm0, XMMWORD PTR [r10+rcx]
	movups	xmm3, XMMWORD PTR [rax+rcx]
	mulps	xmm0, xmm1
	addps	xmm0, xmm3
	movups	XMMWORD PTR [rax+rcx], xmm0
	add	rcx, 16
	cmp	rdx, rcx
	jne	.L11
	mov	rcx, QWORD PTR [rsp+24]
	sal	rcx, 2
	cmp	rbx, rcx
	je	.L12
	mov	r10, rbx
	sub	r10, rcx
	cmp	r10, 1
	je	.L13
.L10:
	lea	r11, [r13+0+rcx]
	movaps	xmm1, xmm2
	mov	QWORD PTR [rsp+8], r11
	lea	r11, [r8+rcx]
	shufps	xmm1, xmm1, 0xe0
	movq	xmm1, xmm1
	movq	xmm0, QWORD PTR [r9+r11*4]
	mov	r11, QWORD PTR [rsp+8]
	mulps	xmm0, xmm1
	movq	xmm1, QWORD PTR [rbp+0+r11*4]
	movq	xmm0, xmm0
	addps	xmm0, xmm1
	movlps	QWORD PTR [rbp+0+r11*4], xmm0
	mov	r11, r10
	and	r11, -2
	and	r10d, 1
	je	.L14
	add	rcx, r11
.L13:
	lea	r10, [r13+0+rcx]
	add	rcx, r8
	add	rsi, 4
	mulss	xmm2, DWORD PTR [r9+rcx*4]
	addss	xmm2, DWORD PTR [rbp+0+r10*4]
	movss	DWORD PTR [rbp+0+r10*4], xmm2
	cmp	r12, rsi
	je	.L42
.L50:
	movss	xmm2, DWORD PTR [rsi]
	add	r8, rbx
	add	rdi, r14
	jmp	.L8
.L40:
	mov	r11, r15
.L9:
	xor	ecx, ecx
	lea	r10, [r9+rdi]
	.p2align 5
	.p2align 4
	.p2align 3
.L17:
	movss	xmm0, DWORD PTR [r10+rcx*4]
	mulss	xmm0, xmm2
	addss	xmm0, DWORD PTR [rax+rcx*4]
	movss	DWORD PTR [rax+rcx*4], xmm0
	add	rcx, 1
	cmp	rbx, rcx
	jne	.L17
	add	rsi, 4
	add	r8, rbx
	add	rdi, r14
	cmp	r12, rsi
	jne	.L20
	mov	rcx, QWORD PTR [rsp+32]
.L16:
	add	r11, 1
	add	r13, QWORD PTR [rsp+40]
	add	rcx, QWORD PTR [rsp+48]
	cmp	r11, QWORD PTR [rsp+72]
	jne	.L5
.L49:
	mov	rbp, QWORD PTR [rsp+96]
	.cfi_restore 6
	mov	r12, QWORD PTR [rsp+104]
	.cfi_restore 12
	mov	r14, QWORD PTR [rsp+120]
	.cfi_restore 14
.L1:
	mov	rbx, QWORD PTR [rsp+88]
	.cfi_restore 3
	mov	r13, QWORD PTR [rsp+112]
	.cfi_restore 13
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
	add	rsp, 136
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L14:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	add	rsi, 4
	cmp	rsi, r12
	jne	.L50
.L42:
	mov	rcx, QWORD PTR [rsp+32]
	mov	r11, r15
	jmp	.L16
	.p2align 4,,10
	.p2align 3
.L12:
	add	rsi, 4
	cmp	r12, rsi
	jne	.L50
	mov	rcx, QWORD PTR [rsp+32]
	mov	r11, r15
	jmp	.L16
.L22:
	mov	r10, rbx
	xor	ecx, ecx
	jmp	.L10
.L45:
	.cfi_restore 3
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	QWORD PTR [rsp+88], rbx
	.cfi_offset 3, -56
	jmp	.L2
.L47:
	.cfi_offset 13, -32
	.cfi_offset 15, -16
	mov	r13, QWORD PTR [rsp+112]
	.cfi_restore 13
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
	jmp	.L2
.L46:
	.cfi_restore 3
	.cfi_offset 13, -32
	.cfi_offset 15, -16
	mov	r13, QWORD PTR [rsp+112]
	.cfi_restore 13
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
	mov	QWORD PTR [rsp+88], rbx
	.cfi_offset 3, -56
	jmp	.L2
	.section	.gcc_except_table,"a",@progbits
.LLSDA3340:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3340-.LLSDACSB3340
.LLSDACSB3340:
.LLSDACSE3340:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3340
	.type	"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_.cold", @function
"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_.cold":
.LFSB3340:
.L2:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -56
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC0
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
.L23:
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
.LFE3340:
	.section	.gcc_except_table
.LLSDAC3340:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3340-.LLSDACSBC3340
.LLSDACSBC3340:
	.uleb128 .LEHB0-.LCOLDB1
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L23-.LCOLDB1
	.uleb128 0
	.uleb128 .LEHB1-.LCOLDB1
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSEC3340:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_", .-"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_"
	.section	.text.unlikely
	.size	"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_.cold", .-"_ZN4gemm8gemm_ikjERKNS_6MatrixES2_RS0_.cold"
.LCOLDE1:
	.text
.LHOTE1:
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
