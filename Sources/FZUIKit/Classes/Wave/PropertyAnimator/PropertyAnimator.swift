//
//  PropertyAnimator.swift
//
//
//  Created by Florian Zand on 07.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import QuartzCore
import FZSwiftUtils
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
/**
 Provides animatable properties of an object conforming to `AnimatablePropertyProvider`.
 
 For easier access of a animatable property, you can extend the object's PropertyAnimator.
 
 ```swift
 extension: MyObject: AnimatablePropertyProvider { }
 
 public extension PropertyAnimator<MyObject> {
    var myAnimatableProperty: CGFloat {
        get { self[\.myAnimatableProperty] }
        set { self[\.myAnimatableProperty] = newValue }
    }
 }
 
 let object = MyObject()
 Wave.animate(withSpring: .smooth) {
    object.animator.myAnimatableProperty = newValue
 }
 ```
 */
public class PropertyAnimator<Object: AnimatablePropertyProvider> {
    internal var object: Object
    
    internal init(_ object: Object) {
        self.object = object
    }
    /// A dictionary containing the current animated property keys and associated animations.
    public var animations: [String: AnimationProviding] = [:]
    
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value>) -> Value {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
        
    /**
     The current value of the property at the specified keypath. Assigning a new value inside a ``Wave`` animation block animates to the new value.
     
     - Parameters keyPath: The keypath to the animatable property.
     */
    public subscript<Value: AnimatableProperty>(keyPath: WritableKeyPath<Object, Value?>) -> Value? {
        get { value(for: keyPath) }
        set { setValue(newValue, for: keyPath) }
    }
    
    /**
     The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

     - Parameters velocity: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value>) -> Value {
        get { ((self.animation(for: velocity) as? (any AnimationVelocityProviding))?.velocity as? Value) ?? .zero }
        set { (self.animation(for: velocity) as? (any AnimationVelocityProviding))?.setVelocity(newValue) }
    }
        
    /**
     The current animation velocity of the property at the specified keypath, or `zero` if there isn't an animation for the property or the animation doesn't support velocity values.

     - Parameters velocity: The keypath to the animatable property for the velocity.
     */
    public subscript<Value: AnimatableProperty>(velocity velocity: WritableKeyPath<Object, Value?>) -> Value {
        get { ((self.animation(for: velocity) as? (any AnimationVelocityProviding))?.velocity as? Value) ?? .zero }
        set { (self.animation(for: velocity) as? (any AnimationVelocityProviding))?.setVelocity(newValue) }
    }
    
    /**
     The current animation for the property at the specified keypath.
     
     - Parameters keyPath: The keypath to an animatable property.
     */
    public func animation(for keyPath: PartialKeyPath<PropertyAnimator>) -> AnimationProviding? {
        var key = keyPath.stringValue
        if let animation = self.animations[key] {
            return animation
        } else if key.contains("layer."), let viewAnimator = self as? PropertyAnimator<NSUIView> {
            key = key.replacingOccurrences(of: "layer.", with: "")
            return viewAnimator.object.optionalLayer?.animator.animations[key]
        }
        return nil
    }
    
    /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: WritableKeyPath<PropertyAnimator, Value>) -> Value? {
        return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
    }
    
    /// The current animation velocity for the property at the specified keypath, or `nil` if there isn't an animation for the keypath or the animation doesn't support velocity values.
    public func animationVelocity<Value: AnimatableProperty>(for keyPath: KeyPath<PropertyAnimator, Value?>) -> Value? {
        return (self.animation(for: keyPath) as? (any AnimationVelocityProviding))?.velocity as? Value
    }
}

