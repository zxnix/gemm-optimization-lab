	.file	"gemm_packed.cpp"
	.intel_syntax noprefix
	.text
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC0:
	.string	"packed B dimensions and block size must be positive"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"packed B tile size overflow"
	.section	.rodata.str1.8
	.align 8
.LC2:
	.string	"packed B element count overflow"
	.align 8
.LC3:
	.string	"cannot create std::vector larger than max_size()"
	.section	.text.unlikely,"ax",@progbits
	.align 2
.LCOLDB4:
	.text
.LHOTB4:
	.align 2
	.p2align 4
	.globl	"_ZN4gemm7PackedBC2Emmm"
	.type	"_ZN4gemm7PackedBC2Emmm", @function
"_ZN4gemm7PackedBC2Emmm":
.LFB3560:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3560
	push	r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	push	rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	mov	rbp, rdi
	push	rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	mov	QWORD PTR [rdi], rsi
	mov	QWORD PTR [rdi+8], rdx
	mov	QWORD PTR [rdi+16], rcx
	test	rcx, rcx
	je	.L2
	mov	rax, rdx
	mov	r8, rdx
	xor	edx, edx
	div	rcx
	mov	rdi, rax
	cmp	rdx, 1
	sbb	rdi, -1
	mov	QWORD PTR [rbp+24], rdi
	test	rsi, rsi
	je	.L3
	test	r8, r8
	je	.L3
	mov	rax, rsi
	xor	edx, edx
	div	rcx
	mov	rsi, rax
	cmp	rdx, 1
	mov	rax, rcx
	sbb	rsi, -1
	mul	rcx
	mov	rcx, rax
	jo	.L6
	mov	rax, rdi
	mul	rsi
	jo	.L30
	mul	rcx
	jo	.L10
	mov	rbx, rax
	shr	rbx, 61
	jne	.L31
	test	rax, rax
	je	.L32
	lea	rbx, [0+rax*4]
	mov	rdi, rbx
.LEHB0:
	call	"_Znwm"
.LEHE0:
	mov	rdx, rbx
	xor	esi, esi
	lea	r12, [rax+rbx]
	mov	QWORD PTR [rbp+32], rax
	mov	rdi, rax
	mov	QWORD PTR [rbp+48], r12
	call	"memset"
	mov	QWORD PTR [rbp+40], r12
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L2:
	.cfi_restore_state
	mov	QWORD PTR [rdi+24], 0
.L3:
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC0
	mov	rdi, rax
	mov	rbx, rax
.LEHB1:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE1:
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L32:
	xor	r12d, r12d
	mov	QWORD PTR [rbp+32], 0
	mov	QWORD PTR [rbp+48], 0
	mov	QWORD PTR [rbp+40], r12
	pop	rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	pop	rbp
	.cfi_def_cfa_offset 16
	pop	r12
	.cfi_def_cfa_offset 8
	ret
.L30:
	.cfi_restore_state
	jmp	.L10
.L31:
	jmp	.L14
.L23:
	mov	rbp, rax
	jmp	.L16
	.section	.gcc_except_table,"a",@progbits
.LLSDA3560:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3560-.LLSDACSB3560
.LLSDACSB3560:
	.uleb128 .LEHB0-.LFB3560
	.uleb128 .LEHE0-.LEHB0
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB1-.LFB3560
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L23-.LFB3560
	.uleb128 0
.LLSDACSE3560:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3560
	.type	"_ZN4gemm7PackedBC2Emmm.cold", @function
"_ZN4gemm7PackedBC2Emmm.cold":
.LFSB3560:
.L6:
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	.cfi_offset 6, -24
	.cfi_offset 12, -16
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC1
	mov	rdi, rax
	mov	rbx, rax
.LEHB2:
	call	"_ZNSt12length_errorC1EPKc"
.LEHE2:
	mov	edx, OFFSET FLAT:"_ZNSt12length_errorD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt12length_error"
	mov	rdi, rbx
