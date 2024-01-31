//
//  NSMenuItem+.swift
//
//
//  Created by Florian Zand on 09.04.23.
//

#if os(macOS)

    import AppKit
    import Foundation
    import SwiftUI

    public extension NSMenuItem {
        /**
         Initializes and returns a menu item with the specified title.
         - Parameter title: The title of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(_ title: String) {
            self.init(title: title)
        }

        /**
         Initializes and returns a menu item with the specified title.
         - Parameter title: The title of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(title: String) {
            self.init(title: title, action: nil, keyEquivalent: "")
            isEnabled = true
        }

        /**
         Initializes and returns a menu item with the specified image.
         - Parameter image: The image of the menu item.
         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(image: NSImage) {
            self.init(title: "")
            self.image = image
        }

        /**
         Initializes and returns a menu item with the view.

         - Parameters:
            - view: The view of the menu item.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(view: NSView, showsHighlight: Bool = true) {
            self.init(title: "")
            if showsHighlight {
                let highlightableView = NSMenuItemHighlightableView(frame: view.frame)
                highlightableView.addSubview(withConstraint: view)
                self.view = highlightableView
            } else {
                self.view = view
            }
        }

        /**
         Initializes and returns a menu item with the `SwiftUI` view.

         - Parameters:
            - view: The view of the menu item.
            - showsHighlight: A Boolean value that indicates whether menu item should highlight on interaction.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init<V: View>(showsHighlight: Bool = true, view: V) {
            self.init(title: "")
            self.view = NSMenu.MenuItemHostingView(showsHighlight: showsHighlight, contentView: view)
        }

        /**
         Initializes and returns a menu item with the specified title and submenu containing the specified menu items.

         - Parameters:
            - title: The title for the menu item.
            - items: The items of the submenu.

         - Returns: An instance of `NSMenuItem`.
         */
        convenience init(title: String,
                         @MenuBuilder items: () -> [NSMenuItem])
        {
            self.init(title: title)
            submenu = NSMenu(title: "", items: items())
        }
        
        /// A Boolean value that indicates whether the menu item is enabled.
        @discardableResult
        func isEnabled(_ isEnabled: Bool) -> Self {
            self.isEnabled = isEnabled
            return self
        }
        
        /// A Boolean value that indicates whether the menu item is hidden.
        @discardableResult
        func isHidden(_ isHidden: Bool) -> Self {
            self.isHidden = isHidden
            return self
        }
        
        /// The menu item's tag.
        @discardableResult
        func tag(_ tag: Int) -> Self {
            self.tag = tag
            return self
        }
        
        /// The menu item's title.
        @discardableResult
        func title(_ title: String) -> Self {
            self.title = title
            return self
        }
        
        /// A custom string for a menu item.
        @discardableResult
        func attributedTitle(_ attributedTitle: NSAttributedString?) -> Self {
            self.attributedTitle = attributedTitle
            return self
        }
        
        /// The state of the menu item.
        @discardableResult
        func state(_ state: NSControl.StateValue) -> Self {
            self.state = state
            return self
        }
        
        /// The menu item’s image.
        @discardableResult
        func image(_ image: NSImage?) -> Self {
            self.image = image
            return self
        }
        
        /// The image of the menu item that indicates an “on” state.
        @discardableResult
        func onStateImage(_ image: NSImage!) -> Self {
            onStateImage = image
            return self
        }
        
        /// The image of the menu item that indicates an “off” state.
        @discardableResult
        func offStateImage(_ image: NSImage?) -> Self {
            offStateImage = image
            return self
        }
        
        /// The image of the menu item that indicates a “mixed” state, that is, a state neither “on” nor “off.”
        @discardableResult
        func mixedStateImage(_ image: NSImage!) -> Self {
            mixedStateImage = image
            return self
        }
        
        /// The menu item’s badge.
        @available(macOS 14.0, *)
        @discardableResult
        func badge(_ badge: NSMenuItemBadge?) -> Self {
            self.badge = badge
            return self
        }
        
        /// The menu item’s unmodified key equivalent.
        @discardableResult
        func keyEquivalent(_ keyEquivalent: String) -> Self {
            self.keyEquivalent = keyEquivalent
            return self
        }
        
        /// The menu item’s keyboard equivalent modifiers.
        @discardableResult
        func keyEquivalentModifierMask(_ modifierMask: NSEvent.ModifierFlags) -> Self {
            keyEquivalentModifierMask = modifierMask
            return self
        }
        
        /// A Boolean value that marks the menu item as an alternate to the previous menu item.
        @discardableResult
        func isAlternate(_ isAlternate: Bool) -> Self {
            self.isAlternate = isAlternate
            return self
        }
        
        /// The menu item indentation level for the menu item.
        @discardableResult
        func indentationLevel(_ level: Int) -> Self {
            indentationLevel = level
            return self
        }
        
        /// The content view for the menu item.
        @discardableResult
        func view(_ view: NSView?) -> Self {
            self.view = view
            return self
        }
        
        /// A help tag for the menu item.
        @discardableResult
        func toolTip(_ toolTip: String?) -> Self {
            self.toolTip = toolTip
            return self
        }
        
        /// The object represented by the menu item.
        @discardableResult
        func representedObject(_ object: Any?) -> Self {
            representedObject = object
            return self
        }
        
        /// A Boolean value that determines whether the system automatically remaps the keyboard shortcut to support localized keyboards.
        @available(macOS 12.0, *)
        @discardableResult
        func allowsAutomaticKeyEquivalentLocalization(_ allows: Bool) -> Self {
            self.allowsAutomaticKeyEquivalentLocalization = allows
            return self
        }
         
        /// A Boolean value that determines whether the system automatically swaps input strings for some keyboard shortcuts when the interface direction changes.
        @available(macOS 12.0, *)
        @discardableResult
        func allowsAutomaticKeyEquivalentMirroring(_ allows: Bool) -> Self {
            self.allowsAutomaticKeyEquivalentMirroring = allows
            return self
        }
        
        /// A Boolean value that determines whether the item allows the key equivalent when hidden.
        @discardableResult
        func allowsKeyEquivalentWhenHidden(_ allows: Bool) -> Self {
            self.allowsKeyEquivalentWhenHidden = allows
            return self
        }
        
        /// The menu item’s menu.
        @discardableResult
        func menu(_ menu: NSMenu?) -> Self {
            self.menu = menu
            return self
        }
        
        /// The submenu of the menu item.
        @discardableResult
        func submenu(_ menu: NSMenu?) -> Self {
            submenu = menu
            return self
        }
    }
#endif
