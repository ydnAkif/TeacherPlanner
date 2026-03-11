//
//  CardView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    let onTap: (() -> Void)?
    
    init(onTap: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onTap = onTap
    }
    
    var body: some View {
        content
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .onTapGesture {
                onTap?()
            }
    }
}

#Preview {
    VStack(spacing: 16) {
        CardView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Kart Başlığı")
                    .font(.headline)
                Text("Kart içeriği buraya gelecek")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding()
}
