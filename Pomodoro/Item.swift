//
//  Item.swift
//  Pomodoro
//
//  Created by Huy Huỳnh on 19/3/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
