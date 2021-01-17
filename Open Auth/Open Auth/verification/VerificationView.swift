//
//  VerificationView.swift
//  Open Auth
//
//  Created by Robert Moryson on 16/01/2021.
//

import SwiftUI

struct VerificationView: View {
    
    @EnvironmentObject var settings: UserSettings
    @Binding var phone: String
    @State var pinCode: String = ""
    @ObservedObject var viewModel = VerificationViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "lock.shield.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.blue)
                .frame(height: 150)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Weryfikacja numeru")
                    .font(.title)
                    .bold()
                    .padding()
                

                HStack {
                    Text("Wysłano wiadomość SMS z kodem PIN na numer telefonu \(phone). Wpisz kod poniżej")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                TextField("Kod PIN", text: $pinCode)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                Divider()
            }.padding(.bottom, 32.0)

            
            Button(action: { viewModel.verifySms(phone: phone, code: pinCode) }) {
                HStack {
                    Spacer()
                    Text("Weryfikuj")
                        .bold()
                    Spacer()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
           Spacer(minLength: 16)
            
        }.padding(32)
        .popup(isPresented: $viewModel.showError, autohideIn: 2) {
            HStack {
                Text("Wpisz poprawny adres email")
                    .foregroundColor(.white)
                    .bold()
            }
            .padding()
            .background(Color.red)
            .clipShape(Capsule())
        }
        .onAppear {
            self.viewModel.setup(self.settings)
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView(phone: .constant("555 666 777"))
    }
}
