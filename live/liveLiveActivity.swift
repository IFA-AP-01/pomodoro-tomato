import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

struct liveLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomodoroActivityAttributes.self) { context in
            // Lock screen/banner UI
            PomodoroLiveActivityView(context: context)
                .activityBackgroundTint(Color(white: 0.1))
                .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.currentSessionType, systemImage: sessionIcon(for: context.state.currentSessionType))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.sessionState == "running" {
                        Text(timerInterval: Date()...context.state.targetDate, countsDown: true)
                            .monospacedDigit()
                            .font(.system(.title3, design: .rounded))
                    } else {
                        Text(formatTime(context.state.timeRemaining))
                            .monospacedDigit()
                            .font(.system(.title3, design: .rounded))
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.taskName)
                        .lineLimit(1)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        MultiSegmentProgressView(
                            currentProgress: 1.0 - (context.state.timeRemaining / context.state.totalDuration),
                            currentCycle: context.state.currentCycleIndex,
                            totalCycles: context.state.cyclesBeforeLongBreak,
                            currentType: context.state.currentSessionType
                        )
                        .frame(height: 6)
                        
                        HStack(spacing: 20) {
                            Button(intent: ResetTimerIntent()) {
                                Image(systemName: "arrow.counterclockwise")
                            }
                            .buttonStyle(.bordered)
                            .clipShape(Circle())
                            
                            Button(intent: ToggleTimerIntent()) {
                                Image(systemName: context.state.sessionState == "running" ? "pause.fill" : "play.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .clipShape(Circle())
                            
                            Button(intent: SkipTimerIntent()) {
                                Image(systemName: "forward.fill")
                            }
                            .buttonStyle(.bordered)
                            .clipShape(Circle())
                        }
                    }
                }
            } compactLeading: {
                Image(systemName: sessionIcon(for: context.state.currentSessionType))
                    .foregroundStyle(sessionColor(for: context.state.currentSessionType))
            } compactTrailing: {
                if context.state.sessionState == "running" {
                    Text(timerInterval: Date()...context.state.targetDate, countsDown: true)
                        .monospacedDigit()
                        .frame(width: 45)
                } else {
                    Text(formatTime(context.state.timeRemaining))
                        .monospacedDigit()
                        .frame(width: 45)
                }
            } minimal: {
                Image(systemName: sessionIcon(for: context.state.currentSessionType))
                    .foregroundStyle(sessionColor(for: context.state.currentSessionType))
            }
            .widgetURL(URL(string: "pomodoro://timer"))
            .keylineTint(sessionColor(for: context.state.currentSessionType))
        }
    }
    
    private func sessionIcon(for type: String) -> String {
        switch type {
        case "Focus": return "brain.head.profile"
        case "Short Break": return "cup.and.saucer.fill"
        case "Long Break": return "bed.double.fill"
        default: return "timer"
        }
    }
    
    private func sessionColor(for type: String) -> Color {
        switch type {
        case "Focus": return .orange
        case "Short Break": return .green
        case "Long Break": return .blue
        default: return .white
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PomodoroLiveActivityView: View {
    let context: ActivityViewContext<PomodoroActivityAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.taskName)
                        .font(.headline)
                    Text(context.state.currentSessionType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if context.state.sessionState == "running" {
                    Text(timerInterval: Date()...context.state.targetDate, countsDown: true)
                        .monospacedDigit()
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                } else {
                    Text(formatTime(context.state.timeRemaining))
                        .monospacedDigit()
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
            }
            
            MultiSegmentProgressView(
                currentProgress: 1.0 - (context.state.timeRemaining / context.state.totalDuration),
                currentCycle: context.state.currentCycleIndex,
                totalCycles: context.state.cyclesBeforeLongBreak,
                currentType: context.state.currentSessionType
            )
            .frame(height: 8)
            
            HStack {
                Button(intent: ResetTimerIntent()) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(intent: ToggleTimerIntent()) {
                    Image(systemName: context.state.sessionState == "running" ? "pause.fill" : "play.fill")
                        .padding(.horizontal, 20)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
                
                Button(intent: SkipTimerIntent()) {
                    Label("Skip", systemImage: "forward.fill")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MultiSegmentProgressView: View {
    let currentProgress: CGFloat
    let currentCycle: Int
    let totalCycles: Int
    let currentType: String
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                let totalSegments = totalCycles * 2
                let segmentWidth = (geometry.size.width - CGFloat(totalSegments - 1) * 2) / CGFloat(totalSegments)
                
                ForEach(0..<totalSegments, id: \.self) { index in
                    let isFocus = index % 2 == 0
                    let cycleIndex = index / 2
                    let isLongBreak = index == totalSegments - 1
                    
                    let isCompleted = isSegmentCompleted(index: index)
                    let isCurrent = isSegmentCurrent(index: index)
                    
                    SegmentShape()
                        .fill(isCompleted ? completedColor(isFocus: isFocus, isLong: isLongBreak) : 
                              isCurrent ? currentColor(isFocus: isFocus, isLong: isLongBreak).opacity(currentProgress) :
                              Color.gray.opacity(0.3))
                        .frame(width: segmentWidth)
                }
            }
        }
    }
    
    private func isSegmentCompleted(index: Int) -> Bool {
        let currentSegmentIndex = getCurrentSegmentIndex()
        return index < currentSegmentIndex
    }
    
    private func isSegmentCurrent(index: Int) -> Bool {
        let currentSegmentIndex = getCurrentSegmentIndex()
        return index == currentSegmentIndex
    }
    
    private func getCurrentSegmentIndex() -> Int {
        // currentCycle is 0-indexed completed cycles? 
        // Let's assume currentCycle is number of focus sessions completed.
        // If currentType == "Focus", we are on the currentCycle-th focus session (which is index currentCycle * 2)
        // If currentType == "Short Break", we are on the break segment after currentCycle-th focus (index currentCycle * 2 + 1)
        // If currentType == "Long Break", we are on the last break segment (index totalCycles * 2 - 1)
        
        if currentType == "Focus" {
            return currentCycle * 2
        } else if currentType == "Short Break" {
            return currentCycle * 2 - 1 // Wait, if we just finished session 1 (currentCycle=1), we are on break index 1.
            // If currentCycle = 1, means 1 focus done. Break segment is index 1.
        } else if currentType == "Long Break" {
            return totalCycles * 2 - 1
        }
        return 0
    }
    
    // Corrected logic:
    // Focus 1 (idx 0), Break 1 (idx 1), Focus 2 (idx 2), Break 2 (idx 3)...
    // If we are in Focus, index = (completedCycles) * 2
    // If we are in Break, index = (completedCycles) * 2 - 1
    
    private func completedColor(isFocus: Bool, isLong: Bool) -> Color {
        if isFocus { return .orange }
        if isLong { return .blue }
        return .green
    }
    
    private func currentColor(isFocus: Bool, isLong: Bool) -> Color {
        if isFocus { return .orange }
        if isLong { return .blue }
        return .green
    }
}

struct SegmentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 2, height: 2))
        return path
    }
}
