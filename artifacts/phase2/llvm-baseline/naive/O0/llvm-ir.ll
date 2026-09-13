; ModuleID = 'src/kernels/gemm_naive.cpp'
source_filename = "src/kernels/gemm_naive.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-redhat-linux-gnu"

%"class.gemm::Matrix" = type { i64, i64, %"class.std::vector" }
%"class.std::vector" = type { %"struct.std::_Vector_base" }
%"struct.std::_Vector_base" = type { %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl" }
%"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl" = type { %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data" }
%"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data" = type { ptr, ptr, ptr }

$_ZNK4gemm6Matrix4colsEv = comdat any

$_ZNK4gemm6Matrix4rowsEv = comdat any

$_ZNK4gemm6MatrixclEmm = comdat any

$_ZN4gemm6MatrixclEmm = comdat any

$_ZNKSt6vectorIfSaIfEEixEm = comdat any

$_ZNKSt6vectorIfSaIfEE4sizeEv = comdat any

$_ZNSt6vectorIfSaIfEEixEm = comdat any

@.str = private unnamed_addr constant [36 x i8] c"incompatible GEMM matrix dimensions\00", align 1
@_ZTISt16invalid_argument = external dso_local constant ptr
@.str.1 = private unnamed_addr constant [88 x i8] c"/usr/bin/../lib/gcc/x86_64-redhat-linux/16/../../../../include/c++/16/bits/stl_vector.h\00", align 1
@__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm = private unnamed_addr constant [110 x i8] c"const_reference std::vector<float>::operator[](size_type) const [_Tp = float, _Alloc = std::allocator<float>]\00", align 1
@.str.2 = private unnamed_addr constant [19 x i8] c"__n < this->size()\00", align 1
@__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm = private unnamed_addr constant [98 x i8] c"reference std::vector<float>::operator[](size_type) [_Tp = float, _Alloc = std::allocator<float>]\00", align 1

; Function Attrs: mustprogress noinline optnone uwtable
define dso_local void @_ZN4gemm10gemm_naiveERKNS_6MatrixES2_RS0_(ptr noundef nonnull align 8 dereferenceable(40) %a, ptr noundef nonnull align 8 dereferenceable(40) %b, ptr noundef nonnull align 8 dereferenceable(40) %c) #0 personality ptr @__gxx_personality_v0 {
entry:
  %a.addr = alloca ptr, align 8
  %b.addr = alloca ptr, align 8
  %c.addr = alloca ptr, align 8
  %exn.slot = alloca ptr, align 8
  %ehselector.slot = alloca i32, align 4
  %m = alloca i64, align 8
  %n = alloca i64, align 8
  %k_size = alloca i64, align 8
  %i = alloca i64, align 8
  %j = alloca i64, align 8
  %sum = alloca float, align 4
  %k = alloca i64, align 8
  store ptr %a, ptr %a.addr, align 8
  store ptr %b, ptr %b.addr, align 8
  store ptr %c, ptr %c.addr, align 8
  %0 = load ptr, ptr %a.addr, align 8, !nonnull !4, !align !5
  %call = call noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %0) #6
  %1 = load ptr, ptr %b.addr, align 8, !nonnull !4, !align !5
  %call1 = call noundef i64 @_ZNK4gemm6Matrix4rowsEv(ptr noundef nonnull align 8 dereferenceable(40) %1) #6
  %cmp = icmp ne i64 %call, %call1
  br i1 %cmp, label %if.then, label %lor.lhs.false

lor.lhs.false:                                    ; preds = %entry
  %2 = load ptr, ptr %c.addr, align 8, !nonnull !4, !align !5
  %call2 = call noundef i64 @_ZNK4gemm6Matrix4rowsEv(ptr noundef nonnull align 8 dereferenceable(40) %2) #6
  %3 = load ptr, ptr %a.addr, align 8, !nonnull !4, !align !5
  %call3 = call noundef i64 @_ZNK4gemm6Matrix4rowsEv(ptr noundef nonnull align 8 dereferenceable(40) %3) #6
  %cmp4 = icmp ne i64 %call2, %call3
  br i1 %cmp4, label %if.then, label %lor.lhs.false5

lor.lhs.false5:                                   ; preds = %lor.lhs.false
  %4 = load ptr, ptr %c.addr, align 8, !nonnull !4, !align !5
  %call6 = call noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %4) #6
  %5 = load ptr, ptr %b.addr, align 8, !nonnull !4, !align !5
  %call7 = call noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %5) #6
  %cmp8 = icmp ne i64 %call6, %call7
  br i1 %cmp8, label %if.then, label %if.end

