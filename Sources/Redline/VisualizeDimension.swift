import SwiftUI

public extension View {
    func visualizeDimension(color content: some ShapeStyle = Color.red, _ dimension: Dimension) -> some View {
        modifier(DimensionVisualizationModifier(content: content, dimensions: [dimension]))
    }

    func visualizeSize(color content: some ShapeStyle = Color.red) -> some View {
        modifier(DimensionVisualizationModifier(content: content, dimensions: [.width, .height]))
    }
}

public enum Dimension: Hashable {
    case width
    case height
}

struct DimensionVisualizationModifier<S: ShapeStyle>: ViewModifier {
    @Environment(\.redlineStyle.strokeStyle) var strokeStyle

    @Environment(\.dimensionNestingCount) var nestingCount

    var shapeStyle: S

    var dimensions: Set<Dimension> = []

    init(content shapeStyle: S, dimensions: Set<Dimension>) {
        self.shapeStyle = shapeStyle
        self.dimensions = dimensions
    }

    func body(content: Content) -> some View {
        content
            .environment(\.dimensionNestingCount, nestingCount + 1)
            .overlay {
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)

                    ZStack {
                        Color.clear

                        switch dimensions {
                        case [.width, .height]:
                            Rectangle().strokeBorder(style: strokeStyle)
                                .overlay(alignment: overlayAlignment) {
                                    DimensionLabel(value: geometry.size)
                                }

                        case [.height]:
                            IBeam(axis: .vertical).overlay(alignment: .dimensionLabel) {
                                DimensionLabel(
                                    edge: frame.midX < 200 ? .leading : .trailing,
                                    value: geometry.size.height
                                )

                            }
                        case [.width]:
                            IBeam(axis: .horizontal).overlay(alignment: .dimensionLabel) {
                                DimensionLabel(
                                    edge: frame.midY < 200 ? .top : .bottom,
                                    value: geometry.size.width
                                )
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
                .foregroundStyle(shapeStyle)
                .allowsHitTesting(false)
            }
    }

    var overlayAlignment: Alignment {
        switch nestingCount % 4 {
        case 0: .topTrailing
        case 1: .bottomTrailing
        case 2: .bottomLeading
        default: .topLeading
        }
    }
}

extension EnvironmentValues {
    @Entry var dimensionNestingCount: Int = 0
}

extension Edge {
    var isHorizontal: Bool {
        self == .leading || self == .trailing
    }
}

#Preview {
    VStack {
        Text("A, B,\nC, D").padding(.trailing, 1 / 6)
            .visualizePosition(edges: .all, in: .named("foo"))

        DisclosureGroup("Foo Bar Baz") {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("Hello, world!")
                .background(.blue)
        }
        .visualizeSize()

        HStack {
            Text("Hallo")
            Text("Welt")
        }
        .visualizeDimension(color: .blue, .width)
        .coordinateSpace(.named("hstack"))
    }
    .padding(80)
    .coordinateSpace(.named("foo"))
    .environment(\.displayScale, 1)
}
