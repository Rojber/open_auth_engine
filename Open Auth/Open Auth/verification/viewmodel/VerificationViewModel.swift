//
//  VerificationViewModel.swift
//  Open Auth
//
//  Created by Robert Moryson on 17/01/2021.
//

import SwiftUI
import Combine
import Alamofire

class VerificationViewModel: ObservableObject {
    @Published var showError = false
    @Published var error: VerificationError?

    private var verifySmsCancellable: AnyCancellable?
    private var networkManager = NetworkManager()
    private var settings: UserSettings?
    
    func setup(_ settings: UserSettings) {
        self.settings = settings
    }
    
    func verifySms(phone: String, code: String) {
        verifySmsCancellable = networkManager.verifySms(phone: phone, code: code)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.error = error
                    self?.showError = true
                case .finished:
                    print("VerificationViewModel: Wysłano kod weryfikacyjny")
                }
            }, receiveValue: { [weak self] isLoggedIn in
                self?.settings?.isLoggedIn = isLoggedIn
            })
    }
}
