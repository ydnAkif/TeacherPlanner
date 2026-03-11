import Foundation

extension Calendar {
    /// Checks if a given date is considered a weekend according to the active calendar rules.
    func isWeekend(_ date: Date) -> Bool {
        isDateInWeekend(date)
    }
    
    /// Checks if a given date is considered a weekday.
    func isWeekday(_ date: Date) -> Bool {
        !isDateInWeekend(date)
    }
    
    /// Returns the start of the week for a given date.
    func startOfWeek(_ date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    /// Backwards-compatible name
    func startOfWeek(for date: Date) -> Date {
        startOfWeek(date)
    }
    
    /// Calculates the number of days between two dates, ignoring time properties.
    func daysBetween(_ start: Date, and end: Date) -> Int {
        let startDay = startOfDay(for: start)
        let endDay = startOfDay(for: end)
        let components = dateComponents([.day], from: startDay, to: endDay)
        return components.day ?? 0
    }
    
    /// Returns the end of the week (startOfWeek + 6 days) for a given date.
    func endOfWeek(_ date: Date) -> Date {
        let start = startOfWeek(date)
        return self.date(byAdding: .day, value: 6, to: start) ?? start
    }
}
