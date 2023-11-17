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

/// An animator that animates a value using a decay function.
public class DecayAnimation<Value: AnimatableProperty>: ConfigurableAnimationProviding, AnimationVelocityProviding {

    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive {
        didSet {
            switch (oldValue, state) {
            case (.inactive, .running):
                runningTime = 0.0
            default:
                break
            }
        }
    }
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// A Boolean value indicating whether the animation repeats indefinitely.
    public var repeats: Bool = false {
        didSet {
            guard oldValue != repeats else { return }
         //   updateAutoreverse()
        }
    }
    
    /// The rate at which the velocity decays over time.
    public var decelerationRate: Double {
        get { decayFunction.decelerationRate }
        set { decayFunction.decelerationRate = newValue }
    }
    
    /// The decay function used to calculate the animation.
    var decayFunction: DecayFunction
    
    /// The current value of the animation. This value will change as the animation executes.
    public var value: Value {
        get { Value(_value) }
        set { _value = newValue.animatableData  }
    }
    
    var _value: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromValue = _value
        }
    }
    
    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value {
        get { Value(_velocity) }
        set { _velocity = newValue.animatableData  }
    }
    
    var _velocity: Value.AnimatableData {
        didSet {
            guard state != .running else { return }
            _fromVelocity = _velocity
        }
    }
    
    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.
     
     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get { return DecayFunction.destination(value: value, velocity: velocity, decelerationRate: decayFunction.decelerationRate) }
        set {
            self._velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: newValue.animatableData)
            self._fromVelocity = self._velocity
            self.runningTime = 0.0
        }
    }
    
    var fromValue: Value {
        get { Value(_fromValue) }
        set { _fromValue = newValue.animatableData }
    }
    
    var _fromValue: Value.AnimatableData {
        didSet {
            guard oldValue != _fromValue else { return }
            updateTotalDuration()
        }
    }

    
    var fromVelocity: Value {
        get { Value(_fromVelocity) }
        set { _fromVelocity = newValue.animatableData }
    }
    
    var _fromVelocity: Value.AnimatableData {
        didSet {
            guard oldValue != _fromVelocity else { return }
            updateTotalDuration()
        }
    }
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /// The completion block gets called to remove the animation from the animators `animations` dictionary.
    var animatorCompletion: (()->())? = nil
    
    var totalDuration: TimeInterval = 0.0
    
    var runningTime: TimeInterval = 0.0
    
    /// The completion percentage of the animation.
    var fractionComplete: CGFloat {
        runningTime / totalDuration
    }
    
    func updateTotalDuration() {
      // totalDuration = DecayFunction.duration(value: _fromValue, velocity: _fromVelocity, decelerationRate: decelerationRate)
    }
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decelerationRate: The rate at which the velocity decays over time. Defaults to ``DecayFunction/ScrollViewDecelerationRate``.
     */
    public init(value: Value, velocity: Value = .zero, decelerationRate: Double = DecayFunction.ScrollViewDecelerationRate) {
        self.decayFunction = DecayFunction(decelerationRate: decelerationRate)
        self._value = value.animatableData
        self._fromValue = _value
        self._velocity = velocity.animatableData
        self._fromVelocity = _velocity
        self.updateTotalDuration()
    }
    
    init(settings: AnimationController.AnimationParameters, value: Value, velocity: Value = .zero, target: Value? = nil) {
        self.decayFunction = DecayFunction(decelerationRate: DecayFunction.ScrollViewDecelerationRate)
        self._value = value.animatableData
        self._fromValue = _value
        self._velocity = velocity.animatableData
        if let target = target {
            self._velocity = DecayFunction.velocity(fromValue: value.animatableData, toValue: target.animatableData)
        }
        self._fromVelocity = _velocity
        self.configure(withSettings: settings)
        self.updateTotalDuration()
    }
    
    deinit {
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    var delayedStart: DispatchWorkItem? = nil
        
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        if let gestureVelocity = settings.animationType.gestureVelocity {
            (self as? DecayAnimation<CGRect>)?.velocity.origin = gestureVelocity
            (self as? DecayAnimation<CGRect>)?.fromVelocity.origin = gestureVelocity
            (self as? DecayAnimation<CGRect>)?.updateTotalDuration()
            
            (self as? DecayAnimation<CGPoint>)?.velocity = gestureVelocity
            (self as? DecayAnimation<CGPoint>)?.fromVelocity = gestureVelocity
            (self as? DecayAnimation<CGPoint>)?.updateTotalDuration()
        }
        self.repeats = settings.repeats
        if settings.integralizeValues == true {
            self.integralizeValues = settings.integralizeValues
        }
        if self.decelerationRate != settings.animationType.decelerationRate {
            self.decelerationRate = settings.animationType.decelerationRate
            self.updateTotalDuration()
        }
    }
    
    /// Resets the animation.
    public func reset() {
        state = .inactive
        velocity = .zero
        runningTime = 0.0
    }
            
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        let deltaTime = deltaTime / 2.0

        guard velocity != .zero else {
            state = .inactive
            return
        }
                
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
}

extension DecayAnimation: CustomStringConvertible {
    public var description: String {
        """
        DecayAnimation<\(Value.self)>(
            uuid: \(id)
            groupUUID: \(String(describing: groupUUID))
            priority: \(relativePriority)
            state: \(state)

            value: \(String(describing: value))
            velocity: \(String(describing: velocity))
            target: \(String(describing: target))

            integralizeValues: \(integralizeValues)
            decelerationRate: \(decelerationRate)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

        )
        """
    }
}

/// The mode how a decaying animation should animate properties.
public enum DecayAnimationMode {
    /// The value of animated properties will increase or decrease (depending on the `velocity` supplied) with a decelerating rate.  This essentially provides the same "decaying" that `UIScrollView` does when you drag and let go. The animation is seeded with velocity, and that velocity decays over time. Any values you assign to properties will be ignored.
    case velocity(CGPoint)
    /// The animated properties will animate with a decelerating rate to your provided values.
    case value
    
    internal var velocity: CGPoint? {
        switch self {
        case .velocity(let velocity): return velocity
        case .value: return nil
        }
    }
}

#endif
