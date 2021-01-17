//
//  VerificationError.swift
//  Open Auth
//
//  Created by Robert Moryson on 17/01/2021.
//

import Foundation

enum VerificationError: String, Error {
    case unauthorized = "Nie masz dostępu"
    case wrongCode = "Niepoprawny kod"
    case other = "Wystąpił błąd"
}
