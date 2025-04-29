import SwiftUI

extension CGRect {
    subscript(unitPoint: UnitPoint) -> CGPoint {
        .init(x: minX + width * unitPoint.x, y: minY + height * unitPoint.y)
    }
}
