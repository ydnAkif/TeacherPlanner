import SwiftUI

// MARK: - Result Extension for AppError

extension Result {
    /// Success value'ı al, yoksa default döndür
    func get(or defaultValue: Success) -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return defaultValue
        }
    }

    /// Success value'ı al, yoksa nil döndür
    func getOrNil() -> Success? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Failure value'ı al, yoksa nil döndür
    func getErrorOrNil() -> Failure? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }

    /// Result'ı Optional'a çevir
    func asOptional() -> Success? {
        getOrNil()
    }

    /// Result'ı Void'a çevir (side effects için)
    func asVoid() -> Result<Void, Failure> {
        map { _ in () }
    }

    /// Success durumunda block çalıştır
    @discardableResult
    func onSuccess(_ block: (Success) -> Void) -> Result<Success, Failure> {
        if case .success(let value) = self {
            block(value)
        }
        return self
    }

    /// Failure durumunda block çalıştır
    @discardableResult
    func onFailure(_ block: (Failure) -> Void) -> Result<Success, Failure> {
        if case .failure(let error) = self {
            block(error)
        }
        return self
    }
}

// MARK: - AppError Specific Extensions

extension Result where Failure == AppError {
    /// AppError'dan String error message oluştur
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.errorDescription
        }
    }

    /// AppError recovery suggestion al
    var recoverySuggestion: String? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error.recoverySuggestion
        }
    }
}

// MARK: - View Extensions

/// Standardized error handling view modifier
struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?

    func body(content: Content) -> some View {
        content
            .alert(
                isPresented: Binding(
                    get: { error != nil },
                    set: { if !$0 { error = nil } }
                ), error: error
            ) { _ in
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
