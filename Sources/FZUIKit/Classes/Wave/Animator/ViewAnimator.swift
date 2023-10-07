//
//  ViewAnimator.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import CoreGraphics
import Foundation
import FZSwiftUtils

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/**
 The `ViewAnimator` class contains the supported NSView/UIView animatable properties, like `frame`, `center`, `cornerRadius`, and more.
 
 In an Wave animation block, change these values to create an animation, like so:
 
 Example usage:
 ```swift
 Wave.animate(withSpring: spring) {
 myView.animator.center = CGPoint(x: 100, y: 100)
 myView.animator.alpha = 0.5
 }
 ```
 */
public class ViewAnimator {
    private var view: NSUIView
    
    internal init(view: NSUIView) {
        self.view = view
#if os(macOS)
        self.view.wantsLayer = true
#endif
    }
    
    // MARK: - Public
    
    /// The bounds of the view.
    public var bounds: CGRect {
        get {
            CGRect(origin: view.animator.boundsOrigin, size: view.animator.boundsSize)
        }
        set {
            guard bounds != newValue else {
                return
            }
            
            // `bounds.size`
            boundsSize = newValue.size
            
            // `bounds.origin`
            boundsOrigin = newValue.origin
        }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get {
#if canImport(UIKit)
            return CGRect(aroundPoint: view.animator.center, size: view.animator.boundsSize)
#elseif os(macOS)
            return animation(for: \.frame)?.target ?? view.frame
#endif
        }
        set {
            guard frame != newValue else { return }
            
#if canImport(UIKit)
            boundsSize = newValue.size
            center = newValue.center
#elseif os(macOS)
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.frame = newValue
                }
                return
            }
            
            let initialValue = view.frame
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.frame)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.frame) ?? SpringAnimator<CGRect>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            if let gestureVelocity = settings.gestureVelocity {
                animation.velocity.origin = gestureVelocity
            }
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] frame in
                guard let strongSelf = self else { return }
#if canImport(UIKit)
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
#elseif os(macOS)
                //  strongSelf.view.bounds = CGRect(origin: .zero, size: frame.size)
                strongSelf.view.frame = frame
#endif
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.frame)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }
            
            start(animation: animation, type: \.frame, delay: settings.delay)
#endif
        }
    }
    
    /// The size of the view. Changing this value keeps the view centered.
    public var size: CGSize {
        get {
#if canImport(UIKit)
            return boundsSize
#elseif os(macOS)
            return frame.size
#endif
        }
        set {
            guard size != newValue else { return }
            
#if canImport(UIKit)
            boundsSize = newValue
#elseif os(macOS)
            frame.sizeCentered = newValue
#endif
        }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get {
            frame.origin
        }
        set {
            guard origin != newValue else { return }
            
            frame.origin = newValue
            /*
             // `frame.center`
             center = CGPoint(x: newValue.x + bounds.width / 2.0, y: newValue.y + bounds.height / 2.0)
             */
        }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get {
#if canImport(UIKit)
            return  animation(for: \.center)?.target ?? view.center
#elseif os(macOS)
            return frame.center
#endif
        }
        set {
            guard center != newValue else { return }
            
#if os(macOS)
            frame.center = newValue
#elseif canImport(UIKit)
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.center = newValue
                }
                return
            }
            
            let initialValue = view.center
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.center)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.center) ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            if let gestureVelocity = settings.gestureVelocity {
                animation.velocity = gestureVelocity
            }
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.center = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.center)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }
            
            start(animation: animation, type: \.center, delay: settings.delay)
#endif
        }
    }
    
    private var boundsOrigin: CGPoint {
        get {
            animation(for: \.boundsOrigin)?.target ?? view.bounds.origin
        }
        set {
            guard boundsOrigin != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.origin = newValue
                }
                return
            }
            
            let initialValue = view.bounds.origin
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.boundsOrigin)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.boundsOrigin) ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] boundsOrigin in
                self?.view.bounds.origin = boundsOrigin
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.boundsOrigin)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.boundsOrigin, delay: settings.delay)
        }
    }
    
    private var boundsSize: CGSize {
        get {
            animation(for: \.boundsSize)?.target ?? view.bounds.size
        }
        set {
            guard boundsSize != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.bounds.size = newValue
                }
                return
            }
            
            let initialValue = view.bounds.size
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.boundsSize)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.boundsSize) ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] size in
                guard let strongSelf = self else { return }
