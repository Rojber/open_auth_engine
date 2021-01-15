//
//  SentSmsRequest.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import Foundation

struct SentSmsRequest: Codable {
    var token: String
    var phone: String
    
    enum CodingKeys: String, CodingKey {
        case token = "auth_token"
        case phone = "user_number"
    }
}
