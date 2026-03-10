//
//  CourseRow.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Ders listesi satırı
struct CourseRow: View {
    let course: Course

    var body: some View {
        HStack(spacing: 12) {
            // Ders rengi ve ikon
            ZStack {
                Circle()
                    .fill(course.color)
                    .frame(width: 40, height: 40)

                Image(systemName: course.symbolName)
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            // Ders bilgisi
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.body)
                    .fontWeight(.medium)

                if let notes = course.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Session sayısı
            Label("\(course.sessions.count)", systemImage: "calendar")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CourseRow(
            course: Course(
                title: "5-C Fen Bilimleri",
                colorHex: "#FF9500",
                symbolName: "flask.fill",
                notes: "Deney günleri: Çarşamba"
            )
        )

        CourseRow(
            course: Course(
                title: "6-A Matematik",
                colorHex: "#007AFF",
                symbolName: "number.circle.fill"
            )
        )
    }
}
