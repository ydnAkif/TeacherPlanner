//
//  ScheduleCellView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

struct ScheduleCellView: View {
    let cell: WeeklyCell
    let onTap: () -> Void
    let onDelete: () -> Void

    init(cell: WeeklyCell, onTap: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.cell = cell
        self.onTap = onTap
        self.onDelete = onDelete
    }

    var body: some View {
        Group {
            if let course = cell.course {
                CourseBlockView(course: course, session: cell.session, onDelete: onDelete)
            } else {
                EmptyCellView(onTap: onTap)
            }
        }
        .frame(minHeight: 60)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

/// Ders blok görünümü
struct CourseBlockView: View {
    let course: Course
    let session: ClassSession?
    let onDelete: () -> Void

    init(course: Course, session: ClassSession?, onDelete: @escaping () -> Void) {
        self.course = course
        self.session = session
        self.onDelete = onDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: course.symbolName)
                    .font(.caption)
                Text(course.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)

            if let room = session?.room {
                Label(room, systemImage: "door.left.hand.open")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer()
        }
        .padding(6)
        .background(course.color)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }
}

/// Boş hücre görünümü
struct EmptyCellView: View {
    let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap
    }

    var body: some View {
        VStack {
            Image(systemName: "plus.circle")
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    ScheduleCellView(
        cell: WeeklyCell(
            weekday: 2,
            session: ClassSession(
                weekday: 2,
                periodOrder: 1,
                course: Course(title: "5-C Fen Bilimleri", colorHex: "#FF9500"),
                room: "201"
            )
        ),
        onTap: {}, onDelete: {}
    )
    .frame(width: 100, height: 80)
}
