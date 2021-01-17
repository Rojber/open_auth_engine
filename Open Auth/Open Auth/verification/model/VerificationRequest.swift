//
//  VerificationRequest.swift
//  Open Auth
//
//  Created by Robert Moryson on 17/01/2021.
//

import Foundation

struct VerificationRequest: Codable {
    var token: String
    var phone: String
    var code: String
    
    enum CodingKeys: String, CodingKey {
        case token = "auth_token"
        case phone = "user_number"
        case code = "user_verification_code"
    }
}
