import UserNotifications
import ActivityKit
import WidgetKit

@Observable
class TimerEngine {
    var sessionState: SessionState = .idle
    var currentSessionType: SessionType = .focus
    
    var timeRemaining: TimeInterval = 0
    var totalDuration: TimeInterval = 0
    
    var completedCycles: Int = 0 
    
    var sessionRepository: SessionRepositoryProtocol?
    var settings: SettingsService?
    private var lastSaveTime: TimeInterval = 0
    
    // Core timing properties
    private var timerStart: Date?
    private var timer: Timer?
    private var pauseTimeRemainingCache: TimeInterval?
    
    // For Undo Reset feature
    var isShowingUndoReset: Bool = false
    private var undoCache: (Date?, TimeInterval, SessionState)?
    
    // Live Activity
    private var currentActivity: Activity<PomodoroActivityAttributes>?
    
    enum SessionState {
        case idle     // Not started
        case running  // Actively ticking
        case paused   // Paused
        case finished // Reached 0
    }
    
    func setupNewSession(type: SessionType, durationMinutes: Int) {
        currentSessionType = type
        totalDuration = TimeInterval(durationMinutes * 60)
        timeRemaining = totalDuration
        lastSaveTime = timeRemaining
        sessionState = .idle
        timerStart = nil
        pauseTimeRemainingCache = nil
        isShowingUndoReset = false
    }
    
    func start() {
        if sessionState == .idle || sessionState == .paused {
            if sessionState == .idle {
                timerStart = Date()
            } else if let cached = pauseTimeRemainingCache {
                timerStart = Date().addingTimeInterval(cached - totalDuration)
                pauseTimeRemainingCache = nil
            }
            
            sessionState = .running
            startTimerTicks()
            scheduleLocalNotification()
            
            if currentActivity == nil {
                startLiveActivity()
            } else {
                updateLiveActivity()
            }
        }
    }
    
    func pause() {
        guard sessionState == .running else { return }
        sessionState = .paused
        pauseTimeRemainingCache = timeRemaining
        
        savePendingTime()
        cancelLocalNotification()
        
        timer?.invalidate()
        timer = nil
        
        updateLiveActivity()
    }
    
    func skip(settings: SettingsService) {
        savePendingTime()
        cancelLocalNotification()
        
        timer?.invalidate()
        timer = nil
        advanceToNextSession(settings: settings)
        
        updateLiveActivity()
    }
    
    func reset() {
        guard sessionState != .idle else { return }
        
        savePendingTime()
        
        // Save state for undo
        undoCache = (timerStart, pauseTimeRemainingCache ?? timeRemaining, sessionState)
        
        cancelLocalNotification()
        
        timer?.invalidate()
        timer = nil
        timeRemaining = totalDuration
        pauseTimeRemainingCache = nil
        
        endLiveActivity()
        
        // trigger snackbar
        isShowingUndoReset = true
        
        // Auto hide undo after 5s
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.cancelUndo()
        }
    }
    
    func performUndoReset() {
        guard let cache = undoCache else { return }
        timerStart = cache.0
        if cache.2 == .paused {
            pauseTimeRemainingCache = cache.1
            timeRemaining = cache.1
            sessionState = .paused
        } else if cache.2 == .running {
            sessionState = .running
            startTimerTicks()
            scheduleLocalNotification()
        }
        
        undoCache = nil
        isShowingUndoReset = false
        
        if sessionState == .running {
            if currentActivity == nil {
                startLiveActivity()
            } else {
                updateLiveActivity()
            }
        }
    }
    
    func cancelUndo() {
        isShowingUndoReset = false
        undoCache = nil
    }
    
    private func startTimerTicks() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common) // Keeps ticking during scrolling
    }
    
    private func tick() {
        guard sessionState == .running, let start = timerStart else { return }
        
        let elapsed = Date().timeIntervalSince(start)
        let remaining = totalDuration - elapsed
        
        if remaining <= 0 {
            timeRemaining = 0
            savePendingTime()
            finishSession()
        } else {
            timeRemaining = remaining
            if lastSaveTime - timeRemaining >= 60 {
                savePendingTime()
            }
        }
    }
    
    private func savePendingTime() {
        let diff = lastSaveTime - timeRemaining
        if diff >= 1.0 { // Save if at least 1 second passed
            sessionRepository?.saveSession(duration: diff, type: currentSessionType, isCompleted: timeRemaining <= 0)
        }
        lastSaveTime = timeRemaining
    }
    
    private func finishSession() {
        timer?.invalidate()
        timer = nil
        sessionState = .finished
        
        updateLiveActivity()
        
        if currentSessionType == .focus {
            completedCycles += 1
        }
        
        // Trigger alarm
        print("BEEP BEEP ALARM")
        
        // 60s auto-stop fallback if user doesn't interact (only works in foreground)
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            if self?.sessionState == .finished {
                print("Auto-stopping alarm after 60s")
            }
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Notification permission granted: \(granted)")
        }
    }
    
    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "\(currentSessionType.rawValue) Finished!"
        content.body = "Time to switch sessions."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeRemaining > 0 ? timeRemaining : 1, repeats: false)
        let request = UNNotificationRequest(identifier: "pomodoro_timer", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelLocalNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["pomodoro_timer"])
    }
    
    private func advanceToNextSession(settings: SettingsService) {
        var nextType: SessionType = .focus
        var duration = settings.focusTimeMinutes
        
        if currentSessionType == .focus {
            completedCycles += 1
            if completedCycles % settings.cyclesBeforeLongBreak == 0 {
                nextType = .longBreak
                duration = settings.longBreakMinutes
            } else {
                nextType = .shortBreak
                duration = settings.shortBreakMinutes
            }
        } else {
            // After any break, next is focus
            nextType = .focus
            duration = settings.focusTimeMinutes
        }
        
        setupNewSession(type: nextType, durationMinutes: duration)
        
        if settings.autoStartNext {
            start()
        }
    }
    
    // MARK: - Live Activity Management
    
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let taskName = settings?.currentTaskName ?? "Nhiệm vụ hiện tại"
        let cyclesGoal = settings?.cyclesBeforeLongBreak ?? 4
        
        let attributes = PomodoroActivityAttributes(taskName: taskName)
        let targetDate = Date().addingTimeInterval(timeRemaining)
        let state = PomodoroActivityAttributes.ContentState(
            currentSessionType: currentSessionType.rawValue,
            timeRemaining: timeRemaining,
            totalDuration: totalDuration,
            sessionState: "running",
            targetDate: targetDate,
            currentCycleIndex: completedCycles,
            cyclesBeforeLongBreak: cyclesGoal
        )
        
        do {
            currentActivity = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let cyclesGoal = settings?.cyclesBeforeLongBreak ?? 4
        
        let targetDate = Date().addingTimeInterval(timeRemaining)
        let state = PomodoroActivityAttributes.ContentState(
            currentSessionType: currentSessionType.rawValue,
            timeRemaining: timeRemaining,
            totalDuration: totalDuration,
            sessionState: sessionStateString,
            targetDate: targetDate,
            currentCycleIndex: completedCycles,
            cyclesBeforeLongBreak: cyclesGoal
        )
        
        let content = ActivityContent(state: state, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    private func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
    
    private var sessionStateString: String {
        switch sessionState {
        case .running: return "running"
        case .paused: return "paused"
        case .finished: return "finished"
        case .idle: return "idle"
        }
    }
}
