//
//  HTTPMethod.swift
//  MilaNetwork
//
//  Created by Justin Lee on 11/12/25.
//


import Foundation

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public protocol APIEndpoint {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var method: HTTPMethod { get }
    var body: Encodable? { get }
    var authToken: String? { get }
}

public protocol NetworkServiceProtocol {
    @discardableResult
    func performRequest<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

