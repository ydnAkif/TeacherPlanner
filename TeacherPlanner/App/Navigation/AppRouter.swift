import SwiftUI

/// Uygulamanın navigasyon durumunu yöneten merkezi router.
@MainActor
@Observable
final class AppRouter {
    enum Tab: Int, CaseIterable, Hashable {
        case today = 0
        case schedule = 1
        case courses = 2
        case settings = 3

        var title: String {
            switch self {
            case .today: return "Bugün"
            case .schedule: return "Program"
            case .courses: return "Dersler"
            case .settings: return "Ayarlar"
            }
        }

        var icon: String {
            switch self {
            case .today: return "sun.max"
            case .schedule: return "calendar"
            case .courses: return "book"
            case .settings: return "gearshape"
            }
        }
    }

    var selectedTab: Tab = .today

    func navigate(to tab: Tab) {
        selectedTab = tab
    }
}
