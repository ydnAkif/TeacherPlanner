//
//  SemesterPresetLoader.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation
import SwiftData

/// Dönem preset yükleyici
/// MEB ve diğer presetleri yüklemeye yarar
struct SemesterPresetLoader {

    /// Mevcut preset tipleri
    enum PresetType: String, CaseIterable {
        case meb2025_2026 = "MEB 2025-2026"
        case meb2026_2027 = "MEB 2026-2027"
        case university = "Üniversite (Özel)"
    }

    /// Preset bilgileri
    struct PresetInfo {
        let type: PresetType
        let description: String
        let startDate: Date?
        let endDate: Date?
    }

    /// Tüm mevcut presetleri listeler
    static func availablePresets() -> [PresetInfo] {
        let calendar = Calendar.current

        return [
            PresetInfo(
                type: .meb2025_2026,
                description: "MEB 2025-2026 Eğitim Yılı (Güz: Eyl 2025 - Oca 2026)",
                startDate: calendar.date(from: DateComponents(year: 2025, month: 9, day: 8)),
                endDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 23))
            ),
            PresetInfo(
                type: .meb2026_2027,
                description: "MEB 2026-2027 Eğitim Yılı (Tahmini)",
                startDate: calendar.date(from: DateComponents(year: 2026, month: 9, day: 7)),
                endDate: calendar.date(from: DateComponents(year: 2027, month: 1, day: 22))
            ),
            PresetInfo(
                type: .university,
                description: "Üniversite Akademik Takvimi (Özel)",
                startDate: nil,
                endDate: nil
            ),
        ]
    }

    /// Preset'i semester'a uygular
    /// - Parameters:
    ///   - type: Uygulanacak preset tipi
    ///   - semester: Hedef semester
    ///   - context: Model context
    static func apply(preset type: PresetType, to semester: Semester, in context: ModelContext) {
        switch type {
        case .meb2025_2026:
            MEBPresetProvider.applyMEBPreset(to: semester, in: context)

        case .meb2026_2027:
            // 2026-2027 için benzer mantık (gelecekte genişletilebilir)
            break

        case .university:
            // Üniversite preset'i yok, kullanıcı manuel ekler
            break
        }
    }

    /// Preset'ten semester oluşturur
    /// - Parameters:
    ///   - type: Preset tipi
    ///   - context: Model context
    /// - Returns: Oluşturulan semester
    static func createSemester(from type: PresetType, in context: ModelContext) -> Semester? {
        let presetInfo = availablePresets().first { $0.type == type }

        guard let startDate = presetInfo?.startDate,
            let endDate = presetInfo?.endDate
        else {
            return nil
        }

        let semester = Semester(
            name: type.rawValue,
            startDate: startDate,
            endDate: endDate,
            weekendRule: .saturdaySunday,
            isActive: true
        )

        context.insert(semester)

        // Preset'i uygula
        apply(preset: type, to: semester, in: context)

        return semester
    }
}
