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
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 144
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	qword ptr [rbp - 24], rdx
	mov	rdi, qword ptr [rbp - 8]
	call	_ZNK4gemm6Matrix4colsEv
	mov	qword ptr [rbp - 104], rax      # 8-byte Spill
	mov	rdi, qword ptr [rbp - 16]
	call	_ZNK4gemm6Matrix4rowsEv
	mov	rcx, rax
	mov	rax, qword ptr [rbp - 104]      # 8-byte Reload
	cmp	rax, rcx
	jne	.LBB0_3
# %bb.1:                                # %lor.lhs.false
	mov	rdi, qword ptr [rbp - 24]
	call	_ZNK4gemm6Matrix4rowsEv
	mov	qword ptr [rbp - 112], rax      # 8-byte Spill
	mov	rdi, qword ptr [rbp - 8]
	call	_ZNK4gemm6Matrix4rowsEv
	mov	rcx, rax
	mov	rax, qword ptr [rbp - 112]      # 8-byte Reload
	cmp	rax, rcx
	jne	.LBB0_3
# %bb.2:                                # %lor.lhs.false5
	mov	rdi, qword ptr [rbp - 24]
	call	_ZNK4gemm6Matrix4colsEv
	mov	qword ptr [rbp - 120], rax      # 8-byte Spill
	mov	rdi, qword ptr [rbp - 16]
	call	_ZNK4gemm6Matrix4colsEv
	mov	rcx, rax
	mov	rax, qword ptr [rbp - 120]      # 8-byte Reload
	cmp	rax, rcx
	je	.LBB0_6
.LBB0_3:                                # %if.then
	mov	edi, 16
	call	__cxa_allocate_exception
	mov	rdi, rax
	mov	rax, rdi
	mov	qword ptr [rbp - 128], rax      # 8-byte Spill
.Ltmp0:                                 # EH_LABEL
	mov	esi, offset .L.str
	call	_ZNSt16invalid_argumentC1EPKc
.Ltmp1:                                 # EH_LABEL
	jmp	.LBB0_4
.LBB0_4:                                # %invoke.cont
	mov	rdi, qword ptr [rbp - 128]      # 8-byte Reload
	movabs	rsi, offset _ZTISt16invalid_argument
	movabs	rdx, offset _ZNSt16invalid_argumentD1Ev
	call	__cxa_throw
.LBB0_5:                                # %lpad
.Ltmp2:                                 # EH_LABEL
	mov	rdi, qword ptr [rbp - 128]      # 8-byte Reload
	mov	rcx, rax
	mov	eax, edx
	mov	qword ptr [rbp - 32], rcx
	mov	dword ptr [rbp - 36], eax
	call	__cxa_free_exception
	jmp	.LBB0_19
.LBB0_6:                                # %if.end
	mov	rdi, qword ptr [rbp - 8]
	call	_ZNK4gemm6Matrix4rowsEv
	mov	qword ptr [rbp - 48], rax
	mov	rdi, qword ptr [rbp - 16]
	call	_ZNK4gemm6Matrix4colsEv
	mov	qword ptr [rbp - 56], rax
	mov	rdi, qword ptr [rbp - 8]
	call	_ZNK4gemm6Matrix4colsEv
	mov	qword ptr [rbp - 64], rax
	mov	qword ptr [rbp - 72], 0
.LBB0_7:                                # %for.cond
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_9 Depth 2
                                        #       Child Loop BB0_11 Depth 3
	mov	rax, qword ptr [rbp - 72]
	cmp	rax, qword ptr [rbp - 48]
	jae	.LBB0_18
# %bb.8:                                # %for.body
                                        #   in Loop: Header=BB0_7 Depth=1
	mov	qword ptr [rbp - 80], 0
.LBB0_9:                                # %for.cond13
                                        #   Parent Loop BB0_7 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_11 Depth 3
	mov	rax, qword ptr [rbp - 80]
	cmp	rax, qword ptr [rbp - 56]
	jae	.LBB0_16
# %bb.10:                               # %for.body15
                                        #   in Loop: Header=BB0_9 Depth=2
	xorps	xmm0, xmm0
	movss	dword ptr [rbp - 84], xmm0
	mov	qword ptr [rbp - 96], 0
.LBB0_11:                               # %for.cond16
                                        #   Parent Loop BB0_7 Depth=1
                                        #     Parent Loop BB0_9 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	mov	rax, qword ptr [rbp - 96]
	cmp	rax, qword ptr [rbp - 64]
	jae	.LBB0_14
