//
//  NetworkService.swift
//  MilaNetwork
//
//  Created by Justin Lee on 11/12/25.
//



import Foundation

public class NetworkService: NetworkServiceProtocol {
    private let session: URLSession = .shared
    
    @discardableResult
    public func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try createRequest(endpoint: endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try validateResponse(response: response)
            
            if T.self == Void.self {
                return () as! T
            }
            
            return try decodeData(data: data)
            
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.networkError(error)
        }
    }
    
    private func createRequest(endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = URL(string: "\(endpoint.base)/\(endpoint.path)") else {
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
    
    private func validateResponse(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.networkError(URLError(.badServerResponse))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw ServiceError.unauthorized
        default:
            throw ServiceError.serverError(httpResponse.statusCode)
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
