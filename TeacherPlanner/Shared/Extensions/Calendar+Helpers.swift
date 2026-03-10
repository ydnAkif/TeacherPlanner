import Foundation

extension Calendar {
    /// Checks if a given date is considered a weekend according to the active calendar rules.
    func isDateInWeekendStrict(_ date: Date) -> Bool {
        return self.isDateInWeekend(date)
    }
    
    /// Returns the start of the week for a given date.
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    /// Calculates the number of days between two dates, ignoring time properties.
    func daysBetween(_ start: Date, and end: Date) -> Int {
        let startDay = startOfDay(for: start)
        let endDay = startOfDay(for: end)
        let components = dateComponents([.day], from: startDay, to: endDay)
        return components.day ?? 0
    }
}
