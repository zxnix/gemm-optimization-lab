	.file	"gemm_microkernel.cpp"
	.intel_syntax noprefix
	.text
	.p2align 4
	.type	"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm", @function
"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm":
.LFB10884:
	.cfi_startproc
	sub	rsp, 144
	.cfi_def_cfa_offset 152
	pxor	xmm0, xmm0
	mov	QWORD PTR [rsp+136], r15
	.cfi_offset 15, -16
	mov	r15, rdi
	mov	rdi, rsi
	mov	rsi, rdx
	mov	r11, QWORD PTR [r15+8]
	mov	QWORD PTR [rsp+120], r13
	.cfi_offset 13, -32
	mov	r13, rcx
	mov	QWORD PTR [rsp-64], r9
	mov	r9, QWORD PTR [rsp+160]
	mov	QWORD PTR [rsp+96], rbx
	movaps	XMMWORD PTR [rsp-40], xmm0
	movaps	XMMWORD PTR [rsp-24], xmm0
	movaps	XMMWORD PTR [rsp-8], xmm0
	movaps	XMMWORD PTR [rsp+8], xmm0
	movaps	XMMWORD PTR [rsp+24], xmm0
	movaps	XMMWORD PTR [rsp+40], xmm0
	movaps	XMMWORD PTR [rsp+56], xmm0
	movaps	XMMWORD PTR [rsp+72], xmm0
	test	r11, r11
	.cfi_offset 3, -56
	je	.L101
	mov	r10, QWORD PTR [rdi+16]
	mov	rax, QWORD PTR [rdi+24]
	xor	edx, edx
	mov	QWORD PTR [rsp-56], rsi
	mov	QWORD PTR [rsp+128], r14
	.cfi_offset 14, -24
	mov	r14, r13
	mov	rcx, QWORD PTR [rdi+32]
	lea	rbx, [r9-1]
	mov	QWORD PTR [rsp-88], rax
	mov	rax, r10
	imul	r14, r11
	lea	rdi, [rsp-40]
	imul	rax, r10
	mov	QWORD PTR [rsp-48], r13
	mov	QWORD PTR [rsp+104], rbp
	.cfi_offset 6, -48
	mov	rbp, r9
	mov	QWORD PTR [rsp+112], r12
	.cfi_offset 12, -40
	shr	rbp, 2
	xor	r12d, r12d
	mov	QWORD PTR [rsp-80], rax
	mov	rax, QWORD PTR [rsp-64]
	div	r10
	mov	QWORD PTR [rsp-72], rax
	lea	rax, [r11+r11*2]
	mov	QWORD PTR [rsp-112], rax
.L37:
	mov	r13, r11
	sub	r13, r12
	cmp	r13, r10
	cmova	r13, r10
	test	r13, r13
	je	.L3
	mov	rax, r12
	xor	edx, edx
	mov	QWORD PTR [rsp-104], r12
	add	r13, r14
	div	r10
	mov	QWORD PTR [rsp-96], r14
	mov	rdx, QWORD PTR [r15+16]
	lea	rsi, [rdx+r14*4]
	lea	r13, [rdx+r13*4]
	imul	rax, QWORD PTR [rsp-88]
	add	rax, QWORD PTR [rsp-72]
	imul	rax, QWORD PTR [rsp-80]
	add	rax, QWORD PTR [rsp+152]
	.p2align 4
	.p2align 3
.L36:
	movss	xmm0, DWORD PTR [rsi]
	cmp	rbx, 2
	jbe	.L102
.L49:
	movups	xmm1, XMMWORD PTR [rcx+rax*4]
	movaps	xmm3, xmm0
	shufps	xmm3, xmm3, 0
	movaps	xmm2, xmm1
	mulps	xmm2, xmm3
	addps	xmm2, XMMWORD PTR [rsp-40]
	movaps	XMMWORD PTR [rsp-40], xmm2
	cmp	rbp, 2
	jne	.L10
	movups	xmm0, XMMWORD PTR [rcx+16+rax*4]
	mulps	xmm0, xmm3
	addps	xmm0, XMMWORD PTR [rsp-24]
	movaps	XMMWORD PTR [rsp-24], xmm0
.L11:
	cmp	r8, 1
	je	.L98
	movss	xmm0, DWORD PTR [rsi+r11*4]
	shufps	xmm0, xmm0, 0
	mulps	xmm1, xmm0
	addps	xmm1, XMMWORD PTR [rsp-8]
	movaps	XMMWORD PTR [rsp-8], xmm1
	cmp	r9, 4
	je	.L21
	movups	xmm4, XMMWORD PTR [rcx+16+rax*4]
	mulps	xmm0, xmm4
	addps	xmm0, XMMWORD PTR [rsp+8]
	movaps	XMMWORD PTR [rsp+8], xmm0
