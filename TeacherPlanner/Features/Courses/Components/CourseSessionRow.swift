//
//  CourseSessionRow.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

struct CourseSessionRow: View {
    let session: ClassSession
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.weekdayEnum?.displayName ?? "Bilinmiyor")
                    .font(.body)
                    .fontWeight(.medium)
                if let period = session.period {
                    Text("\(period.startTimeString)-\(period.endTimeString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, alignment: .leading)
            
            Rectangle()
                .fill(AppColors.secondary.opacity(0.3))
                .frame(width: 2, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                if let period = session.period {
                    Text("\(period.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let room = session.room {
                    Label("Oda: \(room)", systemImage: "door.left.hand.open")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let notes = session.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CourseSessionRow(
            session: ClassSession(
                weekday: 2,
                periodOrder: 1,
                course: Course(title: "5-C Fen"),
                room: "201",
                notes: "Laboratuvar"
            )
        )
    }
}
