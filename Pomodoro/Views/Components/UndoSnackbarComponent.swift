import SwiftUI

struct UndoSnackbarComponent: View {
    let isShowing: Bool
    let theme: PomodoroTheme
    let onUndo: () -> Void
    
    var body: some View {
        if isShowing {
            VStack {
                Spacer()
                HStack {
                    Text("Timer reset.")
                        .foregroundColor(theme.cardText)
                    Spacer()
                    Button("Undo", action: onUndo)
                    .fontWeight(.bold)
                    .foregroundColor(theme.accent)
                }
                .padding()
                .background(theme.surface)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 140)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    UndoSnackbarComponent(
        isShowing: true,
        theme: .defaultTheme,
        onUndo: {}
    )
}
