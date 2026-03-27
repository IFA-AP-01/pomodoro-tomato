import SwiftUI

struct SessionProgressComponent: View {
    let cyclesBeforeLongBreak: Int
    let completedCycles: Int
    let theme: PomodoroTheme
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<cyclesBeforeLongBreak, id: \.self) { index in
                let isCompleted = index < completedCycles % cyclesBeforeLongBreak
                let isCurrent = index == completedCycles % cyclesBeforeLongBreak
                
                if isCurrent {
                    ZStack {
                        Circle()
                            .fill(theme.accent)
                            .frame(width: 16, height: 16)
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .fill(isCompleted ? theme.text.opacity(0.3) : theme.timerBackground)
                        .frame(width: 12, height: 12)
                }
            }
        }
    }
}

#Preview {
    SessionProgressComponent(
        cyclesBeforeLongBreak: 4,
        completedCycles: 1,
        theme: .defaultTheme
    )
}
