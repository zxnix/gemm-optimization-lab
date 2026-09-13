	.intel_syntax noprefix
	.file	"gemm_naive.cpp"
	.text
	.globl	_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_ # -- Begin function _ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_
	.p2align	4
	.type	_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_,@function
_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_: # @_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_
.Lfunc_begin0:
	.cfi_startproc
	.cfi_personality 3, __gxx_personality_v0
	.cfi_lsda 3, .Lexception0
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 56
	.cfi_def_cfa_offset 112
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 32], rdi       # 8-byte Spill
	mov	rax, qword ptr [rdi + 8]
	mov	qword ptr [rsp + 24], rsi       # 8-byte Spill
	cmp	rax, qword ptr [rsi]
	jne	.LBB0_25
# %bb.1:                                # %lor.lhs.false
	mov	rsi, qword ptr [rdx]
	mov	rcx, qword ptr [rsp + 32]       # 8-byte Reload
	cmp	rsi, qword ptr [rcx]
	jne	.LBB0_25
# %bb.2:                                # %lor.lhs.false5
	mov	r12, qword ptr [rdx + 8]
	mov	rcx, qword ptr [rsp + 24]       # 8-byte Reload
	cmp	r12, qword ptr [rcx + 8]
	jne	.LBB0_25
# %bb.3:                                # %for.cond.preheader
	test	rsi, rsi
	je	.LBB0_19
# %bb.4:                                # %for.cond13.preheader.lr.ph
	test	r12, r12
	je	.LBB0_19
# %bb.5:                                # %for.cond13.preheader.lr.ph.split.us
	mov	rcx, qword ptr [rdx + 16]
	mov	qword ptr [rsp], rcx            # 8-byte Spill
	test	rax, rax
	je	.LBB0_10
# %bb.6:                                # %for.cond13.preheader.us.us.preheader
	mov	ecx, eax
	and	ecx, 3
	mov	rdx, rax
	and	rdx, -4
	lea	r8, [4*r12]
	lea	r9, [r8 + 2*r8]
	mov	r10, r12
	shl	r10, 4
	mov	ebx, 12
	xor	edi, edi
	xor	r14d, r14d
	mov	qword ptr [rsp + 8], rsi        # 8-byte Spill
	jmp	.LBB0_7
	.p2align	4
.LBB0_18:                               # %for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us
                                        #   in Loop: Header=BB0_7 Depth=1
	mov	rdi, qword ptr [rsp + 48]       # 8-byte Reload
	inc	rdi
	lea	rsi, [4*rax]
	mov	rbx, qword ptr [rsp + 16]       # 8-byte Reload
	add	rbx, rsi
	mov	r14, qword ptr [rsp + 40]       # 8-byte Reload
	add	r14, rsi
	mov	rsi, qword ptr [rsp + 8]        # 8-byte Reload
	cmp	rdi, rsi
	je	.LBB0_19
.LBB0_7:                                # %for.cond13.preheader.us.us
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_8 Depth 2
                                        #       Child Loop BB0_13 Depth 3
                                        #       Child Loop BB0_16 Depth 3
	mov	rsi, qword ptr [rsp + 32]       # 8-byte Reload
	mov	r13, qword ptr [rsi + 16]
	mov	rsi, qword ptr [rsp + 24]       # 8-byte Reload
	mov	r15, qword ptr [rsi + 16]
	mov	qword ptr [rsp + 48], rdi       # 8-byte Spill
	mov	rsi, rdi
	imul	rsi, r12
	mov	rdi, qword ptr [rsp]            # 8-byte Reload
	lea	r11, [rdi + 4*rsi]
	mov	qword ptr [rsp + 16], rbx       # 8-byte Spill
	add	rbx, r13
	mov	qword ptr [rsp + 40], r14       # 8-byte Spill
	add	r13, r14
	xor	esi, esi
	jmp	.LBB0_8
	.p2align	4
