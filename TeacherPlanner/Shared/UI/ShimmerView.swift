//
//  ShimmerView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    colors: [.black.opacity(0.3), .black, .black.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 200
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct SkeletonRect: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(
        width: CGFloat? = nil, height: CGFloat,
        cornerRadius: CGFloat = AppSpacing.cornerRadiusMedium
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Rectangle()
            .fill(SwiftUI.Color.gray.opacity(0.1))
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shimmer()
    }
}

struct SkeletonText: View {
    let width: CGFloat?
    let height: CGFloat
    let lines: Int

    init(width: CGFloat? = nil, height: CGFloat = 16, lines: Int = 1) {
        self.width = width
        self.height = height
        self.lines = lines
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            ForEach(0..<lines, id: \.self) { index in
                SkeletonRect(
                    width: index == lines - 1 && lines > 1 ? width.map { $0 * 0.6 } : width,
                    height: height,
                    cornerRadius: AppSpacing.cornerRadiusSmall
                )
            }
        }
    }
}

struct SkeletonCircle: View {
    let diameter: CGFloat

    var body: some View {
        Circle()
            .fill(SwiftUI.Color.gray.opacity(0.1))
            .frame(width: diameter, height: diameter)
            .shimmer()
    }
}

#Preview {
    VStack(spacing: AppSpacing.medium) {
        SkeletonText(width: 200, height: 24, lines: 1)
        SkeletonText(width: nil, height: 16, lines: 3)
        HStack(spacing: AppSpacing.small) {
            SkeletonCircle(diameter: 40)
            VStack(alignment: .leading, spacing: 4) {
                SkeletonText(width: 150, height: 16)
                SkeletonText(width: 100, height: 12)
            }
        }
    }
    .padding()
}
