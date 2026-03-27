import SwiftUI

struct AODOverlayComponent: View {
    let currentTimeString: String
    let currentDateString: String
    let progress: CGFloat
    let timeRemainingString: String
    let sessionType: String
    let batteryPercentage: Int
    let batteryIconName: String
    let batteryIconColor: Color
    let batteryStatusText: String
    let aodOffset: CGSize
    let onExitAOD: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                    .frame(height: 80)
                
                // Current Time
                Text(currentTimeString)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .kerning(2)
                
                // Current Date
                Text(currentDateString)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
                
                Spacer()
                    .frame(height: 40)
                
                // Timer Ring
                ZStack {
                    // Background track
                    Circle()
                        .trim(from: 0.0, to: 0.75)
                        .stroke(
                            Color.white.opacity(0.15),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))
                        .frame(width: 160, height: 160)
                    
                    // Timer progress arc
                    Circle()
                        .trim(from: 0.0, to: progress * 0.75)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))
                        .frame(width: 160, height: 160)
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    // Timer countdown text
                    Text(timeRemainingString)
                        .monospacedDigit()
                        .contentTransition(.numericText(value: Double(progress)))
                        .animation(.snappy, value: timeRemainingString)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Session type label
                Text(sessionType)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: 30)
                
                // Battery Info Row
                HStack(spacing: 16) {
                    // Battery icon + percentage
                    HStack(spacing: 6) {
                        Image(systemName: batteryIconName)
                            .font(.system(size: 20))
                            .foregroundColor(batteryIconColor)
                        Text("\(batteryPercentage)%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Separator
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 4, height: 4)
                    
                    // Charging status
                    Text(batteryStatusText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                )
                
                Spacer()
                
                // AOD Exit Button
                Button(action: onExitAOD) {
                    Image(systemName: "moon.stars.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(16)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.08))
                        )
                }
                .padding(.bottom, 60)
            }
            .offset(aodOffset)
        }
        .statusBarHidden(true)
    }
}

#Preview {
    AODOverlayComponent(
        currentTimeString: "10:00",
        currentDateString: "Thứ Hai, 26 tháng 3",
        progress: 0.5,
        timeRemainingString: "12:30",
        sessionType: "Focus",
        batteryPercentage: 85,
        batteryIconName: "battery.75",
        batteryIconColor: .white,
        batteryStatusText: "Không sạc",
        aodOffset: .zero,
        onExitAOD: {}
    )
}
