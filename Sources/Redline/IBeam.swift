import SwiftUI

struct IBeam: View {
    var axis: Axis

    @Environment(\.displayScale) var displayScale

    @Environment(\.redlineStyle.strokeStyle) var strokeStyle

    var body: some View {
        ZStack {
            IBeamEndcaps(axis: axis)
                .stroke(style: .init(lineWidth: 1 / displayScale, lineCap: .round))

            IBeamCrossbar(axis: axis).stroke(style: strokeStyle)
            IBeamArrows(axis: axis).fill()
                .frame(
                    maxWidth: axis == .vertical ? 8 : nil,
                    maxHeight: axis == .horizontal ? 8 : nil
                )
        }
        .frame(
            maxWidth: axis == .vertical ? 16 : nil,
            maxHeight: axis == .horizontal ? 16 : nil
        )

    }
}

public struct RedlineStyle: Hashable {
    enum Guts {
        case dashed
        case `default`
        case dotted
    }

    var guts: Guts = .default

    public static var dashed: Self { .init(guts: .dashed) }

    public static var `default`: Self { .init(guts: .`default`)}

    public static var dotted: Self { .init(guts: .dotted) }

    var strokeStyle: StrokeStyle {
        switch self {
        case .dashed:
            .init(lineWidth: 1, lineCap: .round, dash: [10, 5])
        case .dotted:
            .init(lineWidth: 1, lineCap: .round, dash: [0.5, 3])
        default:
            .init(lineWidth: 1)
        }
    }
}

extension StrokeStyle {
    func resetDash() -> Self {
        var copy = self
        copy.dash = []
        copy.dashPhase = 0
        return copy
    }
}

public extension View {
    func redlineStyle(_ redlineStyle: RedlineStyle) -> some View {
        environment(\.redlineStyle, redlineStyle)
    }
}

extension EnvironmentValues {
    @Entry var redlineStyle: RedlineStyle = .default
}

struct IBeamEndcaps: Shape {
    var axis: Axis

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        if axis == .horizontal {
            path.addLines([ rect[.topLeading], rect[.bottomLeading] ])
            path.addLines([ rect[.topTrailing], rect[.bottomTrailing] ])
        } else {
            path.addLines([ rect[.topLeading], rect[.topTrailing] ])
            path.addLines([ rect[.bottomLeading], rect[.bottomTrailing] ])
        }

        return path
    }
}

struct IBeamCrossbar: Shape {
    var axis: Axis

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        if axis == .horizontal {
            path.addLines([ rect[.leading], rect[.trailing] ])
        } else {
            path.addLines([ rect[.top], rect[.bottom] ])
        }

        return path
    }
}

struct IBeamArrows: Shape {
    var axis: Axis

    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()

        let d = 5.0

        if rect.width <= d || rect.height <= d { return path }


        if axis == .horizontal {
            path.addLines([
                rect[.leading],
                rect[.leading].offset(x: d, y: -d / 2),
                rect[.leading].offset(x: d, y: d / 2),
                rect[.leading]
            ])
            path.addLines([
                rect[.trailing],
                rect[.trailing].offset(x: -d, y: d / 2),
                rect[.trailing].offset(x: -d, y: -d / 2),
                rect[.trailing]
            ])
        } else {
            path.addLines([
                rect[.top],
                rect[.top].offset(x: -d / 2, y: d),
                rect[.top].offset(x: d / 2, y: d),
                rect[.top]
            ])
            path.addLines([
                rect[.bottom],
                rect[.bottom].offset(x: d / 2, y: -d),
                rect[.bottom].offset(x: -d / 2, y: -d),
                rect[.bottom]
            ])
        }

        return path
    }
}

#Preview {
    VStack {
        IBeam(axis: .horizontal)
            .redlineStyle(.dashed)

        IBeam(axis: .vertical)

        IBeam(axis: .horizontal)
            .redlineStyle(.dotted)
    }
    .foregroundStyle(.red)
    .padding()
}
