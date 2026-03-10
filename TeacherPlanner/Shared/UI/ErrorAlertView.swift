//
//  ErrorAlertView.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?
    let onRetry: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: .constant(error != nil)) {
                Alert(
                    title: Text(error?.errorDescription ?? "Hata"),
                    message: Text(error?.recoverySuggestion ?? ""),
                    dismissButton: .default(Text("Tamam")) {
                        error = nil
                    }
                )
            }
    }
}

extension View {
    func errorAlert(error: Binding<AppError?>, onRetry: (() -> Void)? = nil) -> some View {
        self.modifier(ErrorAlertModifier(error: error, onRetry: onRetry))
    }
}

#Preview {
    Text("Preview")
        .errorAlert(error: .constant(.dataNotFound))
}
