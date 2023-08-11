//
//  NSUICollectionView+.swift
//  
//
//  Created by Florian Zand on 23.07.23.
//

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public extension NSUICollectionView {
    /// Supplementary view kinds.
    enum ElementKind {
        /// A supplementary view that acts as a top seperator for a given item.
        public static let itemTopSeperator: String = "ElementKindItemTopSeperator"
        /// A supplementary view that acts as a bottom seperator for a given item.
        public static let itemBottomSeperator: String = "ElementKindBottomSeperator"
        /// A supplementary view that acts as a background for a given item.
        public static let itemBackground: String = "ElementKindItemBackground"
        /// A supplementary view that acts as a background for a given group.
        public static let groupBackground: String = "ElementKindGroumBackground"
        /// A supplementary view that acts as a background for a given section.
        public static let sectionBackground: String = "ElementKindSectionBackground"
        /// A supplementary view that acts as a header for a given section.
        public static var sectionHeader: String {
            return NSUICollectionView.elementKindSectionHeader
        }
        /// A supplementary view that acts as a footer for a given section.
        public static var sectionFooter: String {
            return NSUICollectionView.elementKindSectionFooter
        }
    }
}
