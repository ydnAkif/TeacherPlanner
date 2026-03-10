//
//  CourseHeaderCard.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

/// Ders detay header kartı
struct CourseHeaderCard: View {
    let course: Course

    var body: some View {
        VStack(spacing: 16) {
            // İkon ve renk
            ZStack {
                Circle()
                    .fill(course.color)
                    .frame(width: 80, height: 80)

                Image(systemName: course.symbolName)
                    .font(.title)
                    .foregroundStyle(.white)
            }

            // Başlık
            Text(course.title)
                .font(.title2)
                .fontWeight(.semibold)

            // Session ve item sayısı
            HStack(spacing: 24) {
                VStack {
                    Text("\(course.sessions.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Ders")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()
                    .frame(height: 32)

                VStack {
                    Text("\(course.plannerItems.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Görev")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(course.color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    CourseHeaderCard(
        course: Course(
            title: "5-C Fen Bilimleri",
            colorHex: "#FF9500",
            symbolName: "flask.fill"
        )
    )
    .padding()
}
