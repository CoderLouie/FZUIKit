//
//  NSViewController+firstReponder.swift
//
//
//  Created by Florian Zand on 06.07.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

extension NSViewController {
    /// A handler that gets called whenever the view controller did become or resign first responder.
    public var firstResponderHandler: ((Bool)->())? {
        get { getAssociatedValue(key: "NSViewController_firstResponderHandler", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSViewController_firstResponderHandler", object: self)
            self.setupFirstResponderObserver()
        }
    }
    
    internal var previousIsFirstRespondder: Bool? {
        get { getAssociatedValue(key: "NSViewController_previousIsFirstRespondderr", object: self, initialValue: nil) }
        set {
            set(associatedValue: newValue, key: "NSViewController_previousIsFirstRespondderr", object: self)
        }
    }
    
    internal func setupFirstResponderObserver() {
        if let firstResponderHandler = self.firstResponderHandler {
            if firstResponderObserver == nil {
                firstResponderObserver = self.observeChanges(for: \.view.superview?.window?.firstResponder, sendInitalValue: true, handler: { old, new in
                    guard old != new else { return }
                    let isFirstResponder = (new == self)
                    guard isFirstResponder != self.previousIsFirstRespondder else { return }
                    self.previousIsFirstRespondder = isFirstResponder
                //    self.willChangeValue(forKey: "isFirstResponder")
                    self.isFirstResponder = isFirstResponder
                    firstResponderHandler(isFirstResponder)
                //    self.didChangeValue(forKey: "isFirstResponder")
                })
            }
        } else {
            previousIsFirstRespondder = nil
            firstResponderObserver = nil
        }
    }
    
    internal var firstResponderObserver: NSKeyValueObservation? {
        get { getAssociatedValue(key: "NSViewController_firstResponderObserver", object: self, initialValue: nil) }
        set { set(associatedValue: newValue, key: "NSViewController_firstResponderObserver", object: self) }
    }
}
#endif

