	.file	"gemm_naive.cpp"
	.intel_syntax noprefix
	.text
	.section	.text._ZNK4gemm6Matrix4rowsEv,"axG",@progbits,_ZNK4gemm6Matrix4rowsEv,comdat
	.align 2
	.weak	"_ZNK4gemm6Matrix4rowsEv"
	.type	"_ZNK4gemm6Matrix4rowsEv", @function
"_ZNK4gemm6Matrix4rowsEv":
.LFB3304:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR [rbp-8], rdi
	mov	rax, QWORD PTR [rbp-8]
	mov	rax, QWORD PTR [rax]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3304:
	.size	"_ZNK4gemm6Matrix4rowsEv", .-"_ZNK4gemm6Matrix4rowsEv"
	.section	.text._ZNK4gemm6Matrix4colsEv,"axG",@progbits,_ZNK4gemm6Matrix4colsEv,comdat
	.align 2
	.weak	"_ZNK4gemm6Matrix4colsEv"
	.type	"_ZNK4gemm6Matrix4colsEv", @function
"_ZNK4gemm6Matrix4colsEv":
.LFB3305:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR [rbp-8], rdi
	mov	rax, QWORD PTR [rbp-8]
	mov	rax, QWORD PTR [rax+8]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3305:
	.size	"_ZNK4gemm6Matrix4colsEv", .-"_ZNK4gemm6Matrix4colsEv"
	.section	.text._ZN4gemm6MatrixclEmm,"axG",@progbits,_ZN4gemm6MatrixclEmm,comdat
	.align 2
	.weak	"_ZN4gemm6MatrixclEmm"
	.type	"_ZN4gemm6MatrixclEmm", @function
"_ZN4gemm6MatrixclEmm":
.LFB3308:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR [rbp-8], rdi
	mov	QWORD PTR [rbp-16], rsi
	mov	QWORD PTR [rbp-24], rdx
	mov	rax, QWORD PTR [rbp-8]
	add	rax, 16
	mov	rdx, QWORD PTR [rbp-8]
	mov	rdx, QWORD PTR [rdx+8]
	mov	rcx, rdx
	imul	rcx, QWORD PTR [rbp-16]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	rsi, rdx
	mov	rdi, rax
	call	"_ZNSt6vectorIfSaIfEEixEm"
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3308:
	.size	"_ZN4gemm6MatrixclEmm", .-"_ZN4gemm6MatrixclEmm"
	.section	.text._ZNK4gemm6MatrixclEmm,"axG",@progbits,_ZNK4gemm6MatrixclEmm,comdat
	.align 2
	.weak	"_ZNK4gemm6MatrixclEmm"
	.type	"_ZNK4gemm6MatrixclEmm", @function
"_ZNK4gemm6MatrixclEmm":
.LFB3309:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 32
	mov	QWORD PTR [rbp-8], rdi
	mov	QWORD PTR [rbp-16], rsi
	mov	QWORD PTR [rbp-24], rdx
	mov	rax, QWORD PTR [rbp-8]
	add	rax, 16
	mov	rdx, QWORD PTR [rbp-8]
	mov	rdx, QWORD PTR [rdx+8]
	mov	rcx, rdx
	imul	rcx, QWORD PTR [rbp-16]
	mov	rdx, QWORD PTR [rbp-24]
	add	rdx, rcx
	mov	rsi, rdx
	mov	rdi, rax
	call	"_ZNKSt6vectorIfSaIfEEixEm"
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3309:
	.size	"_ZNK4gemm6MatrixclEmm", .-"_ZNK4gemm6MatrixclEmm"
	.section	.rodata
	.align 8
.LC0:
	.string	"incompatible GEMM matrix dimensions"
	.text
	.globl	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.type	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", @function
"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_":
.LFB3311:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3311
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	push	r12
	push	rbx
	sub	rsp, 96
	.cfi_offset 12, -24
	.cfi_offset 3, -32
	mov	QWORD PTR [rbp-88], rdi
	mov	QWORD PTR [rbp-96], rsi
	mov	QWORD PTR [rbp-104], rdx
	mov	rax, QWORD PTR [rbp-88]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4colsEv"
	mov	rbx, rax
	mov	rax, QWORD PTR [rbp-96]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4rowsEv"
	cmp	rbx, rax
	jne	.L10
	mov	rax, QWORD PTR [rbp-104]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4rowsEv"
	mov	rbx, rax
	mov	rax, QWORD PTR [rbp-88]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4rowsEv"
	cmp	rbx, rax
	jne	.L10
	mov	rax, QWORD PTR [rbp-104]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4colsEv"
	mov	rbx, rax
	mov	rax, QWORD PTR [rbp-96]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4colsEv"
	cmp	rbx, rax
	je	.L11
