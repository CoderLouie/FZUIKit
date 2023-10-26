//
//  Animator+Layer.swift
//  
//
//  Created by Florian Zand on 12.10.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

extension CALayer: AnimatablePropertyProvider { }

public typealias LayerAnimator = PropertyAnimator<CALayer>

extension PropertyAnimator where Object: CALayer {
    /// The bounds of the layer.
    public var bounds: CGRect {
        get { self[\.bounds] }
        set { self[\.bounds] = newValue }
    }
    
    /// The frame of the layer.
    public var frame: CGRect {
        get { self[\.frame] }
        set { self[\.frame] = newValue }
    }
    /// The size of the layer. Changing this value keeps the layer centered.
    public var size: CGSize {
        get { frame.size }
        set {
            guard size != newValue else { return }
            frame.sizeCentered = newValue
        }
    }
    
    /// The origin of the layer.
    public var origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }
    
    /// The center of the layer.
    public var center: CGPoint {
        get { frame.center }
        set { frame.center = newValue }
    }
    
    
    /// The background color of the layer.
    public var backgroundColor: NSUIColor? {
        get { self[\.backgroundColor]?.nsUIColor }
        set { self[\.backgroundColor] = newValue?.cgColor }
    }
        
    /// The opacity value of the layer.
    public var opacity: CGFloat {
        get { CGFloat(self[\.opacity]) }
        set { self[\.opacity] = Float(newValue) }
    }
    
    /// The three-dimensional transform of the layer.
    public var transform: CATransform3D {
        get { self[\.transform] }
        set { self[\.transform] = newValue }
    }
    
    /// The scale of the layer.
    public var scale: CGPoint {
        get { CGPoint(self.transform.scale.x, self.transform.scale.y) }
        set { self.transform.scale = Scale(newValue.x, newValue.y, transform.scale.z) }
    }
    
    /// The rotation of the layer.
    public var rotation: CGQuaternion {
        get { self[\.rotation] }
        set { self[\.rotation] = newValue }
    }
    
    /// The translation transform of the layer.
    public var translation: CGPoint {
        get { CGPoint(self.transform.translation.x, self.transform.translation.y) }
        set { self.transform.translation = Translation(newValue.x, newValue.y, self.transform.translation.z) }
    }
    
    /// The corner radius of the layer.
    public var cornerRadius: CGFloat {
        get { self[\.cornerRadius] }
        set { self[\.cornerRadius] = newValue }
    }
    
    /// The border color of the layer.
    public var borderColor: NSUIColor? {
        get { self[\.borderColor]?.nsUIColor }
        set { self[\.borderColor] = newValue?.cgColor }
    }
    
    /// The border width of the layer.
    public var borderWidth: CGFloat {
        get { self[\.borderWidth] }
        set { self[\.borderWidth] = newValue }
    }
    
    /// The shadow of the layer.
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
        get { CGFloat(self[\.shadowOpacity]) }
        set { self[\.shadowOpacity] = Float(newValue) }
    }
    
    internal var shadowColor: NSUIColor? {
        get { self[\.shadowColor]?.nsUIColor }
        set { self[\.shadowColor] = newValue?.cgColor }
    }
    
    internal var shadowOffset: CGSize {
        get { self[\.shadowOffset] }
        set { self[\.shadowOffset] = newValue }
    }
    
    internal var shadowRadius: CGFloat {
        get { self[\.shadowRadius] }
        set { self[\.shadowRadius] = newValue }
    }
    
    /// The inner shadow of the layer.
    public var innerShadow: ContentConfiguration.InnerShadow {
        get { ContentConfiguration.InnerShadow(color: innerShadowColor, opacity: innerShadowOpacity, radius: innerShadowRadius, offset: innerShadowOffset ) }
        set {
            innerShadowColor = newValue.color
            innerShadowRadius = newValue.radius
            innerShadowOffset = newValue.offset
            innerShadowOpacity = newValue.opacity
        }
    }
    
    internal var innerShadowOpacity: CGFloat {
        get { self[\.innerShadowOpacity] }
        set { self[\.innerShadowOpacity] = newValue }
    }
    
    internal var innerShadowRadius: CGFloat {
        get { self[\.innerShadowRadius] }
        set { self[\.innerShadowRadius] = newValue }
    }
    
    internal var innerShadowOffset: CGPoint {
        get { self[\.innerShadowOffset] }
        set { self[\.innerShadowOffset] = newValue }
    }
    
    internal var innerShadowColor: NSUIColor? {
        get { self[\.innerShadowColor] }
        set { self[\.innerShadowColor] = newValue }
    }
}

extension PropertyAnimator where Object: CATextLayer {
    /// The font size of the layer.
    public var fontSize: CGFloat {
        get { self[\.fontSize] }
        set { self[\.fontSize] = newValue }
    }
    
    /// The text color of the layer.
    public var textColor: NSUIColor? {
        get { self[\.textColor] }
        set { self[\.textColor] = newValue }
    }
}

fileprivate extension CATextLayer {
    @objc var textColor: NSUIColor? {
        get { self.foregroundColor?.nsUIColor }
        set { self.foregroundColor = newValue?.cgColor }
    }
}

fileprivate extension CALayer {
    var innerShadow: ContentConfiguration.InnerShadow {
        get { self.innerShadowLayer?.configuration ?? .none() }
        set { self.configurate(using: newValue) }
    }
        
   @objc var innerShadowOpacity: CGFloat {
        get { innerShadow.opacity }
        set { innerShadow.opacity = newValue }
    }
    
    @objc var innerShadowRadius: CGFloat {
         get { innerShadow.radius }
         set { innerShadow.radius = newValue }
     }
    
    @objc var innerShadowColor: NSUIColor? {
         get { innerShadow.color }
         set { innerShadow.color = newValue }
     }
    
    @objc var innerShadowOffset: CGPoint {
         get { innerShadow.offset }
         set { innerShadow.offset = newValue }
     }
}


#endif
