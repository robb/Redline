import SwiftUI

public extension View {
    func visualizePosition(color: some ShapeStyle = Color.red, edges: Edge.Set = [.top, .leading], in coordinateSpace: CoordinateSpaceProtocol = .global) -> some View {
        modifier(
            PositionVisualizationModifier(shapeStyle: color, edges: edges, coordinateSpace: coordinateSpace)
        )
    }
}

struct PositionVisualizationModifier<S: ShapeStyle>: ViewModifier {
    var shapeStyle: S

    var edges: Edge.Set = .all

    var coordinateSpace: (any CoordinateSpaceProtocol) = .global

    @Environment(\.redlineStyle.strokeStyle) var strokeStyle

    @Environment(\.displayScale) var displayScale

    func body(content: Content) -> some View {
        let pixel = 1 / displayScale

        content.overlay {
            GeometryReader { geometry in
                ZStack {
                    Color.clear

                    let frame = geometry.frame(in: coordinateSpace)

                    if edges.contains(.leading) {
                        let xOffset = frame.minX
                        IBeam(axis: .horizontal)
                            .frame(width: abs(xOffset) - pixel)
                            .overlay(alignment: .dimensionLabel) {
                                DimensionLabel(edge: .top, value: xOffset)
                            }
                            .position(x: 0 - xOffset / 2, y: 8)
                    }

                    if edges.contains(.top) {
                        let yOffset = frame.minY

                        IBeam(axis: .vertical)
                            .frame(height: abs(yOffset) - pixel)
                            .overlay(alignment: .dimensionLabel) {
                                DimensionLabel(edge: .leading, value: yOffset)
                            }
                            .position(x: 8, y: 0 - yOffset / 2)
                    }

                    if let named = coordinateSpace as? NamedCoordinateSpace {
                        let bounds = geometry.bounds(of: named) ?? .zero

                        if edges.contains(.trailing) {
                            let xOffset = bounds.width - frame.maxX
                            IBeam(axis: .horizontal)
                                .frame(width: abs(xOffset) - pixel)
                                .overlay(alignment: .dimensionLabel) {
                                    DimensionLabel(edge: .bottom, value: xOffset)
                                }
                                .position(x: geometry.size.width + xOffset / 2 - pixel, y: geometry.size.height - 8)
                        }

                        if edges.contains(.bottom) {
                            let yOffset = bounds.height - frame.maxY
                            IBeam(axis: .vertical)
                                .frame(height: abs(yOffset) - pixel)
                                .overlay(alignment: .dimensionLabel) {
                                    DimensionLabel(edge: .trailing, value: yOffset)
                                }
                                .position(x: geometry.size.height - 8, y: geometry.size.height + yOffset / 2 - pixel)
                        }
                    }
                }
            }
            .foregroundStyle(shapeStyle)
            .allowsHitTesting(false)
        }
    }
}

#Preview("Animation") {
    @Previewable @State var offset: Date = .now

    TimelineView(.animation) { context in
        ZStack {
            let theta = Angle(degrees: (context.date.timeIntervalSince(offset)) * 36).radians

            let x = sin(theta) * 100 + 100
            let y = cos(theta) * 100 + 100

            Circle()
                .fill(.orange.gradient)
                .frame(width: 44, height: 44)
                .visualizePosition(color: .black, edges: .all, in: .named("zstack"))
                .position(x: x, y: y)
        }
        .frame(width: 180, height: 180)
        .background(.blue)
        .coordinateSpace(.named("zstack"))
    }
}