.L10:
	mov	eax, 1
	jmp	.L12
.L11:
	mov	eax, 0
.L12:
	test	al, al
	je	.L13
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	rbx, rax
	mov	esi, OFFSET FLAT:.LC0
	mov	rdi, rbx
.LEHB0:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE0:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
.LEHB1:
	call	"__cxa_throw"
.L13:
	mov	rax, QWORD PTR [rbp-88]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4rowsEv"
	mov	QWORD PTR [rbp-56], rax
	mov	rax, QWORD PTR [rbp-96]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4colsEv"
	mov	QWORD PTR [rbp-64], rax
	mov	rax, QWORD PTR [rbp-88]
	mov	rdi, rax
	call	"_ZNK4gemm6Matrix4colsEv"
	mov	QWORD PTR [rbp-72], rax
	mov	QWORD PTR [rbp-24], 0
	jmp	.L14
.L19:
	mov	QWORD PTR [rbp-32], 0
	jmp	.L15
.L18:
	pxor	xmm0, xmm0
	movss	DWORD PTR [rbp-36], xmm0
	mov	QWORD PTR [rbp-48], 0
	jmp	.L16
.L17:
	mov	rdx, QWORD PTR [rbp-48]
	mov	rcx, QWORD PTR [rbp-24]
	mov	rax, QWORD PTR [rbp-88]
	mov	rsi, rcx
	mov	rdi, rax
	call	"_ZNK4gemm6MatrixclEmm"
	movss	xmm2, DWORD PTR [rax]
	movss	DWORD PTR [rbp-108], xmm2
	mov	rdx, QWORD PTR [rbp-32]
	mov	rcx, QWORD PTR [rbp-48]
	mov	rax, QWORD PTR [rbp-96]
	mov	rsi, rcx
	mov	rdi, rax
	call	"_ZNK4gemm6MatrixclEmm"
	movss	xmm0, DWORD PTR [rax]
	mulss	xmm0, DWORD PTR [rbp-108]
	movss	xmm1, DWORD PTR [rbp-36]
	addss	xmm0, xmm1
	movss	DWORD PTR [rbp-36], xmm0
	add	QWORD PTR [rbp-48], 1
.L16:
	mov	rax, QWORD PTR [rbp-48]
	cmp	rax, QWORD PTR [rbp-72]
	jb	.L17
	movss	xmm3, DWORD PTR [rbp-36]
	movss	DWORD PTR [rbp-108], xmm3
	mov	rdx, QWORD PTR [rbp-32]
	mov	rcx, QWORD PTR [rbp-24]
	mov	rax, QWORD PTR [rbp-104]
	mov	rsi, rcx
	mov	rdi, rax
	call	"_ZN4gemm6MatrixclEmm"
	movss	xmm3, DWORD PTR [rbp-108]
	movss	DWORD PTR [rax], xmm3
	add	QWORD PTR [rbp-32], 1
.L15:
	mov	rax, QWORD PTR [rbp-32]
	cmp	rax, QWORD PTR [rbp-64]
	jb	.L18
	add	QWORD PTR [rbp-24], 1
.L14:
	mov	rax, QWORD PTR [rbp-24]
	cmp	rax, QWORD PTR [rbp-56]
	jb	.L19
	jmp	.L22
.L21:
	mov	r12, rax
	mov	rdi, rbx
	call	"__cxa_free_exception"
	mov	rax, r12
	mov	rdi, rax
	call	"_Unwind_Resume"
.LEHE1:
.L22:
	add	rsp, 96
	pop	rbx
	pop	r12
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3311:
	.section	.gcc_except_table,"a",@progbits
.LLSDA3311:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3311-.LLSDACSB3311
.LLSDACSB3311:
	.uleb128 .LEHB0-.LFB3311
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L21-.LFB3311
	.uleb128 0
	.uleb128 .LEHB1-.LFB3311
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSE3311:
	.text
	.size	"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_", .-"_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_"
	.section	.rodata
.LC2:
	.string	"__n < this->size()"
	.align 8
.LC3:
	.string	"std::vector<_Tp, _Alloc>::reference std::vector<_Tp, _Alloc>::operator[](size_type) [with _Tp = float; _Alloc = std::allocator<float>; reference = float&; size_type = long unsigned int]"
	.align 8
