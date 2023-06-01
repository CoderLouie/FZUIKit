//
//  File.swift
//  
//
//  Created by Florian Zand on 26.05.23.
//

import Foundation

@available(macOS 12, iOS 15, tvOS 15, watchOS 8, *)
    public struct AttributeContainerTransformer: ContentTransformer {
        public let transform: (AttributeContainer) -> AttributeContainer
        public let id: String
        
        /// Creates a text attributes transformer with the specified closure.
        public init(_ id: String, _ transform: @escaping (AttributeContainer) -> AttributeContainer) {
            self.transform = transform
            self.id = id
        }
    }

