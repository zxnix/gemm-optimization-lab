; ModuleID = 'src/kernels/gemm_naive.cpp'
source_filename = "src/kernels/gemm_naive.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

@.str = private unnamed_addr constant [36 x i8] c"incompatible GEMM matrix dimensions\00", align 1
@_ZTISt16invalid_argument = external dso_local constant ptr

; Function Attrs: mustprogress uwtable
define dso_local void @_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_(ptr noundef nonnull readonly align 8 captures(none) dereferenceable(40) %a, ptr noundef nonnull readonly align 8 captures(none) dereferenceable(40) %b, ptr noundef nonnull readonly align 8 captures(none) dereferenceable(40) %c) local_unnamed_addr #0 personality ptr @__gxx_personality_v0 {
entry:
  %cols_.i = getelementptr inbounds nuw i8, ptr %a, i64 8
  %0 = load i64, ptr %cols_.i, align 8, !tbaa !7
  %1 = load i64, ptr %b, align 8, !tbaa !16
  %cmp.not = icmp eq i64 %0, %1
  br i1 %cmp.not, label %lor.lhs.false, label %if.then

lor.lhs.false:                                    ; preds = %entry
  %2 = load i64, ptr %c, align 8, !tbaa !16
  %3 = load i64, ptr %a, align 8, !tbaa !16
  %cmp4.not = icmp eq i64 %2, %3
  br i1 %cmp4.not, label %lor.lhs.false5, label %if.then

lor.lhs.false5:                                   ; preds = %lor.lhs.false
  %cols_.i50 = getelementptr inbounds nuw i8, ptr %c, i64 8
  %4 = load i64, ptr %cols_.i50, align 8, !tbaa !7
  %cols_.i51 = getelementptr inbounds nuw i8, ptr %b, i64 8
  %5 = load i64, ptr %cols_.i51, align 8, !tbaa !7
  %cmp8.not = icmp eq i64 %4, %5
  br i1 %cmp8.not, label %for.cond.preheader, label %if.then

for.cond.preheader:                               ; preds = %lor.lhs.false5
  %cmp1268.not = icmp eq i64 %2, 0
  br i1 %cmp1268.not, label %for.cond.cleanup, label %for.cond13.preheader.lr.ph

for.cond13.preheader.lr.ph:                       ; preds = %for.cond.preheader
  %cmp1466.not = icmp eq i64 %4, 0
  %data_.i55 = getelementptr inbounds nuw i8, ptr %a, i64 16
  %data_.i59 = getelementptr inbounds nuw i8, ptr %b, i64 16
  %data_.i = getelementptr inbounds nuw i8, ptr %c, i64 16
  %6 = load ptr, ptr %data_.i, align 8
  br i1 %cmp1466.not, label %for.cond.cleanup, label %for.cond13.preheader.lr.ph.split.us

for.cond13.preheader.lr.ph.split.us:              ; preds = %for.cond13.preheader.lr.ph
  %cmp1863.not = icmp eq i64 %0, 0
  br i1 %cmp1863.not, label %for.cond13.preheader.us.preheader, label %for.cond13.preheader.us.us.preheader

for.cond13.preheader.us.us.preheader:             ; preds = %for.cond13.preheader.lr.ph.split.us
  %xtraiter = and i64 %0, 3
  %7 = icmp ult i64 %0, 4
  %unroll_iter = and i64 %0, -4
  %lcmp.mod.not = icmp eq i64 %xtraiter, 0
  %lcmp.mod88 = icmp ne i64 %xtraiter, 0
  br label %for.cond13.preheader.us.us

for.cond13.preheader.us.preheader:                ; preds = %for.cond13.preheader.lr.ph.split.us
  %8 = shl i64 %4, 2
  %xtraiter89 = and i64 %2, 7
  %9 = icmp ult i64 %2, 8
  br i1 %9, label %for.cond13.preheader.us.epil.preheader, label %for.cond13.preheader.us.preheader.new

for.cond13.preheader.us.preheader.new:            ; preds = %for.cond13.preheader.us.preheader
  %unroll_iter93 = and i64 %2, -8
  br label %for.cond13.preheader.us

