//
//  EquatableEnough.swift
//
//
//  Created by Adam Bell on 8/2/20.
//


import CoreGraphics
import Foundation
import simd


public protocol FloatingPointInitializable: FloatingPoint & ExpressibleByFloatLiteral & Comparable {
    init(_ value: Float)
    init(_ value: Double)
}

extension Float: FloatingPointInitializable, EquatableEnough {}
extension Double: FloatingPointInitializable, EquatableEnough {}
extension CGFloat: FloatingPointInitializable, EquatableEnough {}

public protocol EquatableEnough {
    associatedtype EpsilonType: EquatableEnough, FloatingPointInitializable

    /**
     Declares whether or not something else is equal to `self` within a given tolerance.
     (e.g. a floating point value that is equal to another floating point value within a given epsilon)
     */
    func isApproximatelyEqual(to: Self, epsilon: EpsilonType) -> Bool
}

extension SIMD2: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }
extension SIMD3: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }
extension SIMD4: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }
extension SIMD8: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }
extension SIMD16: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }
extension SIMD32: EquatableEnough where Scalar: FloatingPointInitializable & EquatableEnough { }

extension FloatingPointInitializable {
    @inlinable public func isApproximatelyEqual(to other: Self, epsilon: Self) -> Bool {
        isApproximatelyEqual(to: other, absoluteTolerance: epsilon)
    }
}

extension EquatableEnough where Self: SIMD, Scalar: FloatingPointInitializable {
    @inlinable public func isApproximatelyEqual(to other: Self, epsilon: Scalar) -> Bool {
        for i in 0..<indices.count {
            let equal = self[i].isApproximatelyEqual(to: other[i], absoluteTolerance: epsilon)
            if !equal {
                return false
            }
        }
        return true
    }
}

extension SIMDRepresentable where SIMDType: EquatableEnough {
    public func isApproximatelyEqual(to: Self, epsilon: SIMDType.EpsilonType) -> Bool {
        self.simdRepresentation().isApproximatelyEqual(to: to.simdRepresentation(), epsilon: epsilon)
    }
}

