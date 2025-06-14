; string-related:

@.str_i32 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str_i64 = private unnamed_addr constant [5 x i8] c"%ld\0A\00", align 1
@.str_i16 = private unnamed_addr constant [5 x i8] c"%hd\0A\00", align 1
@.str_i8 = private unnamed_addr constant [6 x i8] c"%hhd\0A\00", align 1
@.str_i1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1
@.str_char = private unnamed_addr constant [4 x i8] c"%c\0A\00", align 1
@.str_float = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@.str_double = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1

declare i32 @printf(i8*, ...)

define void @FuzzerUtils.print(i64 %value) {
entry:
    %fmt = getelementptr inbounds [5 x i8], [5 x i8]* @.str_i64, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i64 %value)
    ret void
}

define void @FuzzerUtils.print.1(i32 %value) {
entry:
    %fmt = getelementptr inbounds [4 x i8], [4 x i8]* @.str_i32, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i32 %value)
    ret void
}

define void @FuzzerUtils.print.2(i16 %value) {
entry:
    %fmt = getelementptr inbounds [5 x i8], [5 x i8]* @.str_i16, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i16 %value)
    ret void
}

define void @FuzzerUtils.print.3(i8 %value) {
entry:
    %fmt = getelementptr inbounds [6 x i8], [6 x i8]* @.str_i8, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i8 %value) 
    ret void
}

define void @FuzzerUtils.print.4(i1 %value) {
entry:
    %fmt = getelementptr inbounds [4 x i8], [4 x i8]* @.str_i1, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, i1 %value) 
    ret void
}

define void @FuzzerUtils.print.5(double %value) {
entry:
    %fmt = getelementptr inbounds [5 x i8], [5 x i8]* @.str_double, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, double %value)
    ret void
}

define void @FuzzerUtils.print.6(float %value) {
entry:
    %fmt = getelementptr inbounds [4 x i8], [4 x i8]* @.str_float, i32 0, i32 0
    call i32 (i8*, ...) @printf(i8* %fmt, float %value)
    ret void
}

; Java fuzzer related
%struct.java.lang.String = type opaque
declare void @"Test.<clinit>"()
declare void @"FuzzerUtils.<clinit>"()
declare void @Test.main([0 x %struct.java.lang.String*]* )

define i32 @main() {
entry:
    call void @java_fuzzer()
    ret i32 0
}

define void @java_fuzzer() {
entry:
    call void @"Test.<clinit>"()
    call void @"FuzzerUtils.<clinit>"()
    call void @Test.main([0 x %struct.java.lang.String*]* null)
    ret void
}

define void @test() {
entry:
    call void @FuzzerUtils.print(i64 123456789)
    call void @FuzzerUtils.print.1(i32 42)
    call void @FuzzerUtils.print.2(i16 1234)
    call void @FuzzerUtils.print.3(i8 12)
    call void @FuzzerUtils.print.4(i1 1)
    call void @FuzzerUtils.print.5(double 2.71828)
    call void @FuzzerUtils.print.6(float 0x400928F5C0000000)
    call void @"java.lang.Object.<init>"(%struct.java.lang.Object* null)
    %array = call i64 @jellyfish.newarray.1d(i32 4, i32 10)
    %arrayptr = inttoptr i64 %array to i32*
    %size = call i32 @jellyfish.length(i32* %arrayptr)
    call void @FuzzerUtils.print.1(i32 %size)
    %int2int = trunc i32 -17344 to i16
    call void @FuzzerUtils.print.2(i16 %int2int)
    ret void
}

; OO-related

%struct.java.lang.Object = type opaque

define void @"java.lang.Object.<init>"(%struct.java.lang.Object*) {
entry:
    ret void
}


; array related
define i32 @jellyfish.length(i32*) {
entry:
    %new_ptr = getelementptr i32, i32* %0, i32 -1
    %value = load i32, i32* %new_ptr
    ret i32 %value
}

define i64 @jellyfish.newarray.1d(i32, i32) {
entry:
    %size = mul i32 %0, %1
    %ptr = call i64 @alloc_and_initsize(i32 %size)
    ret i64 %ptr
}

define i64 @jellyfish.newarray.2d(i32, i32, i32) {
entry:
    %size = mul i32 %0, %1
    %size1 = mul i32 %size, %2
    %ptr = call i64 @alloc_and_initsize(i32 %size1)
    ret i64 %ptr
}

declare noalias i8* @malloc(i32)
define i64 @alloc_and_initsize(i32 %N) {
entry:
    %size = add i32 %N, 4
    %ptr = call i8* @malloc(i32 %size)

    %null_check = icmp eq i8* %ptr, null
    br i1 %null_check, label %malloc_failed, label %malloc_success

malloc_failed:
    ret i64 0

malloc_success:
    %int_ptr = bitcast i8* %ptr to i32*
    store i32 %N, i32* %int_ptr

    %result_ptr = getelementptr i32, i32* %int_ptr, i32 1
    %bitcast = ptrtoint i32* %result_ptr to i64
    ret i64 %bitcast
}

; Math related
define i32 @java.lang.Math.abs(i32) {
entry:
    %is_negative = icmp slt i32 %0, 0
    %neg = sub i32 0, %0
    %result = select i1 %is_negative, i32 %neg, i32 %0
    ret i32 %result
}

define i64 @java.lang.Math.abs.1(i64) {
entry:
    %is_negative = icmp slt i64 %0, 0
    %neg = sub i64 0, %0
    %result = select i1 %is_negative, i64 %neg, i64 %0
    ret i64 %result
}


define float @java.lang.Math.abs.2(float) {
entry:
    %is_negative = fcmp olt float %0, 0.0
    %neg = fsub float 0.0, %0
    %result = select i1 %is_negative, float %neg, float %0
    ret float %result
}

define float @java.lang.Math.abs.2(float) {
entry:
    %is_negative = fcmp olt float %0, 0.0
    %neg = fsub float 0.0, %0
    %result = select i1 %is_negative, float %neg, float %0
    ret float %result
}

define double @java.lang.Math.abs.3(double) {
entry:
    %is_negative = fcmp olt double %0, 0.0
    %neg = fsub double 0.0, %0
    %result = select i1 %is_negative, double %neg, double %0
    ret double %result
}


define i32 @java.lang.Math.max(i32 %a, i32 %b) {
entry:
    %is_a_greater = icmp sgt i32 %a, %b
    %result = select i1 %is_a_greater, i32 %a, i32 %b
    ret i32 %result
}

define i64 @java.lang.Math.max.1(i64 %a, i64 %b) {
entry:
    %is_a_greater = icmp sgt i64 %a, %b
    %result = select i1 %is_a_greater, i64 %a, i64 %b
    ret i64 %result
}

define i32 @java.lang.Math.min(i32 %a, i32 %b) {
entry:
    %is_a_greater = icmp sgt i32 %a, %b
    %result = select i1 %is_a_greater, i32 %b, i32 %a
    ret i32 %result
}

define i64 @java.lang.Math.min.1(i64 %a, i64 %b) {
entry:
    %is_a_greater = icmp sgt i64 %a, %b
    %result = select i1 %is_a_greater, i64 %b, i64 %a
    ret i64 %result
}

