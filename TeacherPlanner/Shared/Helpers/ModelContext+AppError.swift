import Foundation
import SwiftData

extension ModelContext {
    @discardableResult
    func saveResult(
        _ failureMessage: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> Result<Void, AppError> {
        do {
            try save()
            return .success(())
        } catch {
            AppLogger.error(error, message: failureMessage, file: file, function: function, line: line)
            return .failure(.dataSaveFailed(error.localizedDescription))
        }
    }

    @discardableResult
    func fetchResult<T>(
        _ descriptor: FetchDescriptor<T>,
        failureMessage: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) -> Result<[T], AppError> {
        do {
            return .success(try fetch(descriptor))
        } catch {
            AppLogger.error(error, message: failureMessage, file: file, function: function, line: line)
            return .failure(.dataLoadFailed(error.localizedDescription))
        }
    }
}