internal extension PropertyAnimator {
    func key(for keyPath: PartialKeyPath<Object>) -> String {
        keyPath.stringValue
    }
    
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value>, key: String? = nil) -> Value {
        if AnimationController.shared.currentAnimationParameters?.animationType.isAnyVelocity == true {
            return (self.velocityAnimation(for: keyPath, key: key)?.velocity as? Value) ?? .zero
        }
        return (self.animation(for: keyPath, key: key)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// The current value of the property at the keypath. If the property is currently animated, it returns the animation target value.
    func value<Value: AnimatableProperty>(for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil) -> Value?  {
        if AnimationController.shared.currentAnimationParameters?.animationType.isAnyVelocity == true {
            return (self.velocityAnimation(for: keyPath, key: key)?.velocity as? Value) ?? .zero
        }
        return (self.animation(for: keyPath, key: key)?.target as? Value) ?? object[keyPath: keyPath]
    }
    
    /// Animates the value of the property at the keypath to a new value.
    @discardableResult
    func setValue<Value: AnimatableProperty>(_ newValue: Value, for keyPath: WritableKeyPath<Object, Value>, key: String? = nil, completion: (()->())? = nil) -> AnimationProviding? {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.nonAnimate {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return nil
        }
        
        guard settings.animationType.isVelocityUpdate == false else {
            (self.animation(for: keyPath, key: key) as? (any AnimationVelocityProviding))?.setVelocity(newValue, delay: settings.delay)
            return nil
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.animationType.isNonAnimated) else {
            return nil
        }
        
        var initialValue = object[keyPath: keyPath]
        var targetValue = newValue
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath, key: key) ?? SpringAnimation<Value>(spring: .smooth, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath, key: key) ?? EasingAnimation<Value>(timingFunction: .linear, duration: 1.0, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath, key: key) ?? DecayAnimation<Value>(value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .nonAnimated:
            self.animation(for: keyPath, key: key)?.stop(at: .current, immediately: true)
            self.animations[key ?? keyPath.stringValue] = nil
            self.object[keyPath: keyPath] = newValue
            return nil
        case .velocityUpdate:
            return nil
        }
    }
    
    /// Animates the value of the property at the keypath to a new value.
    @discardableResult
    func setValue<Value: AnimatableProperty>(_ newValue: Value?, for keyPath: WritableKeyPath<Object, Value?>, key: String? = nil, completion: (()->())? = nil) -> AnimationProviding? {
        guard let settings = AnimationController.shared.currentAnimationParameters else {
            Wave.nonAnimate {
                self.setValue(newValue, for: keyPath, key: key)
            }
            return nil
        }
        
        guard settings.animationType.isVelocityUpdate == false else {
            (self.animation(for: keyPath, key: key) as? (any AnimationVelocityProviding))?.setVelocity(newValue ?? .zero, delay: settings.delay)
            return nil
        }
        
        guard value(for: keyPath, key: key) != newValue || (settings.animationType.isNonAnimated) else {
            return nil
        }
        
        var initialValue = object[keyPath: keyPath] ?? Value.zero
        var targetValue = newValue ?? Value.zero
        updateValue(&initialValue, target: &targetValue)
        
        AnimationController.shared.executeHandler(uuid: animation(for: keyPath, key: key)?.groupUUID, finished: false, retargeted: true)
        
        switch settings.animationType {
        case .spring(_,_):
            let animation = springAnimation(for: keyPath, key: key) ?? SpringAnimation<Value>(spring: .smooth, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .easing(_,_):
            let animation = easingAnimation(for: keyPath, key: key) ?? EasingAnimation<Value>(timingFunction: .linear, duration: 1.0, value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .decay(_,_):
            let animation = decayAnimation(for: keyPath, key: key) ?? DecayAnimation<Value>(value: initialValue, target: targetValue)
            configurateAnimation(animation, target: targetValue, keyPath: keyPath, key: key, settings: settings, completion: completion)
            return animation
        case .nonAnimated:
            self.animation(for: keyPath, key: key)?.stop(at: .current, immediately: true)
            self.animations[key ?? keyPath.stringValue] = nil
            self.object[keyPath: keyPath] = newValue
            return nil
        case .velocityUpdate:
            return nil
        }
    }
    
    /// Configurates an animation and starts it.
    func configurateAnimation<Value>(_ animation: some ConfigurableAnimationProviding<Value>, target: Value, keyPath: PartialKeyPath<Object>, key: String? = nil, settings: AnimationController.AnimationParameters, completion: (()->())? = nil) {
        var animation = animation
        animation.reset()
        if settings.animationType.isDecayVelocity, let animation = animation as? DecayAnimation<Value> {
            animation.velocity = target
            animation._fromVelocity = animation._velocity
        } else {
            animation.target = target
        }
        animation.fromValue = animation.value
        animation.configure(withSettings: settings)
        if let keyPath = keyPath as? WritableKeyPath<Object, Value> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
        } else if let keyPath = keyPath as? WritableKeyPath<Object, Value?> {
            animation.valueChanged = { [weak self] value in
                self?.object[keyPath: keyPath] = value
            }
        }
        #if os(iOS) || os(tvOS)
        if settings.preventUserInteraction {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.insert(animation.id)
        } else {
            (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
        }
        #endif
        
        let animationKey = key ?? keyPath.stringValue
        animation.completion = { [weak self] event in
            switch event {
            case .finished:
                completion?()
                self?.animations[animationKey] = nil
                #if os(iOS) || os(tvOS)
                (self as? PropertyAnimator<UIView>)?.preventingUserInteractionAnimations.remove(animation.id)
                #endif
                AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
            default:
                break
            }
        }
        if let oldAnimation = animations[animationKey], oldAnimation.id != animation.id {
            oldAnimation.stop(at: .current, immediately: true)
        }
        animations[animationKey] = animation
        animation.start(afterDelay: settings.delay)
    }
    
    /// Updates the value and target of an animatable property for better animations.
    func updateValue<V: AnimatableProperty>(_ value: inout V, target: inout V) {
        if V.self == CGColor.self {
            let color = (value as! CGColor).nsUIColor
            let targetColor = (target as! CGColor).nsUIColor
            if color?.isVisible == false {
                value = (targetColor?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
            if targetColor?.isVisible == false {
                target = (color?.withAlphaComponent(0.0).cgColor ?? .clear) as! V
            }
        } else if var collection = value as? (any AnimatableCollection), var targetCollection = target as? (any AnimatableCollection), collection.count != targetCollection.count {
            collection.makeInterpolatable(to: &targetCollection)
            value = collection as! V
            target = targetCollection as! V
        }
    }
}

internal extension PropertyAnimator {
    /// The current animation for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func animation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> (any ConfigurableAnimationProviding)? {
        return animations[key ?? keyPath.stringValue] as? (any ConfigurableAnimationProviding)
    }
    
    /// The current animation that supports velocity for the property at the keypath or key, or `nil` if there isn't an animation for the keypath.
    func velocityAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> (any AnimationVelocityProviding)? {
        return self.animation(for: keyPath, key: key) as? (any AnimationVelocityProviding)
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> SpringAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? SpringAnimation<Val>
    }
    
    /// The current spring animation for the property at the keypath or key, or `nil` if there isn't a spring animation for the keypath.
    func springAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> SpringAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? SpringAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> EasingAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? EasingAnimation<Val>
    }
    
    /// The current easing animation for the property at the keypath or key, or `nil` if there isn't an easing animation for the keypath.
    func easingAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> EasingAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? EasingAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val?>, key: String? = nil) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? DecayAnimation<Val>
    }
    
    /// The current decay animation for the property at the keypath or key, or `nil` if there isn't a decay animation for the keypath.
    func decayAnimation<Val>(for keyPath: WritableKeyPath<Object, Val>, key: String? = nil) -> DecayAnimation<Val>? {
        return self.animation(for: keyPath, key: key) as? DecayAnimation<Val>
    }
}

#if canImport(UIKit)
internal extension DynamicPropertyAnimator<UIView> {
    var preventsUserInteractions: Bool {
        get { getAssociatedValue(key: "preventsUserInteractions", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "preventsUserInteractions", object: self) }
    }
    
    /// Collects the animations that are configurated to prevent user interactions. If the set isn't empty the user interactions get disabled. When all animations finishes and the collection is empty, user interaction gets enabled again.
    var preventingUserInteractionAnimations: Set<UUID> {
        get { getAssociatedValue(key: "preventingAnimations", object: self, initialValue: []) }
        set { set(associatedValue: newValue, key: "preventingAnimations", object: self)
            if !preventingUserInteractionAnimations.isEmpty, object.isUserInteractionEnabled, !preventsUserInteractions {
                object.isUserInteractionEnabled = false
                preventsUserInteractions = true
            } else if preventingUserInteractionAnimations.isEmpty, preventsUserInteractions {
                object.isUserInteractionEnabled = true
                preventsUserInteractions = false
            }
        }
    }
}
#endif

#endif
