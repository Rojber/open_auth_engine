//
//  ContentView.swift
//  Open Auth
//
//  Created by Robert Moryson on 15/01/2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
    
//    func get() {
//
//        guard let url = URL(string: "https://open-auth-engine.herokuapp.com/api/send_sms") else {
//            print("Invalid URL")
//            return
//        }
//        let request = URLRequest(url: url)
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data {
//                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
//                    // we have good data – go back to the main thread
//                    DispatchQueue.main.async {
//                        // update our UI
//                        self.results = decodedResponse.results
//                    }
//
//                    // everything is good, so we can exit
//                    return
//                }
//            }
//
//            // if we're still here it means there was a problem
//            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
//        }.resume()
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