.LBB0_17:                               # %for.cond17.for.cond.cleanup19_crit_edge.us.us.us
                                        #   in Loop: Header=BB0_8 Depth=2
	movss	dword ptr [r11 + 4*rsi], xmm0
	inc	rsi
	add	r15, 4
	cmp	rsi, r12
	je	.LBB0_18
.LBB0_8:                                # %for.cond17.preheader.us.us.us
                                        #   Parent Loop BB0_7 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_13 Depth 3
                                        #       Child Loop BB0_16 Depth 3
	xorps	xmm0, xmm0
	cmp	rax, 4
	jae	.LBB0_12
# %bb.9:                                #   in Loop: Header=BB0_8 Depth=2
	xor	edi, edi
	jmp	.LBB0_15
	.p2align	4
.LBB0_12:                               # %for.body20.us.us.us.preheader
                                        #   in Loop: Header=BB0_8 Depth=2
	mov	rbp, r15
	xor	edi, edi
	.p2align	4
.LBB0_13:                               # %for.body20.us.us.us
                                        #   Parent Loop BB0_7 Depth=1
                                        #     Parent Loop BB0_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	xmm1, dword ptr [rbx + 4*rdi - 12] # xmm1 = mem[0],zero,zero,zero
	mulss	xmm1, dword ptr [rbp]
	movss	xmm2, dword ptr [rbx + 4*rdi - 8] # xmm2 = mem[0],zero,zero,zero
	addss	xmm1, xmm0
	mulss	xmm2, dword ptr [rbp + 4*r12]
	addss	xmm2, xmm1
	movss	xmm1, dword ptr [rbx + 4*rdi - 4] # xmm1 = mem[0],zero,zero,zero
	mulss	xmm1, dword ptr [rbp + 8*r12]
	addss	xmm1, xmm2
	movss	xmm0, dword ptr [rbx + 4*rdi]   # xmm0 = mem[0],zero,zero,zero
	mulss	xmm0, dword ptr [rbp + r9]
	addss	xmm0, xmm1
	add	rdi, 4
	add	rbp, r10
	cmp	rdx, rdi
	jne	.LBB0_13
# %bb.14:                               # %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa
                                        #   in Loop: Header=BB0_8 Depth=2
	test	rcx, rcx
	je	.LBB0_17
.LBB0_15:                               # %for.body20.us.us.us.epil.preheader
                                        #   in Loop: Header=BB0_8 Depth=2
	mov	rbp, r8
	imul	rbp, rdi
	add	rbp, r15
	lea	rdi, [4*rdi]
	add	rdi, r13
	xor	r14d, r14d
	.p2align	4
.LBB0_16:                               # %for.body20.us.us.us.epil
                                        #   Parent Loop BB0_7 Depth=1
                                        #     Parent Loop BB0_8 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	movss	xmm1, dword ptr [rdi + 4*r14]   # xmm1 = mem[0],zero,zero,zero
	mulss	xmm1, dword ptr [rbp]
	addss	xmm0, xmm1
	inc	r14
	add	rbp, r8
	cmp	rcx, r14
	jne	.LBB0_16
	jmp	.LBB0_17
.LBB0_10:                               # %for.cond13.preheader.us.preheader
	lea	rbx, [4*r12]
	mov	r13d, esi
	and	r13d, 7
	cmp	rsi, 8
	jae	.LBB0_20
# %bb.11:
	xor	ebp, ebp
	jmp	.LBB0_23
.LBB0_20:                               # %for.cond13.preheader.us.preheader.new
	and	rsi, -8
	mov	rax, r12
	shl	rax, 5
	mov	qword ptr [rsp + 16], rax       # 8-byte Spill
	xor	ebp, ebp
	mov	r14, qword ptr [rsp]            # 8-byte Reload
	mov	qword ptr [rsp + 8], rsi        # 8-byte Spill
	.p2align	4
