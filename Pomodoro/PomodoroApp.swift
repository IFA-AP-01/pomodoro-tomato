import SwiftUI
import SwiftData

@main
struct PomodoroApp: App {
    @State private var settingsService = SettingsService()
    @State private var timerEngine = TimerEngine()
    @State private var timerViewModel: TimerViewModel
    @State private var statsViewModel: StatsViewModel
    @State private var settingsViewModel: SettingsViewModel
    @State private var batteryService = BatteryService()
    
    init() {
        let settings = SettingsService()
        let engine = TimerEngine()
        self._settingsService = State(initialValue: settings)
        self._timerEngine = State(initialValue: engine)
        self._timerViewModel = State(initialValue: TimerViewModel(timerEngine: engine, settings: settings))
        self._statsViewModel = State(initialValue: StatsViewModel(settings: settings))
        self._settingsViewModel = State(initialValue: SettingsViewModel(settingsService: settings, timerEngine: engine))
        self._batteryService = State(initialValue: BatteryService())
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PomodoroSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settingsService)
                .environment(timerEngine)
                .environment(timerViewModel)
                .environment(statsViewModel)
                .environment(settingsViewModel)
                .environment(batteryService)
                .onAppear {
                    let repository = LocalSessionRepository(modelContext: sharedModelContainer.mainContext)
                    timerEngine.sessionRepository = repository
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