.L21:
	cmp	r8, 2
	jbe	.L98
	movss	xmm1, DWORD PTR [rsi+r11*8]
	movups	xmm0, XMMWORD PTR [rcx+rax*4]
	shufps	xmm1, xmm1, 0
	mulps	xmm0, xmm1
	addps	xmm0, XMMWORD PTR [rsp+24]
	movaps	XMMWORD PTR [rsp+24], xmm0
	cmp	r9, 4
	je	.L29
	movups	xmm0, XMMWORD PTR [rcx+16+rax*4]
	mulps	xmm0, xmm1
	addps	xmm0, XMMWORD PTR [rsp+40]
	movaps	XMMWORD PTR [rsp+40], xmm0
.L29:
	cmp	r8, 4
	jne	.L98
	mov	rdx, QWORD PTR [rsp-112]
	movss	xmm0, DWORD PTR [rsi+rdx*4]
.L32:
	movups	xmm1, XMMWORD PTR [rcx+rax*4]
	movaps	xmm2, xmm0
	shufps	xmm2, xmm2, 0
	mulps	xmm1, xmm2
	addps	xmm1, XMMWORD PTR [rsp+56]
	movaps	XMMWORD PTR [rsp+56], xmm1
	cmp	rbp, 2
	jne	.L34
	movups	xmm0, XMMWORD PTR [rcx+16+rax*4]
	add	rsi, 4
	mulps	xmm0, xmm2
	addps	xmm0, XMMWORD PTR [rsp+72]
	movaps	XMMWORD PTR [rsp+72], xmm0
	cmp	rsi, r13
	je	.L93
.L96:
	movss	xmm0, DWORD PTR [rsi]
	add	rax, r10
	jmp	.L49
	.p2align 4,,10
	.p2align 3
.L10:
	cmp	r9, 4
	je	.L11
	mov	edx, 4
.L12:
	mov	r12, r9
	sub	r12, rdx
	cmp	r12, 1
	je	.L9
	lea	r14, [rax+rdx]
	movaps	xmm2, xmm0
	movq	xmm1, QWORD PTR [rcx+r14*4]
	shufps	xmm2, xmm2, 0xe0
	movq	xmm2, xmm2
	mov	r14, r12
	and	r14, -2
	and	r12d, 1
	mulps	xmm1, xmm2
	movq	xmm2, QWORD PTR [rdi+rdx*4]
	movq	xmm1, xmm1
	addps	xmm1, xmm2
	movlps	QWORD PTR [rdi+rdx*4], xmm1
	je	.L8
	add	rdx, r14
.L9:
	lea	r12, [rax+rdx]
	mulss	xmm0, DWORD PTR [rcx+r12*4]
	addss	xmm0, DWORD PTR [rsp-40+rdx*4]
	movss	DWORD PTR [rsp-40+rdx*4], xmm0
	cmp	r8, 1
	je	.L14
	movss	xmm0, DWORD PTR [rsi+r11*4]
	cmp	rbx, 2
	jbe	.L103
.L16:
	movups	xmm5, XMMWORD PTR [rcx+rax*4]
	movaps	xmm1, xmm0
	mov	edx, 4
	shufps	xmm1, xmm1, 0
	mulps	xmm1, xmm5
	addps	xmm1, XMMWORD PTR [rsp-8]
	movaps	XMMWORD PTR [rsp-8], xmm1
	cmp	r9, 4
	je	.L21
.L22:
	mov	r12, r9
	sub	r12, rdx
	cmp	r12, 1
	je	.L19
.L15:
	lea	r14, [rax+rdx]
	movaps	xmm2, xmm0
	movq	xmm1, QWORD PTR [rcx+r14*4]
	shufps	xmm2, xmm2, 0xe0
	movq	xmm2, xmm2
	mov	r14, r12
	and	r14, -2
	and	r12d, 1
	mulps	xmm1, xmm2
	movq	xmm2, QWORD PTR [rdi+32+rdx*4]
	movq	xmm1, xmm1
	addps	xmm1, xmm2
	movlps	QWORD PTR [rdi+32+rdx*4], xmm1
	je	.L18
	add	rdx, r14
.L19:
	lea	r12, [rdx+rax]
	mulss	xmm0, DWORD PTR [rcx+r12*4]
	addss	xmm0, DWORD PTR [rsp-8+rdx*4]
	movss	DWORD PTR [rsp-8+rdx*4], xmm0
	cmp	r8, 2
	jbe	.L14
	movss	xmm0, DWORD PTR [rsi+r11*8]
	cmp	rbx, 2
	jbe	.L104
.L24:
	movups	xmm6, XMMWORD PTR [rcx+rax*4]
	movaps	xmm1, xmm0
	shufps	xmm1, xmm1, 0
	mulps	xmm1, xmm6
	addps	xmm1, XMMWORD PTR [rsp+24]
	movaps	XMMWORD PTR [rsp+24], xmm1
	cmp	r9, 4
	je	.L29
	mov	edx, 4
.L30:
	mov	r12, r9
	sub	r12, rdx
	cmp	r12, 1
	je	.L27