.LEHB3:
	call	"__cxa_throw"
.L24:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	call	"__cxa_throw"
.LEHE3:
.L10:
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC2
	mov	rdi, rax
	mov	rbx, rax
.LEHB4:
	call	"_ZNSt12length_errorC1EPKc"
.LEHE4:
	mov	edx, OFFSET FLAT:"_ZNSt12length_errorD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt12length_error"
	mov	rdi, rbx
.LEHB5:
	call	"__cxa_throw"
.L14:
	mov	edi, OFFSET FLAT:.LC3
	call	"_ZSt20__throw_length_errorPKc"
.L21:
	mov	rbp, rax
	mov	rdi, rbx
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.L22:
	mov	rbp, rax
	mov	rdi, rbx
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.L16:
	mov	rdi, rbx
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE5:
	.cfi_endproc
.LFE3560:
	.section	.gcc_except_table
.LLSDAC3560:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3560-.LLSDACSBC3560
.LLSDACSBC3560:
	.uleb128 .LEHB2-.LCOLDB4
	.uleb128 .LEHE2-.LEHB2
	.uleb128 .L22-.LCOLDB4
	.uleb128 0
	.uleb128 .LEHB3-.LCOLDB4
	.uleb128 .LEHE3-.LEHB3
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB4-.LCOLDB4
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L21-.LCOLDB4
	.uleb128 0
	.uleb128 .LEHB5-.LCOLDB4
	.uleb128 .LEHE5-.LEHB5
	.uleb128 0
	.uleb128 0
.LLSDACSEC3560:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm7PackedBC2Emmm", .-"_ZN4gemm7PackedBC2Emmm"
	.section	.text.unlikely
	.size	"_ZN4gemm7PackedBC2Emmm.cold", .-"_ZN4gemm7PackedBC2Emmm.cold"
.LCOLDE4:
	.text
.LHOTE4:
	.globl	"_ZN4gemm7PackedBC1Emmm"
	.set	"_ZN4gemm7PackedBC1Emmm","_ZN4gemm7PackedBC2Emmm"
	.section	.rodata.str1.8
	.align 8
.LC5:
	.string	"B and packed B dimensions do not match"
	.section	.text.unlikely
.LCOLDB6:
	.text
.LHOTB6:
	.p2align 4
	.globl	"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE"
	.type	"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE", @function
"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE":
.LFB3562:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3562
	sub	rsp, 136
	.cfi_def_cfa_offset 144
	mov	QWORD PTR [rsp+104], r12
	.cfi_offset 12, -40
	mov	r12, QWORD PTR [rdi]
	cmp	r12, QWORD PTR [rsi]
	mov	QWORD PTR [rsp+88], rbx
	.cfi_offset 3, -56
	jne	.L73
	mov	QWORD PTR [rsp+128], r15
	mov	rbx, QWORD PTR [rdi+8]
	.cfi_offset 15, -16
	mov	r15, rdi
	mov	r8, rsi
	cmp	rbx, QWORD PTR [rsi+8]
	jne	.L74
	mov	r10, QWORD PTR [rsi+16]
	xor	edx, edx
	mov	rax, r12
	mov	QWORD PTR [rsp+96], rbp
	.cfi_offset 6, -48
	mov	rbp, QWORD PTR [rsi+24]
	div	r10
	mov	rcx, r10
	imul	rcx, r10
	mov	QWORD PTR [rsp+48], rcx
	cmp	rdx, 1
	sbb	rax, -1
	imul	rcx, rbp
	imul	rax, rcx
	sal	rax, 2
	mov	rdx, rax
	je	.L36
	mov	rdi, QWORD PTR [rsi+32]
	mov	QWORD PTR [rsp], rsi
	xor	esi, esi
	mov	QWORD PTR [rsp+8], r10
	call	"memset"
	mov	r10, QWORD PTR [rsp+8]
	mov	r8, QWORD PTR [rsp]