for.cond13.preheader.us.us:                       ; preds = %for.cond13.preheader.us.us.preheader, %for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us
  %i.069.us.us = phi i64 [ %inc28.us.us, %for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us ], [ 0, %for.cond13.preheader.us.us.preheader ]
  %mul.i57.us.us = mul i64 %i.069.us.us, %0
  %10 = load ptr, ptr %data_.i55, align 8
  %11 = getelementptr float, ptr %10, i64 %mul.i57.us.us
  %12 = load ptr, ptr %data_.i59, align 8
  %mul.i.us.us = mul i64 %i.069.us.us, %4
  %13 = getelementptr float, ptr %6, i64 %mul.i.us.us
  br label %for.cond17.preheader.us.us.us

for.cond17.preheader.us.us.us:                    ; preds = %for.cond17.for.cond.cleanup19_crit_edge.us.us.us, %for.cond13.preheader.us.us
  %j.067.us.us.us = phi i64 [ 0, %for.cond13.preheader.us.us ], [ %inc25.us.us.us, %for.cond17.for.cond.cleanup19_crit_edge.us.us.us ]
  %invariant.gep.us.us.us = getelementptr float, ptr %12, i64 %j.067.us.us.us
  br i1 %7, label %for.body20.us.us.us.epil.preheader, label %for.body20.us.us.us

for.body20.us.us.us:                              ; preds = %for.cond17.preheader.us.us.us, %for.body20.us.us.us
  %k.065.us.us.us = phi i64 [ %inc.us.us.us.3, %for.body20.us.us.us ], [ 0, %for.cond17.preheader.us.us.us ]
  %sum.064.us.us.us = phi float [ %25, %for.body20.us.us.us ], [ 0.000000e+00, %for.cond17.preheader.us.us.us ]
  %niter = phi i64 [ %niter.next.3, %for.body20.us.us.us ], [ 0, %for.cond17.preheader.us.us.us ]
  %add.ptr.i.i58.us.us.us = getelementptr float, ptr %11, i64 %k.065.us.us.us
  %14 = load float, ptr %add.ptr.i.i58.us.us.us, align 4, !tbaa !17
  %mul.i61.us.us.us = mul i64 %k.065.us.us.us, %4
  %gep.us.us.us = getelementptr float, ptr %invariant.gep.us.us.us, i64 %mul.i61.us.us.us
  %15 = load float, ptr %gep.us.us.us, align 4, !tbaa !17
  %16 = tail call float @llvm.fmuladd.f32(float %14, float %15, float %sum.064.us.us.us)
  %inc.us.us.us = or disjoint i64 %k.065.us.us.us, 1
  %add.ptr.i.i58.us.us.us.1 = getelementptr float, ptr %11, i64 %inc.us.us.us
  %17 = load float, ptr %add.ptr.i.i58.us.us.us.1, align 4, !tbaa !17
  %mul.i61.us.us.us.1 = mul i64 %inc.us.us.us, %4
  %gep.us.us.us.1 = getelementptr float, ptr %invariant.gep.us.us.us, i64 %mul.i61.us.us.us.1
  %18 = load float, ptr %gep.us.us.us.1, align 4, !tbaa !17
  %19 = tail call float @llvm.fmuladd.f32(float %17, float %18, float %16)
  %inc.us.us.us.1 = or disjoint i64 %k.065.us.us.us, 2
  %add.ptr.i.i58.us.us.us.2 = getelementptr float, ptr %11, i64 %inc.us.us.us.1
  %20 = load float, ptr %add.ptr.i.i58.us.us.us.2, align 4, !tbaa !17
  %mul.i61.us.us.us.2 = mul i64 %inc.us.us.us.1, %4
  %gep.us.us.us.2 = getelementptr float, ptr %invariant.gep.us.us.us, i64 %mul.i61.us.us.us.2
  %21 = load float, ptr %gep.us.us.us.2, align 4, !tbaa !17
  %22 = tail call float @llvm.fmuladd.f32(float %20, float %21, float %19)
  %inc.us.us.us.2 = or disjoint i64 %k.065.us.us.us, 3
  %add.ptr.i.i58.us.us.us.3 = getelementptr float, ptr %11, i64 %inc.us.us.us.2
  %23 = load float, ptr %add.ptr.i.i58.us.us.us.3, align 4, !tbaa !17
  %mul.i61.us.us.us.3 = mul i64 %inc.us.us.us.2, %4
  %gep.us.us.us.3 = getelementptr float, ptr %invariant.gep.us.us.us, i64 %mul.i61.us.us.us.3
  %24 = load float, ptr %gep.us.us.us.3, align 4, !tbaa !17
  %25 = tail call float @llvm.fmuladd.f32(float %23, float %24, float %22)
  %inc.us.us.us.3 = add nuw i64 %k.065.us.us.us, 4
  %niter.next.3 = add i64 %niter, 4
  %niter.ncmp.3 = icmp eq i64 %niter.next.3, %unroll_iter
  br i1 %niter.ncmp.3, label %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa, label %for.body20.us.us.us, !llvm.loop !19

