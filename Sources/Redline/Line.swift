import SwiftUI

struct Line: View {
    var axis: Axis

    @Environment(\.redlineStyle.strokeStyle) var strokeStyle

    var body: some View {
        LineShape(axis: axis).strokeBorder(style: strokeStyle)
    }
}

struct LineShape: InsettableShape {
    var axis: Axis

    var inset: CGFloat = 0

    nonisolated func inset(by amount: CGFloat) -> LineShape {
        var copy = self
        copy.inset += amount
        return copy
    }

    nonisolated func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)

        var path = Path()

        if axis == .horizontal {
            path.addLines([
                rect[.leading], rect[.trailing]
            ])
        } else {
            path.addLines([
                rect[.top], rect[.bottom]
            ])
        }

        return path
    }
}
