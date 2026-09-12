	.file	"gemm_blocked.cpp"
	.intel_syntax noprefix
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"incompatible GEMM matrix dimensions"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"block size must be positive"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB2:
	.text
.LHOTB2:
	.p2align 4
	.globl	"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m"
	.type	"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m", @function
"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m":
.LFB3551:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3551
	sub	rsp, 328
	.cfi_def_cfa_offset 336
	mov	QWORD PTR [rsp+280], rbx
	.cfi_offset 3, -56
	mov	rbx, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+192], rdi
	mov	QWORD PTR [rsp+200], rsi
	mov	QWORD PTR [rsp+176], rdx
	mov	QWORD PTR [rsp+152], rcx
	mov	QWORD PTR [rsp+96], rbx
	cmp	rbx, QWORD PTR [rsi]
	jne	.L2
	mov	QWORD PTR [rsp+288], rbp
	.cfi_offset 6, -48
	mov	rbp, QWORD PTR [rdi]
	cmp	QWORD PTR [rdx], rbp
	jne	.L56
	mov	rax, QWORD PTR [rdx+8]
	mov	rdx, QWORD PTR [rsi+8]
	mov	QWORD PTR [rsp+112], rax
	mov	QWORD PTR [rsp+32], rdx
	cmp	rax, rdx
	jne	.L57
	test	rcx, rcx
	je	.L3
	test	rbp, rbp
	je	.L1
	test	rax, rax
	je	.L1
	sal	rax, 2
	mov	QWORD PTR [rsp+320], r15
	xor	ebx, ebx
	mov	QWORD PTR [rsp+24], rax
	mov	QWORD PTR [rsp+296], r12
	.cfi_offset 15, -16
	.cfi_offset 12, -40
	xor	r12d, r12d
.L5:
	mov	rax, QWORD PTR [rsp+176]
	mov	r15, QWORD PTR [rsp+24]
	xor	esi, esi
	add	rbx, 1
	mov	rdi, QWORD PTR [rax+16]
	mov	rdx, r15
	add	rdi, r12
	add	r12, r15
	call	"memset"
	cmp	rbp, rbx
	jne	.L5
	mov	rsi, QWORD PTR [rsp+96]
	test	rsi, rsi
	je	.L58
	mov	rax, QWORD PTR [rsp+152]
	mov	QWORD PTR [rsp+160], 0
	mov	QWORD PTR [rsp+168], 0
	mov	rdx, rax
	imul	rdx, rsi
	mov	rsi, QWORD PTR [rsp+112]
	imul	rsi, rax
	imul	rax, QWORD PTR [rsp+32]
	mov	QWORD PTR [rsp+184], rax
	xor	eax, eax
.L24:
	mov	r8, rax
	add	rax, QWORD PTR [rsp+152]
	mov	rbx, rbp
	cmp	rax, rbp
	cmovbe	rbx, rax
	mov	QWORD PTR [rsp+120], rbx
	cmp	r8, rbx
	jnb	.L6
	mov	rbx, QWORD PTR [rsp+160]
	mov	QWORD PTR [rsp+304], r13
	xor	ecx, ecx
	mov	QWORD PTR [rsp+312], r14
	mov	QWORD PTR [rsp+208], rax
	lea	r9, [0+rbx*4]
	mov	QWORD PTR [rsp+216], rbp
	.cfi_offset 13, -32
	.cfi_offset 14, -24
.L23:
	mov	rax, QWORD PTR [rsp+32]
	mov	r15, rcx
	add	rcx, QWORD PTR [rsp+152]
	mov	QWORD PTR [rsp+104], 0
	mov	QWORD PTR [rsp+224], rcx
	cmp	rcx, rax
	mov	QWORD PTR [rsp+240], rsi
	cmovbe	rax, rcx
	mov	QWORD PTR [rsp+232], rdx
	xor	edi, edi
	mov	rbx, rax
	mov	r12, rax
	sub	rbx, r15
	mov	rdx, r12
	lea	rax, [rbx-1]
	mov	QWORD PTR [rsp+8], rbx
	mov	QWORD PTR [rsp+40], rax
	mov	rax, rbx
	shr	rax, 2
	lea	r13, [0+rax*4]
	mov	r14, rax
	mov	rax, r9
	sub	rbx, r13
	sal	r14, 4
	mov	QWORD PTR [rsp+56], rbx
