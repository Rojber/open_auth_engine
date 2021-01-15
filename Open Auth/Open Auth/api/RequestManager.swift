//
//  RequestManager.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import Foundation

class RequestManager {
    private let baseUrl = "https://open-auth-engine.herokuapp.com/api/"
    
    func createRequest<T: Encodable>(data: T, endpoint: Endpoint, httpMethod: HTTPMethod) -> URLRequest {
        var request = createRequest(endpoint: endpoint, httpMethod: httpMethod)
        request.httpBody = try! JSONEncoder().encode(data)
        return request
    }
    
    func createRequest(endpoint: Endpoint, httpMethod: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: URL(string: baseUrl + endpoint.rawValue)!)
        request.httpMethod = httpMethod.rawValue
        request.setValue(
            "application/json; charset=UTF-8",
            forHTTPHeaderField: "Content-Type"
        )
        return request
    }
}

// MARK: HTTPMethod
extension RequestManager {
    enum HTTPMethod: String {
        case get, post, put, delete
    }
}

// MARK: Endpoint
extension RequestManager {
    enum Endpoint: String {
        case sendSms = "send_sms"
        case verifySms = "verify_sms"
    }
}
