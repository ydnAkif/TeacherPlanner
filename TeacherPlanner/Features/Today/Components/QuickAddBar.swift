//
//  QuickAddBar.swift
//  TeacherPlanner
//

import SwiftUI

struct QuickAddBar: View {
    @State private var showingAddItem = false
    @State private var showingAddNote = false

    private var today: Date {
        Calendar.current.startOfDay(for: Date())
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { showingAddItem = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Görev")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button(action: { showingAddNote = true }) {
                HStack {
                    Image(systemName: "note.text.badge.plus")
                    Text("Not")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.1))
                .foregroundStyle(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingAddItem) {
            EditPlannerItemView(type: .task, prefillDueDate: today)
        }
        .sheet(isPresented: $showingAddNote) {
            EditPlannerItemView(type: .note, prefillDueDate: today)
        }
    }
}

#Preview {
    QuickAddBar()
}
