//
//  DecayAnimation.swift
//
//  Adopted from:
//  Motion. Adam Bell on 8/20/20.
//
//  Created by Florian Zand on 03.11.23.
//

import Foundation
import FZSwiftUtils

/// An animator that animates a value using a decay function.
public class DecayAnimation<Value: AnimatableProperty>: AnimationProviding, ConfigurableAnimationProviding {

    /// A unique identifier for the animation.
    public let id = UUID()
    
    /// A unique identifier that associates an animation with an grouped animation block.
    public internal(set) var groupUUID: UUID?

    /// The relative priority of the animation.
    public var relativePriority: Int = 0
    
    /// The current state of the animation (`inactive`, `running`, or `ended`).
    public internal(set) var state: AnimationState = .inactive
    
    /// A Boolean value that indicates whether the value returned in ``valueChanged`` when the animation finishes should be integralized to the screen's pixel boundaries. This helps prevent drawing frames between pixels, causing aliasing issues.
    public var integralizeValues: Bool = false
    
    /// The rate at which the velocity decays over time.
    public var decayConstant: Double {
        get { decayFunction.decayConstant }
        set { decayFunction.decayConstant = newValue }
    }
    
    /// The decay function used to calculate the animation.
    internal var decayFunction: DecayFunction
    
    /// The _current_ value of the animation. This value will change as the animation executes.
    public var value: Value
    
    /// The velocity of the animation. This value will change as the animation executes.
    public var velocity: Value
    
    /**
     Computes the target value the decay animation will stop at. Getting this value will compute the estimated endpoint for the decay animation. Setting this value adjust the ``velocity`` to an value  that will result in the animation ending up at the specified target when it stops.
     
     Adjusting this is similar to providing a new `targetContentOffset` in `UIScrollView`'s `scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)`.
     */
    public var target: Value {
        get {
            return DecayFunction.destination(value: value, velocity: velocity, decayConstant: decayFunction.decayConstant)
        }
        set {
            self.velocity = DecayFunction.velocity(fromValue: value, toValue: newValue)
        }
    }
    
    internal var fromValue: Value
        
    /// The callback block to call when the animation's ``value`` changes as it executes. Use the `currentValue` to drive your application's animations.
    public var valueChanged: ((_ currentValue: Value) -> Void)?

    /// The completion block to call when the animation either finishes, or "re-targets" to a new target value.
    public var completion: ((_ event: AnimationEvent<Value>) -> Void)?
    
    /**
     Creates a new animation with the specified timing curve and duration, and optionally, an initial and target value.
     While `value` and `target` are optional in the initializer, they must be set to non-nil values before the animation can start.

     - Parameters:
        - value: The start value of the animation.
        - velocity: The velocity of the animation.
        - decayConstant: The rate at which the velocity decays over time. Defaults to ``DecayFunction/ScrollViewDecelerationRate``.
     */
    public init(value: Value, velocity: Value = .zero, decayConstant: Double = DecayFunction.ScrollViewDecelerationRate) {
        self.decayFunction = DecayFunction(decayConstant: decayConstant)
        self.value = value
        self.fromValue = value
        self.velocity = velocity
    }
    
    internal init(settings: AnimationController.AnimationParameters, value: Value, velocity: Value = .zero) {
        self.value = value
        self.fromValue = value
        self.velocity = velocity
        self.decayFunction = DecayFunction(decayConstant: DecayFunction.ScrollViewDecelerationRate)
    }
    
    deinit {
        AnimationController.shared.stopPropertyAnimation(self)
    }
    
    /// The item that starts the animation delayed.
    internal var delayedStart: DispatchWorkItem? = nil
        
    /// Configurates the animation with the specified settings.
    func configure(withSettings settings: AnimationController.AnimationParameters) {
        groupUUID = settings.groupUUID
        if let gestureVelocity = settings.type.gestureVelocity {
            (self as? DecayAnimation<CGRect>)?.velocity.origin = gestureVelocity
            (self as? DecayAnimation<CGPoint>)?.velocity = gestureVelocity
        }
    }
    
    /// Resets the animation.
    public func reset() {
        state = .inactive
        velocity = .zero
    }
        
    /**
     Updates the progress of the animation with the specified delta time.

     - parameter deltaTime: The delta time.
     */
    public func updateAnimation(deltaTime: TimeInterval) {
        guard velocity != .zero else {
            state = .inactive
            return
        }
                
        state = .running
        
        decayFunction.update(value: &value, velocity: &velocity, deltaTime: deltaTime)

        let animationFinished = velocity.animatableData.magnitudeSquared < 0.1
        
        let callbackValue = (integralizeValues && animationFinished) ? value.scaledIntegral : value
        valueChanged?(callbackValue)

        if animationFinished {
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
            decayConstant: \(decayConstant)

            callback: \(String(describing: valueChanged))
            completion: \(String(describing: completion))

        )
        """
    }
}