.L22:
	mov	rbx, QWORD PTR [rsp+96]
	mov	rsi, rdi
	add	rdi, QWORD PTR [rsp+152]
	cmp	rdi, rbx
	cmovbe	rbx, rdi
	mov	rcx, rbx
	cmp	rsi, rbx
	jnb	.L7
	cmp	r15, rdx
	jnb	.L7
	mov	rbx, QWORD PTR [rsp+160]
	mov	QWORD PTR [rsp+248], rdi
	mov	rbp, rax
	mov	QWORD PTR [rsp+256], r8
	add	rbx, r15
	mov	QWORD PTR [rsp+264], rax
	mov	QWORD PTR [rsp+48], rbx
	mov	rbx, QWORD PTR [rsp+192]
	mov	r12, QWORD PTR [rbx+16]
	mov	rbx, QWORD PTR [rsp+104]
	add	rbx, r15
	lea	rsi, [r12+rsi*4]
	mov	QWORD PTR [rsp+128], rbx
	mov	rbx, QWORD PTR [rsp+200]
	mov	QWORD PTR [rsp+144], rsi
	lea	rsi, [r12+rcx*4]
	mov	r12, r8
	mov	r10, QWORD PTR [rbx+16]
	mov	rbx, QWORD PTR [rsp+176]
	mov	QWORD PTR [rsp+136], rsi
	mov	r11, QWORD PTR [rbx+16]
	mov	rbx, QWORD PTR [rsp+168]
	.p2align 4
	.p2align 3
.L8:
	mov	rdi, QWORD PTR [rsp+48]
	mov	r9, QWORD PTR [rsp+104]
	mov	QWORD PTR [rsp+88], r12
	mov	rsi, QWORD PTR [rsp+144]
	mov	rcx, QWORD PTR [rsp+136]
	mov	QWORD PTR [rsp+80], rbp
	mov	rax, rdi
	sub	rax, r15
	mov	QWORD PTR [rsp+64], rax
	lea	rax, [0+rbx*4]
	add	rsi, rax
	add	rax, rcx
	mov	QWORD PTR [rsp+16], rax
	lea	rax, [r11+rdi*4]
	mov	rdi, QWORD PTR [rsp+128]
	lea	r8, [0+rdi*4]
	lea	rdi, [r11+rbp]
	mov	rbp, rbx
	mov	QWORD PTR [rsp+72], rdi
.L21:
	movss	xmm2, DWORD PTR [rsi]
	cmp	QWORD PTR [rsp+8], 1
	je	.L10
.L9:
	lea	rdi, [r10+4+r8]
	mov	rcx, rax
	sub	rcx, rdi
	cmp	rcx, 8
	jbe	.L10
	cmp	QWORD PTR [rsp+40], 2
	jbe	.L27
	movaps	xmm1, xmm2
	lea	rdi, [r10+r8]
	xor	ecx, ecx
	shufps	xmm1, xmm1, 0
	.p2align 5
	.p2align 4
	.p2align 3
.L12:
	movups	xmm0, XMMWORD PTR [rdi+rcx]
	movups	xmm3, XMMWORD PTR [rax+rcx]
	mulps	xmm0, xmm1
	addps	xmm0, xmm3
	movups	XMMWORD PTR [rax+rcx], xmm0
	add	rcx, 16
	cmp	rcx, r14
	jne	.L12
	mov	rcx, r13
	cmp	QWORD PTR [rsp+8], r13
	je	.L15
	mov	r12, QWORD PTR [rsp+56]
	lea	rdi, [r13+0+r15]
	mov	rbx, r12
	cmp	r12, 1
	je	.L14
.L11:
	mov	r12, QWORD PTR [rsp+48]
	movaps	xmm1, xmm2
	shufps	xmm1, xmm1, 0xe0
	movq	xmm1, xmm1
	add	r12, rcx
	add	rcx, r9
	add	rcx, r15
	movq	xmm0, QWORD PTR [r10+rcx*4]
	mov	rcx, rbx
	and	rcx, -2
	and	ebx, 1
	mulps	xmm0, xmm1
	movq	xmm1, QWORD PTR [r11+r12*4]
	movq	xmm0, xmm0
	addps	xmm0, xmm1
	movlps	QWORD PTR [r11+r12*4], xmm0
	je	.L15
	add	rdi, rcx
.L14:
	mov	rbx, QWORD PTR [rsp+64]
	add	rsi, 4
	lea	rcx, [rbx+rdi]
	add	rdi, r9
	mulss	xmm2, DWORD PTR [r10+rdi*4]
	addss	xmm2, DWORD PTR [r11+rcx*4]
	movss	DWORD PTR [r11+rcx*4], xmm2
	cmp	rsi, QWORD PTR [rsp+16]
	je	.L53
.L59:
	movss	xmm2, DWORD PTR [rsi]
	add	r9, QWORD PTR [rsp+32]
	add	r8, QWORD PTR [rsp+24]
	jmp	.L9
	.p2align 4,,10
	.p2align 3
.L15:
	add	rsi, 4
	cmp	QWORD PTR [rsp+16], rsi
	jne	.L59
.L53:
	mov	r12, QWORD PTR [rsp+88]
	mov	rbx, rbp
	mov	rsi, QWORD PTR [rsp+112]
	mov	rbp, QWORD PTR [rsp+80]
	add	QWORD PTR [rsp+48], rsi
	add	r12, 1
	add	rbp, QWORD PTR [rsp+24]
	add	rbx, QWORD PTR [rsp+96]
	cmp	r12, QWORD PTR [rsp+120]
	jne	.L8
	mov	rdi, QWORD PTR [rsp+248]
	mov	r8, QWORD PTR [rsp+256]
	mov	rax, QWORD PTR [rsp+264]
