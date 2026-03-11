import SwiftUI

/// Uygulamanın navigasyon durumunu yöneten merkezi router.
@MainActor
@Observable
final class AppRouter {
    enum Tab: Int, CaseIterable, Hashable {
        case today = 0
        case schedule = 1
        case courses = 2
        case planner = 3
        case semester = 4
        case settings = 5
        
        var title: String {
            switch self {
            case .today: return "Today"
            case .schedule: return "Schedule"
            case .courses: return "Courses"
            case .planner: return "Planner Items"
            case .semester: return "Semester"
            case .settings: return "Settings"
            }
        }
        
        var icon: String {
            switch self {
            case .today: return "sun.max"
            case .schedule: return "calendar"
            case .courses: return "book"
            case .planner: return "checklist"
            case .semester: return "graduationcap"
            case .settings: return "gearshape"
            }
        }
    }
    
    var selectedTab: Tab = .today
    
    func navigate(to tab: Tab) {
        selectedTab = tab
    }
}