.L23:
	lea	r14, [rax+rdx]
	movaps	xmm2, xmm0
	movq	xmm1, QWORD PTR [rcx+r14*4]
	shufps	xmm2, xmm2, 0xe0
	movq	xmm2, xmm2
	mov	r14, r12
	and	r14, -2
	and	r12d, 1
	mulps	xmm1, xmm2
	movq	xmm2, QWORD PTR [rdi+64+rdx*4]
	movq	xmm1, xmm1
	addps	xmm1, xmm2
	movlps	QWORD PTR [rdi+64+rdx*4], xmm1
	je	.L26
	add	rdx, r14
.L27:
	lea	r12, [rdx+rax]
	mulss	xmm0, DWORD PTR [rcx+r12*4]
	addss	xmm0, DWORD PTR [rsp+24+rdx*4]
	movss	DWORD PTR [rsp+24+rdx*4], xmm0
	cmp	r8, 4
	jne	.L14
	mov	rdx, QWORD PTR [rsp-112]
	movss	xmm0, DWORD PTR [rsi+rdx*4]
	cmp	rbx, 2
	jbe	.L57
	movups	xmm7, XMMWORD PTR [rcx+rax*4]
	movaps	xmm1, xmm0
	shufps	xmm1, xmm1, 0
	mulps	xmm1, xmm7
	addps	xmm1, XMMWORD PTR [rsp+56]
	movaps	XMMWORD PTR [rsp+56], xmm1
.L34:
	cmp	r9, 4
	je	.L14
	mov	edx, 4
.L33:
	mov	r12, r9
	sub	r12, rdx
	cmp	r12, 1
	je	.L35
.L31:
	lea	r14, [rax+rdx]
	movaps	xmm2, xmm0
	movq	xmm1, QWORD PTR [rcx+r14*4]
	shufps	xmm2, xmm2, 0xe0
	movq	xmm2, xmm2
	mov	r14, r12
	and	r14, -2
	and	r12d, 1
	mulps	xmm1, xmm2
	movq	xmm2, QWORD PTR [rdi+96+rdx*4]
	movq	xmm1, xmm1
	addps	xmm1, xmm2
	movlps	QWORD PTR [rdi+96+rdx*4], xmm1
	je	.L14
	add	rdx, r14
.L35:
	lea	r12, [rdx+rax]
	mulss	xmm0, DWORD PTR [rcx+r12*4]
	addss	xmm0, DWORD PTR [rsp+56+rdx*4]
	movss	DWORD PTR [rsp+56+rdx*4], xmm0
.L14:
	add	rsi, 4
	add	rax, r10
	cmp	rsi, r13
	jne	.L36
.L93:
	mov	r12, QWORD PTR [rsp-104]
	mov	r14, QWORD PTR [rsp-96]
.L3:
	add	r12, r10
	add	r14, r10
	cmp	r12, r11
	jb	.L37
	mov	rsi, QWORD PTR [rsp-56]
	mov	r13, QWORD PTR [rsp-48]
	mov	rbp, QWORD PTR [rsp+104]
	.cfi_restore 6
	mov	r12, QWORD PTR [rsp+112]
	.cfi_restore 12
	mov	r14, QWORD PTR [rsp+128]
	.cfi_restore 14
.L2:
	mov	rax, QWORD PTR [rsi+8]
	mov	rdx, QWORD PTR [rsi+16]
	sal	r9, 2
	lea	r10d, [r9-1]
	mov	r11d, r9d
	lea	rcx, [0+rax*4]
	mov	ebx, r10d
	imul	rax, r13
	add	rax, QWORD PTR [rsp+152]
	and	ebx, -64
	add	rax, QWORD PTR [rsp-64]
	lea	rdx, [rdx+rax*4]
	mov	rax, r8
	sal	rax, 5
	add	rax, rdi
.L47:
	cmp	r9d, 64
	jnb	.L38
	test	r9b, 32
	jne	.L105
	test	r9b, 16
	jne	.L106
	test	r9b, 8
	jne	.L107
	test	r9b, 4
	jne	.L108
	test	r9d, r9d
	je	.L39
	movzx	esi, BYTE PTR [rdi]
	mov	BYTE PTR [rdx], sil
.L39:
	add	rdi, 32
	add	rdx, rcx
	cmp	rax, rdi
	jne	.L47
	mov	rbx, QWORD PTR [rsp+96]
	mov	r13, QWORD PTR [rsp+120]
	mov	r15, QWORD PTR [rsp+136]
	add	rsp, 144
	.cfi_def_cfa_offset 8
	ret
.L98:
	.cfi_def_cfa_offset 152
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 14, -24
	add	rsi, 4
	cmp	rsi, r13
	jne	.L96
	jmp	.L93
.L8:
	cmp	r8, 1
	je	.L14
	movss	xmm0, DWORD PTR [rsi+r11*4]
	cmp	rbx, 2
	ja	.L16
	mov	r12d, 2
	xor	edx, edx
	jmp	.L15
.L18:
	cmp	r8, 2
	jbe	.L14
	movss	xmm0, DWORD PTR [rsi+r11*8]
	cmp	rbx, 2
	ja	.L24
	mov	r12, r9
	xor	edx, edx
	jmp	.L23
