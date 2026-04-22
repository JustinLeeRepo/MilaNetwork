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
    case unauthorized(message: String? = nil)
    case forbidden(message: String? = nil)
    case notFound(message: String? = nil)
    case badRequest(message: String? = nil)
    case unprocessableEntity(message: String? = nil)
    case tooManyRequests(message: String? = nil)
    case serverError(Int, message: String? = nil)
    case decodingError
    case encodingError
    case networkError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .unauthorized(let message):
            return message ?? "Unauthorized access"
        case .forbidden(let message):
            return message ?? "Access forbidden"
        case .notFound(let message):
            return message ?? "Resource not found"
        case .badRequest(let message):
            return message ?? "Bad request"
        case .unprocessableEntity(let message):
            return message ?? "Unprocessable entity"
        case .tooManyRequests(let message):
            return message ?? "Too many requests - rate limit exceeded"
        case .serverError(let code, let message):
            if let message = message {
                return "Server error (\(code)): \(message)"
            }
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
             (.decodingError, .decodingError),
             (.encodingError, .encodingError):
            return true
        case (.unauthorized(let msg1), .unauthorized(let msg2)):
            return msg1 == msg2
        case (.forbidden(let msg1), .forbidden(let msg2)):
            return msg1 == msg2
        case (.notFound(let msg1), .notFound(let msg2)):
            return msg1 == msg2
        case (.badRequest(let msg1), .badRequest(let msg2)):
            return msg1 == msg2
        case (.unprocessableEntity(let msg1), .unprocessableEntity(let msg2)):
            return msg1 == msg2
        case (.tooManyRequests(let msg1), .tooManyRequests(let msg2)):
            return msg1 == msg2
        case (.serverError(let code1, let msg1), .serverError(let code2, let msg2)):
            return code1 == code2 && msg1 == msg2
        case (.networkError(let err1), .networkError(let err2)):
            return err1.localizedDescription == err2.localizedDescription
        default:
            return false
        }
    }
}
