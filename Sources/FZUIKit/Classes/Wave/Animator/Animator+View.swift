//
//  ViewAnimator.swift
//
//  Modified by Florian Zand
//  Original: Copyright (c) 2022 Janum Trivedi.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension NSUIView: Animatable { }

extension Animator where Object: NSUIView {
    /// The bounds of the view.
    public var bounds: CGRect {
        get { value(for: \.bounds) }
        set { setValue(newValue, for: \.bounds) }
    }
    
    /// The frame of the view.
    public var frame: CGRect {
        get { value(for: \.frame) }
        set { setValue(newValue, for: \.frame) }
    }
    
    /// The size of the view. Changing this value keeps the view centered.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The origin of the view.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the view.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
        
    /// The background color of the view.
    public var backgroundColor: NSUIColor? {
        get { value(for: \.backgroundColor) }
        set { 
            #if os(macOS)
            setValue(newValue, for: \._backgroundColor)
            #elseif canImport(UIKit)
            setValue(newValue, for: \.backgroundColor)
            #endif
        }
    }
        
    /// The alpha value of the view.
    public var alpha: CGFloat {
        get { value(for: \.alpha) }
        set { setValue(newValue, for: \.alpha) }
    }
    
    /// The scale transform of the view.
    public var scale: CGPoint {
        get { CGPoint(self.transform3D.scale.x, self.transform3D.scale.y) }
        set { self.transform3D.scale = Scale(newValue.x, newValue.y, transform3D.scale.z) }
    }
    
    /// The rotation of the view.
    public var rotation: CGQuaternion {
        get { self.transform3D.rotation }
        set { self.transform3D.rotation = newValue }
    }
    
    /// The translation transform of the view.
    public var translation: CGPoint {
        get { CGPoint(self.transform3D.translation.x, self.transform3D.translation.y) }
        set { self.transform3D.translation = Translation(newValue.x, newValue.y, self.transform3D.translation.z) }
    }
    
    /// The corner radius of the view.
    public var cornerRadius: CGFloat {
        get { value(for: \.cornerRadius) }
        set { setValue(newValue, for: \.cornerRadius) }
    }
    
    /// The border color of the view.
    public var borderColor: NSUIColor? {
        get { value(for: \.borderColor) }
        set { setValue(newValue, for: \.borderColor) }
    }
    
    /// The border width of the view.
    public var borderWidth: CGFloat {
        get { value(for: \.borderWidth) }
        set { setValue(newValue, for: \.borderWidth) }
    }
    
    /// The shadow of the view.
    public var shadow: ContentConfiguration.Shadow {
        get { ContentConfiguration.Shadow(color: shadowColor != .clear ? shadowColor : nil, opacity: shadowOpacity, radius: shadowRadius, offset: CGPoint(shadowOffset.width, shadowOffset.height) ) }
        set {
            guard newValue != shadow else { return }
            self.shadowColor = newValue.color
            self.shadowOffset = CGSize(newValue.offset.x, newValue.offset.y)
            self.shadowRadius = newValue.radius
            self.shadowOpacity = newValue.opacity
        }
    }
    
    internal var shadowOpacity: CGFloat {
        get { value(for: \.shadowOpacity) }
        set { setValue(newValue, for: \.shadowOpacity) }
    }
    
    internal var shadowColor: NSUIColor? {
        get { value(for: \.shadowColor) }
        set { setValue(newValue, for: \.shadowColor) }
    }
    
    internal var shadowOffset: CGSize {
        get { value(for: \.shadowOffset) }
        set { setValue(newValue, for: \.shadowOffset) }
    }
    
    internal var shadowRadius: CGFloat {
        get { value(for: \.shadowRadius) }
        set { setValue(newValue, for: \.shadowRadius) }
    }
    
    internal var transform3D: CATransform3D {
        get { value(for: \.transform3D) }
        set { setValue(newValue, for: \.transform3D) }
    }
    
    internal var transform: CGAffineTransform {
        get { value(for: \.transform) }
        set { setValue(newValue, for: \.transform) }
    }
}

#endif
