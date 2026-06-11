import SwiftUI

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        path.move(to: CGPoint(x: width / 2, y: height * 0.85))
        
        // Left bottom curve
        path.addCurve(
            to: CGPoint(x: width * 0.08, y: height * 0.4),
            control1: CGPoint(x: width * 0.30, y: height * 0.72),
            control2: CGPoint(x: width * 0.02, y: height * 0.56)
        )
        
        // Left top curve
        path.addCurve(
            to: CGPoint(x: width / 2, y: height * 0.24),
            control1: CGPoint(x: width * 0.11, y: height * 0.16),
            control2: CGPoint(x: width * 0.40, y: height * 0.16)
        )
        
        // Right top curve
        path.addCurve(
            to: CGPoint(x: width * 0.92, y: height * 0.4),
            control1: CGPoint(x: width * 0.60, y: height * 0.16),
            control2: CGPoint(x: width * 0.89, y: height * 0.16)
        )
        
        // Right bottom curve
        path.addCurve(
            to: CGPoint(x: width / 2, y: height * 0.85),
            control1: CGPoint(x: width * 0.98, y: height * 0.56),
            control2: CGPoint(x: width * 0.70, y: height * 0.72)
        )
        
        path.closeSubpath()
        return path
    }
}