if.then:                                          ; preds = %lor.lhs.false5, %lor.lhs.false, %entry
  %exception = call ptr @__cxa_allocate_exception(i64 16) #6
  invoke void @_ZNSt16invalid_argumentC1EPKc(ptr noundef nonnull align 8 dereferenceable(16) %exception, ptr noundef @.str)
          to label %invoke.cont unwind label %lpad

invoke.cont:                                      ; preds = %if.then
  call void @__cxa_throw(ptr %exception, ptr @_ZTISt16invalid_argument, ptr @_ZNSt16invalid_argumentD1Ev) #7
  unreachable

lpad:                                             ; preds = %if.then
  %6 = landingpad { ptr, i32 }
          cleanup
  %7 = extractvalue { ptr, i32 } %6, 0
  store ptr %7, ptr %exn.slot, align 8
  %8 = extractvalue { ptr, i32 } %6, 1
  store i32 %8, ptr %ehselector.slot, align 4
  call void @__cxa_free_exception(ptr %exception) #6
  br label %eh.resume

if.end:                                           ; preds = %lor.lhs.false5
  %9 = load ptr, ptr %a.addr, align 8, !nonnull !4, !align !5
  %call9 = call noundef i64 @_ZNK4gemm6Matrix4rowsEv(ptr noundef nonnull align 8 dereferenceable(40) %9) #6
  store i64 %call9, ptr %m, align 8
  %10 = load ptr, ptr %b.addr, align 8, !nonnull !4, !align !5
  %call10 = call noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %10) #6
  store i64 %call10, ptr %n, align 8
  %11 = load ptr, ptr %a.addr, align 8, !nonnull !4, !align !5
  %call11 = call noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %11) #6
  store i64 %call11, ptr %k_size, align 8
  store i64 0, ptr %i, align 8
  br label %for.cond

for.cond:                                         ; preds = %for.inc25, %if.end
  %12 = load i64, ptr %i, align 8
  %13 = load i64, ptr %m, align 8
  %cmp12 = icmp ult i64 %12, %13
  br i1 %cmp12, label %for.body, label %for.end27

for.body:                                         ; preds = %for.cond
  store i64 0, ptr %j, align 8
  br label %for.cond13

for.cond13:                                       ; preds = %for.inc22, %for.body
  %14 = load i64, ptr %j, align 8
  %15 = load i64, ptr %n, align 8
  %cmp14 = icmp ult i64 %14, %15
  br i1 %cmp14, label %for.body15, label %for.end24

for.body15:                                       ; preds = %for.cond13
  store float 0.000000e+00, ptr %sum, align 4
  store i64 0, ptr %k, align 8
  br label %for.cond16

for.cond16:                                       ; preds = %for.inc, %for.body15
  %16 = load i64, ptr %k, align 8
  %17 = load i64, ptr %k_size, align 8
  %cmp17 = icmp ult i64 %16, %17
  br i1 %cmp17, label %for.body18, label %for.end

