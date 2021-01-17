//
//  LoginView.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import SwiftUI
import PopupView
import iPhoneNumberField

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                LottieView(name: "animation", loopMode: .autoReverse)
                    .frame(width:350, height:230)
                Spacer()
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Cześć 👋")
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Podaj numer telefonu, aby dostać się do ukrytego widoku")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    
                    iPhoneNumberField("Numer telefonu", text: $viewModel.phone)
                        .flagHidden(false)
                        .maximumDigits(9)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    
                }
                Spacer(minLength: 20)
                NavigationLink("", destination: VerificationView(phone: $viewModel.phone), isActive: $viewModel.isSmsSent)
                
                
                Button("Wyślij kod SMS na podany numer", action: {
                    //hide keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    viewModel.sendSms(phone: viewModel.phone)
                })
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer(minLength: 64)
                
                
            }.padding(32.0)
            .popup(isPresented: $viewModel.showError, autohideIn: 2) {
                HStack {
                    Text(viewModel.error?.rawValue ?? "Wystąpił błąd")
                        .foregroundColor(.white)
                        .bold()
                }
                .padding()
                .background(Color.red)
                .clipShape(Capsule())
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