.L36:
	test	r12, r12
	je	.L33
	mov	QWORD PTR [rsp+112], r13
	lea	rax, [0+r10*4]
	xor	esi, esi
	mov	QWORD PTR [rsp+120], r14
	mov	QWORD PTR [rsp+72], rbp
	mov	QWORD PTR [rsp+56], rax
	mov	rax, r12
	mov	QWORD PTR [rsp+8], r8
	mov	r8, r10
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.p2align 4
	.p2align 3
.L53:
	test	rbx, rbx
	je	.L75
	sub	rax, rsi
	cmp	rax, r8
	cmova	rax, r8
	xor	r13d, r13d
	mov	QWORD PTR [rsp+64], rax
	mov	rcx, rax
	test	rax, rax
	jne	.L78
.L38:
	add	r13, r8
	cmp	r13, rbx
	jb	.L38
	mov	rax, QWORD PTR [r15]
	add	rsi, r8
	cmp	rsi, rax
	jb	.L53
.L75:
	mov	r13, QWORD PTR [rsp+112]
	.cfi_restore 13
	mov	r14, QWORD PTR [rsp+120]
	.cfi_restore 14
.L33:
	mov	rbx, QWORD PTR [rsp+88]
	.cfi_restore 3
	mov	rbp, QWORD PTR [rsp+96]
	.cfi_restore 6
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
	mov	r12, QWORD PTR [rsp+104]
	add	rsp, 136
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L78:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	mov	rax, rsi
	xor	edx, edx
	mov	r12, r15
	div	r8
	imul	rax, QWORD PTR [rsp+72]
	mov	QWORD PTR [rsp+32], rax
	lea	rax, [rcx+rsi]
	mov	QWORD PTR [rsp+40], rax
	.p2align 4
	.p2align 3
.L40:
	mov	r10, rbx
	sub	r10, r13
	cmp	r10, r8
	cmova	r10, r8
	test	r10, r10
	je	.L67
	mov	rax, r13
	xor	edx, edx
	lea	rbp, [0+r10*4]
	div	r8
	add	rax, QWORD PTR [rsp+32]
	imul	rax, QWORD PTR [rsp+48]
	lea	r14, [0+rax*4]
	cmp	r10, 1
	je	.L79
	mov	QWORD PTR [rsp+16], r8
	mov	rax, rbx
	mov	r15, QWORD PTR [rsp+40]
	mov	rbx, r14
	mov	QWORD PTR [rsp+24], rsi
	mov	r14, QWORD PTR [rsp+56]
	mov	QWORD PTR [rsp], rbp
	mov	rbp, rsi
	.p2align 4
	.p2align 3
.L48:
	imul	rax, rbp
	mov	rdx, QWORD PTR [r12+16]
	add	rbp, 1
	add	rax, r13
	lea	rsi, [rdx+rax*4]
	mov	rax, QWORD PTR [rsp+8]
	mov	rdx, QWORD PTR [rsp]
	mov	rdi, QWORD PTR [rax+32]
	add	rdi, rbx
	add	rbx, r14
	call	"memmove"
	mov	rax, QWORD PTR [r12+8]
	cmp	rbp, r15
	jne	.L48
	mov	r8, QWORD PTR [rsp+16]
	mov	rsi, QWORD PTR [rsp+24]
	mov	rbx, rax
	add	r13, r8
	cmp	r13, rax
	jb	.L40
	mov	r15, r12
.L80:
	mov	rax, QWORD PTR [r15]
	add	rsi, r8
	cmp	rsi, rax
	jb	.L53
	jmp	.L75
.L81:
	mov	rcx, QWORD PTR [rsp+64]
	mov	r10, QWORD PTR [r12+16]
	mov	rax, r14
	mov	rdx, rsi
	mov	rdi, QWORD PTR [rsp+56]
	lea	r15, [rcx+rsi]
	mov	rcx, QWORD PTR [rsp+8]
	mov	r11, QWORD PTR [rcx+32]
	.p2align 6
	.p2align 4
	.p2align 3
