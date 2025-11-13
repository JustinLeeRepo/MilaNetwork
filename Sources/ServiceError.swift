//
//  ServiceError.swift
//  MilaNetwork
//
//  Created by Justin Lee on 11/12/25.
//


import Foundation

public enum ServiceError: LocalizedError, Equatable {
    case invalidURL
    case noData
    case unauthorized
    case serverError(Int)
    case decodingError
    case encodingError
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
    
    public static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.unauthorized, .unauthorized),
             (.decodingError, .decodingError),
             (.encodingError, .encodingError):
            return true
        case (.serverError(let code1), .serverError(let code2)):
            return code1 == code2
        case (.networkError(let err1), .networkError(let err2)):
            return err1.localizedDescription == err2.localizedDescription
        default:
            return false
        }
    }
}
