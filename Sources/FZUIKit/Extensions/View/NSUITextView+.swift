//
//  NSUITextView+.swift
//
//
//  Created by Florian Zand on 08.11.23.
//

#if os(macOS) || os(iOS) || os(tvOS)
    #if os(macOS)
        import AppKit
    #elseif canImport(UIKit)
        import UIKit
    #endif

    public extension NSUITextView {
        #if os(macOS)
            /**
             The font size of the text.

             The value can be animated via `animator()`.
             */
            @objc var fontSize: CGFloat {
                get { font?.pointSize ?? 0.0 }
                set { Self.swizzleAnimationForKey()
                    font = font?.withSize(newValue)
                }
            }

        #elseif canImport(UIKit)
            /// The font size of the text.
            @objc var fontSize: CGFloat {
                get { font?.pointSize ?? 0.0 }
                set { font = font?.withSize(newValue) }
            }
        #endif
    }

#endif