.L26:
	cmp	r8, 4
	jne	.L14
	mov	rdx, QWORD PTR [rsp-112]
	movss	xmm0, DWORD PTR [rsi+rdx*4]
	cmp	rbx, 2
	ja	.L32
	mov	r12, r9
	xor	edx, edx
	jmp	.L31
.L102:
	xor	edx, edx
	jmp	.L12
.L103:
	xor	edx, edx
	jmp	.L22
.L104:
	xor	edx, edx
	jmp	.L30
.L38:
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 14
	lea	r8, [rdi+r11]
	movdqu	xmm0, XMMWORD PTR [r8-64]
	movups	XMMWORD PTR [rdx-64+r11], xmm0
	movdqu	xmm0, XMMWORD PTR [r8-48]
	movups	XMMWORD PTR [rdx-48+r11], xmm0
	movdqu	xmm0, XMMWORD PTR [r8-32]
	movups	XMMWORD PTR [rdx-32+r11], xmm0
	movdqu	xmm0, XMMWORD PTR [r8-16]
	movups	XMMWORD PTR [rdx-16+r11], xmm0
	cmp	r10d, 64
	jb	.L39
	xor	r8d, r8d
.L45:
	mov	esi, r8d
	add	r8d, 64
	movdqu	xmm3, XMMWORD PTR [rdi+rsi]
	movdqu	xmm2, XMMWORD PTR [rdi+16+rsi]
	movdqu	xmm1, XMMWORD PTR [rdi+32+rsi]
	movdqu	xmm0, XMMWORD PTR [rdi+48+rsi]
	movups	XMMWORD PTR [rdx+rsi], xmm3
	movups	XMMWORD PTR [rdx+16+rsi], xmm2
	movups	XMMWORD PTR [rdx+32+rsi], xmm1
	movups	XMMWORD PTR [rdx+48+rsi], xmm0
	cmp	r8d, ebx
	jb	.L45
	jmp	.L39
.L57:
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 14, -24
	xor	edx, edx
	jmp	.L33
.L105:
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 14
	movdqu	xmm0, XMMWORD PTR [rdi]
	mov	r8d, r9d
	lea	rsi, [rdx+32+r8]
	lea	r8, [rdi+32+r8]
	movups	XMMWORD PTR [rdx], xmm0
	movdqu	xmm0, XMMWORD PTR [rdi+16]
	movups	XMMWORD PTR [rdx+16], xmm0
	movdqu	xmm0, XMMWORD PTR [r8-64]
	movups	XMMWORD PTR [rsi-64], xmm0
	movdqu	xmm0, XMMWORD PTR [r8-48]
	movups	XMMWORD PTR [rsi-48], xmm0
	jmp	.L39
.L108:
	mov	esi, DWORD PTR [rdi]
	mov	DWORD PTR [rdx], esi
	mov	esi, r9d
	mov	r8d, DWORD PTR [rdi-4+rsi]
	mov	DWORD PTR [rdx-4+rsi], r8d
	jmp	.L39
.L106:
	movdqu	xmm0, XMMWORD PTR [rdi]
	mov	esi, r9d
	movups	XMMWORD PTR [rdx], xmm0
	movdqu	xmm0, XMMWORD PTR [rdi-16+rsi]
	movups	XMMWORD PTR [rdx-16+rsi], xmm0
	jmp	.L39
.L107:
	mov	rsi, QWORD PTR [rdi]
	mov	QWORD PTR [rdx], rsi
	mov	esi, r9d
	mov	r8, QWORD PTR [rdi-8+rsi]
	mov	QWORD PTR [rdx-8+rsi], r8
	jmp	.L39
.L101:
	lea	rdi, [rsp-40]
	jmp	.L2
	.cfi_endproc
.LFE10884:
	.size	"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm", .-"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm"
	.p2align 4
	.type	"_ZN4gemm12_GLOBAL__N_1L14gemm_avx2_implERKNS_6MatrixERKNS_7PackedBERS1_", @function
"_ZN4gemm12_GLOBAL__N_1L14gemm_avx2_implERKNS_6MatrixERKNS_7PackedBERS1_":
.LFB10887:
	.cfi_startproc
	lea	r10, [rsp+8]
	.cfi_def_cfa 10, 0
	and	rsp, -32
	push	QWORD PTR [r10-8]
	push	rbp
	mov	rbp, rsp
	.cfi_escape 0x10,0x6,0x2,0x76,0
	push	r15
	push	r14
	push	r13
	push	r12
	push	r10
	.cfi_escape 0xf,0x3,0x76,0x58,0x6
	.cfi_escape 0x10,0xf,0x2,0x76,0x78
	.cfi_escape 0x10,0xe,0x2,0x76,0x70
	.cfi_escape 0x10,0xd,0x2,0x76,0x68
	.cfi_escape 0x10,0xc,0x2,0x76,0x60
	push	rbx
	add	rsp, -128
	.cfi_escape 0x10,0x3,0x2,0x76,0x50
	mov	r12, QWORD PTR [rdi]
	test	r12, r12
	je	.L149
	mov	rax, QWORD PTR [rsi+8]
	mov	QWORD PTR [rbp-96], rsi
	xor	r15d, r15d
	mov	r14, rdi
	mov	rcx, QWORD PTR [rsi+16]
	mov	r13, rdx
	test	rax, rax
	je	.L148
