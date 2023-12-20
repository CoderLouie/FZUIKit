//
//  AnimationController.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
import Combine
import Foundation
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import FZSwiftUtils

/// Manages all ``Anima`` animations.
internal class AnimationController {
    public static let shared = AnimationController()

    private var displayLink: AnyCancellable?

    private var animations: [UUID: AnimationProviding] = [:]
    private var animationSettingsStack = SettingsStack()
    
    typealias CompletionBlock = (_ finished: Bool, _ retargeted: Bool) -> Void
    var groupAnimationCompletionBlocks: [UUID: CompletionBlock] = [:]

    var currentAnimationParameters: AnimationParameters? {
        animationSettingsStack.currentSettings
    }

    func runAnimationBlock(
        settings: AnimationParameters,
        animations: () -> Void,
        completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)? = nil
    ) {
        precondition(Thread.isMainThread, "All Anima animations are to run and be interfaced with on the main thread only. There is no support for threading of any kind.")

        // Register the handler
        groupAnimationCompletionBlocks[settings.groupID] = completion

        animationSettingsStack.push(settings: settings)
        animations()
        animationSettingsStack.pop()
    }
    
    public func runAnimation(_ animation: AnimationProviding) {
        if displayLinkIsRunning == false {
            startDisplayLink()
        }

        animations[animation.id] = animation

        animation.updateAnimation(deltaTime: .zero)
    }
    
    public func stopAnimation(_ animation: AnimationProviding) {
        animations[animation.id] = nil
    }
    
    func stopAllAnimations(immediately: Bool = true) {
        animations.values.forEach({$0.stop(at: .current, immediately: immediately)})
    }

    private func updateAnimations(_ frame: DisplayLink.Frame) {
        guard displayLinkIsRunning else {
            fatalError("Can't update animations without a display link")
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        #if os(macOS)
        let deltaTime = frame.duration / 2.0
        #else
        let deltaTime = frame.duration
        #endif
        
        let sortedAnimations = animations.values.sorted(by: \.relativePriority, .descending)

        for animation in sortedAnimations {
            if animation.state == .ended {
                self.stopAnimation(animation)
            } else {
                animation.updateAnimation(deltaTime: deltaTime)
            }
        }

        CATransaction.commit()

        if animations.isEmpty {
            stopDisplayLink()
        }
    }
    
    @available(macOS 14.0, iOS 15.0, tvOS 15.0, *)
    internal var preferredFrameRateRange: CAFrameRateRange? {
        get { _preferredFrameRateRange as? CAFrameRateRange }
        set { _preferredFrameRateRange = newValue }
    }
        
    private var _preferredFrameRateRange: Any? = nil {
        didSet {
            if #available(macOS 14.0, iOS 15.0, tvOS 15.0, *), preferredFrameRateRange != nil, displayLinkIsRunning {
                stopDisplayLink()
                startDisplayLink()
            }
        }
    }

    private func startDisplayLink() {
        guard displayLinkIsRunning == false else { return }
        if #available(macOS 14.0, iOS 15.0, tvOS 15.0, *),  let preferredFrameRateRange = preferredFrameRateRange  {
            displayLink = DisplayLink(preferredFrameRateRange: preferredFrameRateRange).sink { [weak self] frame in
                guard let self = self else { return }
                self.updateAnimations(frame)
        }
        } else {
            displayLink = DisplayLink.shared.sink { [weak self] frame in
                guard let self = self else { return }
                self.updateAnimations(frame)
            }
        }
    }

    private func stopDisplayLink() {
        displayLink?.cancel()
        displayLink = nil
    }
    
    private var displayLinkIsRunning: Bool {
        displayLink != nil
    }
    
    internal func executeHandler(uuid: UUID?, finished: Bool, retargeted: Bool) {
        guard let uuid = uuid, let block = groupAnimationCompletionBlocks[uuid] else {
            return
        }
        
        block(finished, retargeted)

        if retargeted == false, finished {
            groupAnimationCompletionBlocks[uuid] = nil
        }
    }
}

extension AnimationController {
    struct AnimationParameters {
        let groupID: UUID
        let delay: CGFloat
        let configuration: AnimationConfiguration
        let options: Anima.AnimationOptions
        let completion: ((_ finished: Bool, _ retargeted: Bool) -> Void)?
        
        init(groupID: UUID, delay: CGFloat = 0.0, configuration: AnimationConfiguration, options: Anima.AnimationOptions = [], completion: ( (_: Bool, _: Bool) -> Void)? = nil) {
            self.groupID = groupID
            self.delay = delay
            self.configuration = configuration
            self.options = options
            self.completion = completion
        }

        var repeats: Bool {
            options.contains(.repeats)
        }
        