.L44:
	mov	rcx, rbx
	imul	rcx, rdx
	add	rdx, 1
	add	rcx, r13
	movss	xmm0, DWORD PTR [r10+rcx*4]
	movss	DWORD PTR [r11+rax], xmm0
	add	rax, rdi
	cmp	r15, rdx
	jne	.L44
	.p2align 4
	.p2align 3
.L67:
	add	r13, r8
	cmp	r13, rbx
	jb	.L40
	mov	r15, r12
	jmp	.L80
.L79:
	cmp	r8, 1
	jne	.L81
	mov	rdx, rsi
	mov	rcx, QWORD PTR [r12+16]
	imul	rdx, rbx
	add	rdx, r13
	add	r13, 1
	movss	xmm0, DWORD PTR [rcx+rdx*4]
	mov	rcx, QWORD PTR [rsp+8]
	mov	rdx, QWORD PTR [rcx+32]
	movss	DWORD PTR [rdx+rax*4], xmm0
	cmp	r13, rbx
	jb	.L40
	mov	r15, r12
	jmp	.L80
.L73:
	.cfi_restore 6
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	jmp	.L34
.L74:
	.cfi_offset 15, -16
	mov	r15, QWORD PTR [rsp+128]
	.cfi_restore 15
	jmp	.L34
	.section	.gcc_except_table
.LLSDA3562:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3562-.LLSDACSB3562
.LLSDACSB3562:
.LLSDACSE3562:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3562
	.type	"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE.cold", @function
"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE.cold":
.LFSB3562:
.L34:
	.cfi_def_cfa_offset 144
	.cfi_offset 3, -56
	.cfi_offset 12, -40
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC5
	mov	rdi, rax
	mov	rbx, rax
.LEHB6:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE6:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+96], rbp
	mov	QWORD PTR [rsp+112], r13
	mov	QWORD PTR [rsp+120], r14
	mov	QWORD PTR [rsp+128], r15
.LEHB7:
	.cfi_remember_state
	.cfi_offset 6, -48
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L55:
	.cfi_restore_state
	mov	QWORD PTR [rsp+96], rbp
	mov	rdi, rbx
	.cfi_offset 6, -48
	mov	rbp, rax
	mov	QWORD PTR [rsp+112], r13
	mov	QWORD PTR [rsp+120], r14
	mov	QWORD PTR [rsp+128], r15
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE7:
	.cfi_endproc
.LFE3562:
	.section	.gcc_except_table
.LLSDAC3562:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3562-.LLSDACSBC3562
.LLSDACSBC3562:
	.uleb128 .LEHB6-.LCOLDB6
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L55-.LCOLDB6
	.uleb128 0
	.uleb128 .LEHB7-.LCOLDB6
	.uleb128 .LEHE7-.LEHB7
	.uleb128 0
	.uleb128 0
.LLSDACSEC3562:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE", .-"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE"
	.section	.text.unlikely
	.size	"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE.cold", .-"_ZN4gemm6pack_bERKNS_6MatrixERNS_7PackedBE.cold"
.LCOLDE6:
	.text
.LHOTE6:
	.section	.rodata.str1.8
	.align 8
.LC7:
	.string	"incompatible packed GEMM matrix dimensions"
	.section	.text.unlikely
.LCOLDB8:
	.text
.LHOTB8:
	.p2align 4
	.globl	"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_"
	.type	"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_", @function
