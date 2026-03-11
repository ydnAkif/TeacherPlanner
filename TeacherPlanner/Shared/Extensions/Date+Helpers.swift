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
    
    /// Reusable formatter for full dates (e.g., "Monday, March 11, 2026")
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    /// ISO 8601 style date formatter (yyyy-MM-dd)
    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
}

extension Date {
    /// Formats the date using the short time style
    var shortTimeString: String {
        DateFormatter.shortTime.string(from: self)
    }
    
    /// Alias: time string in short style
    var timeString: String {
        shortTimeString
    }
    
    /// Formats the date using the medium date style
    var mediumDateString: String {
        DateFormatter.mediumDate.string(from: self)
    }
    
    /// Alias: short date string (uses medium style)
    var shortDateString: String {
        mediumDateString
    }
    
    /// Formats the date using the long date style
    var longDateString: String {
        DateFormatter.longDate.string(from: self)
    }
    
    /// Formats the date using the full date style
    var fullDateString: String {
        DateFormatter.fullDate.string(from: self)
    }
    
    /// Formats the date using the ISO date style (yyyy-MM-dd)
    var isoDateString: String {
        DateFormatter.isoDate.string(from: self)
    }
    
    /// Returns a new date with the specified hour and minute, using the current calendar.
    func setting(hour: Int, minute: Int) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self)
    }
    
    /// Checks if the date falls on the same day as another date.
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }
    
    /// Formats the date using a given date style (no time component).
    func formatted(_ style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Number of days from given date to this date (self - date).
    func days(from date: Date) -> Int {
        Calendar.current.daysBetween(date, and: self)
    }
}
