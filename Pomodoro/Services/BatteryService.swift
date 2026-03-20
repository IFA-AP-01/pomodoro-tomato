import SwiftUI

@Observable
class BatteryService {
    var batteryLevel: Float = 0.0
    var batteryState: UIDevice.BatteryState = .unknown
    var isMonitoring: Bool = false
    
    /// Estimated battery time remaining in minutes (rough estimate)
    var estimatedMinutesRemaining: Int {
        guard batteryLevel > 0 else { return 0 }
        // Rough estimate: full battery ~10 hours for normal use
        let totalMinutesAtFull: Float = 600
        return Int(batteryLevel * totalMinutesAtFull)
    }
    
    var estimatedTimeRemainingText: String {
        let hours = estimatedMinutesRemaining / 60
        let minutes = estimatedMinutesRemaining % 60
        return "\(hours) giờ \(minutes) phút"
    }
    
    var batteryPercentage: Int {
        return Int(batteryLevel * 100)
    }
    
    var isCharging: Bool {
        return batteryState == .charging || batteryState == .full
    }
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryInfo()
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBatteryInfo()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBatteryInfo()
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
    
    private func updateBatteryInfo() {
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }
}