extension Numeric where Magnitude: FloatingPoint {
  /// Test if `self` and `other` are approximately equal.
  ///
  /// `true` if `self` and `other` are equal, or if they are finite and
  /// ```
  /// norm(self - other) <= relativeTolerance * scale
  /// ```
  /// where `scale` is
  /// ```
  /// max(norm(self), norm(other), .leastNormalMagnitude)
  /// ```
  ///
  /// The default value of `relativeTolerance` is `.ulpOfOne.squareRoot()`,
  /// which corresponds to expecting "about half the digits" in the computed
  /// results to be good. This is the usual guidance in numerical analysis,
  /// if you don't know anything about the computation being performed, but
  /// is not suitable for all use cases.
  ///
  /// Mathematical Properties:
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:norm:)` is _reflexive_ for
  ///   non-exceptional values (such as NaN).
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:norm:)` is _symmetric_.
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:norm:)` is __not__
  ///   _transitive_. Because of this, approximately equality is __not an
  ///   equivalence relation__, even when restricted to non-exceptional values.
  ///
  ///   This means that you must not use approximate equality to implement
  ///   a conformance to Equatable, as it will violate the invariants of
  ///   code written against that protocol.
  ///
  /// - For any point `a`, the set of values that compare approximately equal
  ///   to `a` is _convex_. (Under the assumption that the `.magnitude`
  ///   property implements a valid norm.)
  ///
  /// - `isApproximatelyEqual(to:relativeTolerance:norm:)` is _scale invariant_,
  ///   so long as no underflow or overflow has occured, and no exceptional
  ///   value is produced by the scaling.
  ///
  /// See also `isApproximatelyEqual(to:absoluteTolerance:[relativeTolerance:norm:])`.
  ///
  /// - Parameters:
  ///
  ///   - other: The value to which `self` is compared.
  ///
  ///   - relativeTolerance: The tolerance to use for the comparison.
  ///     Defaults to `.ulpOfOne.squareRoot()`.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint on is only checked in debug builds, because a
  ///     mathematically well-defined result exists for any tolerance,
  ///     even one out of range.
  ///
  ///   - norm: The [norm] to use for the comparison.
  ///     Defaults to `\.magnitude`.
  ///
  /// [norm]: https://en.wikipedia.org/wiki/Norm_(mathematics)
public func isApproximatelyEqual(to other: Self, relativeTolerance: Magnitude = Magnitude.ulpOfOne.squareRoot(), norm: (Self) -> Magnitude = \.magnitude) -> Bool {
    return isApproximatelyEqual(to: other, absoluteTolerance: relativeTolerance * Magnitude.leastNormalMagnitude, relativeTolerance: relativeTolerance, norm: norm)
  }
  
  @inlinable @inline(__always)
  public func isApproximatelyEqual(
    to other: Self,
    absoluteTolerance: Magnitude,
    relativeTolerance: Magnitude = 0
  ) -> Bool {
    self.isApproximatelyEqual(
      to: other,
      absoluteTolerance: absoluteTolerance,
      relativeTolerance: relativeTolerance,
      norm: \.magnitude
    )
  }
}

extension AdditiveArithmetic {
  /// Test if `self` and `other` are approximately equal with specified
  /// tolerances and norm.
  ///
  /// `true` if `self` and `other` are equal, or if they are finite and either
  /// ```
  /// norm(self - other) <= absoluteTolerance
  /// ```
  /// or
  /// ```
  /// norm(self - other) <= relativeTolerance * scale
  /// ```
  /// where `scale` is `max(norm(self), norm(other))`.
  ///
  /// Mathematical Properties:
  ///
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:norm:)`
  ///   is _reflexive_ for non-exceptional values (such as NaN).
  ///
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:norm:)`
  ///   is _symmetric_.
  ///
  /// - `isApproximatelyEqual(to:absoluteTolerance:relativeTolerance:norm:)`
  ///   is __not__ _transitive_. Because of this, approximately equality is
  ///   __not an equivalence relation__, even when restricted to
  ///   non-exceptional values.
  ///
  ///   This means that you must not use approximate equality to implement
  ///   a conformance to Equatable, as it will violate the invariants of
  ///   code written against that protocol.
  ///
  /// - For any point `a`, the set of values that compare approximately equal
  ///   to `a` is _convex_ (under the assumption that `norm` implements a
  ///   valid norm, which cannot be checked by this function or a protocol).
  ///
  /// See also `isApproximatelyEqual(to:[relativeTolerance:norm:])` and
  /// `isApproximatelyEqual(to:absoluteTolerance:[relativeTolerance:])`.
  ///
  /// - Parameters:
  ///
  ///   - other: The value to which `self` is compared.
  ///
  ///   - absoluteTolerance: The absolute tolerance to use in the comparison.
  ///
  ///     This value should be non-negative and finite.
  ///     This constraint on is only checked in debug builds, because a
  ///     mathematically well-defined result exists for any tolerance, even
  ///     one out of range.
  ///
  ///   - relativeTolerance: The relative tolerance to use in the comparison.
  ///     Defaults to zero.
  ///
  ///     This value should be non-negative and less than or equal to 1.
  ///     This constraint on is only checked in debug builds, because a
  ///     mathematically well-defined result exists for any tolerance,
  ///     even one out of range.
  ///
  ///   - norm: The norm to use for the comparison.
  ///     Defaults to `\.magnitude`.
  ///
  ///     For example, if we wanted to test if a complex value was inside a
  ///     circle of radius 0.001 centered at (1 + 0i), we could use:
  ///     ```
  ///     z.isApproximatelyEqual(
  ///       to: 1,
  ///       absoluteTolerance: 0.001,
  ///       norm: \.length
  ///     )
  ///     ```
  ///     (if we used the default norm, `.magnitude`, we would be testing if
  ///     `z` were inside a square region instead.)
  @inlinable
  public func isApproximatelyEqual<Magnitude>(
    to other: Self,
    absoluteTolerance: Magnitude,
    relativeTolerance: Magnitude = 0,
    norm: (Self) -> Magnitude
  ) -> Bool
  // TODO: constraint should really be weaker than FloatingPoint,
  // but we need to have `isFinite` for it to work correctly with
  // floating-point magnitudes in generic contexts, which is the
  // most common case. The fix for this is to lift the isFinite
  // requirement to Numeric in the standard library, but that's
  // source-breaking, so requires an ABI rumspringa.
  where Magnitude: FloatingPoint {
    assert(
      absoluteTolerance >= 0 && absoluteTolerance.isFinite,
      "absoluteTolerance should be non-negative and finite, " +
      "but is \(absoluteTolerance)."
    )
    assert(
      relativeTolerance >= 0 && relativeTolerance <= 1,
      "relativeTolerance should be non-negative and <= 1, " +
      "but is \(relativeTolerance)."
    )
    if self == other { return true }
    let delta = norm(self - other)
    let scale = max(norm(self), norm(other))
    let bound = max(absoluteTolerance, scale*relativeTolerance)
    return delta.isFinite && delta <= bound
  }
}
