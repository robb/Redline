import CoreGraphics

extension CGPoint {
    func offset(x: CGFloat = 0, y: CGFloat = 0) -> CGPoint {
        var copy = self
        copy.x += x
        copy.y += y

        return copy
    }
}
