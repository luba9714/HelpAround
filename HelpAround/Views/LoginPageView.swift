//
//  LoginPage.swift
//  HelpAround
//
//  Created by Luba Gluhov on 09/07/2023.
//

import SwiftUI
import FirebaseAuth


struct LoginPageView: View {
    @State private var isFloating = false
    @State private var showNextView = false
    @Binding var currentShowingView: String
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username = ""
    @State private var text: String = ""
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var locationManager = LocationManager()
    func isValidPassword(_ password: String) -> Bool {
           let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
           return passwordRegex.evaluate(with: password)
    }

    var body: some View {
            NavigationView {
                ZStack{
                    Color.white.edgesIgnoringSafeArea(.all)
                    VStack{
                        Image("ask")
                            .resizable()
                            .ignoresSafeArea()
                        HStack{
                            Text ("HelpAround")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color(red: 0.041, green: 0.374, blue: 0.38))
                        }
                        Spacer()
                        
                        HStack{
                            Image(systemName: "mail")
                            TextField("אימייל",text:$email)
                                .autocorrectionDisabled()
                            if(email.count != 0){
                                Image(systemName: email.isValid() ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(email.isValid() ? .green : .red)
                            }
                            
                        }
                        .padding(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundColor(Color(red: 0.506, green: 0.812, blue: 0.82))
                                .shadow(color: Color.black.opacity(0.2),
                                        radius: 3,
                                        x: 3,
                                        y: 3)
                            
                        )
                        .padding()
                        .frame(width: 320)
                        HStack{
                            Image(systemName: "lock")
                            SecureField("סיסמה",text:$password)
                                .autocorrectionDisabled()
                            if(password.count != 0){
                                Image(systemName: isValidPassword(password) ? "checkmark" : "xmark")
                                    .fontWeight(.bold)
                                    .foregroundColor(isValidPassword(password) ? .green : .red)
                            }
                        }
                        .padding(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 3)
                                .foregroundColor(Color(red: 0.506, green: 0.812, blue: 0.82))
                                .shadow(color: Color.black.opacity(0.2),
                                        radius: 3,
                                        x: 3,
                                        y: 3)
                        )
                        .padding(.horizontal)
                        .frame(width: 320)
                        Button(action: {
                            showNextView = true
                        }){
                            Text("הכנס בתור אורח")
                                .foregroundColor(Color(red: 0.258, green: 0.743, blue: 0.755))
                                .underline()
                        }
                        .padding(.bottom,5)
                        Button{
                            withAnimation{
                                self.currentShowingView = "signup"
                            }
                            presentationMode.wrappedValue.dismiss()

                            
                        }label: {
                            Text("להרשמה")
                                .foregroundColor(Color(red: 0.258, green: 0.743, blue: 0.755))
                                .underline()
                        }
                        Spacer(minLength: 10)
                        NavigationLink(destination: HomePageView(), isActive: $showNextView) {
                            EmptyView()

                        }
                        .hidden()
                        VStack{
                            if(!email.isValid() || !isValidPassword(password)){
                                Text(text)
                                    .foregroundColor(.red)
                                    .bold()
                            }else{
                                Text(text)
                            }
                            Button (action:{
                                text = ""
                                Auth.auth().signIn(withEmail: email, password: password){authResult, error in
                                    if let error = error {
                                        if(email.count != 0 && password.count != 0){
                                            text = "אימייל או סיסמה לא תקינים"
                                        }else{
                                            text = "הפרטים חסרים"
                                        }
                                        print(error)
                                        return
                                    }
                                    if let authResult = authResult {
                                        print(authResult.user.uid)
                                        email = ""
                                        password = ""
                                        showNextView = true
                                        UserDefaults.standard.set(true, forKey: "IsLoggedIn")
                                        return
                                    }
                                }
                            }){
                                Text("כניסה")
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.23, green: 0.728, blue: 0.744))
                                        .padding(5)
                                    )
                                    .frame(width: 100)
                            }
                            .shadow(color: Color.black.opacity(0.3),
                                    radius: 3,
                                    x: 3,
                                    y: 3)
                        }
                    }
                }
                
            }
            .onAppear(perform: retrieveUserDetails)
            .onAppear{locationManager.requestLocationAuthorization()}
            .onAppear {locationManager.startUpdatingLocation()}
            .onAppear {locationManager.requestLocation()}
            .onDisappear {locationManager.stopUpdatingLocation()}
            .navigationBarBackButtonHidden(true)
    }
    func retrieveUserDetails() {
        if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
            showNextView = true
        }else{
            showNextView = false
        }
    }
    
}