# %bb.12:                               # %for.body18
                                        #   in Loop: Header=BB0_11 Depth=3
	mov	rdi, qword ptr [rbp - 8]
	mov	rsi, qword ptr [rbp - 72]
	mov	rdx, qword ptr [rbp - 96]
	call	_ZNK4gemm6MatrixclEmm
	movss	xmm0, dword ptr [rax]           # xmm0 = mem[0],zero,zero,zero
	movss	dword ptr [rbp - 132], xmm0     # 4-byte Spill
	mov	rdi, qword ptr [rbp - 16]
	mov	rsi, qword ptr [rbp - 96]
	mov	rdx, qword ptr [rbp - 80]
	call	_ZNK4gemm6MatrixclEmm
	movss	xmm0, dword ptr [rbp - 132]     # 4-byte Reload
                                        # xmm0 = mem[0],zero,zero,zero
	movss	xmm2, dword ptr [rax]           # xmm2 = mem[0],zero,zero,zero
	movss	xmm1, dword ptr [rbp - 84]      # xmm1 = mem[0],zero,zero,zero
	mulss	xmm0, xmm2
	addss	xmm0, xmm1
	movss	dword ptr [rbp - 84], xmm0
# %bb.13:                               # %for.inc
                                        #   in Loop: Header=BB0_11 Depth=3
	mov	rax, qword ptr [rbp - 96]
	add	rax, 1
	mov	qword ptr [rbp - 96], rax
	jmp	.LBB0_11
.LBB0_14:                               # %for.end
                                        #   in Loop: Header=BB0_9 Depth=2
	movss	xmm0, dword ptr [rbp - 84]      # xmm0 = mem[0],zero,zero,zero
	movss	dword ptr [rbp - 136], xmm0     # 4-byte Spill
	mov	rdi, qword ptr [rbp - 24]
	mov	rsi, qword ptr [rbp - 72]
	mov	rdx, qword ptr [rbp - 80]
	call	_ZN4gemm6MatrixclEmm
	movss	xmm0, dword ptr [rbp - 136]     # 4-byte Reload
                                        # xmm0 = mem[0],zero,zero,zero
	movss	dword ptr [rax], xmm0
# %bb.15:                               # %for.inc22
                                        #   in Loop: Header=BB0_9 Depth=2
	mov	rax, qword ptr [rbp - 80]
	add	rax, 1
	mov	qword ptr [rbp - 80], rax
	jmp	.LBB0_9
.LBB0_16:                               # %for.end24
                                        #   in Loop: Header=BB0_7 Depth=1
	jmp	.LBB0_17
.LBB0_17:                               # %for.inc25
                                        #   in Loop: Header=BB0_7 Depth=1
	mov	rax, qword ptr [rbp - 72]
	add	rax, 1
	mov	qword ptr [rbp - 72], rax
	jmp	.LBB0_7
.LBB0_18:                               # %for.end27
	add	rsp, 144
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.LBB0_19:                               # %eh.resume
	.cfi_def_cfa rbp, 16
	mov	rdi, qword ptr [rbp - 32]
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
	.section	.text._ZNK4gemm6Matrix4colsEv,"axG",@progbits,_ZNK4gemm6Matrix4colsEv,comdat
	.weak	_ZNK4gemm6Matrix4colsEv         # -- Begin function _ZNK4gemm6Matrix4colsEv
	.p2align	4
	.type	_ZNK4gemm6Matrix4colsEv,@function
_ZNK4gemm6Matrix4colsEv:                # @_ZNK4gemm6Matrix4colsEv
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	qword ptr [rbp - 8], rdi
	mov	rax, qword ptr [rbp - 8]
	mov	rax, qword ptr [rax + 8]
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end1:
	.size	_ZNK4gemm6Matrix4colsEv, .Lfunc_end1-_ZNK4gemm6Matrix4colsEv
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK4gemm6Matrix4rowsEv,"axG",@progbits,_ZNK4gemm6Matrix4rowsEv,comdat
	.weak	_ZNK4gemm6Matrix4rowsEv         # -- Begin function _ZNK4gemm6Matrix4rowsEv
	.p2align	4
	.type	_ZNK4gemm6Matrix4rowsEv,@function
