//
//  NSTextField+AdjustFont.swift
//  
//
//  Created by Florian Zand on 05.10.23.
//

#if os(macOS)

import AppKit
import FZSwiftUtils

extension NSTextField {
    /**
     A Boolean value that determines whether the text field reduces the text’s font size to fit the title string into the text field’s bounding rectangle.
     
     Normally, the text field draws the text with the font you specify in the `font` property. If this property is true, and the text in the `stringValue` property exceeds the text field’s bounding rectangle, the text field reduces the font size until the text fits or it has scaled the font down to the minimum font size. The default value for this property is false. If you change it to true, be sure that you also set an appropriate minimum font scale by modifying the ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` property. This autoshrinking behavior is only intended for use with a single-line text field.
     */
    public var adjustsFontSizeToFitWidth: Bool {
        get { getAssociatedValue(key: "adjustsFontSizeToFitWidth", object: self, initialValue: false) }
        set { set(associatedValue: newValue, key: "adjustsFontSizeToFitWidth", object: self)
            self.setupStringValueObserver()
        }
    }
    
    /**
     The minimum scale factor for the text field’s text.
     
     If the ``AppKit/NSTextField/adjustsFontSizeToFitWidth`` is true, use this property to specify the smallest multiplier for the current font size that yields an acceptable font size for the text field’s text. If you specify a value of 0 for this property, the text field doesn’t scale the text down. The default value of this property is 0.
     To reveal the text field for editing minimum scale factor in Interface Builder, choose Minimum Font Scale from the Autoshrink pop-up menu in the text field’s Attributes inspector.
     */
    public var minimumScaleFactor: CGFloat {
        get { getAssociatedValue(key: "minimumScaleFactor", object: self, initialValue: 0.0) }
        set { set(associatedValue: newValue.clamped(max: 1.0), key: "minimumScaleFactor", object: self)
            self.setupStringValueObserver()
        }
    }
    
    internal var _font: NSFont? {
        get { getAssociatedValue(key: "_font", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "_font", object: self) }
    }
    
