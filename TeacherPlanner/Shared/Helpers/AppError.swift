//
//  AppError.swift
//  TeacherPlanner
//
//  Created by Akif AYDIN on 9.03.2026.
//

import Foundation

enum AppError: LocalizedError {
    case dataNotFound
    case dataLoadFailed(String)
    case dataSaveFailed(String)
    case dataDeleteFailed(String)
    case validationFailed(String)
    case invalidFormat(field: String)
    case requiredFieldMissing(field: String)
    case networkUnavailable
    case requestFailed(String)
    case timeout
    case permissionDenied(String)
    case unknown(Error?)
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound: return "Veri bulunamadı"
        case .dataLoadFailed(let message): return "Veri yüklenemedi: \(message)"
        case .dataSaveFailed(let message): return "Veri kaydedilemedi: \(message)"
        case .dataDeleteFailed(let message): return "Veri silinemedi: \(message)"
        case .validationFailed(let message): return "Doğrulama hatası: \(message)"
        case .invalidFormat(let field): return "\(field) formatı geçersiz"
        case .requiredFieldMissing(let field): return "\(field) alanı zorunlu"
        case .networkUnavailable: return "Ağ bağlantısı yok"
        case .requestFailed(let message): return "İstek başarısız: \(message)"
        case .timeout: return "İstek zaman aşımına uğradı"
        case .permissionDenied(let permission): return "\(permission) izni verilmedi"
        case .unknown: return "Bilinmeyen hata oluştu"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .dataNotFound: return "Lütfen yeni veri ekleyin"
        case .dataLoadFailed, .dataSaveFailed, .dataDeleteFailed: return "Uygulamayı yeniden başlatmayı deneyin"
        case .validationFailed, .invalidFormat, .requiredFieldMissing: return "Girdiğiniz bilgileri kontrol edin"
        case .networkUnavailable: return "İnternet bağlantınızı kontrol edin"
        case .timeout: return "Tekrar deneyin"
        case .permissionDenied: return "Ayarlar'dan izin verebilirsiniz"
        default: return "Lütfen tekrar deneyin"
        }
    }
    
    static func from(error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        return .unknown(error)
    }
}