for.body18:                                       ; preds = %for.cond16
  %18 = load ptr, ptr %a.addr, align 8, !nonnull !4, !align !5
  %19 = load i64, ptr %i, align 8
  %20 = load i64, ptr %k, align 8
  %call19 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNK4gemm6MatrixclEmm(ptr noundef nonnull align 8 dereferenceable(40) %18, i64 noundef %19, i64 noundef %20) #6
  %21 = load float, ptr %call19, align 4
  %22 = load ptr, ptr %b.addr, align 8, !nonnull !4, !align !5
  %23 = load i64, ptr %k, align 8
  %24 = load i64, ptr %j, align 8
  %call20 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNK4gemm6MatrixclEmm(ptr noundef nonnull align 8 dereferenceable(40) %22, i64 noundef %23, i64 noundef %24) #6
  %25 = load float, ptr %call20, align 4
  %26 = load float, ptr %sum, align 4
  %27 = call float @llvm.fmuladd.f32(float %21, float %25, float %26)
  store float %27, ptr %sum, align 4
  br label %for.inc

for.inc:                                          ; preds = %for.body18
  %28 = load i64, ptr %k, align 8
  %inc = add i64 %28, 1
  store i64 %inc, ptr %k, align 8
  br label %for.cond16, !llvm.loop !6

for.end:                                          ; preds = %for.cond16
  %29 = load float, ptr %sum, align 4
  %30 = load ptr, ptr %c.addr, align 8, !nonnull !4, !align !5
  %31 = load i64, ptr %i, align 8
  %32 = load i64, ptr %j, align 8
  %call21 = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN4gemm6MatrixclEmm(ptr noundef nonnull align 8 dereferenceable(40) %30, i64 noundef %31, i64 noundef %32) #6
  store float %29, ptr %call21, align 4
  br label %for.inc22

for.inc22:                                        ; preds = %for.end
  %33 = load i64, ptr %j, align 8
  %inc23 = add i64 %33, 1
  store i64 %inc23, ptr %j, align 8
  br label %for.cond13, !llvm.loop !8

for.end24:                                        ; preds = %for.cond13
  br label %for.inc25

for.inc25:                                        ; preds = %for.end24
  %34 = load i64, ptr %i, align 8
  %inc26 = add i64 %34, 1
  store i64 %inc26, ptr %i, align 8
  br label %for.cond, !llvm.loop !9

for.end27:                                        ; preds = %for.cond
  ret void

eh.resume:                                        ; preds = %lpad
  %exn = load ptr, ptr %exn.slot, align 8
  %sel = load i32, ptr %ehselector.slot, align 4
  %lpad.val = insertvalue { ptr, i32 } poison, ptr %exn, 0
  %lpad.val28 = insertvalue { ptr, i32 } %lpad.val, i32 %sel, 1
  resume { ptr, i32 } %lpad.val28
}

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef i64 @_ZNK4gemm6Matrix4colsEv(ptr noundef nonnull align 8 dereferenceable(40) %this) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %cols_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 1
  %0 = load i64, ptr %cols_, align 8
  ret i64 %0
}

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef i64 @_ZNK4gemm6Matrix4rowsEv(ptr noundef nonnull align 8 dereferenceable(40) %this) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %rows_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 0
  %0 = load i64, ptr %rows_, align 8
  ret i64 %0
}

declare dso_local ptr @__cxa_allocate_exception(i64)

declare dso_local void @_ZNSt16invalid_argumentC1EPKc(ptr noundef nonnull align 8 dereferenceable(16), ptr noundef) unnamed_addr #2

declare dso_local i32 @__gxx_personality_v0(...)

declare dso_local void @__cxa_free_exception(ptr)

; Function Attrs: nounwind
declare dso_local void @_ZNSt16invalid_argumentD1Ev(ptr noundef nonnull align 8 dereferenceable(16)) unnamed_addr #3

