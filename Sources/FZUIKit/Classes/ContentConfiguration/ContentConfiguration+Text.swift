//
//  ConfigurationProperties+Text.swift
//
//
//  Created by Florian Zand on 02.06.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import SwiftUI
import FZSwiftUtils

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension ContentConfiguration {
    /**
     A configuration that specifies the text.
     
     On AppKit `NSTextField` and `NSTextView` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Text)`.
     
     On UIKit `UILabel` and `UITextField` can be configurated by passing the configuration to `configurate(using configuration: ContentConfiguration.Text)`.
     */
    struct Text {
        /// The font of the text.
        public var font: NSUIFont = .body
        internal var swiftUIFont: Font? = .body
        
        /// The line limit of the text, or 0 if no line limit applies.
        public var numberOfLines: Int = 0
        
        /// The alignment of the text.
        public var alignment: NSTextAlignment = .left
        
        /// The technique for wrapping and truncating the text.
        public var lineBreakMode: NSLineBreakMode = .byCharWrapping
        
        #if canImport(UIKit)
        /// A Boolean value that determines whether the label reduces the text’s font size to fit the title string into the label’s bounding rectangle.
        public var adjustsFontSizeToFitWidth: Bool = false

        /// The minimum scale factor for the label’s text.
        public var minimumScaleFactor: CGFloat = 0.0

        /// A Boolean value that determines whether the label tightens text before truncating.
        public var allowsDefaultTighteningForTruncation: Bool = false

        /// A Boolean that indicates whether the object automatically updates its font when the device’s content size category changes.
        public var adjustsFontForContentSizeCategory: Bool = false

        /// A Boolean value that determines whether the full text of the label displays when the pointer hovers over the truncated text.
        public var showsExpansionTextWhenTruncated: Bool = false
        #endif
        
        /**
         A Boolean value that determines whether the user can select the content of the text field.
         
         If true, the text field becomes selectable but not editable. Use `isEditable` to make the text field selectable and editable. If false, the text is neither editable nor selectable.
         */
        public var isSelectable: Bool = false
        /**
         A Boolean value that controls whether the user can edit the value in the text field.
         
         If true, the user can select and edit text. If false, the user can’t edit text, and the ability to select the text field’s content is dependent on the value of `isSelectable`.
         */
        public var isEditable: Bool = false
        /**
         The edit handler that gets called when editing of the text ended.
         
         It only gets called, if `isEditable` is true.
         */
        public var onEditEnd: ((String)->())? = nil
        
        /**
         Handler that determines whether the edited string is valid.
         
         It only gets called, if `isEditable` is true.
         */
        public var stringValidation: ((String)->(Bool))? = nil
        
        #if os(macOS)
        /// The color of the text.
        public var textColor: NSUIColor = .labelColor {
            didSet { updateResolvedTextColor() } }
        #elseif canImport(UIKit)
        /// The color of the text.
        public var textColor: NSUIColor = .label {
            didSet { updateResolvedTextColor() } }
        #endif
        
        
        /// The color transformer of the text color.
        public var textColorTansform: ColorTransformer? = nil {
            didSet { updateResolvedTextColor() } }
        
        /// Generates the resolved text color for the specified text color, using the color and color transformer.
        public func resolvedTextColor() -> NSUIColor {
            textColorTansform?(textColor) ?? textColor
        }
        
        #if os(macOS)
        internal var _resolvedTextColor: NSUIColor = .labelColor
        #elseif canImport(UIKit)
        internal var _resolvedTextColor: NSUIColor = .label
        #endif
        
        internal mutating func updateResolvedTextColor() {
            _resolvedTextColor = resolvedTextColor()
        }
        
        internal init() {
            
        }
        
        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters size: The size of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(size: CGFloat, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Text  {
            var properties = Text()
            properties.font = .system(size: size, weight: weight, design: design)
            properties.swiftUIFont = .system(size: size, design: design.swiftUI).weight(weight.swiftUI)
            return properties
        }
        
        /**
         Specifies a system font to use, along with the size, weight, and any design parameters you want applied to the text.
         
         - Parameters style: The style of the font.
         - Parameters weight: The weight of the font.
         - Parameters design: The design of the font.
         */
        public static func system(_ style: NSUIFont.TextStyle = .body, weight: NSUIFont.Weight = .regular, design: NSUIFontDescriptor.SystemDesign = .default) -> Text {
            var properties = Text()
            properties.font = .system(style, design: design).weight(weight)
            properties.swiftUIFont = .system(style.swiftUI, design: design.swiftUI).weight(weight.swiftUI)
            return properties
        }
        
        /// A default configuration for a primary text.
        public static var primary: Self {
            var text = Text()
            text.numberOfLines = 1
            return text
        }
        
        /// A default configuration for a secondary text.
        public static var secondary: Self {
            var text = Text()
            text.font = .callout
            #if os(macOS)
            text.textColor = .secondaryLabelColor
            #elseif canImport(UIKit)
            text.textColor = .secondaryLabel
            #endif
            text.swiftUIFont = .callout
            return text
        }
        
        /// A default configuration for a tertiary text.
        public static var tertiary: Self {
            var text = Text()
            text.font = .callout
            #if os(macOS)
            text.textColor = .secondaryLabelColor
            #elseif canImport(UIKit)
            text.textColor = .tertiaryLabel
            #endif
            text.swiftUIFont = .callout
            return text
        }
        
        /// Text configuration with a font for bodies.
        public static var body: Self {
            var text = Self.system(.body)
            text.swiftUIFont = .body
            return text
        }
        
        /// Text configuration with a font for callouts.
        public static var callout: Self {
            var text = Self.system(.callout)
            text.swiftUIFont = .callout
            return text
        }
        /// Text configuration with a font for captions.
        public static var caption1: Self {
            var text = Self.system(.caption1)
            text.swiftUIFont = .caption
            return text
        }
        /// Text configuration with a font for alternate captions.
        public static var caption2: Self {
            var text = Self.system(.caption2)
            text.swiftUIFont = .caption2
            return text
        }
        /// Text configuration with a font for footnotes.
        public static var footnote: Self {
            var text = Self.system(.footnote)
            text.swiftUIFont = .footnote
            return text
        }
        /// Text configuration with a font for headlines.
        public static var headline: Self {
            var text = Self.system(.headline)
            text.swiftUIFont = .headline
            return text
        }
        /// Text configuration with a font for subheadlines.
        public static var subheadline: Self {
            var text = Self.system(.subheadline)
            text.swiftUIFont = .subheadline
            return text
        }
        /// Text configuration with a font for large titles.
        public static var largeTitle: Self {
            var text = Self.system(.largeTitle)
            text.swiftUIFont = .largeTitle
            return text
        }
        /// Text configuration with a font for titles.
        public static var title1: Self {
            var text = Self.system(.title1)
            text.swiftUIFont = .title
            return text
        }
        /// Text configuration with a font for alternate titles.
        public static var title2: Self {
            var text = Self.system(.title2)
            text.swiftUIFont = .title2
            return text
        }
        /// Text configuration with a font for alternate titles.
        public static var title3: Self {
            var text = Self.system(.title3)
            text.swiftUIFont = .title3
            return text
        }
        
        public func alignment(_ alignment: NSTextAlignment) -> Self {
            var text = self
            text.alignment = alignment
            return text
        }
        
    }
}

@available(macOS 11.0, iOS 15.0, tvOS 15.0, watchOS 6.0, *)
extension ContentConfiguration.Text: Hashable {
    public static func == (lhs: ContentConfiguration.Text, rhs: ContentConfiguration.Text) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(font)
        hasher.combine(numberOfLines)
        hasher.combine(alignment)
        hasher.combine(isEditable)
        hasher.combine(isSelectable)
        hasher.combine(textColor)
        hasher.combine(textColorTansform)
    }
}

