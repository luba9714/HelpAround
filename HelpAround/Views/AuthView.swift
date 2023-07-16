//
//  AuthView.swift
//  HelpAround
//
//  Created by Luba Gluhov on 09/07/2023.
//

import SwiftUI

struct AuthView: View {
    @State private var currentViewShowing: String  = "login"
    var body: some View {
        if(currentViewShowing == "login"){
            LoginPageView(currentShowingView: $currentViewShowing)
        } else {
            SignupPageView(currentShowingView: $currentViewShowing)
                .transition(.move(edge: .bottom))
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
