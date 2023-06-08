//
//  File.swift
//
//
//  Created by Florian Zand on 21.10.22.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

import FZSwiftUtils

public protocol BackgroundColorSettable {
    var backgroundColor: NSUIColor? { get set }
}

extension NSUIView: BackgroundColorSettable { }

#if os(macOS)
public extension BackgroundColorSettable where Self: NSView {
    internal var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "_viewEffectiveAppearanceKVO", object: self) }
    }

    internal func updateBackgroundColor() {
        wantsLayer = true
        layer?.backgroundColor = backgroundColor?.resolvedColor(for: effectiveAppearance).cgColor
    }

    var backgroundColor: NSColor? {
        get { getAssociatedValue(key: "_viewBackgroundColor", object: self) }
        set {
            set(associatedValue: newValue, key: "_viewBackgroundColor", object: self)
            updateBackgroundColor()
            if newValue != nil {
                if _effectiveAppearanceKVO == nil {
                    _effectiveAppearanceKVO = observeChange(\.effectiveAppearance) { [weak self] _,_, _ in
                        self?.updateBackgroundColor()
                    }
                }
            } else {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }
    }
}

/*
public extension CALayer {
    var adjustingBackgroundColor: CGColor? {
        get { getAssociatedValue(key: "_adjustingBackgroundColor", object: self) }
        set {
            set(associatedValue: newValue, key: "_adjustingBackgroundColor", object: self)
            if let view = delegate as? NSView {
                self.updateBackgroundColor(view.effectiveAppearance)
                if _effectiveAppearanceKVO == nil {
                    if let view = delegate as? NSView {
                        _effectiveAppearanceKVO = view.observeChange(\.effectiveAppearance) { [weak self] _,_, _ in
                            self?.updateBackgroundColor()
                        }
                    }
                }
            }
            } else {
                _effectiveAppearanceKVO?.invalidate()
                _effectiveAppearanceKVO = nil
            }
        }
    
internal func updateBackgroundColor(_ effectiveAppearance: NSAppearance) {
    if let adjustingBackgroundColor = self.adjustingBackgroundColor {
        self.backgroundColor = NSColor(cgColor: adjustingBackgroundColor)?.resolvedColor(for: effectiveAppearance).cgColor
    }
}

    
    internal var _effectiveAppearanceKVO: NSKeyValueObservation? {
        get { getAssociatedValue(key: "calayer_viewEffectiveAppearanceKVO", object: self) }
        set { set(associatedValue: newValue, key: "calayer_viewEffectiveAppearanceKVO", object: self) }
    }
}
*/
#endif