        var integralizeValues: Bool {
            options.contains(.integralizeValues)
        }
        
        var autoreverse: Bool {
            options.contains(.autoreverse)
        }
        
        var isAnimation: Bool {
            !configuration.isNonAnimated
        }
        
        var resetSpringVelocity: Bool {
            options.contains(.resetSpringVelocity)
        }
                
        #if os(iOS) || os(tvOS)
        var preventUserInteraction: Bool {
            options.contains(.preventUserInteraction)
        }
        #endif
        
        var animationType: AnimationType? {
            configuration.type
        }
        
        enum AnimationType: Int, Hashable {
            case spring
            case easing
            case decay
        }
        
        var needsVelocityValue: Bool {
            switch configuration {
            case .velocityUpdate: return true
            case .decay(let mode, _):
                return mode == .velocity
            default: return false
            }
        }
        
        enum AnimationConfiguration {
            case spring(spring: Spring, gestureVelocity: CGPoint?)
            case easing(timingFunction: TimingFunction, duration: TimeInterval)
            case decay(mode: Anima.DecayAnimationMode, decelerationRate: Double)
            case nonAnimated
            case velocityUpdate
            
            var type: AnimationType? {
                switch self {
                case .spring: return .spring
                case .easing: return .easing
                case .decay: return .decay
                default: return nil
                }
            }
            
            var isDecayVelocity: Bool {
                switch self {
                case .decay(let mode, _): return mode == .velocity
                default: return false
                }
            }
            
            var isVelocityUpdate: Bool {
                switch self {
                case .velocityUpdate: return true
                default: return false
                }
            }
            
            var isAnyVelocity: Bool {
                switch self {
                case .velocityUpdate, .decay(_, _): return true
                default: return false
                }
            }
            
            var isNonAnimated: Bool {
                switch self {
                case .nonAnimated: return true
                default: return false
                }
            }
            
            var decelerationRate: Double? {
                switch self {
                case .decay(_, let decelerationRate): return decelerationRate
                default: return nil
                }
            }
            
            var spring: Spring? {
                switch self {
                case.spring(let spring,_):  return spring
                default: return nil
                }
            }
            
            var timingFunction: TimingFunction? {
                switch self {
                case.easing(let timingFunction,_): return timingFunction
                default: return nil
                }
            }
            
            var duration: TimeInterval? {
                switch self {
                case.easing(_, let duration): return duration
                default: return nil
                }
            }
            
            var gestureVelocity: CGPoint? {
                switch self {
                case .spring(_, let gestureVelocity): return gestureVelocity
                default: return nil
                }
            }
        }
    }

    private class SettingsStack {
        private var stack: [AnimationParameters] = []

        var currentSettings: AnimationParameters? {
            stack.last
        }

        func push(settings: AnimationParameters) {
            stack.append(settings)
        }

        func pop() {
            stack.removeLast()
        }
    }
}

#endif

/*
 var mouseDownDisabledViews: [UUID: [NSView]] = [:] {
     didSet { setupMouseDownMonitor() }
 }
 
 /// Monitors mouseDown events on views that are currently animated and that are disabled for user interactions while animating (`isUserInteractionEnabled`).
 private var mouseDownMonitor: NSEvent.Monitor? = nil
 
 private func setupMouseDownMonitor() {
     if mouseDownDisabledViews.isEmpty == false {
         Swift.debugPrint("setupMouseDownMonitor", mouseDownDisabledViews.flatMap({$0.value}).uniqued().count)
         if mouseDownMonitor == nil {
             mouseDownMonitor = .local(for: [.leftMouseDown]) { [weak self] event in
                 guard let self = self else { return event }
                 if let contentView = NSApp.keyWindow?.contentView {
                     let mouseLocation = event.location(in: contentView)
                     if let hitView = contentView.hitTest(mouseLocation) {
                         let allMouseDownDisabledViews = mouseDownDisabledViews.flatMap({$0.value}).uniqued()
                         for view in allMouseDownDisabledViews {
                             if hitView == view || hitView.isDescendant(of: view) {
                                 Swift.debugPrint("mouseDownMonitor nil")
                                 return nil
                             }
                         }
                     }
                 }
                 Swift.debugPrint("mouseDownMonitor event")
                 return event
             }
         }
     } else {
         Swift.debugPrint("setupMouseDownMonitor disable")
         mouseDownMonitor = nil
     }
 }
 
 if let groupUUID = animation.groupUUID, mouseDownDisabledViews[groupUUID] != nil, animations.contains(where: {$0.value.groupUUID == animation.groupUUID}) == false {
     mouseDownDisabledViews[groupUUID] = nil
 }
 */