#if canImport(UIKit)
                strongSelf.view.bounds = CGRect(origin: strongSelf.view.bounds.origin, size: size)
#elseif os(macOS)
                //   strongSelf.view.bounds.size = size
                strongSelf.view.frame.size = size
#endif
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.boundsSize)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                case .retargeted:
                    break
                }
            }
            
            start(animation: animation, type: \.boundsSize, delay: settings.delay)
        }
    }
    
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get {
            let color = animation(for: \.backgroundColor)?.target ?? view.backgroundColor
            return color == .clear ? nil : color
        }
        set {
            guard backgroundColor != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.backgroundColor = newValue
                }
                return
            }
            
            let initialValue = view.backgroundColor ?? .clear
            let targetValue = newValue ?? .clear
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.backgroundColor)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.backgroundColor) ??
                             SpringAnimator<NSUIColor>(
                                spring: settings.spring,
                                value: initialValue,
                                target: targetValue
                             )
            )
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] color in
                self?.view.backgroundColor = color
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.waveAnimations.removeValue(forKey: \.backgroundColor)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.backgroundColor, delay: settings.delay)
        }
    }
        
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get {
            animation(for: \.alpha)?.target ?? view.alpha
        }
        set {
            guard alpha != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.alpha = newValue
                }
                return
            }
            
            let initialValue = view.alpha
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.alpha)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.alpha) ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.alpha = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.alpha)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.alpha, delay: settings.delay)
        }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get {
            return animation(for: \.scale)?.target ?? self.view.optionalLayer?.scale ?? CGPoint(x: 1, y: 1)
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.scale = newValue
                }
                return
            }
            
            #if os(macOS)
            self.view.anchorPoint = CGPoint(0.5, 0.5)
            #endif
            
            let initialValue = self.view.optionalLayer?.scale ?? CGPoint(x: 1, y: 1)
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.scale)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.scale) ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }
                strongSelf.view.optionalLayer?.scale = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.scale)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.scale, delay: settings.delay)
        }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get {
            return animation(for: \.translation)?.target ?? self.view.optionalLayer?.translation ?? CGPoint(x: 0, y: 0)
        }
        set {
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.translation = newValue
                }
                return
            }
            
            let initialValue = self.view.optionalLayer?.translation ?? CGPoint(x: 0, y: 0)
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.translation)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.translation) ?? SpringAnimator<CGPoint>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                guard let strongSelf = self else { return }
                
                strongSelf.view.optionalLayer?.translation = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.translation)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.translation, delay: settings.delay)
        }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get {
            animation(for: \.cornerRadius)?.target ?? view.cornerRadius
        }
        set {
            guard cornerRadius != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.cornerRadius = newValue
                }
                return
            }
            
            let initialValue = view.cornerRadius
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.cornerRadius)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.cornerRadius) ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.cornerRadius = value
            }
            
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.cornerRadius)
                    AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.cornerRadius, delay: settings.delay)
        }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get {
            let color = animation(for: \.borderColor)?.target ?? view.borderColor
            return color == .clear ? nil : color
        }
        
        set {
            guard borderColor != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.borderColor = newValue
                }
                return
            }
            
            let initialValue = view.borderColor ?? .clear
            let targetValue = newValue ?? .clear
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.borderColor)?.groupUUID, finished: false, retargeted: true)
            
            let animation = animation(for: \.borderColor) ?? SpringAnimator<NSUIColor>(spring: settings.spring, value: initialValue, target: targetValue)
            animation.configure(withSettings: settings)
            animation.target = targetValue
            animation.valueChanged = { [weak self] color in
                self?.view.borderColor = color
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.waveAnimations.removeValue(forKey: \.borderColor)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.borderColor, delay: settings.delay)
        }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get {
            animation(for: \.borderWidth)?.target ?? view.borderWidth
        }
        set {
            guard borderWidth != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.borderWidth = newValue
                }
                return
            }
            
            let initialValue = view.borderWidth
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.borderWidth)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.borderWidth) ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.borderWidth = value
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.borderWidth)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.borderWidth, delay: settings.delay)
        }
    }
    
    /// The shadow of the view.
    public var shadow: ContentConfiguration.Shadow {
        get {
            ContentConfiguration.Shadow(color: shadowColor != .clear ? shadowColor : nil, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height) )
        }
        set {
            guard newValue != shadow else { return }
            self.shadowColor = newValue.color ?? .clear
            self.shadowOffset = CGSize(newValue.offset.x, newValue.offset.y)
            self.shadowRadius = newValue.radius
            self.shadowOpacity = newValue.opacity
        }
    }
    
    internal var shadowOpacity: CGFloat {
        get {
            animation(for: \.shadowOpacity)?.target ?? view.shadowOpacity
        }
        set {
            guard shadowOpacity != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOpacity = newValue
                }
                return
            }
            
            let initialValue = view.shadowOpacity
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.shadowOpacity)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.shadowOpacity) ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                let clippedValue = value.clamped(max: 1.0)
                self?.view.shadowOpacity = clippedValue
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.shadowOpacity)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.shadowOpacity, delay: settings.delay)
        }
    }
    
    internal var shadowColor: NSUIColor? {
        get {
            let color = animation(for: \.shadowColor)?.target ?? view.shadowColor
            return color == .clear ? nil : color
        }
        
        set {

            guard shadowColor != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowColor = newValue
                }
                return
            }
            
            let initialValue = view.shadowColor ?? .clear
            let targetValue = newValue ?? .clear
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.shadowColor)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.shadowColor) ??
                             SpringAnimator<NSUIColor>(
                                spring: settings.spring,
                                value: initialValue,
                                target: targetValue
                             )
            )
            
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] color in
                self?.view.shadowColor = color
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished(at: _):
                    self?.view.waveAnimations.removeValue(forKey: \.shadowColor)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.shadowColor, delay: settings.delay)
        }
    }
    
    /// The shadow offset of the attached layer.
    internal var shadowOffset: CGSize {
        get {
            animation(for: \.shadowOffset)?.target ?? view.shadowOffset
        }
        set {
            guard shadowOffset != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowOffset = newValue
                }
                return
            }
            
            let initialValue = view.shadowOffset
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.shadowOffset)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.shadowOffset) ?? SpringAnimator<CGSize>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.shadowOffset = value
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.shadowOffset)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.shadowOffset, delay: settings.delay)
        }
    }
    
    internal var shadowRadius: CGFloat {
        get {
            animation(for: \.shadowRadius)?.target ?? view.shadowRadius
        }
        set {
            guard shadowRadius != newValue else {
                return
            }
            
            guard let settings = AnimationController.shared.currentAnimationParameters else {
                Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                    self.view.animator.shadowRadius = newValue
                }
                return
            }
            
            let initialValue = view.shadowRadius
            let targetValue = newValue
                        
            // Re-targeting an animation.
            AnimationController.shared.executeHandler(uuid: animation(for: \.shadowRadius)?.groupUUID, finished: false, retargeted: true)
            
            let animation = (animation(for: \.shadowRadius) ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
            animation.configure(withSettings: settings)
            
            animation.target = targetValue
            animation.valueChanged = { [weak self] value in
                self?.view.shadowRadius = max(0, value)
            }
            
            let groupUUID = animation.groupUUID
            animation.completion = { [weak self] event in
                switch event {
                case .finished:
                    self?.view.waveAnimations.removeValue(forKey: \.shadowRadius)
                    AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
                default:
                    break
                }
            }
            
            start(animation: animation, type: \.shadowRadius, delay: settings.delay)
        }
    }
}

