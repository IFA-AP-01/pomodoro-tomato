import SwiftUI

struct TimerRingComponent: View {
    let progress: CGFloat
    let timeString: String
    let progressColor: Color
    let theme: PomodoroTheme
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 16)
                .foregroundColor(theme.timerBackground)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 16, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear(duration: 1.0), value: progress)
            
            Text(timeString)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(progress)))
                .animation(.snappy, value: timeString)
                .foregroundColor(theme.text)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(40)
        }
        .padding(.horizontal, 60)
    }
}

#Preview {
    TimerRingComponent(
        progress: 0.75,
        timeString: "25:00",
        progressColor: .orange,
        theme: .defaultTheme
    )
    .padding()
}