declare dso_local void @__cxa_throw(ptr, ptr, ptr)

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef nonnull align 4 dereferenceable(4) ptr @_ZNK4gemm6MatrixclEmm(ptr noundef nonnull align 8 dereferenceable(40) %this, i64 noundef %row, i64 noundef %col) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %row.addr = alloca i64, align 8
  %col.addr = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store i64 %row, ptr %row.addr, align 8
  store i64 %col, ptr %col.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %data_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 2
  %0 = load i64, ptr %row.addr, align 8
  %cols_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 1
  %1 = load i64, ptr %cols_, align 8
  %mul = mul i64 %0, %1
  %2 = load i64, ptr %col.addr, align 8
  %add = add i64 %mul, %2
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt6vectorIfSaIfEEixEm(ptr noundef nonnull align 8 dereferenceable(24) %data_, i64 noundef %add) #6
  ret ptr %call
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #4

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef nonnull align 4 dereferenceable(4) ptr @_ZN4gemm6MatrixclEmm(ptr noundef nonnull align 8 dereferenceable(40) %this, i64 noundef %row, i64 noundef %col) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %row.addr = alloca i64, align 8
  %col.addr = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store i64 %row, ptr %row.addr, align 8
  store i64 %col, ptr %col.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %data_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 2
  %0 = load i64, ptr %row.addr, align 8
  %cols_ = getelementptr inbounds nuw %"class.gemm::Matrix", ptr %this1, i32 0, i32 1
  %1 = load i64, ptr %cols_, align 8
  %mul = mul i64 %0, %1
  %2 = load i64, ptr %col.addr, align 8
  %add = add i64 %mul, %2
  %call = call noundef nonnull align 4 dereferenceable(4) ptr @_ZNSt6vectorIfSaIfEEixEm(ptr noundef nonnull align 8 dereferenceable(24) %data_, i64 noundef %add) #6
  ret ptr %call
}

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef nonnull align 4 dereferenceable(4) ptr @_ZNKSt6vectorIfSaIfEEixEm(ptr noundef nonnull align 8 dereferenceable(24) %this, i64 noundef %__n) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__n.addr = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store i64 %__n, ptr %__n.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  br label %do.body

do.body:                                          ; preds = %entry
  %0 = load i64, ptr %__n.addr, align 8
  %call = call noundef i64 @_ZNKSt6vectorIfSaIfEE4sizeEv(ptr noundef nonnull align 8 dereferenceable(24) %this1) #6
  %cmp = icmp ult i64 %0, %call
  %lnot = xor i1 %cmp, true
  br i1 %lnot, label %if.then, label %if.end

if.then:                                          ; preds = %do.body
  call void @_ZSt21__glibcxx_assert_failPKciS0_S0_(ptr noundef @.str.1, i32 noundef 1272, ptr noundef @__PRETTY_FUNCTION__._ZNKSt6vectorIfSaIfEEixEm, ptr noundef @.str.2) #8
  unreachable

if.end:                                           ; preds = %do.body
  br label %do.cond

do.cond:                                          ; preds = %if.end
  br label %do.end

do.end:                                           ; preds = %do.cond
  %_M_impl = getelementptr inbounds nuw %"struct.std::_Vector_base", ptr %this1, i32 0, i32 0
  %_M_start = getelementptr inbounds nuw %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data", ptr %_M_impl, i32 0, i32 0
  %1 = load ptr, ptr %_M_start, align 8
  %2 = load i64, ptr %__n.addr, align 8
  %add.ptr = getelementptr inbounds nuw float, ptr %1, i64 %2
  ret ptr %add.ptr
}

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef i64 @_ZNKSt6vectorIfSaIfEE4sizeEv(ptr noundef nonnull align 8 dereferenceable(24) %this) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__dif = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  %_M_impl = getelementptr inbounds nuw %"struct.std::_Vector_base", ptr %this1, i32 0, i32 0
  %_M_finish = getelementptr inbounds nuw %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data", ptr %_M_impl, i32 0, i32 1
  %0 = load ptr, ptr %_M_finish, align 8
  %_M_impl2 = getelementptr inbounds nuw %"struct.std::_Vector_base", ptr %this1, i32 0, i32 0
  %_M_start = getelementptr inbounds nuw %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data", ptr %_M_impl2, i32 0, i32 0
  %1 = load ptr, ptr %_M_start, align 8
  %sub.ptr.lhs.cast = ptrtoint ptr %0 to i64
  %sub.ptr.rhs.cast = ptrtoint ptr %1 to i64
  %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
  %sub.ptr.div = sdiv exact i64 %sub.ptr.sub, 4
  store i64 %sub.ptr.div, ptr %__dif, align 8
  %2 = load i64, ptr %__dif, align 8
  %cmp = icmp slt i64 %2, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  unreachable

