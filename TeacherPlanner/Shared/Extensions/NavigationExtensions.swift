//
//  NavigationExtensions.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

extension View {
    func hideBackButton() -> some View {
        self.navigationBarBackButtonHidden(true)
    }
}

enum AppRoute: Hashable {
    case today
    case schedule
    case courses
    case courseDetail(UUID)
    case plannerItems
    case semester
    case settings
}