"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_":
.LFB3563:
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDA3563
	sub	rsp, 376
	.cfi_def_cfa_offset 384
	mov	QWORD PTR [rsp+328], rbx
	.cfi_offset 3, -56
	mov	rbx, QWORD PTR [rdi+8]
	mov	QWORD PTR [rsp+248], rdi
	mov	QWORD PTR [rsp+112], rbx
	cmp	rbx, QWORD PTR [rsi]
	jne	.L83
	mov	rbx, QWORD PTR [rdi]
	cmp	QWORD PTR [rdx], rbx
	jne	.L83
	mov	rax, QWORD PTR [rdx+8]
	mov	r9, QWORD PTR [rsi+8]
	mov	QWORD PTR [rsp+336], rbp
	.cfi_offset 6, -48
	mov	rbp, rsi
	mov	QWORD PTR [rsp+120], rax
	cmp	rax, r9
	jne	.L136
	mov	rdi, QWORD PTR [rsi+16]
	imul	rax, rbx
	mov	QWORD PTR [rsp+368], r15
	.cfi_offset 15, -16
	mov	r15, QWORD PTR [rdx+16]
	mov	QWORD PTR [rsp+32], rdi
	mov	rdi, QWORD PTR [rsi+24]
	sal	rax, 2
	mov	QWORD PTR [rsp+192], rdi
	mov	rdx, rax
	je	.L85
	xor	esi, esi
	mov	rdi, r15
	mov	QWORD PTR [rsp+8], r9
	call	"memset"
	mov	r9, QWORD PTR [rsp+8]
.L85:
	test	rbx, rbx
	je	.L82
	test	r9, r9
	je	.L82
	mov	rsi, QWORD PTR [rsp+112]
	test	rsi, rsi
	je	.L82
	mov	rax, QWORD PTR [rsp+32]
	xor	ecx, ecx
	mov	QWORD PTR [rsp+168], 0
	mov	QWORD PTR [rsp+184], 0
	mov	rdi, rax
	imul	rdi, rax
	mov	QWORD PTR [rsp+216], rdi
	mov	rdi, rsi
	mov	rsi, QWORD PTR [rsp+120]
	imul	rdi, rax
	mov	r8, rsi
	imul	r8, rax
	lea	rax, [0+rsi*4]
	mov	QWORD PTR [rsp+208], rax
.L105:
	mov	QWORD PTR [rsp+240], rcx
	mov	rsi, rcx
	add	rcx, QWORD PTR [rsp+32]
	mov	rax, rbx
	cmp	rcx, rbx
	cmovbe	rax, rcx
	mov	QWORD PTR [rsp+136], rax
	cmp	rsi, rax
	jnb	.L87
	mov	rax, QWORD PTR [rsp+168]
	mov	rsi, QWORD PTR [rbp+32]
	mov	QWORD PTR [rsp+344], r12
	mov	QWORD PTR [rsp+360], r14
	sal	rax, 2
	mov	QWORD PTR [rsp+256], rbx
	lea	rdx, [r15+rax]
	mov	QWORD PTR [rsp+272], rbp
	mov	QWORD PTR [rsp+176], rdx
	mov	rdx, r15
	sub	rdx, rsi
	mov	QWORD PTR [rsp+264], rdi
	mov	rdi, r9
	mov	r9, QWORD PTR [rsp+208]
	add	rax, rdx
	mov	QWORD PTR [rsp+352], r13
	.cfi_offset 12, -40
	.cfi_offset 14, -24
	.cfi_offset 13, -32
	mov	r13, r15
	mov	QWORD PTR [rsp+232], rax
	mov	QWORD PTR [rsp+200], rsi
	xor	esi, esi
.L104:
	mov	rdx, QWORD PTR [rsp+32]
	mov	r12, rsi
	mov	rbx, rdi
	mov	QWORD PTR [rsp+160], 0
	mov	rax, r12
	mov	QWORD PTR [rsp+280], rcx
	add	rsi, rdx
	mov	r11, rdx
	mov	QWORD PTR [rsp+296], rdi
	cmp	rsi, rdi
	mov	QWORD PTR [rsp+288], rsi
	cmovbe	rbx, rsi
	xor	edx, edx
	mov	QWORD PTR [rsp+304], r8
	div	r11
	mov	rdx, QWORD PTR [rsp+176]
	mov	r10, rbx
	mov	r15, rax
	lea	rax, [0+r12*4]
	add	rdx, rax
	mov	QWORD PTR [rsp+312], r15
	mov	QWORD PTR [rsp+224], rdx
	mov	rdx, rbx
	sub	rdx, r12
	lea	r11, [rdx-1]
	mov	QWORD PTR [rsp+8], rdx
	mov	QWORD PTR [rsp+40], r11
	mov	r11, QWORD PTR [rsp+200]
	add	rax, r11
	mov	r15, r11
	mov	QWORD PTR [rsp+56], rax
	mov	rax, rdx
	shr	rax, 2
	lea	rbp, [0+rax*4]
	mov	r14, rax
	sub	rdx, rbp
	sal	r14, 4
	mov	QWORD PTR [rsp+64], rdx
