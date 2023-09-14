//
//  UIContentConfiguration+Stateless.swift
//  
//
//  Created by Florian Zand on 01.07.23.
//

#if os(iOS) || os(tvOS)
import UIKit

public extension UIContentConfiguration {
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}
#endif