.LBB0_21:                               # %for.cond13.preheader.us
                                        # =>This Inner Loop Header: Depth=1
	mov	rdi, r14
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	lea	r15, [r14 + rbx]
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r15, rbx
	mov	rdi, r15
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	mov	rsi, qword ptr [rsp + 8]        # 8-byte Reload
	add	rbp, 8
	add	r14, qword ptr [rsp + 16]       # 8-byte Folded Reload
	cmp	rsi, rbp
	jne	.LBB0_21
# %bb.22:                               # %for.cond.cleanup.loopexit.unr-lcssa
	test	r13, r13
	je	.LBB0_19
.LBB0_23:                               # %for.cond13.preheader.us.epil.preheader
	imul	rbp, r12
	mov	rax, qword ptr [rsp]            # 8-byte Reload
	lea	r14, [rax + 4*rbp]
	.p2align	4
.LBB0_24:                               # %for.cond13.preheader.us.epil
                                        # =>This Inner Loop Header: Depth=1
	mov	rdi, r14
	xor	esi, esi
	mov	rdx, rbx
	call	memset@PLT
	add	r14, rbx
	dec	r13
	jne	.LBB0_24
.LBB0_19:                               # %for.cond.cleanup
	add	rsp, 56
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	ret
.LBB0_25:                               # %if.then
	.cfi_def_cfa_offset 112
	mov	edi, 16
	call	__cxa_allocate_exception
	mov	rbx, rax
.Ltmp0:                                 # EH_LABEL
	mov	esi, offset .L.str
	mov	rdi, rax
	call	_ZNSt16invalid_argumentC1EPKc
.Ltmp1:                                 # EH_LABEL
# %bb.26:                               # %invoke.cont
	mov	esi, offset _ZTISt16invalid_argument
	mov	edx, offset _ZNSt16invalid_argumentD1Ev
	mov	rdi, rbx
	call	__cxa_throw
.LBB0_27:                               # %lpad
.Ltmp2:                                 # EH_LABEL
	mov	r14, rax
	mov	rdi, rbx
	call	__cxa_free_exception
	mov	rdi, r14
	call	_Unwind_Resume@PLT
.Lfunc_end0:
	.size	_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_, .Lfunc_end0-_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_
	.cfi_endproc
	.section	.gcc_except_table,"a",@progbits
	.p2align	2, 0x0
GCC_except_table0:
.Lexception0:
	.byte	255                             # @LPStart Encoding = omit
	.byte	255                             # @TType Encoding = omit
	.byte	1                               # Call site Encoding = uleb128
	.uleb128 .Lcst_end0-.Lcst_begin0
.Lcst_begin0:
	.uleb128 .Lfunc_begin0-.Lfunc_begin0    # >> Call Site 1 <<
	.uleb128 .Ltmp0-.Lfunc_begin0           #   Call between .Lfunc_begin0 and .Ltmp0
	.byte	0                               #     has no landing pad
	.byte	0                               #   On action: cleanup
	.uleb128 .Ltmp0-.Lfunc_begin0           # >> Call Site 2 <<
	.uleb128 .Ltmp1-.Ltmp0                  #   Call between .Ltmp0 and .Ltmp1
	.uleb128 .Ltmp2-.Lfunc_begin0           #     jumps to .Ltmp2
	.byte	0                               #   On action: cleanup
	.uleb128 .Ltmp1-.Lfunc_begin0           # >> Call Site 3 <<
	.uleb128 .Lfunc_end0-.Ltmp1             #   Call between .Ltmp1 and .Lfunc_end0
	.byte	0                               #     has no landing pad
	.byte	0                               #   On action: cleanup
.Lcst_end0:
	.p2align	2, 0x0
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"incompatible GEMM matrix dimensions"
	.size	.L.str, 36

	.ident	"clang version 22.1.8 (Fedora 22.1.8-4.fc44)"
	.section	".note.GNU-stack","",@progbits
