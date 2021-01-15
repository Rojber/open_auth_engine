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
        let data = SentSmsRequest(token: "3bffdfde9a00e30cda50947bc786b2e21f2081e6e1b1fad5", phone: phone)
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
    
//    func get() -> Future<[MyCoursesResponse], MyCoursesError> {
//        let request = requestManager.createRequest(endpoint: ., httpMethod: .get)
//
//        return (request: request)
//    }

}