internal extension NSTextAlignment {
    var swiftUI: Alignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }
    
    var swiftUIMultiline: SwiftUI.TextAlignment {
        switch self {
        case .left: return .leading
        case .center: return .center
        case .right: return .trailing
        default: return .leading
        }
    }
}

#if os(macOS)
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension NSTextField {
    /**
     Configurates the text field.
     
     - Parameters:
     - configuration:The configuration for configurating the text field.
     */
    func configurate(using configuration: ContentConfiguration.Text) {
        self.maximumNumberOfLines = configuration.numberOfLines
        self.textColor = configuration._resolvedTextColor
        self.font = configuration.font
        self.alignment = configuration.alignment
        self.lineBreakMode = configuration.lineBreakMode
        self.isEditable = configuration.isEditable
        self.isSelectable = configuration.isSelectable
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension NSTextView {
    /**
     Configurates the text view.
     
     - Parameters:
     - configuration:The configuration for configurating the text view.
     */
    func configurate(using configuration: ContentConfiguration.Text) {
        self.textContainer?.maximumNumberOfLines = configuration.numberOfLines
        self.textContainer?.lineBreakMode = configuration.lineBreakMode
        self.textColor = configuration._resolvedTextColor
        self.font = configuration.font
        self.alignment = configuration.alignment
        self.isEditable = configuration.isEditable
        self.isSelectable = configuration.isSelectable
    }
}
#elseif canImport(UIKit)
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension UILabel {
    /**
     Configurates the label.
     
     - Parameters:
     - configuration:The configuration for configurating the label.
     */
    func configurate(using configuration: ContentConfiguration.Text) {
        self.numberOfLines = configuration.numberOfLines
        self.textColor = configuration.textColor
        self.font = configuration.font
        self.lineBreakMode = configuration.lineBreakMode
        self.textAlignment = configuration.alignment
        
        self.adjustsFontSizeToFitWidth = configuration.adjustsFontSizeToFitWidth
        self.minimumScaleFactor = configuration.minimumScaleFactor
        self.allowsDefaultTighteningForTruncation = configuration.allowsDefaultTighteningForTruncation
        self.adjustsFontForContentSizeCategory = configuration.adjustsFontForContentSizeCategory
        self.showsExpansionTextWhenTruncated = configuration.showsExpansionTextWhenTruncated
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 6.0, *)
public extension UITextField {
    /**
     Configurates the label.
     
     - Parameters:
     - configuration:The configuration for configurating the label.
     */
    func configurate(using configuration: ContentConfiguration.Text) {
        self.textColor = configuration.textColor
        self.font = configuration.font
        self.textAlignment = configuration.alignment
        
        self.adjustsFontSizeToFitWidth = configuration.adjustsFontSizeToFitWidth
        self.adjustsFontForContentSizeCategory = configuration.adjustsFontForContentSizeCategory

        // self.numberOfLines = configuration.numberOfLines
        // self.lineBreakMode = configuration.lineBreakMode
      //  self.minimumScaleFactor = configuration.minimumScaleFactor
      //  self.allowsDefaultTighteningForTruncation = configuration.allowsDefaultTighteningForTruncation
      //  self.showsExpansionTextWhenTruncated = configuration.showsExpansionTextWhenTruncated
    }
}
#endif
