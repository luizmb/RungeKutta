// `[Double]`-specialised RK45 step + trajectory entry points.
//
// Picked by Swift's overload resolution at the call site when `State` is
// concretely `[Double]`. Routes the per-stage vector arithmetic through
// vDSP's fused multiply-add (vDSP_vsmaD), so each `y + (h·aᵢⱼ)·kⱼ` is one
// in-place SIMD operation rather than two allocations through the generic
// `+` and `*`.
//
// Apple-only — Accelerate provides vDSP; OpenBLAS doesn't have direct
// equivalents for elementwise vector add / scale. On Linux + OpenBLAS the
// generic trajectory keeps the per-stage ops on the scalar Swift path (the
// dominant cost is the derivative evaluation, which already routes through
// `Matrix.apply(to:)` → `cblas_dgemv`).

#if canImport(Accelerate) && !SWIFTCALX_NO_ACCELERATE
import Accelerate
import Math

extension RungeKutta45 {
    // MARK: - Specialised step

    /// `[Double]`-specialised Dormand-Prince step. Identical math to
    /// ``step(from:y:k1:size:derivative:)``; the per-stage vector
    /// combination uses vDSP for fewer allocations and SIMD throughput.
    internal static func stepDouble(
        from t: Double,
        y: [Double],
        k1: [Double],
        size h: Double,
        derivative f: @Sendable (Double, [Double]) -> [Double]
    ) -> Step<[Double]> {
        // Stage 2: y + (h·a21)·k1
        var acc2 = y
        scaledAddInPlace(&acc2, scalar: h * A.a21, vector: k1)
        let k2 = f(t + C.c2 * h, acc2)

        // Stage 3: y + (h·a31)·k1 + (h·a32)·k2
        var acc3 = y
        scaledAddInPlace(&acc3, scalar: h * A.a31, vector: k1)
        scaledAddInPlace(&acc3, scalar: h * A.a32, vector: k2)
        let k3 = f(t + C.c3 * h, acc3)

        // Stage 4
        var acc4 = y
        scaledAddInPlace(&acc4, scalar: h * A.a41, vector: k1)
        scaledAddInPlace(&acc4, scalar: h * A.a42, vector: k2)
        scaledAddInPlace(&acc4, scalar: h * A.a43, vector: k3)
        let k4 = f(t + C.c4 * h, acc4)

        // Stage 5
        var acc5 = y
        scaledAddInPlace(&acc5, scalar: h * A.a51, vector: k1)
        scaledAddInPlace(&acc5, scalar: h * A.a52, vector: k2)
        scaledAddInPlace(&acc5, scalar: h * A.a53, vector: k3)
        scaledAddInPlace(&acc5, scalar: h * A.a54, vector: k4)
        let k5 = f(t + C.c5 * h, acc5)

        // Stage 6
        var acc6 = y
        scaledAddInPlace(&acc6, scalar: h * A.a61, vector: k1)
        scaledAddInPlace(&acc6, scalar: h * A.a62, vector: k2)
        scaledAddInPlace(&acc6, scalar: h * A.a63, vector: k3)
        scaledAddInPlace(&acc6, scalar: h * A.a64, vector: k4)
        scaledAddInPlace(&acc6, scalar: h * A.a65, vector: k5)
        let k6 = f(t + C.c6 * h, acc6)

        // 5th-order solution (B5.b2 and B5.b7 are zero, so skipped).
        var y5 = y
        scaledAddInPlace(&y5, scalar: h * B5.b1, vector: k1)
        scaledAddInPlace(&y5, scalar: h * B5.b3, vector: k3)
        scaledAddInPlace(&y5, scalar: h * B5.b4, vector: k4)
        scaledAddInPlace(&y5, scalar: h * B5.b5, vector: k5)
        scaledAddInPlace(&y5, scalar: h * B5.b6, vector: k6)

        // FSAL stage: k7 = f(t + h, y5)
        let k7 = f(t + C.c7 * h, y5)

        // 4th-order embedded (B4.b2 is zero, skipped).
        var y4 = y
        scaledAddInPlace(&y4, scalar: h * B4.b1, vector: k1)
        scaledAddInPlace(&y4, scalar: h * B4.b3, vector: k3)
        scaledAddInPlace(&y4, scalar: h * B4.b4, vector: k4)
        scaledAddInPlace(&y4, scalar: h * B4.b5, vector: k5)
        scaledAddInPlace(&y4, scalar: h * B4.b6, vector: k6)
        scaledAddInPlace(&y4, scalar: h * B4.b7, vector: k7)

        // Error norm = ||y5 - y4||_∞
        let diff = subtract(y5, y4)
        return Step(y5: y5, y4: y4, kLast: k7, errorNorm: diff.infinityNorm)
    }

    // MARK: - vDSP primitives

    /// `acc += scalar · vector`  via `vDSP_vsmaD` with `acc` as both input
    /// and output (vDSP supports this in-place).
    @inline(__always)
    private static func scaledAddInPlace(
        _ acc: inout [Double],
        scalar: Double,
        vector: [Double]
    ) {
        let n = acc.count
        var alpha = scalar
        vector.withUnsafeBufferPointer { vBuf in
            acc.withUnsafeMutableBufferPointer { accBuf in
                if let v = vBuf.baseAddress, let a = accBuf.baseAddress {
                    vDSP_vsmaD(v, 1, &alpha, a, 1, a, 1, vDSP_Length(n))
                }
            }
        }
    }

    /// `result = lhs - rhs`  via `vDSP_vsubD`. (vDSP signature is
    /// `result = b - a`, so arguments are swapped at the call site.)
    @inline(__always)
    private static func subtract(_ lhs: [Double], _ rhs: [Double]) -> [Double] {
        let n = lhs.count
        var result = [Double](repeating: 0, count: n)
        lhs.withUnsafeBufferPointer { lBuf in
            rhs.withUnsafeBufferPointer { rBuf in
                result.withUnsafeMutableBufferPointer { resBuf in
                    if let l = lBuf.baseAddress, let r = rBuf.baseAddress, let res = resBuf.baseAddress {
                        vDSP_vsubD(r, 1, l, 1, res, 1, vDSP_Length(n))
                    }
                }
            }
        }
        return result
    }
}

#endif