for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa: ; preds = %for.body20.us.us.us
  br i1 %lcmp.mod.not, label %for.cond17.for.cond.cleanup19_crit_edge.us.us.us, label %for.body20.us.us.us.epil.preheader

for.body20.us.us.us.epil.preheader:               ; preds = %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa, %for.cond17.preheader.us.us.us
  %k.065.us.us.us.epil.init = phi i64 [ 0, %for.cond17.preheader.us.us.us ], [ %inc.us.us.us.3, %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa ]
  %sum.064.us.us.us.epil.init = phi float [ 0.000000e+00, %for.cond17.preheader.us.us.us ], [ %25, %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa ]
  tail call void @llvm.assume(i1 %lcmp.mod88)
  br label %for.body20.us.us.us.epil

for.body20.us.us.us.epil:                         ; preds = %for.body20.us.us.us.epil, %for.body20.us.us.us.epil.preheader
  %k.065.us.us.us.epil = phi i64 [ %k.065.us.us.us.epil.init, %for.body20.us.us.us.epil.preheader ], [ %inc.us.us.us.epil, %for.body20.us.us.us.epil ]
  %sum.064.us.us.us.epil = phi float [ %sum.064.us.us.us.epil.init, %for.body20.us.us.us.epil.preheader ], [ %28, %for.body20.us.us.us.epil ]
  %epil.iter = phi i64 [ 0, %for.body20.us.us.us.epil.preheader ], [ %epil.iter.next, %for.body20.us.us.us.epil ]
  %add.ptr.i.i58.us.us.us.epil = getelementptr float, ptr %11, i64 %k.065.us.us.us.epil
  %26 = load float, ptr %add.ptr.i.i58.us.us.us.epil, align 4, !tbaa !17
  %mul.i61.us.us.us.epil = mul i64 %k.065.us.us.us.epil, %4
  %gep.us.us.us.epil = getelementptr float, ptr %invariant.gep.us.us.us, i64 %mul.i61.us.us.us.epil
  %27 = load float, ptr %gep.us.us.us.epil, align 4, !tbaa !17
  %28 = tail call float @llvm.fmuladd.f32(float %26, float %27, float %sum.064.us.us.us.epil)
  %inc.us.us.us.epil = add nuw i64 %k.065.us.us.us.epil, 1
  %epil.iter.next = add i64 %epil.iter, 1
  %epil.iter.cmp.not = icmp eq i64 %epil.iter.next, %xtraiter
  br i1 %epil.iter.cmp.not, label %for.cond17.for.cond.cleanup19_crit_edge.us.us.us, label %for.body20.us.us.us.epil, !llvm.loop !21

for.cond17.for.cond.cleanup19_crit_edge.us.us.us: ; preds = %for.body20.us.us.us.epil, %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa
  %.lcssa = phi float [ %25, %for.cond17.for.cond.cleanup19_crit_edge.us.us.us.unr-lcssa ], [ %28, %for.body20.us.us.us.epil ]
  %add.ptr.i.i.us.us.us = getelementptr float, ptr %13, i64 %j.067.us.us.us
  store float %.lcssa, ptr %add.ptr.i.i.us.us.us, align 4, !tbaa !17
  %inc25.us.us.us = add nuw i64 %j.067.us.us.us, 1
  %exitcond79.not = icmp eq i64 %inc25.us.us.us, %4
  br i1 %exitcond79.not, label %for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us, label %for.cond17.preheader.us.us.us, !llvm.loop !23

