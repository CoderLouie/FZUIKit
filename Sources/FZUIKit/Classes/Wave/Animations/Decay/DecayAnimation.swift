//
//  DecayAnimation.swift
//
//  Adopted from:
//  Motion. Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 03.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)

import Foundation
import FZSwiftUtils

/**
 An animation that animates a value with a decaying acceleration.
 
 Example usage:
 ```swift
 let decayAnimation = DecayAnimation(value: CGPoint(x: 0, y: 0), target: CGPoint(x: 50, y: 100))
 decayAnimation.valueChanged = { newValue in
    view.frame.origin = newValue
 }
 decayAnimation.start()
 ```
 */
public class DecayAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding {
    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// The delay (in seconds) after which the animations begin.
    public internal(set) var delay: TimeInterval = 0.0
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` should be integralized to the screen's pixel boundaries when the animation finishes. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value that indicates whether the animation automatically starts when the ``velocity`` value isn't `zero` or the `target` changes.
    public var autoStarts: Bool = false
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false
    
    /// A Boolean value indicating whether the animation is running backwards and forwards (must be combined with ``repeats`` `true`).
    public var autoreverse: Bool = false
        
    /// A Boolean value indicating whether the animation is running in the reverse direction.
    public var isReversed: Bool = false
    
    /// The rate at which the velocity decays over time.
    public var decelerationRate: Double {
        get { decayFunction.decelerationRate }
        set { 
            guard newValue != decelerationRate else { return }
            decayFunction.decelerationRate = newValue
            updateTarget()
        }
    }
    
    func updateTarget() {
        _target = DecayFunction.destination(value: _fromValue, velocity: _fromVelocity, decelerationRate: decayFunction.decelerationRate)
        duration = DecayFunction.duration(value: _fromValue, velocity: _fromVelocity, decelerationRate: decelerationRate)
    }
    
    /// The decay function used to calculate the animation.
    var decayFunction: DecayFunction
    
     public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData  }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromValue = _value
            updateTarget()
        }
    }
    
    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value {
        get { Value(_velocity) }
        set {
            guard newValue != velocity else { return }
            _velocity = newValue.animatableData
            updateTarget()
            runningTime = 0.0
        }
    }
    
    var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running, oldValue != _velocity else { return }
            _fromVelocity = _velocity
            if autoStarts, _velocity != .zero {
                start(afterDelay: 0.0)
            }
        }
    }
    
    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.
     
     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get { 
            _velocity == .zero ? value : Value(DecayFunction.destination(value: _value, velocity: _velocity, decelerationRate: decayFunction.decelerationRate)) }
        set {
            let newVelocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: newValue.animatableData)
            if newVelocity != _velocity {
                _velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: newValue.animatableData)
                _fromVelocity = _velocity
                duration = DecayFunction.duration(value: _fromValue, velocity: _fromVelocity, decelerationRate: decelerationRate)
                _target = newValue.animatableData
                runningTime = 0.0
            }
        }
    }
    
    internal var _target: Value.AnimatableData = .zero {
        didSet {
            if state == .running {
                completion?(.retargeted(from: Value(oldValue), to: Value(_target)))
            }
        }
    }
    
    var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    var _fromValue: Value.AnimatableData {
        didSet {
            guard oldValue != _fromValue else { return }
            updateTarget()
        }
    }
    
    var fromVelocity: Value {
        get { Value(_fromVelocity) }
        set { _fromVelocity = newValue.animatableData }
    }
    
    var _fromVelocity: Value.AnimatableData {
        didSet {
            guard oldValue != _fromVelocity else { return }
            updateTarget()
        }
    }
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    var duration: TimeInterval = 0.0

    var runningTime: TimeInterval = 0.0
    
    /// The completion percentage of the animation.
    var fractionComplete: CGFloat {
        runningTime / duration 
    }
    
    /**
     Creates a new animation with the specified initial value and velocity.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decelerationRate: The rate at which the velocity decays over time. The default value decelerates like scrollviews.
     */
    public init(value: Value, velocity: Value, decelerationRate: Double = ScrollViewDecelerationRate) {
        decayFunction = DecayFunction(decelerationRate: decelerationRate)
        _value = value.animatableData
        _fromValue = _value
        _velocity = velocity.animatableData
        _fromVelocity = _velocity
        updateTarget()
    }
    
    /**
     Creates a new animation with the specified initial value and target.

     - Parameters:
        - value: The start value of the animation.
        - target: The target value of the animation.
        - decelerationRate: The rate at which the velocity decays over time. The default value decelerates like scrollviews.
     */
    public init(value: Value, target: Value, decelerationRate: Double = ScrollViewDecelerationRate) {
        decayFunction = DecayFunction(decelerationRate: decelerationRate)
        _value = value.animatableData
        _fromValue = _value
        _velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: target.animatableData)
        _fromVelocity = _velocity
        updateTarget()
    }
    
    deinit {
        delayedStart?.cancel()
        AnimationController.shared.stopAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
        
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        repeats = settings.repeats
        autoStarts = settings.autoStarts
        integralizeValues = settings.integralizeValues
        if decelerationRate != settings.animationType.decelerationRate {
            decelerationRate = settings.animationType.decelerationRate ?? decelerationRate
        }
    }
            
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        state = .running
        
        decayFunction.update(value: &_value, velocity: &_velocity, deltaTime: deltaTime)

        let animationFinished = _velocity.magnitudeSquared < 0.05
                
        if animationFinished, repeats {
            _value = _fromValue
            _velocity = _fromVelocity
        }
        
        runningTime = runningTime + deltaTime
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)
        
        if animationFinished, !repeats {
            stop(at: .current)
        }
    }
    
    func reset() {
        runningTime = 0.0
        delayedStart?.cancel()
    }
}

extension DecayAnimation: CustomStringConvertible {
    public var description: String {
        """
        DecayAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(groupUUID?.description ?? "nil")
            priority: \(relativePriority)
            state: \(state)

            value: \(value)
            velocity: \(velocity)
            target: \(target)

            decelerationRate: \(decelerationRate)
            isReversed: \(isReversed)
            repeats: \(repeats)
            autoreverse: \(autoreverse)
            integralizeValues: \(integralizeValues)
            autoStarts: \(autoStarts)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))
        )
        """
    }
}

/// The mode how ``Wave`` should animate properties with a decaying animation.
public enum DecayAnimationMode {
    /// The value of animated properties will increase or decrease (depending on the values applied) with a decelerating rate.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time.
    case velocity
    /// The animated properties will animate to the applied values  with a decelerating rate.
    case value
}

#endif