_ZNK4gemm6Matrix4rowsEv:                # @_ZNK4gemm6Matrix4rowsEv
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	qword ptr [rbp - 8], rdi
	mov	rax, qword ptr [rbp - 8]
	mov	rax, qword ptr [rax]
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end2:
	.size	_ZNK4gemm6Matrix4rowsEv, .Lfunc_end2-_ZNK4gemm6Matrix4rowsEv
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNK4gemm6MatrixclEmm,"axG",@progbits,_ZNK4gemm6MatrixclEmm,comdat
	.weak	_ZNK4gemm6MatrixclEmm           # -- Begin function _ZNK4gemm6MatrixclEmm
	.p2align	4
	.type	_ZNK4gemm6MatrixclEmm,@function
_ZNK4gemm6MatrixclEmm:                  # @_ZNK4gemm6MatrixclEmm
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 32
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	qword ptr [rbp - 24], rdx
	mov	rax, qword ptr [rbp - 8]
	mov	rdi, rax
	add	rdi, 16
	mov	rsi, qword ptr [rbp - 16]
	imul	rsi, qword ptr [rax + 8]
	add	rsi, qword ptr [rbp - 24]
	call	_ZNKSt6vectorIfSaIfEEixEm
	add	rsp, 32
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end3:
	.size	_ZNK4gemm6MatrixclEmm, .Lfunc_end3-_ZNK4gemm6MatrixclEmm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZN4gemm6MatrixclEmm,"axG",@progbits,_ZN4gemm6MatrixclEmm,comdat
	.weak	_ZN4gemm6MatrixclEmm            # -- Begin function _ZN4gemm6MatrixclEmm
	.p2align	4
	.type	_ZN4gemm6MatrixclEmm,@function
_ZN4gemm6MatrixclEmm:                   # @_ZN4gemm6MatrixclEmm
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 32
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	qword ptr [rbp - 24], rdx
	mov	rax, qword ptr [rbp - 8]
	mov	rdi, rax
	add	rdi, 16
	mov	rsi, qword ptr [rbp - 16]
	imul	rsi, qword ptr [rax + 8]
	add	rsi, qword ptr [rbp - 24]
	call	_ZNSt6vectorIfSaIfEEixEm
	add	rsp, 32
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end4:
	.size	_ZN4gemm6MatrixclEmm, .Lfunc_end4-_ZN4gemm6MatrixclEmm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNKSt6vectorIfSaIfEEixEm,"axG",@progbits,_ZNKSt6vectorIfSaIfEEixEm,comdat
	.weak	_ZNKSt6vectorIfSaIfEEixEm       # -- Begin function _ZNKSt6vectorIfSaIfEEixEm
	.p2align	4
	.type	_ZNKSt6vectorIfSaIfEEixEm,@function
_ZNKSt6vectorIfSaIfEEixEm:              # @_ZNKSt6vectorIfSaIfEEixEm
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 32
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	rax, qword ptr [rbp - 8]
	mov	qword ptr [rbp - 24], rax       # 8-byte Spill
# %bb.1:                                # %do.body
	mov	rdi, qword ptr [rbp - 24]       # 8-byte Reload
	mov	rax, qword ptr [rbp - 16]
	mov	qword ptr [rbp - 32], rax       # 8-byte Spill
	call	_ZNKSt6vectorIfSaIfEE4sizeEv
	mov	rcx, rax
	mov	rax, qword ptr [rbp - 32]       # 8-byte Reload
	cmp	rax, rcx
	setb	al
	xor	al, -1
	test	al, 1
	jne	.LBB5_2
	jmp	.LBB5_3
.LBB5_2:                                # %if.then
	movabs	rdi, offset .L.str.1
	mov	esi, 1272
	movabs	rdx, offset .L__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm
	movabs	rcx, offset .L.str.2
	call	_ZSt21__glibcxx_assert_failPKciS0_S0_
.LBB5_3:                                # %if.end
	jmp	.LBB5_4
.LBB5_4:                                # %do.cond
	jmp	.LBB5_5
.LBB5_5:                                # %do.end
	mov	rax, qword ptr [rbp - 24]       # 8-byte Reload
	mov	rax, qword ptr [rax]
	mov	rcx, qword ptr [rbp - 16]
	shl	rcx, 2
	add	rax, rcx
	add	rsp, 32
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end5:
	.size	_ZNKSt6vectorIfSaIfEEixEm, .Lfunc_end5-_ZNKSt6vectorIfSaIfEEixEm
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNKSt6vectorIfSaIfEE4sizeEv,"axG",@progbits,_ZNKSt6vectorIfSaIfEE4sizeEv,comdat
	.weak	_ZNKSt6vectorIfSaIfEE4sizeEv    # -- Begin function _ZNKSt6vectorIfSaIfEE4sizeEv
	.p2align	4
	.type	_ZNKSt6vectorIfSaIfEE4sizeEv,@function
