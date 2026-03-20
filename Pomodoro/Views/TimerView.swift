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
                HStack {
                    Spacer()
                    Text(viewModel.timerEngine.currentSessionType.rawValue.uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .kerning(1.5)
                        .foregroundColor(theme.statusText)
                        
                    Spacer()
                    if viewModel.settings.enableInAppAOD {
                        Button(action: {
                            enterAODMode()
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
            if viewModel.isAODMode {
                aodOverlayView
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .onAppear {
            viewModel.timerEngine.sessionRepository = LocalSessionRepository(modelContext: modelContext)
            viewModel.timerEngine.requestNotificationPermission()
            viewModel.checkAndSetupInitialSession()
        }
    }
    
    // MARK: - AOD Overlay View
    
    private var aodOverlayView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                Spacer()
                    .frame(height: 80)
                
                // Current Time
                Text(aodCurrentTimeString)
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .kerning(2)
                
                // Current Date
                Text(aodCurrentDateString)
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
                    Text(timeString(from: viewModel.timerEngine.timeRemaining))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Session type label
                Text(viewModel.timerEngine.currentSessionType.rawValue)
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
                        Text("\(batteryService.batteryPercentage)%")
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
                Button(action: {
                    exitAODMode()
                }) {
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
        .onReceive(timerForAOD) { _ in
            currentTime = Date()
            withAnimation(.easeInOut(duration: 2.0)) {
                aodOffset = CGSize(
                    width: CGFloat.random(in: -15...15),
                    height: CGFloat.random(in: -25...25)
                )
            }
        }
        .statusBarHidden(true)
    }
    
    // MARK: - AOD Battery Helpers
    
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
        .environment(BatteryService())
}
