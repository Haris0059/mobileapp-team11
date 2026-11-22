import SwiftUI

/// The app logo mark: two rings and an amber sweep. Drawn in a 100×100 grid, scales to any size.
struct RadarMark: View {
    var ring: Color = Theme.ink
    var dot: Color = Theme.amber

    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height) / 100
            let style = StrokeStyle(lineWidth: 7 * s, lineCap: .round)
            func circle(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) -> Path {
                Path(ellipseIn: CGRect(x: (x - r) * s, y: (y - r) * s, width: 2 * r * s, height: 2 * r * s))
            }
            context.stroke(circle(50, 50, 34), with: .color(ring.opacity(0.45)), style: style)
            context.stroke(circle(50, 50, 18), with: .color(ring.opacity(0.75)), style: style)
            var sweep = Path()
            sweep.move(to: CGPoint(x: 50 * s, y: 50 * s))
            sweep.addLine(to: CGPoint(x: 74 * s, y: 26 * s))
            context.stroke(sweep, with: .color(dot), style: style)
            context.fill(circle(74, 26, 7), with: .color(dot))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }
}

#Preview {
    RadarMark().frame(width: 120)
}
