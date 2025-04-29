import SwiftUI

public extension View {
    func visualizeAlignmentGuide(color content: some ShapeStyle = Color.red, _ alignmentGuides: VerticalAlignment...) -> some View {
        modifier(AlignmentGuideVisualizationModifier(content: content, alignmentGuides))
    }

    func visualizeAlignmentGuide(color content: some ShapeStyle = Color.red, _ alignmentGuides: HorizontalAlignment...) -> some View {
        modifier(AlignmentGuideVisualizationModifier(content: content, alignmentGuides))
    }

    func visualizeAlignment(color content: some ShapeStyle = Color.red, _ alignments: Alignment...) -> some View {
        modifier(AlignmentGuideVisualizationModifier(content: content, alignments))
    }
}

struct AlignmentGuideVisualizationModifier<S: ShapeStyle>: ViewModifier {
    struct AligningLayout: Layout {
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            subviews.first?.sizeThatFits(proposal) ?? .zero
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            guard let dimensions = subviews.first?.dimensions(in: proposal) else { return }

            for (i, subview) in subviews.enumerated() {
                if i == 0 {
                    subview.place(at: bounds.origin, proposal: proposal)
                } else {

                    let x = dimensions[subview.containerValues.horizontalAlignment] + bounds.origin.x
                    let y = dimensions[subview.containerValues.verticalAlignment] + bounds.origin.y

                    subview.place(at: .init(x: x, y: y), proposal: .init(bounds.size))
                }
            }
        }
    }

    var shapeStyle: S

    var alignmentGuides: [AlignmentGuide] = []

    var alignments: [IdentifiedAlignment] = []

    init(content: S, _ alignments: [Alignment]) {
        self.shapeStyle = content
        self.alignments = alignments.map(IdentifiedAlignment.init)
    }

    init(content: S, _ alignmentGuides: [VerticalAlignment]) {
        self.shapeStyle = content
        self.alignmentGuides = alignmentGuides.map(AlignmentGuide.vertical)
    }

    init(content: S, _ alignmentGuides: [HorizontalAlignment]) {
        self.shapeStyle = content
        self.alignmentGuides = alignmentGuides.map(AlignmentGuide.horizontal)
    }

    @Environment(\.displayScale) var displayScale

    func body(content: Content) -> some View {
        let pixel = 1 / displayScale

        AligningLayout {
            content

            Group {
                ForEach(alignmentGuides) { guide in
                    switch guide {
                    case .horizontal(let alignment):
                        Line(axis: .vertical)
                            .containerValue(\.horizontalAlignment, alignment)
                            .frame(maxWidth: 1, maxHeight: .infinity)

                    case .vertical(let alignment):
                        Line(axis: .horizontal)
                            .containerValue(\.verticalAlignment, alignment)
                            .frame(maxWidth: .infinity, maxHeight: 1)
                    }
                }

                ForEach(alignments) { alignment in
                    XMark()
                        .strokeBorder(style: .init(lineCap: .round))
                        .frame(width: 8, height: 8)
                        .containerValue(\.horizontalAlignment, alignment.horizontal)
                        .containerValue(\.verticalAlignment, alignment.vertical)
                        .offset(x: -4 + pixel, y: -4 + pixel)
                }
            }
            .foregroundStyle(shapeStyle)
            .allowsHitTesting(false)
        }
    }
}

struct XMark: InsettableShape {
    var inset: CGFloat = 0

    nonisolated func inset(by amount: CGFloat) -> Self {
        var copy = self
        copy.inset += amount
        return copy
    }

    nonisolated func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: inset, dy: inset)

        var path = Path()

        path.addLines([ rect[.topLeading], rect[.bottomTrailing] ])
        path.addLines([ rect[.bottomLeading], rect[.topTrailing] ])

        return path
    }
}

extension ContainerValues {
    @Entry var horizontalAlignment: HorizontalAlignment = .leading
    @Entry var verticalAlignment: VerticalAlignment = .top
}

enum AlignmentGuide: Identifiable {
    case horizontal(HorizontalAlignment)
    case vertical(VerticalAlignment)

    var id: some Hashable {
        switch self {
        case .horizontal(let alignment): alignment.key
        case .vertical(let alignment): alignment.key
        }
    }
}

struct IdentifiedAlignment: Identifiable {
    struct HashablePair<A: Hashable, B: Hashable>: Hashable {
        var a: A
        var b: B
    }

    var horizontal: HorizontalAlignment
    var vertical: VerticalAlignment

    init(alignment: Alignment) {
        horizontal = alignment.horizontal
        vertical = alignment.vertical
    }

    var id: some Hashable {
        HashablePair(a: horizontal.key, b: vertical.key)
    }
}

#Preview {
    @Previewable @State var offset: Date = .now

    HStack(alignment: .center) {
        Image(systemName: "leaf.fill").foregroundStyle(.green)

        TimelineView(.animation) { context in
            Color.red.frame(
                width: 25 + sin(context.date.timeIntervalSince(offset)) * 20,
                height: 25 + cos(context.date.timeIntervalSince(offset)) * 20
            )
        }

        Text("Lorem Ipsum\ndolor amet\nsit relinquat.")
            .visualizeAlignment(.centerFirstTextBaseline)

        TimelineView(.animation) { context in
            Color.blue.frame(
                width: 25 + sin(context.date.timeIntervalSince(offset + 10)) * 20,
                height: 50 + cos(context.date.timeIntervalSince(offset + 10)) * 50
            )
            .visualizeAlignment(.bottomTrailing)
        }
    }
    .visualizeAlignmentGuide(.firstTextBaseline, .lastTextBaseline, .bottom, .top)
    .visualizeAlignmentGuide(.leading, .listRowSeparatorLeading, .listRowSeparatorTrailing, .trailing)
    .visualizeAlignment(.topLeading)
}
