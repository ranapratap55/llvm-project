; RUN: opt -S -aarch64-sve-intrinsic-opts < %s | FileCheck %s

target triple = "aarch64-unknown-linux-gnu"

define <vscale x 16 x i1> @pred_load_v2i8(ptr %addr) #0 {
; CHECK-LABEL: @pred_load_v2i8(
; CHECK-NEXT:    [[TMP2:%.*]] = load <vscale x 16 x i1>, ptr %addr
; CHECK-NEXT:    ret <vscale x 16 x i1> [[TMP2]]
  %load = load <2 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v2i8(<vscale x 2 x i8> poison, <2 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

define <vscale x 16 x i1> @pred_load_v4i8(ptr %addr) #1 {
; CHECK-LABEL: @pred_load_v4i8(
; CHECK-NEXT:    [[TMP2:%.*]] = load <vscale x 16 x i1>, ptr %addr
; CHECK-NEXT:    ret <vscale x 16 x i1> [[TMP2]]
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> poison, <4 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

define <vscale x 16 x i1> @pred_load_v8i8(ptr %addr) #2 {
; CHECK-LABEL: @pred_load_v8i8(
; CHECK-NEXT:    [[TMP2:%.*]] = load <vscale x 16 x i1>, ptr %addr
; CHECK-NEXT:    ret <vscale x 16 x i1> [[TMP2]]
  %load = load <8 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v8i8(<vscale x 2 x i8> poison, <8 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Ensure the insertion point is at the load
define <vscale x 16 x i1> @pred_load_insertion_point(ptr %addr) #0 {
; CHECK-LABEL: @pred_load_insertion_point(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP2:%.*]] = load <vscale x 16 x i1>, ptr %addr
; CHECK-NEXT:    br label %bb1
; CHECK:       bb1:
; CHECK-NEXT:    ret <vscale x 16 x i1> [[TMP2]]
entry:
  %load = load <2 x i8>, ptr %addr, align 4
  br label %bb1

bb1:
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v2i8(<vscale x 2 x i8> poison, <2 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Check that too small of a vscale prevents optimization
define <vscale x 16 x i1> @pred_load_neg1(ptr %addr) #0 {
; CHECK-LABEL: @pred_load_neg1(
; CHECK:         call <vscale x 2 x i8> @llvm.vector.insert
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> poison, <4 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Check that too large of a vscale prevents optimization
define <vscale x 16 x i1> @pred_load_neg2(ptr %addr) #2 {
; CHECK-LABEL: @pred_load_neg2(
; CHECK:         call <vscale x 2 x i8> @llvm.vector.insert
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> poison, <4 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Check that a non-zero index prevents optimization
define <vscale x 16 x i1> @pred_load_neg3(ptr %addr) #1 {
; CHECK-LABEL: @pred_load_neg3(
; CHECK:         call <vscale x 2 x i8> @llvm.vector.insert
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> poison, <4 x i8> %load, i64 4)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Check that differing vscale min/max prevents optimization
define <vscale x 16 x i1> @pred_load_neg4(ptr %addr) #3 {
; CHECK-LABEL: @pred_load_neg4(
; CHECK:         call <vscale x 2 x i8> @llvm.vector.insert
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> poison, <4 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

; Check that insertion into a non-undef vector prevents optimization
define <vscale x 16 x i1> @pred_load_neg5(ptr %addr, <vscale x 2 x i8> %passthru) #1 {
; CHECK-LABEL: @pred_load_neg5(
; CHECK:         call <vscale x 2 x i8> @llvm.vector.insert
  %load = load <4 x i8>, ptr %addr, align 4
  %insert = tail call <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8> %passthru, <4 x i8> %load, i64 0)
  %ret = bitcast <vscale x 2 x i8> %insert to <vscale x 16 x i1>
  ret <vscale x 16 x i1> %ret
}

declare <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v2i8(<vscale x 2 x i8>, <2 x i8>, i64)
declare <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v4i8(<vscale x 2 x i8>, <4 x i8>, i64)
declare <vscale x 2 x i8> @llvm.vector.insert.nxv2i8.v8i8(<vscale x 2 x i8>, <8 x i8>, i64)

attributes #0 = { "target-features"="+sve" vscale_range(1,1) }
attributes #1 = { "target-features"="+sve" vscale_range(2,2) }
attributes #2 = { "target-features"="+sve" vscale_range(4,4) }
attributes #3 = { "target-features"="+sve" vscale_range(2,4) }