for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us: ; preds = %for.cond17.for.cond.cleanup19_crit_edge.us.us.us
  %inc28.us.us = add nuw i64 %i.069.us.us, 1
  %exitcond80.not = icmp eq i64 %inc28.us.us, %2
  br i1 %exitcond80.not, label %for.cond.cleanup, label %for.cond13.preheader.us.us, !llvm.loop !24

for.cond13.preheader.us:                          ; preds = %for.cond13.preheader.us, %for.cond13.preheader.us.preheader.new
  %i.069.us = phi i64 [ 0, %for.cond13.preheader.us.preheader.new ], [ %inc28.us.7, %for.cond13.preheader.us ]
  %niter94 = phi i64 [ 0, %for.cond13.preheader.us.preheader.new ], [ %niter94.next.7, %for.cond13.preheader.us ]
  %29 = mul i64 %8, %i.069.us
  %scevgep = getelementptr i8, ptr %6, i64 %29
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us = or disjoint i64 %i.069.us, 1
  %30 = mul i64 %8, %inc28.us
  %scevgep.1 = getelementptr i8, ptr %6, i64 %30
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.1, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.1 = or disjoint i64 %i.069.us, 2
  %31 = mul i64 %8, %inc28.us.1
  %scevgep.2 = getelementptr i8, ptr %6, i64 %31
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.2, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.2 = or disjoint i64 %i.069.us, 3
  %32 = mul i64 %8, %inc28.us.2
  %scevgep.3 = getelementptr i8, ptr %6, i64 %32
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.3, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.3 = or disjoint i64 %i.069.us, 4
  %33 = mul i64 %8, %inc28.us.3
  %scevgep.4 = getelementptr i8, ptr %6, i64 %33
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.4, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.4 = or disjoint i64 %i.069.us, 5
  %34 = mul i64 %8, %inc28.us.4
  %scevgep.5 = getelementptr i8, ptr %6, i64 %34
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.5, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.5 = or disjoint i64 %i.069.us, 6
  %35 = mul i64 %8, %inc28.us.5
  %scevgep.6 = getelementptr i8, ptr %6, i64 %35
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.6, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.6 = or disjoint i64 %i.069.us, 7
  %36 = mul i64 %8, %inc28.us.6
  %scevgep.7 = getelementptr i8, ptr %6, i64 %36
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.7, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.7 = add nuw i64 %i.069.us, 8
  %niter94.next.7 = add i64 %niter94, 8
  %niter94.ncmp.7 = icmp eq i64 %niter94.next.7, %unroll_iter93
  br i1 %niter94.ncmp.7, label %for.cond.cleanup.loopexit.unr-lcssa, label %for.cond13.preheader.us, !llvm.loop !24

if.then:                                          ; preds = %lor.lhs.false5, %lor.lhs.false, %entry
  %exception = tail call ptr @__cxa_allocate_exception(i64 16) #7
  invoke void @_ZNSt16invalid_argumentC1EPKc(ptr noundef nonnull align 8 dereferenceable(16) %exception, ptr noundef nonnull @.str)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %if.then
  tail call void @__cxa_throw(ptr nonnull %exception, ptr nonnull @_ZTISt16invalid_argument, ptr nonnull @_ZNSt16invalid_argumentD1Ev) #8
  unreachable

lpad:                                             ; preds = %if.then
  %37 = landingpad { ptr, i32 }
          cleanup
  tail call void @__cxa_free_exception(ptr nonnull %exception) #7
  resume { ptr, i32 } %37

for.cond.cleanup.loopexit.unr-lcssa:              ; preds = %for.cond13.preheader.us
  %lcmp.mod91.not = icmp eq i64 %xtraiter89, 0
  br i1 %lcmp.mod91.not, label %for.cond.cleanup, label %for.cond13.preheader.us.epil.preheader

for.cond13.preheader.us.epil.preheader:           ; preds = %for.cond.cleanup.loopexit.unr-lcssa, %for.cond13.preheader.us.preheader
  %i.069.us.epil.init = phi i64 [ 0, %for.cond13.preheader.us.preheader ], [ %inc28.us.7, %for.cond.cleanup.loopexit.unr-lcssa ]
  %lcmp.mod92 = icmp ne i64 %xtraiter89, 0
  tail call void @llvm.assume(i1 %lcmp.mod92)
  br label %for.cond13.preheader.us.epil

