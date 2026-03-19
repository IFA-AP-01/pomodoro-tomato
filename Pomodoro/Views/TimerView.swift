import SwiftUI
import Combine

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerViewModel.self) private var viewModel
    
    @State private var isAODMode = false
    @State private var aodOffset = CGSize.zero
    let timerForAOD = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header (With AOD button)
                HStack {
                    Spacer()
                    Text(viewModel.timerEngine.currentSessionType.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(headerColor)
                    Spacer()
                    if viewModel.settings.enableInAppAOD {
                        Button(action: {
                            isAODMode = true
                            UIApplication.shared.isIdleTimerDisabled = true
                        }) {
                            Image(systemName: "moon.stars.fill")
                                .foregroundColor(.secondary)
                                .font(.title3)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Progress & Clock
                ZStack {
                    // Background track
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.1)
                        .foregroundColor(.gray)
                    
                    // Progress
                    if viewModel.timerEngine.currentSessionType == .focus {
                        Circle()
                            .trim(from: 0.0, to: progress)
                            .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                            .foregroundColor(progressColor)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(Animation.linear(duration: 0.1), value: progress)
                    } else {
                        WavyCircle(frequency: 20, amplitude: 5, progress: progress)
                            .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                            .foregroundColor(progressColor)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(Animation.linear(duration: 0.1), value: progress)
                    }
                    
                    // Clock text
                    Text(timeString(from: viewModel.timerEngine.timeRemaining))
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(40)
                }
                .padding(40)
                
                // Subtitle
                Text(upNextText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Controls
                HStack(spacing: 30) {
                    // Reset
                    Button(action: {
                        viewModel.reset()
                        triggerHaptic(style: .medium)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // Play / Pause
                    Button(action: {
                        viewModel.togglePlayPause()
                        triggerHaptic(style: .heavy)
                    }) {
                        Image(systemName: viewModel.timerEngine.sessionState == .running ? "pause.fill" : "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(progressColor)
                            .clipShape(Circle())
                    }
                    
                    // Skip
                    Button(action: {
                        viewModel.skip()
                        triggerHaptic(style: .light)
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .frame(width: 60, height: 60)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Undo Reset Snackbar
            if viewModel.timerEngine.isShowingUndoReset {
                VStack {
                    Spacer()
                    HStack {
                        Text("Timer reset.")
                            .foregroundColor(.white)
                        Spacer()
                        Button("Undo") {
                            viewModel.performUndoReset()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(Color.accentColor)
                    }
                    .padding()
                    .background(Color(UIColor.darkGray))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
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
                    // Anti-burn-in shift (max 30 pts in any direction)
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
    
    private var progressColor: Color {
        switch viewModel.timerEngine.currentSessionType {
        case .focus: return .orange
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
    
    private var headerColor: Color {
        progressColor
    }
    
    private var upNextText: String {
        // Calculate what's next based on cycles
        let nextType: String
        let nextDuration: Int
        
        if viewModel.timerEngine.currentSessionType == .focus {
            if (viewModel.timerEngine.completedCycles + 1) % viewModel.settings.cyclesBeforeLongBreak == 0 {
                nextType = "Long Break"
                nextDuration = viewModel.settings.longBreakMinutes
            } else {
                nextType = "Short Break"
                nextDuration = viewModel.settings.shortBreakMinutes
            }
        } else {
            nextType = "Focus"
            nextDuration = viewModel.settings.focusTimeMinutes
        }
        
        return "Up Next: \(nextType) (\(nextDuration)m)"
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
