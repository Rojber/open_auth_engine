//
//  NetworkManager.swift
//  test
//
//  Created by Robert Moryson on 17/11/2020.
//

import UIKit
import Combine
import Alamofire

struct SentSmsRequest: Codable {
    var token: String
    var phone: String
}

class NetworkManager {
    private let requestManager = RequestManager()
    
    func sendSms(phone: String) -> Future<String?, Never> {
        let data = SentSmsRequest(token: "email", phone: "545454545445")
        let request = requestManager.createRequest(data: data, endpoint: .sendSms, httpMethod: .post)
        
        return Future<String?, Never> { promise in
            AF.request(request)
                .responseString { response in
                    print(response)
                    return promise(.success(response.value))
                }
        }
    }
    
//    func get() -> Future<[MyCoursesResponse], MyCoursesError> {
//        let request = requestManager.createRequest(endpoint: ., httpMethod: .get)
//
//        return (request: request)
//    }

}
