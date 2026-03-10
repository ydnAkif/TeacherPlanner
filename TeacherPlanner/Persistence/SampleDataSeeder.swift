//
//  SampleDataSeeder.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

struct SampleDataSeeder {
    static func seed(_ container: ModelContainer) throws {
        let context = container.mainContext

        // Mevcut veri var mı kontrol et
        let existingSemesters = try context.fetch(FetchDescriptor<Semester>())
        guard existingSemesters.isEmpty else { return }

        // 2025-2026 Eğitim Yılı Güz Dönemi (Örnek: 8 Eylül 2025 - 23 Ocak 2026)
        let calendar = Calendar.current
        let semester = Semester(
            name: "2025-2026 Güz Dönemi",
            startDate: calendar.date(from: DateComponents(year: 2025, month: 9, day: 8))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 23))!,
            weekendRule: .saturdaySunday,
            isActive: true
        )
        context.insert(semester)

        // Dersler
        let course1 = Course(
            title: "5-C Fen Bilimleri",
            colorHex: "#FF9500",
            symbolName: "flask.fill",
            notes: "Deney günleri: Çarşamba"
        )
        context.insert(course1)

        let course2 = Course(
            title: "6-A Fen Bilimleri",
            colorHex: "#007AFF",
            symbolName: "atom",
            notes: "Proje ağırlıklı"
        )
        context.insert(course2)

        let course3 = Course(
            title: "7-B Fen Bilimleri",
            colorHex: "#34C759",
            symbolName: "leaf.fill",
            notes: "Doğa bilimleri odaklı"
        )
        context.insert(course3)

        // Ders Saatleri (Period Definitions)
        // 1. Ders: 08:40 - 09:20
        let period1 = PeriodDefinition(
            title: "1. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 8, minute: 40))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 9, minute: 20))!,
            orderIndex: 1
        )
        context.insert(period1)

        // 2. Ders: 09:30 - 10:10
        let period2 = PeriodDefinition(
            title: "2. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 9, minute: 30))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 10, minute: 10))!,
            orderIndex: 2
        )
        context.insert(period2)

        // 3. Ders: 10:25 - 11:05
        let period3 = PeriodDefinition(
            title: "3. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 10, minute: 25))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 11, minute: 5))!,
            orderIndex: 3
        )
        context.insert(period3)

        // 4. Ders: 11:15 - 11:55
        let period4 = PeriodDefinition(
            title: "4. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 11, minute: 15))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 11, minute: 55))!,
            orderIndex: 4
        )
        context.insert(period4)

        // 5. Ders: 13:00 - 13:40
        let period5 = PeriodDefinition(
            title: "5. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 13, minute: 0))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 13, minute: 40))!,
            orderIndex: 5
        )
        context.insert(period5)

        // 6. Ders: 13:50 - 14:30
        let period6 = PeriodDefinition(
            title: "6. Ders",
            startTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 13, minute: 50))!,
            endTime: calendar.date(
                from: DateComponents(year: 2000, month: 1, day: 1, hour: 14, minute: 30))!,
            orderIndex: 6
        )
        context.insert(period6)

        // Haftalık Program (Class Sessions)
        // Pazartesi
        let session1 = ClassSession(
            weekday: 2,  // Pazartesi
            periodOrder: 1,
            course: course1,
            period: period1,
            room: "201",
            notes: "Laboratuvar haftası"
        )
        context.insert(session1)

        let session2 = ClassSession(
            weekday: 2,
            periodOrder: 3,
            course: course2,
            period: period3,
            room: "201"
        )
        context.insert(session2)

        // Salı
        let session3 = ClassSession(
            weekday: 3,  // Salı
            periodOrder: 2,
            course: course3,
            period: period2,
            room: "202"
        )
        context.insert(session3)

        let session4 = ClassSession(
            weekday: 3,
            periodOrder: 4,
            course: course1,
            period: period4,
            room: "Lab-1"
        )
        context.insert(session4)

        // Çarşamba
        let session5 = ClassSession(
            weekday: 4,  // Çarşamba
            periodOrder: 1,
            course: course2,
            period: period1,
            room: "201"
        )
        context.insert(session5)

        let session6 = ClassSession(
            weekday: 4,
            periodOrder: 5,
            course: course3,
            period: period5,
            room: "202"
        )
        context.insert(session6)

        // Perşembe
        let session7 = ClassSession(
            weekday: 5,  // Perşembe
            periodOrder: 2,
            course: course1,
            period: period2,
            room: "201"
        )
        context.insert(session7)

        let session8 = ClassSession(
            weekday: 5,
            periodOrder: 3,
            course: course3,
            period: period3,
            room: "202"
        )
        context.insert(session8)

        // Cuma
        let session9 = ClassSession(
            weekday: 6,  // Cuma
            periodOrder: 1,
            course: course2,
            period: period1,
            room: "201"
        )
        context.insert(session9)

        let session10 = ClassSession(
            weekday: 6,
            periodOrder: 4,
            course: course1,
            period: period4,
            room: "201",
            notes: "Hafta sonu ödevi ver"
        )
        context.insert(session10)

        // Planner Items (Örnek görevler)
        let item1 = PlannerItem(
            title: "5-C Deney föyü hazırla",
            details: "Asit-baz deneyi için malzemeleri kontrol et",
            type: .task,
            dueDate: calendar.date(byAdding: .day, value: 2, to: Date()),
            priority: 1,
            course: course1
        )
        context.insert(item1)

        let item2 = PlannerItem(
            title: "6-A Proje konuları",
            details: "Öğrencilere proje konularını dağıt",
            type: .reminder,
            dueDate: calendar.date(byAdding: .day, value: 5, to: Date()),
            priority: 2,
            course: course2
        )
        context.insert(item2)

        let item3 = PlannerItem(
            title: "Zümre toplantısı notları",
            details:
                "Geçen toplantıda alınan kararlar:\n- Deney sayısı artırılacak\n- Ortak sınav tarihi belirlenecek",
            type: .note,
            priority: 3
        )
        context.insert(item3)

        // Kaydet
        try context.save()
    }
}