extension ViewAnimator {
    // MARK: - Internal
    
    private func start(animation: AnimationProviding, type: PartialKeyPath<ViewAnimator>, delay: TimeInterval) {
        view.waveAnimations[type] = animation
        animation.start(afterDelay: delay)
    }
    
    private func animation<Val>(for keyPath: WritableKeyPath<ViewAnimator, Val?>) -> SpringAnimator<Val>? {
        view.waveAnimations[keyPath] as? SpringAnimator<Val>
    }
    
    private func animation<Val>(for keyPath: WritableKeyPath<ViewAnimator, Val>) -> SpringAnimator<Val>? {
        view.waveAnimations[keyPath] as? SpringAnimator<Val>
    }
}

public extension NSUIView {
    /**
     Use the `animator` property to set any animatable properties on a `UIView` in an ``Wave.animateWith(...)`` animation block.

     Example usage:
     ```swift
     Wave.animateWith(spring: spring) {
        myView.animator.center = CGPoint(x: 100, y: 100)
        myView.animator.alpha = 0.5
     }
     ```

     See ``ViewAnimator`` for a list of supported animatable properties on `UIView`.
     */
    var animator: ViewAnimator {
        get { getAssociatedValue(key: "Animator", object: self, initialValue: ViewAnimator(view: self)) }
        set { set(associatedValue: newValue, key: "Animator", object: self) }
    }

