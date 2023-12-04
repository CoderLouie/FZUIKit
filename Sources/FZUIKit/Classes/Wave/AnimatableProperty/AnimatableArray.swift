//
//  AnimatableArrray.swift
//
//
//  Created by Florian Zand on 15.10.21.
//

import Foundation
import SwiftUI
import Accelerate
import FZSwiftUtils

/// An array that can serve as the animatable data of an animatable type (see ``AnimatableProperty``).
public struct AnimatableArray<Element: VectorArithmetic & AdditiveArithmetic> {
    internal var elements: [Element] = []

    public init() {}

    public init(arrayLiteral elements: Element...) {
        self.elements = elements
    }
    
    public init<S>(_ elements: S) where S: Sequence, Element == S.Element {
        self.elements = .init(elements)
    }

    public init(repeating repeatedValue: Element, count: Int) {
        elements = .init(repeating: repeatedValue, count: count)
    }
    
    public subscript(index: Int) -> Element {
        get {  return elements[index] }
        set {  elements[index] = newValue }
    }
    
    public subscript(range: ClosedRange<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
    }
    
    public subscript(range: Range<Int>) -> ArraySlice<Element> {
        get { return elements[range] }
        set { elements[range] = newValue }
    }

    public var count: Int {
        return elements.count
    }

    public var underestimatedCount: Int {
        return elements.underestimatedCount
    }

    public mutating func set(contents: [Element]) {
        elements = contents
    }

    public mutating func removeAll() {
        elements.removeAll()
    }

    @discardableResult
    public mutating func remove(at i: Int) -> Element {
        elements.remove(at: i)
    }

    @discardableResult
    public mutating func removeFirst() -> Element {
        elements.removeFirst()
    }

    public mutating func removeFirst(_ k: Int) {
        elements.removeFirst(k)
    }

    public mutating func removeSubrange(_ bounds: Range<Int>) {
        elements.removeSubrange(bounds)
    }

    public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try elements.removeAll(where: shouldBeRemoved)
    }

    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        elements.removeAll(keepingCapacity: keepCapacity)
    }

    public mutating func removeLast(_ k: Int) {
        elements.removeLast(k)
    }

    public mutating func removeLast() {
        elements.removeLast()
    }

    public mutating func append(_ newElement: Element) {
        elements.append(newElement)
    }

    public mutating func append<S>(contentsOf newElements: S) where S: Sequence, Element == S.Element {
        elements.append(contentsOf: newElements)
    }

    public var indices: Range<Int> {
        return elements.indices
    }

    public var isEmpty: Bool {
        return elements.isEmpty
    }

    public func distance(from start: Int, to end: Int) -> Int {
        return elements.distance(from: start, to: end)
    }

    public mutating func swapAt(_ i: Int, _ j: Int) {
        elements.swapAt(i, j)
    }

    public mutating func reserveCapacity(_ n: Int) {
        elements.reserveCapacity(n)
    }

    public mutating func insert(_ newElement: Element, at i: Int) {
        elements.insert(newElement, at: i)
    }

    public mutating func insert<S>(contentsOf newElements: S, at i: Int) where S: Collection, Element == S.Element {
        elements.insert(contentsOf: newElements, at: i)
    }

    public func formIndex(after i: inout Int) {
        elements.formIndex(after: &i)
    }

    public func formIndex(before i: inout Int) {
        elements.formIndex(before: &i)
    }

    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        try elements.partition(by: belongsInSecondPartition)
    }

    public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
        try elements.withContiguousStorageIfAvailable(body)
    }

    public mutating func withContiguousMutableStorageIfAvailable<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R? {
        try elements.withContiguousMutableStorageIfAvailable(body)
    }

    private func isInBounds(index: Int) -> Bool {
        return indices ~= index
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public func index(before i: Int) -> Int {
        return elements.index(before: i)
    }

    public func index(_ i: Int, offsetBy distance: Int) -> Int {
        return elements.index(i, offsetBy: distance)
    }

    public func index(_ i: Int, offsetBy distance: Int, limitedBy limit: Int) -> Int? {
        return elements.index(i, offsetBy: distance, limitedBy: limit)
    }

    public mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C)
        where C: Collection, R: RangeExpression, Element == C.Element, Int == R.Bound
    {
        elements.replaceSubrange(subrange, with: newElements)
    }
}

extension AnimatableArray: MutableCollection, RangeReplaceableCollection, RandomAccessCollection, BidirectionalCollection { }

extension AnimatableArray: Sendable where Element: Sendable { }

extension AnimatableArray: Encodable where Element: Encodable {}

extension AnimatableArray: Decodable where Element: Decodable {}

extension AnimatableArray: CVarArg {
    public var _cVarArgEncoding: [Int] {
        return elements._cVarArgEncoding
    }
}

extension AnimatableArray: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public var customMirror: Mirror {
        return elements.customMirror
    }

    public var debugDescription: String {
        return elements.debugDescription
    }

    public var description: String {
        return elements.description
    }
}

extension AnimatableArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(elements)
    }
}

extension AnimatableArray: ContiguousBytes {
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try elements.withUnsafeBytes(body)
    }
}

extension AnimatableArray: ExpressibleByArrayLiteral {}


extension AnimatableArray: VectorArithmetic & AdditiveArithmetic {
    
