import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var viewModel
    @AppStorage("forceDarkMode") private var forceDarkMode = false
    
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Timer Durations")) {
                    Stepper("Focus Time: \(viewModel.settingsService.focusTimeMinutes) min", value: Bindable(viewModel.settingsService).focusTimeMinutes, in: 1...120)
                        .onChange(of: viewModel.settingsService.focusTimeMinutes) { viewModel.applySettingsChanges() }
                    
                    Stepper("Short Break: \(viewModel.settingsService.shortBreakMinutes) min", value: Bindable(viewModel.settingsService).shortBreakMinutes, in: 1...30)
                        .onChange(of: viewModel.settingsService.shortBreakMinutes) { viewModel.applySettingsChanges() }
                    
                    Stepper("Long Break: \(viewModel.settingsService.longBreakMinutes) min", value: Bindable(viewModel.settingsService).longBreakMinutes, in: 5...60)
                        .onChange(of: viewModel.settingsService.longBreakMinutes) { viewModel.applySettingsChanges() }
                    
                    Stepper("Cycles before Long Break: \(viewModel.settingsService.cyclesBeforeLongBreak)", value: Bindable(viewModel.settingsService).cyclesBeforeLongBreak, in: 1...10)
                }
                
                Section(header: Text("Automation")) {
                    Toggle("Auto-start Next Session", isOn: Bindable(viewModel.settingsService).autoStartNext)
                }
                
                Section(header: Text("Appearance")) {
                    Toggle("Force Dark Mode", isOn: Bindable(viewModel.settingsService).forceDarkMode)
                        .onChange(of: viewModel.settingsService.forceDarkMode) { _, newValue in
                            forceDarkMode = newValue
                        }
                    Toggle("Enable In-App AOD", isOn: Bindable(viewModel.settingsService).enableInAppAOD)
                }
                
                Section(header: Text("Goal")) {
                    Stepper("Daily Focus Goal: \(viewModel.settingsService.dailyFocusGoalMinutes / 60) hours", value: Bindable(viewModel.settingsService).dailyFocusGoalMinutes, in: 60...600, step: 60)
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showingResetAlert = true
                    }) {
                        Text("Hard Reset Timer")
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Hard Reset", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    viewModel.forceResetTimer()
                }
            } message: {
                Text("This will cancel your current session and start over.")
            }
        }
    }
}

#Preview {
    let settings = SettingsService()
    let engine = TimerEngine()
    SettingsView()
        .environment(SettingsViewModel(settingsService: settings, timerEngine: engine))
}
