//
//  NetworkService.swift
//  MilaNetwork
//
//  Created by Justin Lee on 11/12/25.
//



import Foundation

struct EmptyResponse: Decodable {}

// Helper struct to decode error messages from server responses
struct ErrorResponse: Decodable {
    let message: String?
    let error: String?
    let detail: String?
    
    var errorMessage: String? {
        message ?? error ?? detail
    }
}

public class NetworkService: NetworkServiceProtocol {
    private let session: URLSession = .shared
    
    public init() {
        
    }
    
    @discardableResult
    public func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try createRequest(endpoint: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try validateResponse(response: response, data: data)
            
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            
            return try decodeData(data: data, dateDecodingStrategy: endpoint.dateDecodingStrategy)
            
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.networkError(error)
        }
    }
    
    public func performRequest(_ endpoint: APIEndpoint) async throws {
        let _: EmptyResponse = try await performRequest(endpoint)
    }
    
    private func createRequest(endpoint: APIEndpoint) throws -> URLRequest {
        var urlComponent = URLComponents(string: "\(endpoint.base)/\(endpoint.path)")
        urlComponent?.queryItems = endpoint.queryItems
        guard let url = urlComponent?.url?.absoluteURL else {
            throw ServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let authToken = endpoint.authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = endpoint.body {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(body)
            } catch {
                throw ServiceError.encodingError
            }
        }
        
        return request
    }
    
    private func validateResponse(response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.networkError(URLError(.badServerResponse))
        }
        
        // Try to extract error message from response data if available
        let errorMessage = data.flatMap { data -> String? in
            try? JSONDecoder().decode(ErrorResponse.self, from: data).errorMessage
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw ServiceError.badRequest(message: errorMessage)
        case 401:
            throw ServiceError.unauthorized(message: errorMessage)
        case 403:
            throw ServiceError.forbidden(message: errorMessage)
        case 404:
            throw ServiceError.notFound(message: errorMessage)
        case 422:
            throw ServiceError.unprocessableEntity(message: errorMessage)
        case 429:
            throw ServiceError.tooManyRequests(message: errorMessage)
        case 500...599:
            throw ServiceError.serverError(httpResponse.statusCode, message: errorMessage)
        default:
            throw ServiceError.serverError(httpResponse.statusCode, message: errorMessage)
        }
    }
    
    private func decodeData<T: Decodable>(
        data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .base64,
        nonConformingFloatDecodingStrategy: JSONDecoder.NonConformingFloatDecodingStrategy = .throw
    ) throws -> T {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.dataDecodingStrategy = dataDecodingStrategy
            decoder.nonConformingFloatDecodingStrategy = nonConformingFloatDecodingStrategy
            
            let result = try decoder.decode(T.self, from: data)
            return result
        }
        catch {
            throw ServiceError.decodingError
        }
    }
}
