import SwiftUI
import Combine

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerViewModel.self) private var viewModel
    @Environment(BatteryService.self) private var batteryService
    
    @State private var aodOffset = CGSize.zero
    @State private var previousBrightness: CGFloat = UIScreen.main.brightness
    @State private var currentTime = Date()
    let timerForAOD = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let theme = viewModel.settings.currentTheme
        
        ZStack {
            // Background
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header (Title & AOD Button)
                TimerHeaderComponent(
                    sessionType: viewModel.timerEngine.currentSessionType.rawValue,
                    showAODButton: viewModel.settings.enableInAppAOD,
                    theme: theme,
                    onAODToggle: { enterAODMode() }
                )
                
                // Dynamic Task Pill
                TaskPillComponent(
                    taskName: viewModel.settings.currentTaskName,
                    taskTopic: viewModel.settings.currentTaskTopic,
                    theme: theme
                )
                
                Spacer()
                
                // Progress & Clock
                TimerRingComponent(
                    progress: progress,
                    timeString: timeString(from: viewModel.timerEngine.timeRemaining),
                    progressColor: progressColor(for: theme),
                    theme: theme
                )
                
                Spacer()
                
                // Session Dots
                SessionProgressComponent(
                    cyclesBeforeLongBreak: viewModel.settings.cyclesBeforeLongBreak,
                    completedCycles: viewModel.timerEngine.completedCycles,
                    theme: theme
                )
                
                Spacer()
                
                // Controls
                TimerControlsComponent(
                    isRunning: viewModel.timerEngine.sessionState == .running,
                    theme: theme,
                    onReset: {
                        viewModel.reset()
                        triggerHaptic(style: .medium)
                    },
                    onTogglePlayPause: {
                        viewModel.togglePlayPause()
                        triggerHaptic(style: .heavy)
                    },
                    onSkip: {
                        viewModel.skip()
                        triggerHaptic(style: .light)
                    }
                )
            }
            .padding()
            
            // Undo Reset Snackbar
            UndoSnackbarComponent(
                isShowing: viewModel.timerEngine.isShowingUndoReset,
                theme: theme,
                onUndo: { viewModel.performUndoReset() }
            )
            .animation(.spring(), value: viewModel.timerEngine.isShowingUndoReset)
            
            // AOD Overlay
            if viewModel.isAODMode {
                AODOverlayComponent(
                    currentTimeString: aodCurrentTimeString,
                    currentDateString: aodCurrentDateString,
                    progress: progress,
                    timeRemainingString: timeString(from: viewModel.timerEngine.timeRemaining),
                    sessionType: viewModel.timerEngine.currentSessionType.rawValue,
                    batteryPercentage: batteryService.batteryPercentage,
                    batteryIconName: batteryIconName,
                    batteryIconColor: batteryIconColor,
                    batteryStatusText: batteryStatusText,
                    aodOffset: aodOffset,
                    onExitAOD: { exitAODMode() }
                )
                .transition(.opacity)
                .onReceive(timerForAOD) { _ in
                    currentTime = Date()
                    withAnimation(.easeInOut(duration: 2.0)) {
                        aodOffset = CGSize(
                            width: CGFloat.random(in: -15...15),
                            height: CGFloat.random(in: -25...25)
                        )
                    }
                }
                .zIndex(2)
            }
        }
        .onAppear {
            viewModel.timerEngine.sessionRepository = LocalSessionRepository(modelContext: modelContext)
            viewModel.timerEngine.requestNotificationPermission()
            viewModel.checkAndSetupInitialSession()
        }
    }
    
    // MARK: - AOD Helpers (Private logic remains in TimerView for now)
    
    private var batteryIconName: String {
        if batteryService.isCharging {
            return "battery.100.bolt"
        }
        let level = batteryService.batteryPercentage
        switch level {
        case 0..<20: return "battery.0"
        case 20..<50: return "battery.25"
        case 50..<75: return "battery.50"
        case 75..<100: return "battery.75"
        default: return "battery.100"
        }
    }
    
    private var batteryIconColor: Color {
        if batteryService.isCharging { return .green }
        if batteryService.batteryPercentage < 20 { return .red }
        return .white
    }
    
    private var batteryStatusText: String {
        switch batteryService.batteryState {
        case .charging: return "Đang sạc"
        case .full: return "Đã đầy"
        case .unplugged: return "Không sạc"
        default: return "Không xác định"
        }
    }
    
    // MARK: - AOD Mode Management
    
    private func enterAODMode() {
        previousBrightness = UIScreen.main.brightness
        currentTime = Date()
        batteryService.startMonitoring()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.isAODMode = true
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Reduce brightness for OLED optimization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIScreen.main.brightness = 0.1
        }
    }
    
    private func exitAODMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.isAODMode = false
        }
        
        UIApplication.shared.isIdleTimerDisabled = false
        UIScreen.main.brightness = previousBrightness
        batteryService.stopMonitoring()
    }
    
    // MARK: - AOD Formatters
    
    private var aodCurrentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: currentTime)
    }
    
    private var aodCurrentDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEEE, 'thg' M d"
        return formatter.string(from: currentTime)
    }
    
    // MARK: - Helpers
    
    private var progress: CGFloat {
        guard viewModel.timerEngine.totalDuration > 0 else { return 0 }
        let p = viewModel.timerEngine.timeRemaining / viewModel.timerEngine.totalDuration
        return CGFloat(p)
    }
    
    private func progressColor(for theme: PomodoroTheme) -> Color {
        switch viewModel.timerEngine.currentSessionType {
        case .focus: return theme.accent
        case .shortBreak: return theme.accent.opacity(0.7)
        case .longBreak: return theme.accent.opacity(0.4)
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
        .environment(BatteryService())
}
