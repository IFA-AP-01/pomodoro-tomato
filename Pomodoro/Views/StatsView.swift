import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(StatsViewModel.self) private var viewModel
    @Environment(SettingsService.self) private var settings
    
    @State private var selectedTab = 0 // 0: Today, 1: Week, 2: Month, 3: Year
    
    // Theme
    private var theme: PomodoroTheme {
        settings.currentTheme
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Title
                Text("DASHBOARD")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.text)
                    .padding(.top, 10)
                
                Picker("Time Range", selection: $selectedTab) {
                    Text("Today").tag(0)
                    Text("Week").tag(1)
                    Text("Month").tag(2)
                    Text("Year").tag(3)
                }
                .pickerStyle(.segmented)
                
                if selectedTab == 0 {
                    todayDashboard
                } else if selectedTab == 1 {
                    weekDashboard
                } else if selectedTab == 2 {
                    monthDashboard
                } else {
                    yearDashboard
                }
                
                // Spacer for TabBar
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
        .background(theme.background.ignoresSafeArea())
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
    }
    
    // MARK: - Dashboards
    
    private var todayDashboard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                goalAchievedCard
                
                VStack(spacing: 16) {
                    focusTimeLoggedCard
                    addTasksCard
                }
            }
            
            lifetimeStatsCard
        }
    }
    
    private var weekDashboard: some View {
        modernChartCard(
            title: "Last 7 Days (Minutes)",
            data: viewModel.last7DaysData,
            isWavy: true
        )
    }
    
    private var monthDashboard: some View {
        modernBarChartCard(
            title: "This Month (Minutes)",
            data: viewModel.thisMonthData
        )
    }
    
    private var yearDashboard: some View {
        modernChartCard(
            title: "This Year (Hours)",
            data: viewModel.thisYearData,
            isWavy: false
        )
    }
    
    // MARK: - Subviews
    
    private var goalAchievedCard: some View {
        let goalSeconds = TimeInterval(settings.dailyFocusGoalMinutes * 60)
        let achievedRatio = goalSeconds > 0 ? min(viewModel.todayFocusSeconds / goalSeconds, 1.0) : 0
        let percentage = Int(achievedRatio * 100)
        
        return VStack {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: achievedRatio)
                    .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("Goal Achieved")
                        .font(.system(size: 8))
                        .foregroundColor(theme.cardSecondaryText)
                    Text("\(percentage)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(theme.cardText)
                }
            }
            .frame(width: 100, height: 100)
            .padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .background(theme.surface)
        .cornerRadius(25)
    }

    private var focusTimeLoggedCard: some View {
        let hoursLogged = viewModel.todayFocusSeconds / 3600.0
        let ratio = min(hoursLogged / 8.0, 1.0) // arbitrary max of 8 hours for circle fullness
        
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 5)
                
                Circle()
                    .trim(from: 0, to: ratio)
                    .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text(String(format: "%.1f\nhrs", hoursLogged))
                    .font(.system(size: 8))
                    .multilineTextAlignment(.center)
                    .foregroundColor(theme.cardText)
            }
            .frame(width: 40, height: 40)
            
            Text("Focus Time\nLogged")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(theme.cardText)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.surface)
        .cornerRadius(20)
    }
    
    private var addTasksCard: some View {
        Button(action: {
            // Add task action
        }) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                Text("Add Tasks")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundColor(theme.cardText)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.accent)
            .cornerRadius(20)
        }
    }
    
    private var lifetimeStatsCard: some View {
        let totalHours = Int(viewModel.totalFocusSeconds) / 3600
        let totalMinutes = (Int(viewModel.totalFocusSeconds) % 3600) / 60
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lifetime Focus")
                    .font(.subheadline)
                    .foregroundColor(theme.cardSecondaryText)
                Text("\(totalHours)h \(totalMinutes)m")
                    .font(.title2.bold())
                    .foregroundColor(theme.cardText)
            }
            Spacer()
            Image(systemName: "medal.fill")
                .font(.largeTitle)
                .foregroundColor(theme.accent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(theme.surface)
        .cornerRadius(20)
    }
    
    private func modernChartCard(title: String, data: [(label: String, value: Double)], isWavy: Bool) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.cardText)
                .padding(.top, 10)
            
            Chart {
                ForEach(data, id: \.label) { item in
                    LineMark(
                        x: .value("Day", item.label),
                        y: .value("Value", item.value)
                    )
                    .interpolationMethod(isWavy ? .catmullRom : .linear)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .foregroundStyle(theme.cardText)
                    
                    AreaMark(
                        x: .value("Day", item.label),
                        y: .value("Value", item.value)
                    )
                    .interpolationMethod(isWavy ? .catmullRom : .linear)
                    .foregroundStyle(
                        LinearGradient(colors: [theme.cardText.opacity(0.3), theme.cardText.opacity(0.0)], startPoint: .top, endPoint: .bottom)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .foregroundStyle(theme.cardSecondaryText)
                        .font(.system(size: 10))
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 180)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(theme.surface)
        .cornerRadius(25)
    }
    
    private func modernBarChartCard(title: String, data: [(label: String, value: Double)]) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(theme.cardText)
                .padding(.top, 10)
            
            Chart {
                ForEach(data, id: \.label) { item in
                    BarMark(
                        x: .value("Day", item.label),
                        y: .value("Value", item.value)
                    )
                    .foregroundStyle(theme.cardText.opacity(0.8))
                    .cornerRadius(2)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    // Only show some labels if there are too many (like 31 days)
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 180)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(theme.surface)
        .cornerRadius(25)
    }
}