.L103:
	mov	rax, QWORD PTR [rsp+160]
	mov	rbx, QWORD PTR [rsp+32]
	mov	rsi, QWORD PTR [rsp+112]
	mov	rdi, rax
	add	rax, rbx
	cmp	rax, rsi
	mov	QWORD PTR [rsp+160], rax
	cmovbe	rsi, rax
	cmp	rdi, rsi
	jnb	.L88
	cmp	r12, r10
	jnb	.L88
	mov	rax, rdi
	xor	edx, edx
	mov	r8, QWORD PTR [rsp+176]
	mov	QWORD PTR [rsp+88], r10
	div	rbx
	mov	rdx, QWORD PTR [rsp+240]
	mov	rcx, QWORD PTR [rsp+184]
	mov	QWORD PTR [rsp+80], r8
	mov	r11, QWORD PTR [rsp+232]
	imul	rax, QWORD PTR [rsp+192]
	add	rax, QWORD PTR [rsp+312]
	imul	rax, QWORD PTR [rsp+216]
	mov	QWORD PTR [rsp+128], rax
	mov	rax, QWORD PTR [rsp+168]
	add	rax, r12
	mov	QWORD PTR [rsp+48], rax
	mov	rax, QWORD PTR [rsp+248]
	mov	rbx, QWORD PTR [rax+16]
	mov	rax, QWORD PTR [rsp+224]
	lea	rdi, [rbx+rdi*4]
	lea	rbx, [rbx+rsi*4]
	mov	QWORD PTR [rsp+152], rdi
	mov	QWORD PTR [rsp+144], rbx
	mov	rbx, rdx
	.p2align 4
	.p2align 3
.L89:
	mov	rdi, QWORD PTR [rsp+48]
	mov	rsi, QWORD PTR [rsp+152]
	lea	rdx, [0+rcx*4]
	mov	QWORD PTR [rsp+104], r9
	mov	r10, QWORD PTR [rsp+144]
	mov	QWORD PTR [rsp+96], rbx
	mov	rbx, r11
	sub	rdi, r12
	mov	QWORD PTR [rsp+72], rdi
	lea	rdi, [rsi+rdx]
	add	rdx, r10
	mov	rsi, QWORD PTR [rsp+128]
	mov	QWORD PTR [rsp+16], rdx
	lea	rdx, [r11-4]
	mov	r11, rcx
	mov	QWORD PTR [rsp+24], rdx
	sub	rsi, r12
.L102:
	movss	xmm2, DWORD PTR [rdi]
	lea	rcx, [rsi+r12]
	cmp	QWORD PTR [rsp+8], 1
	je	.L139
.L91:
	mov	rdx, QWORD PTR [rsp+24]
	lea	r9, [0+rsi*4]
	sub	rdx, r9
	cmp	rdx, 8
	jbe	.L90
	cmp	QWORD PTR [rsp+40], 2
	jbe	.L107
	mov	rdx, QWORD PTR [rsp+56]
	movaps	xmm1, xmm2
	shufps	xmm1, xmm1, 0
	lea	r8, [r9+rdx]
	xor	edx, edx
	.p2align 5
	.p2align 4
	.p2align 3
