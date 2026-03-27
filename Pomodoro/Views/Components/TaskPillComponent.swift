import SwiftUI

struct TaskPillComponent: View {
    let taskName: String
    let taskTopic: String
    let theme: PomodoroTheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundColor(theme.cardText)
            VStack(alignment: .leading, spacing: 2) {
                Text(taskName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(theme.cardText)
                Text("Topic: \(taskTopic)")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(theme.cardSecondaryText)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(theme.surface)
        .clipShape(Capsule())
    }
}

#Preview {
    TaskPillComponent(
        taskName: "Refactoring Components",
        taskTopic: "Code Quality",
        theme: .defaultTheme
    )
}
