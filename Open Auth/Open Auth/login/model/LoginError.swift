//
//  LoginError.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import Foundation

enum LoginError: String, Error {
    case unauthorized = "Nie masz dostępu"
    case other = "Wystąpił błąd"
}