.L93:
	movups	xmm0, XMMWORD PTR [r8+rdx]
	movups	xmm3, XMMWORD PTR [rax+rdx]
	mulps	xmm0, xmm1
	addps	xmm0, xmm3
	movups	XMMWORD PTR [rax+rdx], xmm0
	add	rdx, 16
	cmp	r14, rdx
	jne	.L93
	mov	r8, rbp
	cmp	rbp, QWORD PTR [rsp+8]
	je	.L96
	mov	r10, QWORD PTR [rsp+64]
	lea	rdx, [rbp+0+r12]
	mov	r9, r10
	cmp	r10, 1
	je	.L95
.L92:
	mov	r10, QWORD PTR [rsp+48]
	movaps	xmm1, xmm2
	shufps	xmm1, xmm1, 0xe0
	movq	xmm1, xmm1
	add	r10, r8
	add	r8, rcx
	mov	rcx, r9
	movq	xmm0, QWORD PTR [r15+r8*4]
	and	rcx, -2
	and	r9d, 1
	mulps	xmm0, xmm1
	movq	xmm1, QWORD PTR [r13+0+r10*4]
	movq	xmm0, xmm0
	addps	xmm0, xmm1
	movlps	QWORD PTR [r13+0+r10*4], xmm0
	je	.L96
	add	rdx, rcx
.L95:
	mov	rcx, QWORD PTR [rsp+72]
	add	rdi, 4
	add	rcx, rdx
	add	rdx, rsi
	mulss	xmm2, DWORD PTR [r15+rdx*4]
	addss	xmm2, DWORD PTR [r13+0+rcx*4]
	movss	DWORD PTR [r13+0+rcx*4], xmm2
	cmp	QWORD PTR [rsp+16], rdi
	je	.L133
.L137:
	add	rsi, QWORD PTR [rsp+32]
	movss	xmm2, DWORD PTR [rdi]
	lea	rcx, [rsi+r12]
	jmp	.L91
	.p2align 4,,10
	.p2align 3
.L96:
	add	rdi, 4
	cmp	QWORD PTR [rsp+16], rdi
	jne	.L137
.L133:
	mov	r9, QWORD PTR [rsp+104]
	mov	rcx, r11
	mov	r11, rbx
	mov	rbx, QWORD PTR [rsp+96]
	mov	rdi, QWORD PTR [rsp+120]
	add	QWORD PTR [rsp+80], r9
	add	QWORD PTR [rsp+48], rdi
	add	rbx, 1
	add	rax, r9
	add	r11, r9
	add	rcx, QWORD PTR [rsp+112]
	cmp	rbx, QWORD PTR [rsp+136]
	jne	.L89
	mov	r10, QWORD PTR [rsp+88]
.L88:
	mov	rbx, QWORD PTR [rsp+112]
	cmp	QWORD PTR [rsp+160], rbx
	jb	.L103
	mov	rsi, QWORD PTR [rsp+288]
	mov	rdi, QWORD PTR [rsp+296]
	mov	rcx, QWORD PTR [rsp+280]
	mov	r8, QWORD PTR [rsp+304]
	cmp	rsi, rdi
	jb	.L104
	mov	r15, r13
	mov	r9, rdi
	mov	rbx, QWORD PTR [rsp+256]
	mov	rdi, QWORD PTR [rsp+264]
	mov	rbp, QWORD PTR [rsp+272]
	mov	r12, QWORD PTR [rsp+344]
	.cfi_restore 12
	mov	r13, QWORD PTR [rsp+352]
	.cfi_restore 13
	mov	r14, QWORD PTR [rsp+360]
	.cfi_restore 14
.L87:
	add	QWORD PTR [rsp+184], rdi
	add	QWORD PTR [rsp+168], r8
	cmp	rcx, rbx
	jb	.L105
.L82:
	mov	rbp, QWORD PTR [rsp+336]
	.cfi_restore 6
	mov	r15, QWORD PTR [rsp+368]
	.cfi_restore 15
	mov	rbx, QWORD PTR [rsp+328]
	add	rsp, 376
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L139:
	.cfi_def_cfa_offset 384
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	lea	r9, [0+rsi*4]
.L90:
	mov	r10, QWORD PTR [rsp+88]
	mov	r8, QWORD PTR [rsp+80]
	add	r9, r15
	mov	rdx, r12
	.p2align 5
	.p2align 4
	.p2align 3