.L152:
	lea	rbx, [rcx+r15]
	mov	QWORD PTR [rbp-88], 0
	cmp	rbx, r12
	mov	QWORD PTR [rbp-152], rbx
	cmovbe	r12, rbx
	mov	rsi, r12
	mov	r12, r13
	mov	r13, rcx
.L121:
	cmp	r15, rsi
	jnb	.L111
	mov	rdx, rax
	sub	rdx, QWORD PTR [rbp-88]
	cmp	rdx, r13
	cmova	rdx, r13
	mov	QWORD PTR [rbp-144], rdx
	test	rdx, rdx
	je	.L111
	mov	QWORD PTR [rbp-80], r15
	mov	rax, r12
	mov	rbx, rsi
	mov	r12, r14
	mov	QWORD PTR [rbp-160], r13
	mov	r14, rax
	mov	QWORD PTR [rbp-168], r15
.L120:
	mov	edx, 4
	mov	rax, rbx
	sub	rax, QWORD PTR [rbp-80]
	mov	QWORD PTR [rbp-136], rbx
	cmp	rax, rdx
	mov	r15, QWORD PTR [rbp-144]
	cmovbe	rdx, rax
	cmp	rax, 3
	seta	BYTE PTR [rbp-113]
	xor	r13d, r13d
	mov	QWORD PTR [rbp-128], rdx
	.p2align 4
	.p2align 3
.L119:
	mov	rax, r15
	sub	rax, r13
	cmp	rax, 7
	jbe	.L113
	cmp	BYTE PTR [rbp-113], 0
	je	.L113
	mov	rcx, QWORD PTR [r12+8]
	test	rcx, rcx
	je	.L123
	mov	rbx, QWORD PTR [rbp-96]
	xor	edx, edx
	mov	QWORD PTR [rbp-104], r15
	vxorps	xmm1, xmm1, xmm1
	mov	QWORD PTR [rbp-112], r14
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	vxorps	xmm4, xmm4, xmm4
	mov	r10, QWORD PTR [rbx+16]
	mov	rax, QWORD PTR [rbx+24]
	xor	r11d, r11d
	mov	rbx, QWORD PTR [rbx+32]
	mov	QWORD PTR [rbp-56], rax
	mov	rax, r10
	lea	r8, [0+r10*4]
	imul	rax, r10
	mov	QWORD PTR [rbp-64], rbx
	mov	rbx, QWORD PTR [rbp-80]
	imul	rbx, rcx
	mov	QWORD PTR [rbp-72], rax
	mov	rax, QWORD PTR [rbp-88]
	div	r10
	lea	rsi, [rbx+rcx*2]
	lea	rdi, [rsi+rcx]
	sub	rsi, rbx
	sub	rdi, rbx
	mov	r14, rax
	.p2align 4
	.p2align 3
.L117:
	mov	r9, rcx
	sub	r9, r11
	cmp	r9, r10
	cmova	r9, r10
	test	r9, r9
	je	.L115
	mov	rax, r11
	xor	edx, edx
	mov	r15, QWORD PTR [r12+16]
	add	r9, rbx
	div	r10
	mov	rdx, QWORD PTR [rbp-64]
	lea	r9, [r15+r9*4]
	imul	rax, QWORD PTR [rbp-56]
	add	rax, r14
	imul	rax, QWORD PTR [rbp-72]
	add	rax, r13
	lea	rdx, [rdx+rax*4]
	lea	rax, [r15+rbx*4]
	.p2align 6
	.p2align 4
	.p2align 3
.L116:
	vmovups	ymm0, YMMWORD PTR [rdx]
	vbroadcastss	ymm5, DWORD PTR [rax]
	add	rdx, r8
	vfmadd231ps	ymm4, ymm5, ymm0
	vbroadcastss	ymm5, DWORD PTR [rax+rcx*4]
	vfmadd231ps	ymm3, ymm5, ymm0
	vbroadcastss	ymm5, DWORD PTR [rax+rsi*4]
	vfmadd231ps	ymm2, ymm5, ymm0
	vbroadcastss	ymm5, DWORD PTR [rax+rdi*4]
	add	rax, 4
	vfmadd231ps	ymm1, ymm5, ymm0
	cmp	rax, r9
	jne	.L116
.L115:
	add	r11, r10
	add	rbx, r10
	cmp	r11, rcx
	jb	.L117
	mov	r15, QWORD PTR [rbp-104]
	mov	r14, QWORD PTR [rbp-112]
