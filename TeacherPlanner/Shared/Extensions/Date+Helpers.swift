import Foundation

extension DateFormatter {
    /// Reusable formatter for short time (e.g., "HH:mm")
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    /// Reusable formatter for dates (e.g., "12 Oct 2025")
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
    
    /// Reusable formatter for long dates
    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        return formatter
    }()
}

extension Date {
    /// Formats the date using the short time style
    var shortTimeString: String {
        DateFormatter.shortTime.string(from: self)
    }
    
    /// Formats the date using the medium date style
    var mediumDateString: String {
        DateFormatter.mediumDate.string(from: self)
    }
    
    /// Formats the date using the long date style
    var longDateString: String {
        DateFormatter.longDate.string(from: self)
    }
    
    /// Returns a new date with the specified hour and minute, using the current calendar.
    func setting(hour: Int, minute: Int) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)
    }
    
    /// Checks if the date falls on the same day as another date.
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
}
