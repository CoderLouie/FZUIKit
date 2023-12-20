//
//  NSBackgroundConfiguration.swift
//  
//
//  Created by Florian Zand on 08.04.23.
//


#if os(macOS)
import AppKit
import FZSwiftUtils

/**
 A content configuration suitable for backgrounds.

 ```swift
 var configuration = NSBackgroundConfiguration()

 // Customize appearance.
 configuration.backgroundColor = .controlAccentColor
 configuration.cornerRadius = 6.0
 configuration.shadow = .black
 configuration.imageProperties.tintColor = .purple

 collectionItem.backgroundConfiguration = configuration
 ```
 */
public struct NSBackgroundConfiguration: NSContentConfiguration, Hashable {
    /// Creates a new instance of the content view using the configuration.
    public func makeContentView() -> NSView & NSContentView {
        NSBackgroundView(configuration: self)
    }
    
    /// Generates a configuration for the specified state by applying the configuration’s default values for that state to any properties that you don’t customize.
    public func updated(for state: NSConfigurationState) -> NSBackgroundConfiguration {
        
        return self
    }
    
    /// The background color
    public var color: NSColor? = nil {
        didSet {
            if self.color != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    /// The color transformer of the background color.
    public var colorTransformer: ColorTransformer? = nil {
        didSet {
            if self.colorTransformer != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    ///  Generates the resolved background color for the specified background color, using the color and color transformer.
    public func resolvedColor() -> NSColor? {
        if let color = self.color {
            return colorTransformer?(color) ?? color
        }
        return nil
    }
    
    /// The background image.
    public var image: NSImage? = nil
    /// The scaling of the background image.
    public var imageScaling: CALayerContentsGravity = .center
    
    /// The background view.
    public var view: NSView? = nil
    
    /// Properties for configuring the border.
    public var border: BorderConfiguration = .none() {
        didSet {
            if self.border != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    
    /// Properties for configuring the shadow.
    public var shadow: ShadowConfiguration = .none() {
        didSet {
            if self.shadow != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    
    /// Properties for configuring the inner shadow.
    public var innerShadow: ShadowConfiguration = .none() {
        didSet {
            if self.innerShadow != oldValue {
                self.updateResolvedColors()
            }
        }
    }
    
    /// Properties for configuring the background visual effect.
    public var visualEffect: VisualEffectConfiguration? = nil
    
    /// The corner radius.
    public var cornerRadius: CGFloat = 0.0
    
    /// The rounded corners.
    public var roundedCorners: CACornerMask = .all
    /// The insets (or outsets, if negative) for the background and border, relative to the edges of the containing view.
    public var insets: NSDirectionalEdgeInsets = .zero
    
    /// Creates an empty background configuration with a transparent background and no default styling.
    public static func clear() -> NSBackgroundConfiguration { NSBackgroundConfiguration() }
    
    /// Creates a background configuration.
    public init() {
        
    }
    
    /*
    /// Creates a cell background configuration.
    public init(color: NSColor? = nil,
                colorTransformer: ColorTransformer? = nil,
                image: NSImage? = nil,
                imageScaling: CALayerContentsGravity = .center,
                view: NSView? = nil,
                border: BorderConfiguration = .init(),
                shadow: ShadowConfiguration = .none(),
                innerShadow: ShadowConfiguration = .none(),
                visualEffect: VisualEffectConfiguration? = nil,
                cornerRadius: CGFloat = 0.0,
                insets: NSDirectionalEdgeInsets = .init()
    ) {
        self.view = view
        self.cornerRadius = cornerRadius
        self.insets = insets
        self.color = color
        self.colorTransformer = colorTransformer
        self.visualEffect = visualEffect
        self.border = border
        self.image = image
        self.imageScaling = imageScaling
        self.shadow = shadow
        self.innerShadow = innerShadow
        self.updateResolvedColors()
    }
     */
    
    internal var _resolvedColor: NSColor? = nil
    internal var _resolvedBorderColor: NSColor? = nil
    internal var _resolvedShadowColor: NSColor? = nil
    internal var _resolvedInnerShadowColor: NSColor? = nil

    internal mutating func updateResolvedColors() {
        self._resolvedColor = self.resolvedColor()
        self._resolvedBorderColor = self.border.resolvedColor()
        self._resolvedShadowColor = self.shadow.resolvedColor(withOpacity: false)
        self._resolvedInnerShadowColor = self.innerShadow.resolvedColor(withOpacity: false)
    }
}

#endif