.L114:
	mov	rcx, QWORD PTR [r14+8]
	mov	rdx, QWORD PTR [rbp-80]
	mov	rax, QWORD PTR [rbp-88]
	mov	rsi, QWORD PTR [r14+16]
	imul	rdx, rcx
	add	rax, r13
	lea	rdi, [rax+rdx]
	add	rdx, rcx
	vmovups	YMMWORD PTR [rsi+rdi*4], ymm4
	mov	rsi, QWORD PTR [r14+16]
	lea	rdi, [rax+rdx]
	add	rdx, rcx
	vmovups	YMMWORD PTR [rsi+rdi*4], ymm3
	mov	rsi, QWORD PTR [r14+16]
	lea	rdi, [rax+rdx]
	add	rax, rcx
	add	rax, rdx
	vmovups	YMMWORD PTR [rsi+rdi*4], ymm2
	mov	rdx, QWORD PTR [r14+16]
	vmovups	YMMWORD PTR [rdx+rax*4], ymm1
.L118:
	add	r13, 8
	cmp	r13, r15
	jb	.L119
	add	QWORD PTR [rbp-80], 4
	mov	rbx, QWORD PTR [rbp-136]
	cmp	QWORD PTR [rbp-80], rbx
	jb	.L120
	mov	rax, r14
	mov	r14, r12
	mov	r13, QWORD PTR [rbp-160]
	mov	rsi, rbx
	mov	r12, rax
	mov	rax, QWORD PTR [rbp-96]
	mov	r15, QWORD PTR [rbp-168]
	mov	rax, QWORD PTR [rax+8]
.L111:
	add	QWORD PTR [rbp-88], r13
	cmp	QWORD PTR [rbp-88], rax
	jb	.L121
	mov	rcx, r13
	mov	rbx, QWORD PTR [rbp-152]
	mov	r13, r12
	mov	r12, QWORD PTR [r14]
	cmp	rbx, r12
	jnb	.L148
	mov	r15, rbx
	test	rax, rax
	jne	.L152
.L148:
	vzeroupper
.L149:
	lea	rsp, [rbp-48]
	pop	rbx
	pop	r10
	.cfi_remember_state
	.cfi_def_cfa 10, 0
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	rbp
	lea	rsp, [r10-8]
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L113:
	.cfi_restore_state
	mov	edx, 8
	mov	r9, QWORD PTR [rbp-88]
	mov	r8, QWORD PTR [rbp-128]
	mov	rdi, r12
	cmp	rax, rdx
	mov	rcx, QWORD PTR [rbp-80]
	mov	rsi, QWORD PTR [rbp-96]
	cmova	rax, rdx
	mov	rdx, r14
	push	rax
	push	r13
	call	"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm"
	pop	rax
	pop	rdx
	jmp	.L118
.L123:
	vxorps	xmm1, xmm1, xmm1
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	vxorps	xmm4, xmm4, xmm4
	jmp	.L114
	.cfi_endproc
.LFE10887:
	.size	"_ZN4gemm12_GLOBAL__N_1L14gemm_avx2_implERKNS_6MatrixERKNS_7PackedBERS1_", .-"_ZN4gemm12_GLOBAL__N_1L14gemm_avx2_implERKNS_6MatrixERKNS_7PackedBERS1_"
	.p2align 4
	.globl	"_ZN4gemm21cpu_supports_avx2_fmaEv"
	.type	"_ZN4gemm21cpu_supports_avx2_fmaEv", @function
"_ZN4gemm21cpu_supports_avx2_fmaEv":
.LFB10888:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	call	"__cpu_indicator_init"
	mov	eax, DWORD PTR "__cpu_model"[rip+12]
	not	eax
	test	ah, 68
	sete	al
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE10888:
	.size	"_ZN4gemm21cpu_supports_avx2_fmaEv", .-"_ZN4gemm21cpu_supports_avx2_fmaEv"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"incompatible microkernel GEMM dimensions"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB1:
	.text
.LHOTB1:
	.p2align 4
	.globl	"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_"
	.type	"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_", @function
"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_":
.LFB10889:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA10889
	sub	rsp, 120
	.cfi_def_cfa_offset 128
	mov	rcx, rdx
	mov	QWORD PTR [rsp+96], r13
	.cfi_offset 13, -32
	mov	r13, rsi
	mov	rsi, QWORD PTR [rdi]
	mov	rax, QWORD PTR [r13+0]
	cmp	QWORD PTR [rdi+8], rax
	mov	QWORD PTR [rsp+80], rbp
	setne	al
	cmp	QWORD PTR [rdx], rsi
	.cfi_offset 6, -48
	mov	rbp, QWORD PTR [r13+8]
	setne	dl
	or	al, dl
	jne	.L168
	cmp	QWORD PTR [rcx+8], rbp
	jne	.L168
	test	rsi, rsi
	je	.L155
	mov	QWORD PTR [rsp+112], r15
	.cfi_offset 15, -16
	mov	r15, rdi
	mov	rdi, r13
	xor	eax, eax
	mov	QWORD PTR [rsp+104], r14
	.cfi_offset 14, -24
	mov	r14, QWORD PTR [r13+16]
	mov	r13, r15
	mov	r15, rdi
	mov	QWORD PTR [rsp+72], rbx
	mov	QWORD PTR [rsp+88], r12
	mov	QWORD PTR [rsp+48], rcx
	test	rbp, rbp
	.cfi_offset 3, -56
	.cfi_offset 12, -40
	je	.L182
