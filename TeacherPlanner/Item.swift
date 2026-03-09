//
//  Item.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
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
