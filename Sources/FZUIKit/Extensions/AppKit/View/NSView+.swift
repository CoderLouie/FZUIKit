//
//  NSView+.swift
//  
//
//  Created by Florian Zand on 19.10.21.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSView {
    /**
     The frame rectangle, which describes the view’s location and size in its window’s coordinate system.

     This rectangle defines the size and position of the view in its window’s coordinate system. If the view isn't installed in a window, it will return zero.
     */
    public var frameInWindow: CGRect {
        convert(bounds, to: nil)
    }

    /**
     The frame rectangle, which describes the view’s location and size in its screen’s coordinate system.

     This rectangle defines the size and position of the view in its screen’s coordinate system.
     */
    public var frameOnScreen: CGRect? {
        return window?.convertToScreen(frameInWindow)
    }
    
    /**
     Embeds the view in a scroll view and returns that scroll view.
     
     If the view is already emedded in a scroll view, it will return that.

     The scroll view can be accessed via the view's `enclosingScrollView` property.
     */
    @discardableResult
    public func addEnclosingScrollView() -> NSScrollView {
        guard self.enclosingScrollView == nil else { return self.enclosingScrollView! }
        let scrollView = NSScrollView()
        scrollView.documentView = self
        return scrollView
    }

    /**
     A Boolean value that determines whether subviews are confined to the bounds of the view.

     Setting this value to true causes subviews to be clipped to the bounds of the view. If set to false, subviews whose frames extend beyond the visible bounds of the view aren’t clipped.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var maskToBounds: Bool {
        get { layer?.masksToBounds ?? false }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.masksToBounds = newValue
        }
    }

    /**
     The view whose alpha channel is used to mask a view’s content.

     The view’s alpha channel determines how much of the view’s content and background shows through. Fully or partially opaque pixels allow the underlying content to show through but fully transparent pixels block that content.
     
     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var mask: NSView? {
        get { return getAssociatedValue(key: "_viewMaskView", object: self) }
        set {
            wantsLayer = true
            layer?.mask = nil
            swizzleAnimationForKey()
            set(associatedValue: newValue, key: "_viewMaskView", object: self)
            if let maskView = newValue {
                wantsLayer = true
                maskView.wantsLayer = true
                layer?.mask = maskView.layer
            }
        }
    }

    /**
     A Boolean value that determines whether the view is opaque.

     This property provides a hint to the drawing system as to how it should treat the view. If set to true, the drawing system treats the view as fully opaque, which allows the drawing system to optimize some drawing operations and improve performance. If set to false, the drawing system composites the view normally with other content. The default value of this property is true.

     An opaque view is expected to fill its bounds with entirely opaque content—that is, the content should have an alpha value of 1.0. If the view is opaque and either does not fill its bounds or contains wholly or partially transparent content, the results are unpredictable. You should always set the value of this property to false if the view is fully or partially transparent.

     Using this property turns the view into a layer-backed view.
     */
    public var isOpaque: Bool {
        get { layer?.isOpaque ?? false }
        set { wantsLayer = true
            layer?.isOpaque = newValue
        }
    }
        
    /**
     The left edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var left: CGFloat {
        get { frame.left }
        set {
            swizzleAnimationForKey()
            frame.left = newValue }
    }
    
    /**
     The right edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var right: CGFloat {
        get { frame.right }
        set {
            swizzleAnimationForKey()
            frame.right = newValue }
    }
    
    /**
     The top edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var top: CGFloat {
        get { frame.top }
        set {
            swizzleAnimationForKey()
            frame.top = newValue }
    }
    
    /**
     The bottom edge of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var bottom: CGFloat {
        get { frame.bottom }
        set {
            swizzleAnimationForKey()
            frame.bottom = newValue }
    }
    
    /**
     The top-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var topLeft: CGPoint {
        get { frame.topLeft }
        set {
            swizzleAnimationForKey()
            frame.topLeft = newValue }
    }
    
    /**
     The top-center point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var topCenter: CGPoint {
        get { frame.topCenter }
        set {
            swizzleAnimationForKey()
            frame.topCenter = newValue }
    }
    
    /**
     The top-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var topRight: CGPoint {
        get { frame.topRight }
        set {
            swizzleAnimationForKey()
            frame.topRight = newValue }
    }
    
    /**
     The center-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var centerLeft: CGPoint {
        get { frame.centerLeft }
        set {
            swizzleAnimationForKey()
            frame.centerLeft = newValue }
    }
    
    /**
     The center point of the view's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var center: CGPoint {
        get { frame.center }
        set {
            swizzleAnimationForKey()
            frame.center = newValue }
    }
    
    /**
     The center-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var centerRight: CGPoint {
        get { frame.centerRight }
        set {
            swizzleAnimationForKey()
            frame.centerRight = newValue }
    }
    
    /**
     The bottom-left point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var bottomLeft: CGPoint {
        get { frame.bottomLeft }
        set {
            swizzleAnimationForKey()
            frame.bottomLeft = newValue }
    }
    
    /**
     The bottom-center point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var bottomCenter: CGPoint {
        get { frame.bottomCenter }
        set {
            swizzleAnimationForKey()
            frame.bottomCenter = newValue }
    }
    
    /**
     The bottom-right point of the view's frame rectangle.
     
     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var bottomRight: CGPoint {
        get { frame.bottomRight }
        set {
            swizzleAnimationForKey()
            frame.bottomRight = newValue }
    }
    
    /**
     The horizontal center of the view's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var centerX: CGFloat {
        get { frame.centerX }
        set {
            swizzleAnimationForKey()
            frame.centerX = newValue }
    }
    
    /**
     The vertical center of the view's frame rectangle.

     Setting this property updates the origin of the rectangle in the frame property appropriately.
     Use this property, instead of the frame property, when you want to change the position of a view. The center point is always valid, even when scaling or rotation factors are applied to the view's transform.
     
     The value can be animated via `animator()`.
     */
    @objc open dynamic var centerY: CGFloat {
        get { frame.centerY }
        set {
            swizzleAnimationForKey()
            frame.centerY = newValue }
    }

    /**
     Specifies the transform applied to the view, relative to the center of its bounds.

     Use this property to scale or rotate the view's frame rectangle within its superview's coordinate system. (To change the position of the view, modify the center property instead.) The default value of this property is CGAffineTransformIdentity.
     Transformations occur relative to the view's anchor point. By default, the anchor point is equal to the center point of the frame rectangle. To change the anchor point, modify the anchorPoint property of the view's underlying CALayer object.
     Changes to this property can be animated.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform: CGAffineTransform {
        get { wantsLayer = true
            return layer?.affineTransform() ?? .init()
        }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.setAffineTransform(newValue)
        }
    }
    
    /**
     The three-dimensional transform to apply to the view.

     The default value of this property is CATransform3DIdentity.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var transform3D: CATransform3D {
        get { wantsLayer = true
            return layer?.transform ?? CATransform3DIdentity
        }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.transform = newValue
        }
    }
    
    /**
     The scale transform of the view..

     The default value of this property is `CGPoint(x: 1.0, y: 1.0)`.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var scale: CGPoint {
        get { layer?.scale ?? CGPoint(x: 1, y: 1) }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.scale = newValue
        }
    }

    /**
     The anchor point of the view’s bounds rectangle.

     You specify the value for this property using the unit coordinate space, where (0, 0) is the bottom-left corner of the view’s bounds rectangle, and (1, 1) is the top-right corner. The default value of this property is (0.5, 0.5), which represents the center of the view’s bounds rectangle.

     All geometric manipulations to the view occur about the specified point. For example, applying a rotation transform to a view with the default anchor point causes the view to rotate around its center. Changing the anchor point to a different location causes the view to rotate around that new point.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var anchorPoint: CGPoint {
        get { layer?.anchorPoint ?? .zero }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            setAnchorPoint(newValue)
        }
    }
    
    /**
     The corner radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var cornerRadius: CGFloat {
        get { layer?.cornerRadius ?? 0.0 }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.cornerRadius = newValue
        }
    }

    /**
     The corner curve of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var cornerCurve: CALayerCornerCurve {
        get { layer?.cornerCurve ?? .circular }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.cornerCurve = newValue
        }
    }

    /**
     The rounded corners of the view.

     Using this property turns the view into a layer-backed view.
     */
    @objc open dynamic var roundedCorners: CACornerMask {
        get { layer?.maskedCorners ?? CACornerMask() }
        set {
            wantsLayer = true
            layer?.maskedCorners = newValue
        }
    }

    /**
     The border width of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var borderWidth: CGFloat {
        get { layer?.borderWidth ?? 0.0 }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.borderWidth = newValue
        }
    }

    /**
     The border color of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var borderColor: NSColor? {
        get { layer?.borderColor?.nsColor }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            var newValue = newValue
            if newValue == nil, String(describing: self).contains("NSViewAnimator") {
                newValue = .clear
            }
            layer?.borderColor = newValue?.cgColor
        }
    }
        
    /**
     The shadow color of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var shadowColor: NSColor? {
        get { layer?.shadowColor?.nsColor }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            var newValue = newValue
            if newValue == nil, String(describing: self).contains("NSViewAnimator") {
                newValue = .clear
            }
            layer?.borderColor = newValue?.cgColor
        }
    }
    
    /**
     The shadow offset of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var shadowOffset: CGSize {
        get { layer?.shadowOffset ?? .zero }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.shadowOffset = newValue
        }
    }
    
    /**
     The shadow radius of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var shadowRadius: CGFloat {
        get { layer?.shadowRadius ?? .zero }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.shadowRadius = newValue
        }
    }
    
    /**
     The shadow opacity of the view.

     Using this property turns the view into a layer-backed view. The value can be animated via `animator()`.
     */
    @objc open dynamic var shadowOpacity: CGFloat {
        get { CGFloat(layer?.shadowOpacity ?? .zero) }
        set {
            wantsLayer = true
            swizzleAnimationForKey()
            layer?.shadowOpacity = Float(newValue)
        }
    }

    /**
     Adds a tracking area to the view.

     - Parameters:
        - rect: A rectangle that defines a region of the view for tracking events related to mouse tracking and cursor updating. The specified rectangle should not exceed the view’s bounds rectangle.
        - options: One or more constants that specify the type of tracking area, the situations when the area is active, and special behaviors of the tracking area. See the description of NSTrackingArea.Options and related constants for details. You must specify one or more options for the initialized object for the type of tracking area and for when the tracking area is active; zero is not a valid value.
     */
    public func addTrackingArea(rect: NSRect? = nil, options: NSTrackingArea.Options = [
        .mouseMoved,
        .mouseEnteredAndExited,
        .activeInKeyWindow,
    ]) {
        addTrackingArea(NSTrackingArea(
            rect: rect ?? bounds,
            options: options,
            owner: self
        ))
    }

    /// Removes all tracking areas.
    public func removeAllTrackingAreas() {
        for trackingArea in trackingAreas {
            removeTrackingArea(trackingArea)
        }
    }
    
    /**
     Marks the receiver’s entire bounds rectangle as needing to be redrawn.
     
     A convinient way of `needsDisplay = true`.
     */
    public func setNeedsDisplay() {
        needsDisplay = true
    }

    /**
     Invalidates the current layout of the receiver and triggers a layout update during the next update cycle.

     A convinient way of `needsLayout = true`.
     */
    public func setNeedsLayout() {
        needsLayout = true
    }

    /**
     Controls whether the view’s constraints need updating.

     A convinient way of `needsUpdateConstraints = true`.
     */
    public func setNeedsUpdateConstraints() {
        needsUpdateConstraints = true
    }
    
    /// A convinient way of `wantsLayer = true`.
    @discardableResult
    public func setWantsLayer() -> Self {
        wantsLayer = true
        return self
    }

    /// The parent view controller managing the view.
    public var parentController: NSViewController? {
        if let responder = nextResponder as? NSViewController {
            return responder
        }
        return (nextResponder as? NSView)?.parentController
    }

    /// A Boolean value that indicates whether the view is visible.
    public var isVisible: Bool {
        window != nil && alphaValue != 0.0 && visibleRect != .zero && isHidden == false
    }
    
    /**
     Scrolls the view’s closest ancestor `NSClipView object animated so a point in the view lies at the origin of the clip view's bounds rectangle.
     
     - Parameters:
        - point: The point in the view to scroll to.
        - animationDuration: The animation duration of the scolling.
     */
    func scroll(_ point: CGPoint, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                if let enclosingScrollView = self.enclosingScrollView {
                    enclosingScrollView.contentView.animator().setBoundsOrigin(point)
                    enclosingScrollView.reflectScrolledClipView(enclosingScrollView.contentView)
                }
            }
        } else {
            scroll(point)
        }
    }

    /**
     Scrolls the view’s closest ancestor NSClipView object  the minimum distance needed animated so a specified region of the view becomes visible in the clip view.
     
     - Parameters:
        - rect: The rectangle to be made visible in the clip view.
        - animationDuration: The animation duration of the scolling.
     */
    func scrollToVisible(_ rect: CGRect, animationDuration: CGFloat) {
        if animationDuration > 0.0 {
            NSAnimationContext.runAnimationGroup {
                context in
                context.duration = animationDuration
                self.scrollToVisible(rect)
            }
            
        } else {
            scrollToVisible(rect)
        }
    }
    
    /// Sets the anchor point of the view’s bounds rectangle while retaining the position.
    internal func setAnchorPoint(_ anchorPoint: CGPoint) {
        guard let layer = layer else { return }
        var newPoint = CGPoint(bounds.size.width * anchorPoint.x, bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(bounds.size.width * layer.anchorPoint.x, bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(layer.affineTransform())
        oldPoint = oldPoint.applying(layer.affineTransform())

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }
    
    internal var alpha: CGFloat {
        get { guard let cgValue = layer?.opacity else { return 1.0 }
            return CGFloat(cgValue)
        }
        set {
            wantsLayer = true
            layer?.opacity = Float(newValue)
        }
    }
}

public extension NSView.AutoresizingMask {
    /// A empy autoresizing mask.
    static let none: NSView.AutoresizingMask = []
    /// An autoresizing mask with flexible size.
    static let flexibleSize: NSView.AutoresizingMask = [.height, .width]
    /// An autoresizing mask with flexible size and fixed margins.
    static let all: NSView.AutoresizingMask = [.height, .width, .minYMargin, .minXMargin, .maxXMargin, .maxYMargin]
}

internal extension CALayerContentsGravity {
    var viewLayerContentsPlacement: NSView.LayerContentsPlacement {
        switch self {
        case .topLeft: return .topLeft
        case .top: return .top
        case .topRight: return .topRight
        case .center: return .center
        case .bottomLeft: return .bottomLeft
        case .bottom: return .bottom
        case .bottomRight: return .bottomRight
        case .resize: return .scaleAxesIndependently
        case .resizeAspectFill: return .scaleProportionallyToFill
        case .resizeAspect: return .scaleProportionallyToFit
        case .left: return .left
        case .right: return .right
        default: return .scaleProportionallyToFill
        }
    }
}

internal extension NSView {
    
    func swizzleAnimationForKey() {
        guard didSwizzleAnimationForKey == false else { return }
        didSwizzleAnimationForKey = true
        guard let viewClass = object_getClass(self) else { return }
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_animatable")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(self, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            objc_registerClassPair(viewSubclass)
            object_setClass(self, viewSubclass)
            
            if let method = class_getInstanceMethod(viewClass, #selector(NSView.animation(forKey:))) {
                let animationForKey: @convention(block) (AnyObject, NSAnimatablePropertyKey) -> Any? = { object, key in
                    Swift.print("animationForKey", key)
                    Swift.print("original", self.original?(object, key) ?? nil)
                    if NSViewAnimationKeys.contains(key) {
                       /*
                        let springAnimation = CASpringAnimation()
                        springAnimation.damping = 14
                        springAnimation.initialVelocity = 5
                        springAnimation.fillMode = CAMediaTimingFillMode.forwards
                        return springAnimation
                        */
                        let animation = CABasicAnimation()
                        animation.timingFunction = .default
                        return animation
                    }
                    if NSViewTransitionKeys.contains(key) {
                        let transition: CATransition = .fade()
                        transition.timingFunction = .default
                        return transition
                    }
                    return nil
                }
                
               let original = class_replaceMethod(viewSubclass, #selector(NSView.animation(forKey:)),
                                                  imp_implementationWithBlock(animationForKey), method_getTypeEncoding(method))
                Swift.print("class_replaceMethod", original ?? nil)
                self.animationForKeyImp = original

                /*
                class_addMethod(viewSubclass, #selector(NSView.animation(forKey:)),
                                imp_implementationWithBlock(animationForKey), method_getTypeEncoding(method))
                 */
            }
        }
    }
    
    var animationForKeyImp: IMP? {
       get { getAssociatedValue(key: "animationForKeyImp", object: self, initialValue: nil) }
       set {
           set(associatedValue: newValue, key: "animationForKeyImp", object: self)
       }
   }
    
    var original: ((AnyObject, NSAnimatablePropertyKey) -> Any?)? {
        if let savedOrigIMP = animationForKeyImp {
            return unsafeBitCast(savedOrigIMP, to: ((AnyObject, NSAnimatablePropertyKey) -> Any?).self)
        }
        return nil
    }
    
     var didSwizzleAnimationForKey: Bool {
        get { getAssociatedValue(key: "NSView_didSwizzleAnimationForKey", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "NSView_didSwizzleAnimationForKey", object: self)
        }
    }
}
private let NSViewTransitionKeys = ["NSAnimationTriggerOrderIn", "NSAnimationTriggerOrderOut", "hidden"]
private let NSViewAnimationKeys = ["transform", "transform3D", "anchorPoint", "cornerRadius", "roundedCorners", "borderWidth", "borderColor", "masksToBounds", "mask", "_backgroundColor", "left", "right", "top", "bottom", "topLeft", "topCenter", "topRight", "centerLeft", "center", "centerRight", "bottomLeft", "bottomCenter", "bottomRight", "centerX", "centerY", "shadowColor", "shadowOffset", "shadowOpacity", "shadowRadius", "frame", "bounds", "alphaValue", "shadow", "scale"]

#endif

/*
 let basicAnimation = CASpringAnimation(keyPath: "position")
 basicAnimation.fromValue = NSValue(cgPoint: initialPos)
 basicAnimation.toValue = NSValue(cgPoint: finalPos)
 basicAnimation.duration = basicAnimation.settlingDuration
 basicAnimation.damping = 14
 basicAnimation.initialVelocity = 5
 basicAnimation.isRemovedOnCompletion = false
 basicAnimation.fillMode = CAMediaTimingFillMode.forwards
 */