    internal var waveAnimations: [PartialKeyPath<ViewAnimator>: AnimationProviding] {
        get { getAssociatedValue(key: "waveAnimations", object: self, initialValue: [:]) }
        set { set(associatedValue: newValue, key: "waveAnimations", object: self) }
    }
}

#endif

fileprivate extension NSUIView {
    var optionalLayer: CALayer? {
        return self.layer
    }
}

/*
 public var transform: CGAffineTransform {
     get {
         runningTransformAnimator?.target ?? view.transform
     }
     set {
         guard transform != newValue else {
             return
         }
         
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator.transform = newValue
             }
             return
         }
         
         let initialValue = view.transform
         let targetValue = newValue
         
         let animationType = AnimatableProperty.transform
         
         // Re-targeting an animation.
         AnimationController.shared.executeHandler(uuid: runningTransformAnimator?.groupUUID, finished: false, retargeted: true)
         
         let animation = (runningTransformAnimator ?? SpringAnimator<CGAffineTransform>(spring: settings.spring, value: initialValue, target: targetValue))
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view.transform = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished:
                 self?.view.waveAnimations.removeValue(forKey: animationType)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         
         start(animation: animation, type: animationType, delay: settings.delay)
     }
 }
 
 public var transform3D: CATransform3D {
     get {
         runningTransform3DAnimator?.target ?? view.transform3D
     }
     set {
         guard transform3D != newValue else {
             return
         }
         
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator.transform3D = newValue
             }
             return
         }
         
         let initialValue = view.transform3D
         let targetValue = newValue
         
         let animationType = AnimatableProperty.transform3D
         
         // Re-targeting an animation.
         AnimationController.shared.executeHandler(uuid: runningTransform3DAnimator?.groupUUID, finished: false, retargeted: true)
         
         let animation = (runningTransform3DAnimator ?? SpringAnimator<CATransform3D>(spring: settings.spring, value: initialValue, target: targetValue))
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view.transform3D = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished:
                 self?.view.waveAnimations.removeValue(forKey: animationType)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         
         start(animation: animation, type: animationType, delay: settings.delay)
     }
 }
 
 public func addSubview(_ subview: NSView) {
     guard subview.superview != view else { return }
     subview.alpha = 0.0
     self.view.addSubview(subview)
     subview.animator.alpha = 1.0
 }
     
 public func removeFromSuperView() {
     guard view.superview != nil else { return }
     
     guard let settings = AnimationController.shared.currentAnimationParameters else {
         Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
             self.view.animator.alpha = 0.0
         }
         return
     }
     
     let initialValue = view.alpha
     let targetValue = 0.0
     
     let animationType = AnimatableProperty.alpha
     
     // Re-targeting an animation.
     AnimationController.shared.executeHandler(uuid: runningAlphaAnimator?.groupUUID, finished: false, retargeted: true)
     
     let animation = (runningAlphaAnimator ?? SpringAnimator<CGFloat>(spring: settings.spring, value: initialValue, target: targetValue))
     animation.configure(withSettings: settings)
     
     animation.target = targetValue
     animation.valueChanged = { [weak self] value in
         self?.view.alpha = value
     }
     
     animation.completion = { [weak self] event in
         switch event {
         case .finished:
             self?.view.waveAnimations.removeValue(forKey: animationType)
             AnimationController.shared.executeHandler(uuid: animation.groupUUID, finished: true, retargeted: false)
             self?.view.removeFromSuperview()
         default:
             break
         }
     }
     
     start(animation: animation, type: animationType, delay: settings.delay)
 }
 
 private var runningTransformAnimator: SpringAnimator<CGAffineTransform>? {
     view.waveAnimations[AnimatableProperty.transform] as? SpringAnimator<CGAffineTransform>
 }
 
 private var runningTransform3DAnimator: SpringAnimator<CATransform3D>? {
     view.waveAnimations[AnimatableProperty.transform3D] as? SpringAnimator<CATransform3D>
 }
 */