for.cond13.preheader.us.epil:                     ; preds = %for.cond13.preheader.us.epil, %for.cond13.preheader.us.epil.preheader
  %i.069.us.epil = phi i64 [ %inc28.us.epil, %for.cond13.preheader.us.epil ], [ %i.069.us.epil.init, %for.cond13.preheader.us.epil.preheader ]
  %epil.iter90 = phi i64 [ %epil.iter90.next, %for.cond13.preheader.us.epil ], [ 0, %for.cond13.preheader.us.epil.preheader ]
  %38 = mul i64 %8, %i.069.us.epil
  %scevgep.epil = getelementptr i8, ptr %6, i64 %38
  tail call void @llvm.memset.p0.i64(ptr align 4 %scevgep.epil, i8 0, i64 %8, i1 false), !tbaa !17
  %inc28.us.epil = add nuw i64 %i.069.us.epil, 1
  %epil.iter90.next = add i64 %epil.iter90, 1
  %epil.iter90.cmp.not = icmp eq i64 %epil.iter90.next, %xtraiter89
  br i1 %epil.iter90.cmp.not, label %for.cond.cleanup, label %for.cond13.preheader.us.epil, !llvm.loop !25

for.cond.cleanup:                                 ; preds = %for.cond13.for.cond.cleanup15_crit_edge.split.us.us.us, %for.cond.cleanup.loopexit.unr-lcssa, %for.cond13.preheader.us.epil, %for.cond13.preheader.lr.ph, %for.cond.preheader
  ret void
}

declare dso_local ptr @__cxa_allocate_exception(i64) local_unnamed_addr

declare dso_local void @_ZNSt16invalid_argumentC1EPKc(ptr noundef nonnull align 8 dereferenceable(16), ptr noundef) unnamed_addr #1

declare dso_local i32 @__gxx_personality_v0(...)

declare dso_local void @__cxa_free_exception(ptr) local_unnamed_addr

; Function Attrs: nounwind
declare dso_local void @_ZNSt16invalid_argumentD1Ev(ptr noundef nonnull align 8 dereferenceable(16)) unnamed_addr #2

; Function Attrs: cold noreturn
declare dso_local void @__cxa_throw(ptr, ptr, ptr) local_unnamed_addr #3

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #4

; Function Attrs: nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #5

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write)
declare void @llvm.assume(i1 noundef) #6

attributes #0 = { mustprogress uwtable "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { nounwind "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { cold noreturn }
attributes #4 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #6 = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: write) }
attributes #7 = { nounwind }
attributes #8 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}
!llvm.errno.tbaa = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 2}
!2 = !{!"clang version 22.1.8 (Fedora 22.1.8-4.fc44)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"int", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!8, !9, i64 8}
!8 = !{!"_ZTSN4gemm6MatrixE", !9, i64 0, !9, i64 8, !10, i64 16}
!9 = !{!"long", !5, i64 0}
!10 = !{!"_ZTSSt6vectorIfSaIfEE", !11, i64 0}
!11 = !{!"_ZTSSt12_Vector_baseIfSaIfEE", !12, i64 0}
!12 = !{!"_ZTSNSt12_Vector_baseIfSaIfEE12_Vector_implE", !13, i64 0}
!13 = !{!"_ZTSNSt12_Vector_baseIfSaIfEE17_Vector_impl_dataE", !14, i64 0, !14, i64 8, !14, i64 16}
!14 = !{!"p1 float", !15, i64 0}
!15 = !{!"any pointer", !5, i64 0}
!16 = !{!8, !9, i64 0}
!17 = !{!18, !18, i64 0}
!18 = !{!"float", !5, i64 0}
!19 = distinct !{!19, !20}
!20 = !{!"llvm.loop.mustprogress"}
!21 = distinct !{!21, !22}
!22 = !{!"llvm.loop.unroll.disable"}
!23 = distinct !{!23, !20}
!24 = distinct !{!24, !20}
!25 = distinct !{!25, !22}
