//
//  GenericPageController.swift
//  PageController
//
//  Created by Florian Zand on 26.05.22.
//

#if os(macOS)
    import AppKit
    import Foundation

    public class PageController<ViewController: NSViewController, Element>: NSPageController, NSPageControllerDelegate {
        override public func loadView() {
            view = NSView()
        }

        var isSwipeable = true
        var isLooping = false
        var keyboardControl: KeyboardControl = .on()

        typealias Handler = (ViewController, Element) -> Void
        private let handler: Handler

        init(elements: [Element] = [], handler: @escaping Handler) {
            self.handler = handler
            super.init(nibName: nil, bundle: nil)
            self.elements = elements
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override public func performKeyEquivalent(with event: NSEvent) -> Bool {
            var type: AdvanceType? = nil
            if event.keyCode == 123 {
                if event.modifierFlags.contains(.command) {
                    type = .first
                } else {
                    type = .previous
                }
            } else {
                if event.modifierFlags.contains(.command) {
                    type = .last
                } else {
                    type = .next
                }
            }
            if let type = type, let values = keyboardControl.values(for: type) {
                advance(to: values.0, duration: values.1)
                return true
            }
            return false
        }

        override public var acceptsFirstResponder: Bool {
            return true
        }

        override public func viewDidLoad() {
            super.viewDidLoad()
            delegate = self
            transitionStyle = .horizontalStrip

            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                let isHandled = self.performKeyEquivalent(with: event)
                //  self.keyDown(with: $0)
                return isHandled ? nil : event
            }
        }

        override public func scrollWheel(with event: NSEvent) {
            if isSwipeable {
                super.scrollWheel(with: event)
            }
        }

        var elements: [Element] {
            get { return arrangedObjects.isEmpty ? [] : (arrangedObjects as! [Element]) }
            set { arrangedObjects = newValue }
        }

        public func pageController(_: NSPageController, viewControllerForIdentifier _: String) -> NSViewController {
            return ViewController()
        }

        public func pageController(_: NSPageController, identifierFor _: Any) -> String {
            return "ViewController"
        }

        func prepare(viewController: ViewController, with element: Element) {
            handler(viewController, element)
        }

        public func pageController(_: NSPageController, prepare viewController: NSViewController, with object: Any?) {
            guard let element = object as? Element, let itemVC = viewController as? ViewController else { return }
            prepare(viewController: itemVC, with: element)
        }

        public func pageControllerDidEndLiveTransition(_: NSPageController) {
            completeTransition()
        }
    }
#endif
