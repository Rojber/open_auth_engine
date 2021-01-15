//
//  LoginViewModel.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import SwiftUI
import Combine
import Alamofire

class LoginViewModel: ObservableObject {
    @Published var phone: String = ""
    @Published var showError = false
    @Published var isSmsSent = false
    @Published var error: LoginError?

    private var sendSmsCancellable: AnyCancellable?
    private var networkManager = NetworkManager()
    
    func sendSms(phone: String) {
        sendSmsCancellable = networkManager.sendSms(phone: phone)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                    self?.showError = true
                case .finished:
                    print("LoginViewModel: Wysłano wiadomość SMS")
                }
            }, receiveValue: { [weak self] isSmsSent in
                self?.isSmsSent = isSmsSent
            })
    }
}

