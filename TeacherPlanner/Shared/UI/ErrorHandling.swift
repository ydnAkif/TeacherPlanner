import SwiftUI

/// Standardized error handling view modifier
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?
    
    func body(content: Content) -> some View {
        content
            .alert(isPresented: Binding(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            ), error: error) { _ in
                Button("Tamam") {
                    error = nil
                }
            } message: { error in
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                }
            }
    }
}

extension View {
    /// Adds a standardized error alert to the view
    func errorAlert(error: Binding<AppError?>) -> some View {
        self.modifier(ErrorAlertModifier(error: error))
    }
}
