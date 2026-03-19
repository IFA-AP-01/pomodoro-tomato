import SwiftUI
import Combine

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerViewModel.self) private var viewModel
    
    @State private var isAODMode = false
    @State private var aodOffset = CGSize.zero
    let timerForAOD = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let theme = viewModel.settings.currentTheme
        
        ZStack {
            // Background
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header (Title & AOD Button)
                HStack {
                    Spacer()
                    Text(viewModel.timerEngine.currentSessionType.rawValue.uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .kerning(1.5)
                        .foregroundColor(theme.statusText)
                        
                    Spacer()
                    if viewModel.settings.enableInAppAOD {
                        Button(action: {
                            isAODMode = true
                            UIApplication.shared.isIdleTimerDisabled = true
                        }) {
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(theme.text.opacity(0.3))
                                .font(.title3)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Dynamic Task Pill
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(theme.cardText)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.settings.currentTaskName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(theme.cardText)
                        Text("Topic: \(viewModel.settings.currentTaskTopic)")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundColor(theme.cardSecondaryText)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(theme.surface)
                .clipShape(Capsule())
                
                Spacer()
                
                // Progress & Clock
                ZStack {
                    // Background track
                    Circle()
                        .stroke(lineWidth: 30)
                        .foregroundColor(theme.timerBackground)
                    
                    // Progress
                    Circle()
                        .trim(from: 0.0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .round, lineJoin: .round))
                        .foregroundColor(progressColor(for: theme))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    // Clock text
                    Text(timeString(from: viewModel.timerEngine.timeRemaining))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(theme.text)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(40)
                }
                .padding(.horizontal, 60)
                
                Spacer()
                
                // Session Dots
                HStack(spacing: 12) {
                    ForEach(0..<viewModel.settings.cyclesBeforeLongBreak, id: \.self) { index in
                        let completed = index < viewModel.timerEngine.completedCycles % viewModel.settings.cyclesBeforeLongBreak
                        let isCurrent = index == viewModel.timerEngine.completedCycles % viewModel.settings.cyclesBeforeLongBreak
                        
                        if isCurrent && viewModel.timerEngine.currentSessionType == .focus {
                            ZStack {
                                Circle()
                                    .fill(theme.accent)
                                    .frame(width: 16, height: 16)
                                Image(systemName: "plus")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black) // This is fine if accent is yellow
                            }
                        } else {
                            Circle()
                                .fill(completed ? theme.text.opacity(0.3) : theme.timerBackground)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 35) {
                    // Reset
                    Button(action: {
                        viewModel.reset()
                        triggerHaptic(style: .medium)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundColor(theme.text.opacity(0.3))
                    }
                    
                    // Play / Pause
                    Button(action: {
                        viewModel.togglePlayPause()
                        triggerHaptic(style: .heavy)
                    }) {
                        Image(systemName: viewModel.timerEngine.sessionState == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(theme.text)
                    }
                    
                    // Skip
                    Button(action: {
                        viewModel.skip()
                        triggerHaptic(style: .light)
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(theme.text.opacity(0.3))
                    }
                }
                .padding(.bottom, 130)
            }
            .padding()
            
            // Undo Reset Snackbar
            if viewModel.timerEngine.isShowingUndoReset {
                VStack {
                    Spacer()
                    HStack {
                        Text("Timer reset.")
                            .foregroundColor(theme.cardText)
                        Spacer()
                        Button("Undo") {
                            viewModel.performUndoReset()
                        }
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
                .animation(.spring(), value: viewModel.timerEngine.isShowingUndoReset)
            }
            
            // AOD Overlay
            if isAODMode {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack {
                        Text(timeString(from: viewModel.timerEngine.timeRemaining))
                            .font(.system(size: 100, weight: .thin, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .offset(aodOffset)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isAODMode = false
                                UIApplication.shared.isIdleTimerDisabled = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                }
                .transition(.opacity)
                .zIndex(2)
                .onReceive(timerForAOD) { _ in
                    withAnimation(.easeInOut(duration: 2.0)) {
                        aodOffset = CGSize(
                            width: CGFloat.random(in: -30...30),
                            height: CGFloat.random(in: -50...50)
                        )
                    }
                }
            }
        }
        .onAppear {
            viewModel.timerEngine.sessionRepository = LocalSessionRepository(modelContext: modelContext)
            viewModel.timerEngine.requestNotificationPermission()
            viewModel.checkAndSetupInitialSession()
        }
    }
    
    // MARK: - Helpers
    
    private var progress: CGFloat {
        guard viewModel.timerEngine.totalDuration > 0 else { return 0 }
        let p = viewModel.timerEngine.timeRemaining / viewModel.timerEngine.totalDuration
        return CGFloat(p)
    }
    
    private func progressColor(for theme: PomodoroTheme) -> Color {
        switch viewModel.timerEngine.currentSessionType {
        case .focus: return theme.text
        case .shortBreak: return theme.accent
        case .longBreak: return .blue
        }
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

#Preview {
    let settings = SettingsService()
    let engine = TimerEngine()
    TimerView()
        .environment(TimerViewModel(timerEngine: engine, settings: settings))
}