    public static func + (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = Swift.min(lhs.count, rhs.count)
        if let _lhs = lhs as? AnimatableArray<Double>, let _rhs = rhs as? AnimatableArray<Double> {
            return AnimatableArray<Double>(vDSP.add(_lhs[0..<count], _rhs[0..<count])) as! Self
        }
        var lhs = lhs
        for index in 0..<count {
            lhs[index] += rhs[index]
        }
        return lhs
    }
    
    public static func += (lhs: inout AnimatableArray, rhs: AnimatableArray) {
        lhs = lhs + rhs
    }
    
    public static func - (lhs: AnimatableArray, rhs: AnimatableArray) -> AnimatableArray {
        let count = Swift.min(lhs.count, rhs.count)
        if let _lhs = lhs as? AnimatableArray<Double>, let _rhs = rhs as? AnimatableArray<Double> {
            return AnimatableArray<Double>(vDSP.subtract(_lhs[0..<count], _rhs[0..<count])) as! Self
        }
        var lhs = lhs
        for index in 0..<count {
            lhs[index] += rhs[index]
        }
        return lhs
    }
    
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    public mutating func scale(by rhs: Double) {
        if let _self = self as? AnimatableArray<Double> {
            self.elements = vDSP.multiply(rhs, _self.elements) as! [Element]
        } else {
            for index in startIndex..<endIndex {
                self[index].scale(by: rhs)
            }
        }
    }
    
    public var magnitudeSquared: Double {
        if let _self = self as? AnimatableArray<Double> {
            return vDSP.sum(vDSP.multiply(_self.elements, _self.elements))
        }
       return reduce(into: 0.0) { (result, new) in
            result += new.magnitudeSquared
        }
    }

    public static var zero: Self { .init() }
}

extension AnimatableArray: MultiplicativeArithmetic where Element: MultiplicativeArithmetic {
    public static func / (lhs: Self, rhs: Self) -> Self {
        let count = Swift.min(lhs.count, rhs.count)
        if let lhs = lhs as? AnimatableArray<Double>, let rhs = rhs as? AnimatableArray<Double> {
            return AnimatableArray<Double>(vDSP.divide(lhs[0..<count], rhs[0..<count])) as! Self
        }
        if let lhs = lhs as? AnimatableArray<Float>, let rhs = rhs as? AnimatableArray<Float> {
            return AnimatableArray<Float>(vDSP.divide(lhs[0..<count], rhs[0..<count])) as! Self
        }
        var lhs = lhs
        for i in 0..<count {
            lhs[index] = lhs[index] / rhs[index]
        }
        
        var array = Self()
        for i in 0..<count {
            array.append(lhs[i] / rhs[i])
        }
        return array
    }
    
    public static func /= (lhs: inout AnimatableArray, rhs: AnimatableArray) {
        lhs = lhs / rhs
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        let count = Swift.min(lhs.count, rhs.count)
        if let lhs = lhs as? AnimatableArray<Double>, let rhs = rhs as? AnimatableArray<Double> {
            return AnimatableArray<Double>(vDSP.multiply(lhs[0..<count], rhs[0..<count])) as! Self
        }
        if let lhs = lhs as? AnimatableArray<Float>, let rhs = rhs as? AnimatableArray<Float> {
            return AnimatableArray<Float>(vDSP.multiply(lhs[0..<count], rhs[0..<count])) as! Self
        }
        var array = Self()
        for i in 0..<count {
            array.append(lhs[i] * rhs[i])
        }
        return array
    }
    
    public static func *= (lhs: inout AnimatableArray, rhs: AnimatableArray) {
        lhs = lhs * rhs
    }
}

extension AnimatableArray: Comparable where Element: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        for (leftElement, rightElement) in zip(lhs.elements, rhs.elements) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

protocol SupportedScalar { }
extension Float: SupportedScalar {}
extension Double: SupportedScalar {}

protocol SupportedCollection {
    associatedtype Element: SupportedScalar
    var elements: [Element] { get set }
    func add(other: Self) -> Self
}

extension SupportedCollection where Element == Float {
    func add(other: Self) -> Self {
        return self
    }
}

/*
protocol InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double
}

extension InterpolatablePosition {
    func interolatePositionAny(fromValue: Any, toValue: Any) -> Double? {
        guard let fromValue = fromValue as? Self, let toValue = toValue as? Self else { return nil }
        return interolatePosition(fromValue: fromValue, toValue: toValue)
    }
}

extension CGFloat: InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double {
         (self - fromValue) / (toValue - fromValue)
    }
}

extension Double: InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double {
         (self - fromValue) / (toValue - fromValue)
    }
}

extension Float: InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double {
         Double((self - fromValue) / (toValue - fromValue))
    }
}

extension AnimatablePair: InterpolatablePosition where First: InterpolatablePosition, Second: InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double {
        let first = first.interolatePosition(fromValue: fromValue.first, toValue: toValue.first)
        let second = second.interolatePosition(fromValue: fromValue.second, toValue: toValue.second)
        return [first, second].average()
    }
}

extension AnimatableArray: InterpolatablePosition where Element: InterpolatablePosition {
    func interolatePosition(fromValue: Self, toValue: Self) -> Double {
        var positions: [Double] = []
        for (index, value) in self.elements.enumerated() {
            let position = value.interolatePosition(fromValue: fromValue[index], toValue: toValue[index])
            positions.append(position)
        }
        return positions.average()
    }
}
*/
