import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel
    @State private var showingResetAlert = false
    
    var body: some View {
        @Bindable var settings = viewModel.settingsService
        let theme = settings.currentTheme
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    sectionHeader("Focus Timer", theme: theme)
                    cardContainer(theme: theme) { focusTimerCardContent }
                    
                    sectionHeader("Current Task", theme: theme)
                    cardContainer(theme: theme) { taskCardContent }
                    
                    sectionHeader("Alerts & Automations", theme: theme)
                    cardContainer(theme: theme) { alertsCardContent }
                    
                    sectionHeader("Appearance", theme: theme)
                    cardContainer(theme: theme) { appearanceCardContent }
                }
                
                VStack(spacing: 16) {
                    Button(action: { viewModel.applySettingsChanges() }) {
                        Text("Save Settings")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(theme.text)
                            .cornerRadius(20)
                    }
                    
                    Button(action: { showingResetAlert = true }) {
                        Text("HARD RESET")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 10)
                
                Color.clear.frame(height: 100)
            }
            .padding(20)
        }
        .background(theme.background.ignoresSafeArea())
        .alert("Hard Reset Timer?", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) { viewModel.forceResetTimer() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will stop your current session and reset all progress.")
        }
    }
    
    // MARK: - Components
    
    private func cardContainer<Content: View>(theme: PomodoroTheme, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(20)
            .background(theme.surface)
            .cornerRadius(32)
            .shadow(color: Color.black.opacity(theme.id == "default" ? 0.05 : 0), radius: 10, y: 5)
    }
    
    private func sectionHeader(_ text: String, theme: PomodoroTheme) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(theme.text)
    }
    
    private func innerPillButton<Content: View>(title: String, value: String, theme: PomodoroTheme, @ViewBuilder pickerContent: () -> Content) -> some View {
        Menu {
            pickerContent()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 8, weight: .bold))
                    .tracking(0.5)
                    .foregroundColor(theme.cardSecondaryText)
                    .lineLimit(1)
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(theme.cardText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(theme.cardElementBackground)
            .cornerRadius(22)
        }
    }
    
    private var focusTimerCardContent: some View {
        @Bindable var settings = viewModel.settingsService
        let theme = settings.currentTheme
        return VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack(alignment: .bottom) {
                    Text("FOCUS DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(theme.cardSecondaryText)
                    Spacer()
                    Text("\(Int(settings.focusTimeMinutes)):00")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.accent)
                }
                
                CustomSlider(
                    value: Binding(
                        get: { Double(settings.focusTimeMinutes) },
                        set: { settings.focusTimeMinutes = Int($0) }
                    ),
                    bounds: 1...120,
                    thumbColor: theme.accent,
                    trackColor: theme.cardElementBackground
                )
            }
            
            HStack(spacing: 12) {
                innerPillButton(title: "SHORT BREAK", value: "\(settings.shortBreakMinutes) min", theme: theme) {
                    Picker("Short Break", selection: $settings.shortBreakMinutes) {
                        ForEach([3, 5, 10, 15], id: \.self) { Text("\($0) min").tag($0) }
                    }
                }
                innerPillButton(title: "LONG BREAK", value: "\(settings.longBreakMinutes) min", theme: theme) {
                    Picker("Long Break", selection: $settings.longBreakMinutes) {
                        ForEach([10, 15, 20, 30], id: \.self) { Text("\($0) min").tag($0) }
                    }
                }
            }
            
            HStack(spacing: 12) {
                innerPillButton(title: "CYCLES", value: "\(settings.cyclesBeforeLongBreak)", theme: theme) {
                    Picker("Cycles", selection: $settings.cyclesBeforeLongBreak) {
                        ForEach(1...10, id: \.self) { Text("\($0) cycles").tag($0) }
                    }
                }
                innerPillButton(title: "DAILY GOAL", value: "\(settings.dailyFocusGoalMinutes / 60) hr", theme: theme) {
                    Picker("Daily Goal", selection: $settings.dailyFocusGoalMinutes) {
                        ForEach([60, 120, 180, 240, 300], id: \.self) { Text("\($0 / 60) hr").tag($0) }
                    }
                }
            }
        }
    }
    
    private var taskCardContent: some View {
        @Bindable var settings = viewModel.settingsService
        let theme = settings.currentTheme
        return VStack(spacing: 12) {
            TextField("Task Name", text: $settings.currentTaskName)
                .font(.system(size: 14, weight: .medium))
                .padding()
                .background(theme.cardElementBackground)
                .cornerRadius(18)
                .foregroundColor(theme.cardText)
            
            TextField("Topic / Description", text: $settings.currentTaskTopic)
                .font(.system(size: 14, weight: .medium))
                .padding()
                .background(theme.cardElementBackground)
                .cornerRadius(18)
                .foregroundColor(theme.cardText)
        }
    }
    
    private var alertsCardContent: some View {
        @Bindable var settings = viewModel.settingsService
        let theme = settings.currentTheme
        return VStack(spacing: 24) {
            Toggle(isOn: $settings.autoStartNext) {
                HStack(spacing: 14) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.cardSecondaryText)
                    Text("Auto-Start Next")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.cardText)
                }
            }
            .tint(theme.accent)
            
            Toggle(isOn: $settings.enableInAppAOD) {
                HStack(spacing: 14) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14))
                        .foregroundColor(theme.cardSecondaryText)
                    Text("Enable In-App AOD")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.cardText)
                }
            }
            .tint(theme.accent)
        }
    }
    
    private var appearanceCardContent: some View {
        @Bindable var settings = viewModel.settingsService
        let theme = settings.currentTheme
        let isDark = settings.selectedThemeID == "dark"
        
        return HStack(spacing: 0) {
            Button(action: { settings.selectedThemeID = "default" }) {
                appearanceButton(title: "LIGHT", icon: "sun.max.fill", isSelected: !isDark, theme: theme)
            }
            Button(action: { settings.selectedThemeID = "dark" }) {
                appearanceButton(title: "DARK", icon: "moon.fill", isSelected: isDark, theme: theme)
            }
        }
        .padding(6)
        .background(theme.cardElementBackground)
        .cornerRadius(30)
    }
    
    private func appearanceButton(title: String, icon: String, isSelected: Bool, theme: PomodoroTheme) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
        }
        .foregroundColor(isSelected ? theme.accent : theme.cardSecondaryText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(isSelected ? (theme.id == "dark" ? Color(white: 0.2) : .white) : Color.clear)
        .cornerRadius(24)
        .shadow(color: .black.opacity(isSelected && theme.id == "default" ? 0.1 : 0), radius: 4, y: 2)
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var bounds: ClosedRange<Double>
    var thumbColor: Color
    var trackColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(trackColor)
                    .frame(height: 4)
                    .cornerRadius(2)
                
                Circle()
                    .fill(thumbColor)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.1), radius: 2)
                    .offset(x: thumbOffset(in: geometry.size.width))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                updateValue(with: gesture.location.x, in: geometry.size.width)
                            }
                    )
            }
        }
        .frame(height: 20)
    }
    
    private func thumbOffset(in width: CGFloat) -> CGFloat {
        let range = bounds.upperBound - bounds.lowerBound
        let percentage = (value - bounds.lowerBound) / (range > 0 ? range : 1)
        return CGFloat(percentage) * (width - 20)
    }
    
    private func updateValue(with x: CGFloat, in width: CGFloat) {
        let percentage = max(0, min(1, x / width))
        let range = bounds.upperBound - bounds.lowerBound
        value = bounds.lowerBound + (percentage * range)
    }
}
