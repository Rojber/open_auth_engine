//
//  ContentView.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        if settings.isLoggedIn {
            Text("Udało się zalogować")
        } else {
            LoginView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserSettings())
    }
}