.L183:
	lea	rbx, [r14+rax]
	mov	rdx, r14
	mov	r10, rbp
	cmp	rbx, rsi
	mov	QWORD PTR [rsp+56], rbx
	cmovbe	rsi, rbx
	xor	ecx, ecx
	mov	QWORD PTR [rsp+24], rsi
	.p2align 4
	.p2align 3
.L164:
	cmp	rax, QWORD PTR [rsp+24]
	jnb	.L160
	sub	r10, rcx
	cmp	r10, rdx
	cmova	r10, rdx
	test	r10, r10
	je	.L161
	mov	QWORD PTR [rsp+32], rdx
	mov	rbx, QWORD PTR [rsp+48]
	mov	r14, r10
	mov	r12, rax
	mov	QWORD PTR [rsp+16], rcx
	mov	QWORD PTR [rsp+40], rax
	.p2align 4
	.p2align 3
.L163:
	mov	rdi, QWORD PTR [rsp+24]
	mov	eax, 4
	sub	rdi, r12
	cmp	rdi, rax
	cmova	rdi, rax
	mov	rax, rbx
	xor	ebp, ebp
	mov	rbx, r14
	mov	r14, rax
	mov	QWORD PTR [rsp+8], rdi
	.p2align 4
	.p2align 3
.L162:
	mov	rdx, rbx
	mov	ecx, 8
	mov	rsi, r15
	mov	rdi, r13
	sub	rdx, rbp
	cmp	rdx, rcx
	cmova	rdx, rcx
	mov	rcx, r12
	push	rdx
	.cfi_def_cfa_offset 136
	mov	rdx, r14
	push	rbp
	.cfi_def_cfa_offset 144
	mov	r9, QWORD PTR [rsp+32]
	add	rbp, 8
	mov	r8, QWORD PTR [rsp+24]
	call	"_ZN4gemm12_GLOBAL__N_1L26compute_portable_microtileERKNS_6MatrixERKNS_7PackedBERS1_mmmmm"
	pop	rax
	.cfi_def_cfa_offset 136
	pop	rdx
	.cfi_def_cfa_offset 128
	cmp	rbp, rbx
	jb	.L162
	mov	rax, r14
	add	r12, 4
	mov	r14, rbx
	mov	rbx, rax
	cmp	r12, QWORD PTR [rsp+24]
	jb	.L163
	mov	rdx, QWORD PTR [rsp+32]
	mov	rcx, QWORD PTR [rsp+16]
	mov	rax, QWORD PTR [rsp+40]
.L161:
	mov	r10, QWORD PTR [r15+8]
.L160:
	add	rcx, rdx
	cmp	rcx, r10
	jb	.L164
	mov	rbx, QWORD PTR [rsp+56]
	mov	rsi, QWORD PTR [r13+0]
	mov	r14, rdx
	mov	rbp, r10
	cmp	rbx, rsi
	jnb	.L182
	mov	rax, rbx
	test	rbp, rbp
	jne	.L183
.L182:
	mov	rbx, QWORD PTR [rsp+72]
	.cfi_restore 3
	mov	r12, QWORD PTR [rsp+88]
	.cfi_restore 12
	mov	r14, QWORD PTR [rsp+104]
	.cfi_restore 14
	mov	r15, QWORD PTR [rsp+112]
	.cfi_restore 15
.L155:
	mov	rbp, QWORD PTR [rsp+80]
	mov	r13, QWORD PTR [rsp+96]
	add	rsp, 120
	.cfi_def_cfa_offset 8
	ret
	.section	.gcc_except_table,"a",@progbits
.LLSDA10889:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10889-.LLSDACSB10889
.LLSDACSB10889:
.LLSDACSE10889:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC10889
	.type	"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold", @function
"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold":
.LFSB10889:
.L168:
	.cfi_def_cfa_offset 128
	.cfi_offset 6, -48
	.cfi_offset 13, -32
	mov	edi, 16
	mov	QWORD PTR [rsp+72], rbx
	.cfi_offset 3, -56
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
	mov	QWORD PTR [rsp+88], r12
	mov	QWORD PTR [rsp+104], r14
	mov	QWORD PTR [rsp+112], r15
.LEHB1:
	.cfi_offset 12, -40
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L167:
	.cfi_restore 12
	.cfi_restore 14
	.cfi_restore 15
	mov	rbp, rax
	mov	rdi, rbx
	mov	QWORD PTR [rsp+88], r12
	mov	QWORD PTR [rsp+104], r14
	mov	QWORD PTR [rsp+112], r15
	.cfi_offset 12, -40
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE1:
	.cfi_endproc