.L99:
	movss	xmm0, DWORD PTR [r9+rdx*4]
	mulss	xmm0, xmm2
	addss	xmm0, DWORD PTR [r8+rdx*4]
	movss	DWORD PTR [r8+rdx*4], xmm0
	add	rdx, 1
	cmp	r10, rdx
	jne	.L99
	add	rdi, 4
	add	rsi, QWORD PTR [rsp+32]
	cmp	rdi, QWORD PTR [rsp+16]
	jne	.L102
	jmp	.L133
.L107:
	mov	r9, QWORD PTR [rsp+8]
	mov	rdx, r12
	xor	r8d, r8d
	jmp	.L92
.L136:
	.cfi_restore 12
	.cfi_restore 13
	.cfi_restore 14
	.cfi_restore 15
	mov	rbp, QWORD PTR [rsp+336]
	.cfi_restore 6
	jmp	.L83
	.section	.gcc_except_table
.LLSDA3563:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE3563-.LLSDACSB3563
.LLSDACSB3563:
.LLSDACSE3563:
	.text
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x3,"__gxx_personality_v0"
	.cfi_lsda 0x3,.LLSDAC3563
	.type	"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_.cold", @function
"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_.cold":
.LFSB3563:
.L83:
	.cfi_def_cfa_offset 384
	.cfi_offset 3, -56
	mov	edi, 16
	call	"__cxa_allocate_exception"
	mov	esi, OFFSET FLAT:.LC7
	mov	rdi, rax
	mov	rbx, rax
.LEHB8:
	call	"_ZNSt16invalid_argumentC1EPKc"
.LEHE8:
	mov	edx, OFFSET FLAT:"_ZNSt16invalid_argumentD1Ev"
	mov	esi, OFFSET FLAT:"_ZTISt16invalid_argument"
	mov	rdi, rbx
	mov	QWORD PTR [rsp+336], rbp
	mov	QWORD PTR [rsp+344], r12
	mov	QWORD PTR [rsp+352], r13
	mov	QWORD PTR [rsp+360], r14
	mov	QWORD PTR [rsp+368], r15
.LEHB9:
	.cfi_remember_state
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_throw"
.L108:
	.cfi_restore_state
	mov	QWORD PTR [rsp+336], rbp
	mov	rdi, rbx
	.cfi_offset 6, -48
	mov	rbp, rax
	mov	QWORD PTR [rsp+344], r12
	mov	QWORD PTR [rsp+352], r13
	mov	QWORD PTR [rsp+360], r14
	mov	QWORD PTR [rsp+368], r15
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	call	"__cxa_free_exception"
	mov	rdi, rbp
	call	"_Unwind_Resume"
.LEHE9:
	.cfi_endproc
.LFE3563:
	.section	.gcc_except_table
.LLSDAC3563:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC3563-.LLSDACSBC3563
.LLSDACSBC3563:
	.uleb128 .LEHB8-.LCOLDB8
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L108-.LCOLDB8
	.uleb128 0
	.uleb128 .LEHB9-.LCOLDB8
	.uleb128 .LEHE9-.LEHB9
	.uleb128 0
	.uleb128 0
.LLSDACSEC3563:
	.section	.text.unlikely
	.text
	.size	"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_", .-"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_"
	.section	.text.unlikely
	.size	"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_.cold", .-"_ZN4gemm13gemm_packed_bERKNS_6MatrixERKNS_7PackedBERS0_.cold"
.LCOLDE8:
	.text
.LHOTE8:
	.globl	"__gxx_personality_v0"
	.ident	"GCC: (GNU) 16.1.1 20260515 (Red Hat 16.1.1-2)"
	.section	.note.GNU-stack,"",@progbits
