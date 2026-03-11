import Foundation

/// Bildirim işlemleri için Use Case uygulaması
@MainActor
final class NotificationUseCase: NotificationUseCaseProtocol {
    private let scheduler: any NotificationScheduling
    
    init(scheduler: any NotificationScheduling) {
        self.scheduler = scheduler
    }
    
    func rescheduleNotifications() async {
        await scheduler.rescheduleAllNotifications()
    }
    
    func updateReminderSettings(enabled: Bool, minutesBefore: Int) async {
        if enabled {
            await scheduler.rescheduleAllNotifications()
        } else {
            await scheduler.cancelAllNotifications()
        }
    }
}
