import SwiftUI

public struct EmptyShape: InsettableShape {
    public init() {}

    public func path(in _: CGRect) -> SwiftUI.Path {
        SwiftUI.Path()
    }

    public func inset(by _: CGFloat) -> some InsettableShape {
        self
    }
}
