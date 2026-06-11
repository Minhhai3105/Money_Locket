import SwiftUI

struct CustomZoomSlider: View {
    @Binding var zoomFactor: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
            
            GeometryReader { gp in
                ZStack(alignment: .bottom) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4)
                    
                    Capsule()
                        .fill(Color.yellow)
                        .frame(width: 4, height: percentage * gp.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { val in
                            let fraction = 1.0 - (val.location.y / gp.size.height)
                            let bounded = min(max(fraction, 0), 1)
                            zoomFactor = 1.0 + (bounded * 2.0) // Maps 0..1 to 1x..3x zoom
                        }
                )
            }
            .frame(width: 20, height: 120)
            
            Image(systemName: "minus")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
            
            // Text readout of current zoom
            Text(String(format: "%.1fx", zoomFactor))
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(Color.black.opacity(0.5))
        .clipShape(Capsule())
    }
    
    private var percentage: CGFloat {
        (zoomFactor - 1.0) / 2.0 // mapping 1x to 3x -> 0% to 100%
    }
}