.LFE10889:
	.section	.gcc_except_table
.LLSDAC10889:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC10889-.LLSDACSBC10889
.LLSDACSBC10889:
	.uleb128 .LEHB0-.LCOLDB1
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L167-.LCOLDB1
	.uleb128 0
	.uleb128 .LEHB1-.LCOLDB1
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
.LLSDACSEC10889:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_", .-"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_"
	.section	.text.unlikely
	.size	"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold", .-"_ZN4gemm20gemm_microkernel_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold"
.LCOLDE1:
	.text
.LHOTE1:
	.section	.rodata.str1.8
	.align 8
.LC2:
	.string	"AVX2/FMA is not supported by this CPU"
	.section	.text.unlikely
.LCOLDB3:
	.text
.LHOTB3:
	.p2align 4
	.globl	"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_"
	.type	"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_", @function
"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_":
.LFB10890:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA10890
	sub	rsp, 56
	.cfi_def_cfa_offset 64
	mov	rax, QWORD PTR [rsi]
	cmp	QWORD PTR [rdi+8], rax
	mov	rcx, QWORD PTR [rdx]
	setne	al
	cmp	QWORD PTR [rdi], rcx
	setne	cl
	or	al, cl
	jne	.L192
	mov	rax, QWORD PTR [rdx+8]
	cmp	QWORD PTR [rsi+8], rax
	jne	.L192
	mov	QWORD PTR [rsp+24], rdx
	mov	QWORD PTR [rsp+16], rsi
	mov	QWORD PTR [rsp+8], rdi
	call	"__cpu_indicator_init"
	mov	eax, DWORD PTR "__cpu_model"[rip+12]
	not	eax
	test	ah, 68
	jne	.L188
	mov	rdx, QWORD PTR [rsp+24]
	mov	rsi, QWORD PTR [rsp+16]
	mov	rdi, QWORD PTR [rsp+8]
	add	rsp, 56
	.cfi_def_cfa_offset 8
.LEHB2:
	jmp	"_ZN4gemm12_GLOBAL__N_1L14gemm_avx2_implERKNS_6MatrixERKNS_7PackedBERS1_"
.LEHE2:
	.section	.gcc_except_table
.LLSDA10890:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE10890-.LLSDACSB10890
.LLSDACSB10890:
	.uleb128 .LEHB2-.LFB10890
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSE10890:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC10890
	.type	"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold", @function
"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold":
.LFSB10890:
.L192:
	.cfi_def_cfa_offset 64
	mov	edi, 16
	mov	QWORD PTR [rsp+40], rbx
	.cfi_remember_state
	.cfi_offset 3, -24
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC0
	mov	rdi, rax
	mov	rbx, rax
.LEHB3:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE3:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+48], r14
.LEHB4:
	.cfi_offset 14, -16
	call	"__cxa_throw"
.LEHE4:
.L188:
	.cfi_restore_state
	mov	edi, 16
	mov	QWORD PTR [rsp+40], rbx
	.cfi_offset 3, -24
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC2
	mov	rdi, rax
	mov	rbx, rax
.LEHB5:
	call	"_ZNSt13runtime_errorC1EPKc"
.LEHE5:
	mov	edx, OFFSET FLAT:"_ZNSt13runtime_errorD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt13runtime_error"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+48], r14
.LEHB6:
	.cfi_offset 14, -16
	call	"__cxa_throw"
.L191:
	.cfi_restore 14
	mov	QWORD PTR [rsp+48], r14
	mov	rdi, rbx
	.cfi_remember_state
	.cfi_offset 14, -16
	mov	r14, rax
	call	"__cxa_free_exception"
	mov	rdi, r14
	call	"_Unwind_Resume"
.L190:
	.cfi_restore_state
	mov	QWORD PTR [rsp+48], r14
	.cfi_offset 14, -16
	mov	rdi, rbx
	mov	r14, rax
	call	"__cxa_free_exception"
	mov	rdi, r14
	call	"_Unwind_Resume"
.LEHE6:
	.cfi_endproc
.LFE10890:
	.section	.gcc_except_table
.LLSDAC10890:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC10890-.LLSDACSBC10890
.LLSDACSBC10890:
	.uleb128 .LEHB3-.LCOLDB3
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L191-.LCOLDB3
	.uleb128 0
	.uleb128 .LEHB4-.LCOLDB3
	.uleb128 .LEHE4-.LEHB4
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB5-.LCOLDB3
	.uleb128 .LEHE5-.LEHB5
	.uleb128 .L190-.LCOLDB3
	.uleb128 0
	.uleb128 .LEHB6-.LCOLDB3
	.uleb128 .LEHE6-.LEHB6
	.uleb128 0
	.uleb128 0
.LLSDACSEC10890:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_", .-"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_"
	.section	.text.unlikely
	.size	"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold", .-"_ZN4gemm13gemm_avx2_4x8ERKNS_6MatrixERKNS_7PackedBERS0_.cold"
.LCOLDE3:
	.text
.LHOTE3:
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
