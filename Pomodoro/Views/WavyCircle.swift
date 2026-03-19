import SwiftUI

struct WavyCircle: Shape {
    var frequency: Double
    var amplitude: Double
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        guard progress > 0 else { return path }
        
        let points = 500 // More points for smoother animation
        let maxAngle = 2 * Double.pi * Double(progress)
        
        for i in 0...points {
            let relativeProgress = Double(i) / Double(points)
            let angle = relativeProgress * maxAngle
            
            // To make the wave continuous, we should use a consistent angle for the sin wave
            // But we also want the wave to meet at the start/end if possible.
            // Using frequency * angle helps.
            let waveOffset = amplitude * sin(angle * frequency)
            let x = Double(center.x) + (Double(radius) + waveOffset) * cos(angle)
            let y = Double(center.y) + (Double(radius) + waveOffset) * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}