    internal func setupStringValueObserver() {
        if adjustsFontSizeToFitWidth, minimumScaleFactor != 0.0 {
            swizzleTextField()
          //  Self.swizzleTextField()
            if observer == nil {
                observer = KeyValueObserver(self)
                observer?.add(\.stringValue, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.isBezeled, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.isBordered, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.bezelStyle, handler: { [weak self] old, new in
                    guard let self = self, self.isBezeled, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.preferredMaxLayoutWidth, handler: { [weak self] old, new in
                    guard let self = self, self.isBezeled, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.maximumNumberOfLines, handler: { [weak self] old, new in
                    guard let self = self, old != new else { return }
                    self.adjustFontSize()
                })
                observer?.add(\.frame, handler: { [weak self] old, new in
                    guard let self = self, old.size != new.size else { return }
                    self.adjustFontSize()
                })
            }
        } else {
            observer = nil
        }
    }
    
    internal func adjustFontSize() {
        if adjustsFontSizeToFitWidth, minimumScaleFactor != 0.0, minimumScaleFactor != 1.0 {
            guard let font = _font, let cell = cell else { return }
            cell.font = _font
            var scaleFactor = 1.0
            var needsUpdate = isTruncatingText
            let _bounds = CGRect(.zero, CGSize(bounds.width, CGFloat.greatestFiniteMagnitude))
            if needsUpdate == false, cell.cellSize(forBounds: _bounds).height > bounds.height {
                needsUpdate = true
            }
            while needsUpdate && scaleFactor != minimumScaleFactor {
                scaleFactor -= 0.01
                cell.font = font.withSize(font.pointSize * scaleFactor)
                needsUpdate = isTruncatingText
                if needsUpdate == false {
                    // if maximumNumberOfLines == 0 {
                    if cell.cellSize(forBounds: _bounds).height > bounds.height {
                        needsUpdate = true
                    }
                    //  }
                }
            }
        } else if cell?.font != _font {
            cell?.font = _font
        }
    }
    
    internal func swizzleTextField() {
        guard didSwizzleTextField == false else { return }
        didSwizzleTextField = true
        keyDownMonitor = NSEvent.localMonitor(for: .keyDown) {event in
            if self.hasKeyboardFocus, self.editingState != .didEnd {
                if event.keyCode == 36, self.actionAtEnterKeyDown == .endEditing {
                    self.window?.makeFirstResponder(nil)
                    return nil
                }
                if event.keyCode == 53 {
                    if self.actionAtEscapeKeyDown == .endEditingAndReset {
                        self.stringValue = self.editStartString
                        self.adjustFontSize()
                    }
                    if self.actionAtEscapeKeyDown != .none {
                        self.window?.makeFirstResponder(nil)
                        return nil
                    }
                }
            }
            return event
        }
        _font = self.font
        adjustFontSize()
        guard let viewClass = object_getClass(self) else { return }
        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_animatable")
        if let viewSubclass = NSClassFromString(viewSubclassName) {
            object_setClass(self, viewSubclass)
        } else {
            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
            if let getFontMethod = class_getInstanceMethod(viewClass, #selector(getter: NSTextField.font)),
                let setFontMethod = class_getInstanceMethod(viewClass, #selector(setter: NSTextField.font)),
                let textDidChangeMethod = class_getInstanceMethod(viewClass, #selector(textDidChange)),
               let textDidEndEditingMethod = class_getInstanceMethod(viewClass, #selector(textDidEndEditing)),
               let textDidBeginEditingMethod = class_getInstanceMethod(viewClass, #selector(textDidBeginEditing))
            {
                let setFont: @convention(block) (AnyObject, NSFont?) -> Void = { _, font in
                    self._font = font
                    self.adjustFontSize()
                }
                let getFont: @convention(block) (AnyObject) -> NSFont? = { _ in
                    return self._font
                }
                
                let beginEditing: @convention(block) (AnyObject) -> Void = { [weak self] _ in
                    guard let self = self else { return }
                //    self.editingState = .didBegin
                    self.editStartString = self.stringValue
                    self.editingString = self.stringValue
                }
                
                let endEditing: @convention(block) (AnyObject) -> Void = { [weak self] _ in
                    guard let self = self else { return }
                //    self.editingState = .didEnd
                    self.adjustFontSize()
                }
                
                let textEdit: @convention(block) (AnyObject) -> Void = { [weak self] _ in
                    guard let self = self else { return }
                    /*
                    if let maxCharCount = self.maximumNumberOfCharacters, self.stringValue.count > maxCharCount {
                        self.stringValue = self.editingString.count == self.maximumNumberOfCharacters ? self.editingString : String(self.stringValue.prefix(maxCharCount))
                    }
                    self.editingState = .isEditing
                    self.editingString = self.stringValue
                     */
                    self.adjustFontSize()
                }
                
                class_addMethod(viewSubclass, #selector(getter: NSTextField.font),
                                imp_implementationWithBlock(getFont), method_getTypeEncoding(getFontMethod))
                class_addMethod(viewSubclass, #selector(setter: NSTextField.font),
                                imp_implementationWithBlock(setFont), method_getTypeEncoding(setFontMethod))
                class_addMethod(viewSubclass, #selector(textDidChange),
                                imp_implementationWithBlock(textEdit), method_getTypeEncoding(textDidChangeMethod))
                class_addMethod(viewSubclass, #selector(textDidBeginEditing),
                                imp_implementationWithBlock(beginEditing), method_getTypeEncoding(textDidBeginEditingMethod))
                class_addMethod(viewSubclass, #selector(textDidEndEditing),
                                imp_implementationWithBlock(endEditing), method_getTypeEncoding(textDidEndEditingMethod))
            }
            objc_registerClassPair(viewSubclass)
            object_setClass(self, viewSubclass)
        }
    }
    
    internal var didSwizzleTextField: Bool {
        get { getAssociatedValue(key: "didSwizzleTextField", object: self, initialValue: false) }
        set {
            set(associatedValue: newValue, key: "didSwizzleTextField", object: self)
        }
    }
    
    internal var editStartString: String {
        get { getAssociatedValue(key: "editStartString", object: self, initialValue: "") }
        set { set(associatedValue: newValue, key: "editStartString", object: self) }
    }
    
    internal var editingString: String {
        get { getAssociatedValue(key: "editingString", object: self, initialValue: "") }
        set { set(associatedValue: newValue, key: "editingString", object: self) }
    }
    
    internal var observer: KeyValueObserver<NSTextField>? {
        get { getAssociatedValue(key: "observer", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "observer", object: self) }
    }
    
    internal var keyDownMonitor: NSEvent.Monitor? {
        get { getAssociatedValue(key: "keyDownMonitor", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "keyDownMonitor", object: self) }
    }
}

#endif
