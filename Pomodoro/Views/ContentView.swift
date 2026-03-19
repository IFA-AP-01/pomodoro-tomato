import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.xaxis")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