.L7:
	mov	rbx, QWORD PTR [rsp+184]
	add	QWORD PTR [rsp+104], rbx
	cmp	rdi, QWORD PTR [rsp+96]
	jb	.L22
	mov	rcx, QWORD PTR [rsp+224]
	mov	rdx, QWORD PTR [rsp+232]
	mov	r9, rax
	mov	rsi, QWORD PTR [rsp+240]
	cmp	rcx, QWORD PTR [rsp+32]
	jb	.L23
	mov	rax, QWORD PTR [rsp+208]
	mov	rbp, QWORD PTR [rsp+216]
	mov	r13, QWORD PTR [rsp+304]
	.cfi_restore 13
	mov	r14, QWORD PTR [rsp+312]
	.cfi_restore 14
.L6:
	add	QWORD PTR [rsp+168], rdx
	add	QWORD PTR [rsp+160], rsi
	cmp	rax, rbp
	jb	.L24
.L58:
	mov	r12, QWORD PTR [rsp+296]
	.cfi_restore 12
	mov	r15, QWORD PTR [rsp+320]
	.cfi_restore 15
.L1:
	mov	rbp, QWORD PTR [rsp+288]
	.cfi_restore 6
	mov	rbx, QWORD PTR [rsp+280]
	add	rsp, 328
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L10:
	.cfi_def_cfa_offset 336
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	mov	rdi, QWORD PTR [rsp+72]
	lea	rbx, [r10+r9*4]
	mov	rcx, r15
	.p2align 5
	.p2align 4
	.p2align 3
.L18:
	movss	xmm0, DWORD PTR [rbx+rcx*4]
	mulss	xmm0, xmm2
	addss	xmm0, DWORD PTR [rdi+rcx*4]
	movss	DWORD PTR [rdi+rcx*4], xmm0
	add	rcx, 1
	cmp	rdx, rcx
	jne	.L18
	add	rsi, 4
	add	r9, QWORD PTR [rsp+32]
	add	r8, QWORD PTR [rsp+24]
	cmp	QWORD PTR [rsp+16], rsi
	jne	.L21
	jmp	.L53
.L27:
	mov	rbx, QWORD PTR [rsp+8]
	mov	rdi, r15
	xor	ecx, ecx
	jmp	.L11
.L57:
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	rbp, QWORD PTR [rsp+288]
	.cfi_remember_state
	.cfi_restore 6
	jmp	.L2
.L56:
	.cfi_restore_state
	mov	rbp, QWORD PTR [rsp+288]
	.cfi_restore 6
	jmp	.L2
	.section	.gcc_except_table,"a",@progbits
.LLSDA3551:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3551-.LLSDACSB3551
.LLSDACSB3551:
.LLSDACSE3551:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3551
	.type	"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m.cold", @function
"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m.cold":
.LFSB3551:
.L2:
	.cfi_def_cfa_offset 336
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
	mov	QWORD PTR [rsp+288], rbp
	mov	QWORD PTR [rsp+296], r12
	mov	QWORD PTR [rsp+304], r13
	mov	QWORD PTR [rsp+312], r14
	mov	QWORD PTR [rsp+320], r15
.LEHB1:
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.LEHE1:
.L3:
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC1
	mov	rdi, rax
	mov	rbx, rax
.LEHB2:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE2:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+296], r12
	mov	QWORD PTR [rsp+304], r13
	mov	QWORD PTR [rsp+312], r14
	mov	QWORD PTR [rsp+320], r15
.LEHB3:
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L28:
	.cfi_restore 6
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	QWORD PTR [rsp+288], rbp
	mov	rdi, rbx
	.cfi_offset 6, -48
	mov	rbp, rax
	mov	QWORD PTR [rsp+296], r12
	mov	QWORD PTR [rsp+304], r13
	mov	QWORD PTR [rsp+312], r14
	mov	QWORD PTR [rsp+320], r15
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.L29:
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	rbp, rax
	mov	rdi, rbx
	mov	QWORD PTR [rsp+296], r12
	mov	QWORD PTR [rsp+304], r13
	mov	QWORD PTR [rsp+312], r14
	mov	QWORD PTR [rsp+320], r15
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE3:
	.cfi_endproc
.LFE3551:
	.section	.gcc_except_table
.LLSDAC3551:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3551-.LLSDACSBC3551
.LLSDACSBC3551:
	.uleb128 .LEHB0-.LCOLDB2
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L28-.LCOLDB2
	.uleb128 0
	.uleb128 .LEHB1-.LCOLDB2
	.uleb128 .LEHE1-.LEHB1
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB2-.LCOLDB2
	.uleb128 .LEHE2-.LEHB2
	.uleb128 .L29-.LCOLDB2
	.uleb128 0
	.uleb128 .LEHB3-.LCOLDB2
	.uleb128 .LEHE3-.LEHB3
	.uleb128 0
	.uleb128 0
.LLSDACSEC3551:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m", .-"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m"
	.section	.text.unlikely
	.size	"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m.cold", .-"_ZN4gemm12gemm_blockedERKNS_6MatrixES2_RS0_m.cold"
.LCOLDE2:
	.text
.LHOTE2:
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
