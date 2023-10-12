//
//  SpringInterpolatable.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation
import simd
import QuartzCore
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public protocol SpringInterpolatable: Equatable {
    associatedtype ValueType: SpringInterpolatable
    associatedtype VelocityType: VelocityProviding
    
    var scaledIntegral: Self { get }
    
    static func updateValue(spring: Spring, value: ValueType, target: ValueType, velocity: VelocityType, dt: TimeInterval) -> (value: ValueType, velocity: VelocityType)
}

public protocol VelocityProviding {
    static var zero: Self { get }
}

public extension SpringInterpolatable where Self: SIMDRepresentable {
    static func updateValue(spring: Spring, value: Self, target: Self, velocity: Self, dt: TimeInterval) -> (value: Self, velocity: Self) where Self.SIMDType.Scalar == CGFloat.NativeType {
        
        let value = value.simdRepresentation()
        let target = target.simdRepresentation()
        let velocity = velocity.simdRepresentation()
        
        let displacement = value - target
        let springForce = (-spring.stiffness * displacement)
        let dampingForce = (spring.damping * velocity)
        let force = springForce - dampingForce
        let acceleration = force / spring.mass
        
        let newVelocity = (velocity + (acceleration * dt))
        let newValue = (value + (newVelocity * dt))
        
        return (value: Self(newValue), velocity: Self(newVelocity))
    }
    
    var scaledIntegral: Self {
        self
    }
}

extension CGFloat: SpringInterpolatable, VelocityProviding { }
extension CGSize: SpringInterpolatable, VelocityProviding { }
extension CGPoint: SpringInterpolatable, VelocityProviding { }
extension CGRect: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: CGRect, target: CGRect, velocity: CGRect, dt: TimeInterval) -> (value: CGRect, velocity: CGRect) {
        let origin = CGPoint.updateValue(spring: spring, value: value.origin, target: target.origin, velocity: velocity.origin, dt: dt)
        let size = CGSize.updateValue(spring: spring, value: value.size, target: target.size, velocity: velocity.size, dt: dt)
        
        let newValue = CGRect(origin.value, size.value)
        let newVelocity = CGRect(origin.velocity, size.velocity)
        
        return (newValue, newVelocity)
    }
}

extension NSUIColor: SpringInterpolatable, VelocityProviding {
    public static var zero: Self {
        NSUIColor(red: 0, green: 0, blue: 0, alpha: 0) as! Self
    }
}

extension CGQuaternion: SpringInterpolatable, VelocityProviding { }

extension CATransform3D: SpringInterpolatable, VelocityProviding { }
extension CGAffineTransform: SpringInterpolatable, VelocityProviding {
    public static var zero: CGAffineTransform {
        CGAffineTransform()
    }
}

extension Float: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: Float, target: Float, velocity: Float, dt: TimeInterval) -> (value: Float, velocity: Float) {
        let values = CGFloat.updateValue(spring: spring, value: CGFloat(value), target: CGFloat(target), velocity: CGFloat(velocity), dt: dt)
        return (Float(values.value), Float(values.velocity))
    }
}

extension CGColor: SpringInterpolatable, VelocityProviding { }

/*
extension ContentConfiguration.Shadow: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: ContentConfiguration.Shadow, target: ContentConfiguration.Shadow, velocity: ContentConfiguration.Shadow, dt: TimeInterval) -> (value: ContentConfiguration.Shadow, velocity: ContentConfiguration.Shadow) {
        let opacity = CGFloat.updateValue(spring: spring, value: value.opacity, target: target.opacity, velocity: velocity.opacity, dt: dt)
        let radius = CGFloat.updateValue(spring: spring, value: value.radius, target: target.radius, velocity: velocity.radius, dt: dt)
        let color = NSUIColor.updateValue(spring: spring, value: value.color ?? .zero, target: target.color ?? .zero, velocity: velocity.color ?? .zero, dt: dt)
        let offset = CGPoint.updateValue(spring: spring, value: value.offset, target: target.offset, velocity: velocity.offset, dt: dt)
        return (ContentConfiguration.Shadow(color: color.value, opacity: opacity.value, radius: radius.value, offset: offset.value), ContentConfiguration.Shadow(color: color.velocity, opacity: opacity.velocity, radius: radius.velocity, offset: offset.velocity))
    }
    
    public var scaledIntegral: ContentConfiguration.Shadow {
        ContentConfiguration.Shadow(color: color?.scaledIntegral, opacity: opacity.scaledIntegral, radius: radius.scaledIntegral, offset: offset.scaledIntegral)
    }
    
    public static var zero: ContentConfiguration.Shadow {
        .none()
    }
}

extension ContentConfiguration.InnerShadow: SpringInterpolatable, VelocityProviding {
    public static func updateValue(spring: Spring, value: ContentConfiguration.InnerShadow, target: ContentConfiguration.InnerShadow, velocity: ContentConfiguration.InnerShadow, dt: TimeInterval) -> (value: ContentConfiguration.InnerShadow, velocity: ContentConfiguration.InnerShadow) {
        let opacity = CGFloat.updateValue(spring: spring, value: value.opacity, target: target.opacity, velocity: velocity.opacity, dt: dt)
        let radius = CGFloat.updateValue(spring: spring, value: value.radius, target: target.radius, velocity: velocity.radius, dt: dt)
        let color = NSUIColor.updateValue(spring: spring, value: value.color ?? .zero, target: target.color ?? .zero, velocity: velocity.color ?? .zero, dt: dt)
        let offset = CGPoint.updateValue(spring: spring, value: value.offset, target: target.offset, velocity: velocity.offset, dt: dt)
        return (ContentConfiguration.InnerShadow(color: color.value, opacity: opacity.value, radius: radius.value, offset: offset.value), ContentConfiguration.InnerShadow(color: color.velocity, opacity: opacity.velocity, radius: radius.velocity, offset: offset.velocity))
    }
    
    public var scaledIntegral: ContentConfiguration.InnerShadow {
        ContentConfiguration.InnerShadow(color: color?.scaledIntegral, opacity: opacity.scaledIntegral, radius: radius.scaledIntegral, offset: offset.scaledIntegral)
    }
    
    public static var zero: ContentConfiguration.InnerShadow {
        .none()
    }
}
 */

#endif
