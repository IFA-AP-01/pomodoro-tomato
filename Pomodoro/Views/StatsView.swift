import SwiftUI
import SwiftData
import Charts
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StatsViewModel.self) private var viewModel
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Time Range", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                    Text("Year").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    VStack(spacing: 30) {
                        if selectedTab == 0 {
                            todayView
                        } else if selectedTab == 1 {
                            weekView
                        } else if selectedTab == 2 {
                            monthView
                        } else {
                            yearView
                        }
                        
                        Divider()
                        
                        // Lifetime stats
                        let totalFocusSeconds = viewModel.totalFocusSeconds
                        let totalHours = Int(totalFocusSeconds) / 3600
                        let totalMinutes = (Int(totalFocusSeconds) % 3600) / 60
                        
                        VStack(spacing: 8) {
                            Text("Lifetime Focus")
                                .font(.headline)
                            Text("\(totalHours)h \(totalMinutes)m")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        .padding()
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Statistics")
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }
    
    // MARK: - Today View
    private var todayView: some View {
        VStack {
            let todayFocusSeconds = viewModel.todayFocusSeconds
            
            let goalSeconds = TimeInterval(viewModel.settings.dailyFocusGoalMinutes * 60)
            let remainingSeconds = max(0, goalSeconds - todayFocusSeconds)
            
            let todayMinutes = Int(todayFocusSeconds) / 60
            
            Text("Daily Goal: \(viewModel.settings.dailyFocusGoalMinutes / 60)h")
                .font(.headline)
            
            Chart {
                if todayFocusSeconds > 0 {
                    SectorMark(
                        angle: .value("Focused", todayFocusSeconds),
                        innerRadius: .ratio(0.6),
                        angularInset: 2.0
                    )
                    .foregroundStyle(.orange)
                    .annotation(position: .overlay) {
                        Text("\(Int(todayFocusSeconds / goalSeconds * 100))%")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                    }
                }
                
                if remainingSeconds > 0 {
                    SectorMark(
                        angle: .value("Remaining", remainingSeconds),
                        innerRadius: .ratio(0.6),
                        angularInset: 2.0
                    )
                    .foregroundStyle(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 250)
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    VStack {
                        Text("Today")
                            .font(.callout)
                            .foregroundColor(.secondary)
                        Text("\(todayMinutes)m")
                            .font(.title2.bold())
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Week View
    private var weekView: some View {
        VStack(alignment: .leading) {
            Text("Last 7 Days")
                .font(.headline)
                .padding(.horizontal)
            
            // Mock data for display, in real life we aggregate sessions by day
            let mockData: [(day: String, minutes: Int)] = [
                ("Mon", 120), ("Tue", 90), ("Wed", 150),
                ("Thu", 60), ("Fri", 200), ("Sat", 30), ("Sun", 0)
            ]
            
            Chart {
                ForEach(mockData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(.orange.gradient)
                    .cornerRadius(4)
                }
            }
            .frame(height: 250)
            .padding()
        }
    }
    
    // MARK: - Month View
    private var monthView: some View {
        VStack(alignment: .leading) {
            Text("This Month")
                .font(.headline)
                .padding(.horizontal)
            
            Text("Activity Calendar Placeholder")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Just using BarMark for month overview as fallback
            let mockData = (1...30).map { (day: "\($0)", minutes: Int.random(in: 0...180)) }
            
            Chart {
                ForEach(mockData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Minutes", item.minutes)
                    )
                    .foregroundStyle(.orange.gradient)
                }
            }
            .frame(height: 200)
            .padding()
        }
    }
    
    // MARK: - Year View
    private var yearView: some View {
        VStack(alignment: .leading) {
            Text("This Year")
                .font(.headline)
                .padding(.horizontal)
            
            let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            let mockData = months.map { (month: $0, hours: Int.random(in: 20...100)) }
            
            Chart {
                ForEach(mockData, id: \.month) { item in
                    LineMark(
                        x: .value("Month", item.month),
                        y: .value("Hours", item.hours)
                    )
                    .symbol(Circle())
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Month", item.month),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(.orange.opacity(0.1).gradient)
                }
            }
            .frame(height: 250)
            .padding()
            
            Text("Heatmap Placeholder")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview {
    let settings = SettingsService()
    StatsView()
        .environment(StatsViewModel(settings: settings))
        .modelContainer(for: PomodoroSession.self, inMemory: true)
}
