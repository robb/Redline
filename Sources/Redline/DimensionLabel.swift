import SwiftUI

struct DimensionLabel<Content: View>: View {
    @ViewBuilder var content: Content

    var edge: Edge?

    var body: some View {
        content
            .textRenderer(SubpixelRenderer())
            .contentTransition(.identity)
            .transaction { t in
                t.disablesAnimations = true
                t.animation = nil
            }
            .font(font)
            .kerning(0.2)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.shadow(.drop(color: .black.opacity(0.4), radius: 0, x: 1, y: 1)))
            .padding(.horizontal, 2.5)
            .padding(.vertical, 1.3)
            .background(.foreground, in: LabelBackground(edge: edge))
            .fixedSize()
            .alignmentGuide(HorizontalAlignment.dimensionLabel) { d in
                switch edge {
                case .top, .bottom, nil: d[HorizontalAlignment.center]
                case .leading: d[.leading] - 8
                case .trailing: d[.trailing] + 8
                }
            }
            .alignmentGuide(VerticalAlignment.dimensionLabel) { d in
                switch edge {
                case .leading, .trailing, nil: d[VerticalAlignment.center]
                case .top: d[.top] - 8
                case .bottom: d[.bottom] + 8
                }
            }
            .geometryGroup()
    }

    var font: Font {
        Font.system(size: 7.25, weight: .semibold)
            .monospacedDigit()
            .width(.init(-0.1))
    }

    init(edge: Edge? = nil, value: CGFloat) where Content == Text {
        self.content = Text(value, format: .number.precision(.fractionLength(2 ... 2)))
        self.edge = edge
    }

    init(edge: Edge? = nil, value: CGSize) where Content == Text {
        self.content = Text("\(value.width, format: .number.precision(.fractionLength(2 ... 2)))×\(value.height, format: .number.precision(.fractionLength(2 ... 2)))")
        self.edge = edge
    }
}

extension VerticalAlignment {
    struct DimensionLabel: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let dimensionLabel = VerticalAlignment(DimensionLabel.self)
}

extension HorizontalAlignment {
    struct DimensionLabel: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    static let dimensionLabel = HorizontalAlignment(DimensionLabel.self)
}

extension Alignment {
    static var dimensionLabel: Alignment {
        .init(horizontal: .dimensionLabel, vertical: .dimensionLabel)
    }
}

private struct LabelBackground: Shape {
    var edge: Edge?

    var cornerRadius: CGFloat = 3

    nonisolated func path(in rect: CGRect) -> Path {
        var triangle = Path()

        let r = cornerRadius * 2 * 1.528665

        let dimension = edge == .leading || edge == .trailing ? rect.height : rect.width
        let w = max(2, min((dimension - r) / 2, 4))

        switch edge {
        case nil:
            break
        case .leading:
            triangle.addLines([
                rect[.leading].offset(y:  w),
                rect[.leading].offset(x: -4),
                rect[.leading].offset(y: -w)
            ])
        case .trailing:
            triangle.addLines([
                rect[.trailing].offset(y:  w),
                rect[.trailing].offset(x:  4),
                rect[.trailing].offset(y: -w)
            ])
        case .top:
            triangle.addLines([
                rect[.top].offset(x:  w),
                rect[.top].offset(y: -4),
                rect[.top].offset(x: -w)
            ])
        case .bottom:
            triangle.addLines([
                rect[.bottom].offset(x:  w),
                rect[.bottom].offset(y:  4),
                rect[.bottom].offset(x: -w)
            ])
        }
        triangle.closeSubpath()

        return Path(roundedRect: rect, cornerRadius: cornerRadius).union(triangle)
    }
}

struct SubpixelRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        ctx.translateBy(x: 0, y: -0.33333333)

        for line in layout {
            ctx.draw(line, options: .disablesSubpixelQuantization)
        }
    }
}

#Preview {
    VStack {
        DimensionLabel(edge: .leading, value: 1234567890)
        DimensionLabel(edge: .top, value: 1234567890)
        DimensionLabel(edge: .trailing, value: 1234567890)
        DimensionLabel(edge: .bottom, value: 1234567890)

        DimensionLabel(value: CGSize(width: 100, height: 100))
    }

    VStack {
        DimensionLabel(value: 10.20)
        DimensionLabel(value: 10.666667)
        DimensionLabel(value: 10.3333333333)
        DimensionLabel(value: 10.99999)
    }
    .foregroundStyle(.purple)
}
