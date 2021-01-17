//
//  NetworkManager.swift
//  Open Auth
//
//  Created by Robert Moryson on 17/11/2020.
//

import UIKit
import Combine
import Alamofire

class NetworkManager {
    private let requestManager = RequestManager()
    
    func sendSms(phone: String) -> Future<Bool, LoginError> {
        let data = SentSmsRequest(token: C.token, phone: phone)
        let request = requestManager.createRequest(data: data, endpoint: .sendSms, httpMethod: .post)
        
        return Future<Bool, LoginError> { promise in
            AF.request(request)
                .responseString { response in
                    guard let value = response.value else {
                        return promise(.failure(.other))
                    }
                    switch value {
                    case "SMS SENT":
                        return promise(.success(true))
                    case "UNAUTHORIZED":
                        return promise(.failure(.unauthorized))
                    default:
                        return promise(.failure(.other))
                    }
                }
        }
    }
    
    func verifySms(phone: String, code: String) -> Future<Bool, VerificationError> {
        let data = VerificationRequest(token: C.token, phone: phone, code: code)
        let request = requestManager.createRequest(data: data, endpoint: .verifySms, httpMethod: .post)
        
        return Future<Bool, VerificationError> { promise in
            AF.request(request)
                .responseString { response in
                    guard let value = response.value else {
                        return promise(.failure(.other))
                    }
                    switch value {
                    case "VERIFIED SUCCESSFULLY":
                        return promise(.success(true))
                    case "UNAUTHORIZED":
                        return promise(.failure(.unauthorized))
                    case "WRONG CODE":
                        return promise(.failure(.wrongCode))
                    default:
                        return promise(.failure(.other))
                    }
                }
        }
    }
}