_ZNKSt6vectorIfSaIfEE4sizeEv:           # @_ZNKSt6vectorIfSaIfEE4sizeEv
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	mov	qword ptr [rbp - 8], rdi
	mov	rcx, qword ptr [rbp - 8]
	mov	rax, qword ptr [rcx + 8]
	mov	rcx, qword ptr [rcx]
	sub	rax, rcx
	sar	rax, 2
	mov	qword ptr [rbp - 16], rax
	cmp	qword ptr [rbp - 16], 0
	jge	.LBB6_2
# %bb.1:                                # %if.then
.LBB6_2:                                # %if.end
	mov	rax, qword ptr [rbp - 16]
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end6:
	.size	_ZNKSt6vectorIfSaIfEE4sizeEv, .Lfunc_end6-_ZNKSt6vectorIfSaIfEE4sizeEv
	.cfi_endproc
                                        # -- End function
	.section	.text._ZNSt6vectorIfSaIfEEixEm,"axG",@progbits,_ZNSt6vectorIfSaIfEEixEm,comdat
	.weak	_ZNSt6vectorIfSaIfEEixEm        # -- Begin function _ZNSt6vectorIfSaIfEEixEm
	.p2align	4
	.type	_ZNSt6vectorIfSaIfEEixEm,@function
_ZNSt6vectorIfSaIfEEixEm:               # @_ZNSt6vectorIfSaIfEEixEm
	.cfi_startproc
# %bb.0:                                # %entry
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset rbp, -16
	mov	rbp, rsp
	.cfi_def_cfa_register rbp
	sub	rsp, 32
	mov	qword ptr [rbp - 8], rdi
	mov	qword ptr [rbp - 16], rsi
	mov	rax, qword ptr [rbp - 8]
	mov	qword ptr [rbp - 24], rax       # 8-byte Spill
# %bb.1:                                # %do.body
	mov	rdi, qword ptr [rbp - 24]       # 8-byte Reload
	mov	rax, qword ptr [rbp - 16]
	mov	qword ptr [rbp - 32], rax       # 8-byte Spill
	call	_ZNKSt6vectorIfSaIfEE4sizeEv
	mov	rcx, rax
	mov	rax, qword ptr [rbp - 32]       # 8-byte Reload
	cmp	rax, rcx
	setb	al
	xor	al, -1
	test	al, 1
	jne	.LBB7_2
	jmp	.LBB7_3
.LBB7_2:                                # %if.then
	movabs	rdi, offset .L.str.1
	mov	esi, 1253
	movabs	rdx, offset .L__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm
	movabs	rcx, offset .L.str.2
	call	_ZSt21__glibcxx_assert_failPKciS0_S0_
.LBB7_3:                                # %if.end
	jmp	.LBB7_4
.LBB7_4:                                # %do.cond
	jmp	.LBB7_5
.LBB7_5:                                # %do.end
	mov	rax, qword ptr [rbp - 24]       # 8-byte Reload
	mov	rax, qword ptr [rax]
	mov	rcx, qword ptr [rbp - 16]
	shl	rcx, 2
	add	rax, rcx
	add	rsp, 32
	pop	rbp
	.cfi_def_cfa rsp, 8
	ret
.Lfunc_end7:
	.size	_ZNSt6vectorIfSaIfEEixEm, .Lfunc_end7-_ZNSt6vectorIfSaIfEEixEm
	.cfi_endproc
                                        # -- End function
	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"incompatible GEMM matrix dimensions"
	.size	.L.str, 36

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"/usr/bin/../lib/gcc/x86_64-redhat-linux/16/../../../../include/c++/16/bits/stl_vector.h"
	.size	.L.str.1, 88

	.type	.L__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm,@object # @__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm
.L__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm:
	.asciz	"const_reference std::vector<float>::operator[](size_type) const [_Tp = float, _Alloc = std::allocator<float>]"
	.size	.L__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm, 110

	.type	.L.str.2,@object                # @.str.2
.L.str.2:
	.asciz	"__n < this->size()"
	.size	.L.str.2, 19

	.type	.L__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm,@object # @__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm
.L__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm:
	.asciz	"reference std::vector<float>::operator[](size_type) [_Tp = float, _Alloc = std::allocator<float>]"
	.size	.L__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm, 98

	.ident	"clang version 22.1.8 (Fedora 22.1.8-4.fc44)"
	.section	".note.GNU-stack","",@progbits
