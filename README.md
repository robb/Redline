# Redline

## Easy Redlines for SwiftUI

With Redline, you can quickly visualize positions, sizes, spacings and alignment guides to verify your implementation against specs or to debug layout problem.

![](/example.png)

```swift
import Redline

GroupBox {
    VStack(spacing: 24) {
        Image(systemName: "globe")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .foregroundStyle(.tint)
            .measureSpacing()
            .visualizePosition(color: .blue, in: .named("outside"))
            .visualizeSize()

        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "figure.wave")
                .visualizeAlignmentGuide(.firstTextBaseline)

            Text("Hello, world!\nHow are you?")
                .visualizeAlignmentGuide(.firstTextBaseline)
        }
        .measureSpacing()

        Text("Thank you, bye").font(.caption)
            .measureSpacing()
            .visualizePosition(color: .blue, edges: [.bottom, .trailing], in: .named("outside"))
    }
    .visualizeSpacing(axis: .vertical)
    .padding(8)
}
.visualizeSize()
.coordinateSpace(name: "outside")
.visualizePosition(color: .blue)
```