if.end:                                           ; preds = %entry
  %3 = load i64, ptr %__dif, align 8
  ret i64 %3
}

; Function Attrs: cold noreturn nounwind
declare dso_local void @_ZSt21__glibcxx_assert_failPKciS0_S0_(ptr noundef, i32 noundef, ptr noundef, ptr noundef) #5

; Function Attrs: mustprogress noinline nounwind optnone uwtable
define linkonce_odr dso_local noundef nonnull align 4 dereferenceable(4) ptr @_ZNSt6vectorIfSaIfEEixEm(ptr noundef nonnull align 8 dereferenceable(24) %this, i64 noundef %__n) #1 comdat align 2 {
entry:
  %this.addr = alloca ptr, align 8
  %__n.addr = alloca i64, align 8
  store ptr %this, ptr %this.addr, align 8
  store i64 %__n, ptr %__n.addr, align 8
  %this1 = load ptr, ptr %this.addr, align 8
  br label %do.body

do.body:                                          ; preds = %entry
  %0 = load i64, ptr %__n.addr, align 8
  %call = call noundef i64 @_ZNKSt6vectorIfSaIfEE4sizeEv(ptr noundef nonnull align 8 dereferenceable(24) %this1) #6
  %cmp = icmp ult i64 %0, %call
  %lnot = xor i1 %cmp, true
  br i1 %lnot, label %if.then, label %if.end

if.then:                                          ; preds = %do.body
  call void @_ZSt21__glibcxx_assert_failPKciS0_S0_(ptr noundef @.str.1, i32 noundef 1253, ptr noundef @__PRETTY_FUNCTION__._ZNSt6vectorIfSaIfEEixEm, ptr noundef @.str.2) #8
  unreachable

if.end:                                           ; preds = %do.body
  br label %do.cond

do.cond:                                          ; preds = %if.end
  br label %do.end

do.end:                                           ; preds = %do.cond
  %_M_impl = getelementptr inbounds nuw %"struct.std::_Vector_base", ptr %this1, i32 0, i32 0
  %_M_start = getelementptr inbounds nuw %"struct.std::_Vector_base<float, std::allocator<float>>::_Vector_impl_data", ptr %_M_impl, i32 0, i32 0
  %1 = load ptr, ptr %_M_start, align 8
  %2 = load i64, ptr %__n.addr, align 8
  %add.ptr = getelementptr inbounds nuw float, ptr %1, i64 %2
  ret ptr %add.ptr
}

attributes #0 = { mustprogress noinline optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { mustprogress noinline nounwind optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #2 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #3 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #4 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #5 = { cold noreturn nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #6 = { nounwind }
attributes #7 = { noreturn }
attributes #8 = { cold noreturn nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"uwtable", i32 2}
!2 = !{i32 7, !"frame-pointer", i32 2}
!3 = !{!"clang version 22.1.8 (Fedora 22.1.8-4.fc44)"}
!4 = !{}
!5 = !{i64 8}
!6 = distinct !{!6, !7}
!7 = !{!"llvm.loop.mustprogress"}
!8 = distinct !{!8, !7}
!9 = distinct !{!9, !7}