/*
 extension ViewAnimator {
     func setValue<Val>(_ newValue: Val?, _ keyPath: WritableKeyPath<ViewAnimator, Val?>, _ viewKeyPath: WritableKeyPath<NSView, Val.ValueType?>) where Val: SpringInterpolatable {
         guard self[keyPath: keyPath] != newValue else {
             return
         }
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator[keyPath: keyPath] = newValue
             }
             return
         }
         
         let initialValue = (self[keyPath: keyPath] as? Val.ValueType) ?? Val.ValueType.zero
         let targetValue = (newValue as? Val.ValueType) ?? Val.ValueType.zero

         AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
         
         let animation = (animation(for: keyPath) ??
                          SpringAnimator<Val>(
                             spring: settings.spring,
                             value: initialValue,
                             target: targetValue
                          )
         )
         
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view[keyPath: viewKeyPath] = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished(at: _):
                 self?.view.waveAnimationsNew.removeValue(forKey: keyPath)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         view.waveAnimationsNew[keyPath] = animation
         animation.start(afterDelay: settings.delay)
     }

     func setValue<Val>(_ newValue: Val, _ keyPath: WritableKeyPath<ViewAnimator, Val>, _ viewKeyPath: WritableKeyPath<NSView, Val.ValueType>) where Val: SpringInterpolatable {
         guard self[keyPath: keyPath] != newValue else {
             return
         }
         guard let settings = AnimationController.shared.currentAnimationParameters else {
             Wave.animate(withSpring: .nonAnimated, mode: .nonAnimated) {
                 self.view.animator[keyPath: keyPath] = newValue
             }
             return
         }
         
         let initialValue = (self[keyPath: keyPath] as! Val.ValueType)
         let targetValue = (newValue as! Val.ValueType)

         AnimationController.shared.executeHandler(uuid: animation(for: keyPath)?.groupUUID, finished: false, retargeted: true)
         
         let animation = (animation(for: keyPath) ??
                          SpringAnimator<Val>(
                             spring: settings.spring,
                             value: initialValue,
                             target: targetValue
                          )
         )
         
         animation.configure(withSettings: settings)
         
         animation.target = targetValue
         animation.valueChanged = { [weak self] value in
             self?.view[keyPath: viewKeyPath] = value
         }
         
         let groupUUID = animation.groupUUID
         animation.completion = { [weak self] event in
             switch event {
             case .finished(at: _):
                 self?.view.waveAnimationsNew.removeValue(forKey: keyPath)
                 AnimationController.shared.executeHandler(uuid: groupUUID, finished: true, retargeted: false)
             default:
                 break
             }
         }
         view.waveAnimationsNew[keyPath] = animation
         animation.start(afterDelay: settings.delay)
     }
 }
 */