.LC4:
	.string	"/usr/include/c++/16/bits/stl_vector.h"
	.section	.text._ZNSt6vectorIfSaIfEEixEm,"axG",@progbits,_ZNSt6vectorIfSaIfEEixEm,comdat
	.align 2
	.weak	"_ZNSt6vectorIfSaIfEEixEm"
	.type	"_ZNSt6vectorIfSaIfEEixEm", @function
"_ZNSt6vectorIfSaIfEEixEm":
.LFB3671:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	mov	QWORD PTR [rbp-8], rdi
	mov	QWORD PTR [rbp-16], rsi
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	"_ZNKSt6vectorIfSaIfEE4sizeEv"
	cmp	QWORD PTR [rbp-16], rax
	setnb	al
	movzx	eax, al
	test	rax, rax
	setne	al
	test	al, al
	je	.L24
	mov	ecx, OFFSET FLAT:.LC2
	mov	edx, OFFSET FLAT:.LC3
	mov	esi, 1253
	mov	edi, OFFSET FLAT:.LC4
	call	"_ZSt21__glibcxx_assert_failPKciS0_S0_"
.L24:
	mov	rax, QWORD PTR [rbp-8]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR [rbp-16]
	sal	rdx, 2
	add	rax, rdx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3671:
	.size	"_ZNSt6vectorIfSaIfEEixEm", .-"_ZNSt6vectorIfSaIfEEixEm"
	.section	.rodata
	.align 8
.LC5:
	.string	"std::vector<_Tp, _Alloc>::const_reference std::vector<_Tp, _Alloc>::operator[](size_type) const [with _Tp = float; _Alloc = std::allocator<float>; const_reference = const float&; size_type = long unsigned int]"
	.section	.text._ZNKSt6vectorIfSaIfEEixEm,"axG",@progbits,_ZNKSt6vectorIfSaIfEEixEm,comdat
	.align 2
	.weak	"_ZNKSt6vectorIfSaIfEEixEm"
	.type	"_ZNKSt6vectorIfSaIfEEixEm", @function
"_ZNKSt6vectorIfSaIfEEixEm":
.LFB3672:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 16
	mov	QWORD PTR [rbp-8], rdi
	mov	QWORD PTR [rbp-16], rsi
	mov	rax, QWORD PTR [rbp-8]
	mov	rdi, rax
	call	"_ZNKSt6vectorIfSaIfEE4sizeEv"
	cmp	QWORD PTR [rbp-16], rax
	setnb	al
	movzx	eax, al
	test	rax, rax
	setne	al
	test	al, al
	je	.L27
	mov	ecx, OFFSET FLAT:.LC2
	mov	edx, OFFSET FLAT:.LC5
	mov	esi, 1272
	mov	edi, OFFSET FLAT:.LC4
	call	"_ZSt21__glibcxx_assert_failPKciS0_S0_"
.L27:
	mov	rax, QWORD PTR [rbp-8]
	mov	rax, QWORD PTR [rax]
	mov	rdx, QWORD PTR [rbp-16]
	sal	rdx, 2
	add	rax, rdx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3672:
	.size	"_ZNKSt6vectorIfSaIfEEixEm", .-"_ZNKSt6vectorIfSaIfEEixEm"
	.section	.text._ZNKSt6vectorIfSaIfEE4sizeEv,"axG",@progbits,_ZNKSt6vectorIfSaIfEE4sizeEv,comdat
	.align 2
	.weak	"_ZNKSt6vectorIfSaIfEE4sizeEv"
	.type	"_ZNKSt6vectorIfSaIfEE4sizeEv", @function
"_ZNKSt6vectorIfSaIfEE4sizeEv":
.LFB3849:
	.cfi_startproc
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	mov	QWORD PTR [rbp-24], rdi
	mov	rax, QWORD PTR [rbp-24]
	mov	rdx, QWORD PTR [rax+8]
	mov	rax, QWORD PTR [rbp-24]
	mov	rax, QWORD PTR [rax]
	sub	rdx, rax
	mov	rax, rdx
	sar	rax, 2
	mov	QWORD PTR [rbp-8], rax
	cmp	QWORD PTR [rbp-8], 0
	mov	rax, QWORD PTR [rbp-8]
	pop	rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3849:
	.size	"_ZNKSt6vectorIfSaIfEE4sizeEv", .-"_ZNKSt6vectorIfSaIfEE4sizeEv"
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
