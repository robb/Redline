import SwiftUI

public extension View {
    func measureSpacing() -> some View {
        self.modifier(MeasureSpacingModifier())
    }

    func visualizeSpacing(color: some ShapeStyle = Color.red, axis: Axis = .horizontal) -> some View {
        self.modifier(SpacingVisualizationModifier(shapeStyle: color, axis: axis))
    }
}

struct MeasureSpacingModifier: ViewModifier {
    @Namespace var id

    func body(content: Content) -> some View {
        content.anchorPreference(key: MeasuredRectKey.self, value: .bounds) {
            [ MeasuredRect(id: id, rect: $0) ]
        }
    }
}

struct SpacingVisualizationModifier<S: ShapeStyle>: ViewModifier {
    var shapeStyle: S

    var axis: Axis

    func body(content: Content) -> some View {
        content
            .overlayPreferenceValue(MeasuredRectKey.self) { rects in
                GeometryReader { geometry in
                    let rects = rects
                        .map { $0.resolve(in: geometry) }
                        .sorted { a, b in
                            a.isOrderedBefore(b, axis: axis)
                        }

                    let spacings: [Spacing] = zip(rects.dropLast(), rects.dropFirst())
                        .reduce(into: []) { result, tuple in
                            let (a, b) = tuple
                            result.append(Spacing(axis: axis, a: a, b: b))
                        }

                    ForEach(spacings) { spacing in
                        let width = axis == .horizontal ? abs(spacing.width) : 8
                        let height = axis == .vertical ? abs(spacing.height) : 8

                        IBeam(axis: axis)
                            .frame(width: abs(width), height: abs(height))
                            .overlay(alignment: .dimensionLabel) {
                                DimensionLabel(
                                    edge: axis == .horizontal ? .top : .trailing,
                                    value: abs(axis == .horizontal ? spacing.width : spacing.height)
                                )
                            }
                            .position(spacing.position)
                    }
                }
                .foregroundStyle(shapeStyle)
            }
            .transformAnchorPreference(key: MeasuredRectKey.self, value: .bounds) { rects, _ in
                rects = []
            }
    }
}

struct MeasuredRect: Identifiable {
    var id: Namespace.ID

    var rect: Anchor<CGRect>

    func resolve(in geometry: GeometryProxy) -> ResolvedRect {
        .init(id: id, rect: geometry[rect])
    }
}

struct ResolvedRect: Identifiable {
    var id: Namespace.ID

    var rect: CGRect
}

extension ResolvedRect {
    func isOrderedBefore(_ other: Self, axis: Axis) -> Bool {
        switch axis {
        case .horizontal:
            rect.maxX < other.rect.minX
        case .vertical:
            rect.maxY < other.rect.minY
        }
    }
}

struct Spacing: Identifiable {
    var axis: Axis

    var a: ResolvedRect

    var b: ResolvedRect

    var position: CGPoint {
        switch axis {
        case .horizontal:
            CGPoint(x: a.rect.maxX + width / 2, y: a.rect.midY)
        case .vertical where a.rect.maxY < b.rect.minY:
            CGPoint(x: a.rect.midX, y: a.rect.maxY + height / 2)
        case .vertical:
            CGPoint(x: a.rect.midX, y: a.rect.minY - height / 2)
        }
    }

    var width: CGFloat {
        if a.rect.maxX < b.rect.minX {
            b.rect.minX - a.rect.maxX
        } else if b.rect.maxX < a.rect.minX {
            a.rect.minX - b.rect.maxX
        } else {
            0
        }
    }

    var height: CGFloat {
        if a.rect.maxY < b.rect.minY {
            b.rect.minY - a.rect.maxY
        } else if b.rect.maxY < a.rect.minY {
            a.rect.minY - b.rect.maxY
        } else {
            0
        }
    }

    var id: some Hashable {
        Pair(a: a.id, b: b.id)
    }
}

struct Pair<A: Hashable, B: Hashable>: Hashable {
    var a: A
    var b: B
}

struct MeasuredRectKey: PreferenceKey {
    static let defaultValue: [MeasuredRect] = []

    static func reduce(value: inout [MeasuredRect], nextValue: () -> [MeasuredRect]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
    HStack(alignment: .top, spacing: 32) {
        Text("A")
            .background(.red)
            .visualizePosition()

        Text("B")
            .background(.red)
            .measureSpacing()

        Text("B'")
            .background(.red)
            .measureSpacing()
            .offset(y: 22)


        Text("C!")
            .background(.red)
            .measureSpacing()
            .offset(y: -30)
    }
    .visualizeSpacing(axis: .vertical)

    Spacer().frame(height: 100)

    HStack(alignment: .top, spacing: 32) {
        Text("A")
            .background(.red)
            .measureSpacing()

        Text("B")
            .background(.red)
            .measureSpacing()
            .offset(x: 20, y: -20)

        Text("B'")
            .background(.red)
            .measureSpacing()
            .offset(x: -50, y: 20)

        Text("C!")
            .background(.red)
            .measureSpacing()
            .offset(y: 0)
    }
    .padding()
    .visualizeSpacing(axis: .horizontal)
}
