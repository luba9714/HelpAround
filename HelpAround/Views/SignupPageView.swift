//
//  SignupPage.swift
//  HelpAround
//
//  Created by Luba Gluhov on 09/07/2023.
//

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct SignupPageView: View {
    @Binding var currentShowingView: String
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var text: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var showLoginView = false
    let db = Firestore.firestore()
    
    struct User: Codable {
        let name: String
        let email: String
        let password: String
    }
    func isValidPassword(_ password: String) -> Bool {
           let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
           return passwordRegex.evaluate(with: password)
    }
    
    func saveUserData(name: String, email: String, password: String) {
        let user = User(name:name, email: email, password: password)
        do {
            let userDict: [String: Any] = [
                "name": user.name,
                "email": user.email,
                "password": user.password
            ]
            var ref: DocumentReference? = nil
            ref = try db.collection("users").addDocument(data: userDict) { error in
                if let error = error {
                    print("Error saving data: \(error.localizedDescription)")
                } else {
                    print("Document ID: \(ref?.documentID ?? "")")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack{
                Color(red: 0.506, green: 0.812, blue: 0.82).edgesIgnoringSafeArea(.all)
                NavigationLink(destination: AuthView(), isActive: $showLoginView) {
                    EmptyView()
                }
                .hidden()
                
                VStack{
                    HStack{
                        Text ("טופס הרשמה")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color.black)
                    }
                    .padding(.top,20)
                    .padding(.bottom,30)
                    Spacer()
                    
                    HStack{
                        TextField("שם מלא",text:$name)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(.black)
                                            .shadow(color: Color.black.opacity(0.3),
                                                    radius: 3,
                                                    x: 3,
                                                    y: 3)
                                    )
                            )
                    }
                    .padding(.horizontal,30)
                    .padding(.bottom)
                    .frame(width: 320)
                    
                    HStack{
                        TextField("אימייל",text:$email)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(.black)
                                            .shadow(color: Color.black.opacity(0.3),
                                                    radius: 3,
                                                    x: 3,
                                                    y: 3)
                                    )
                            )
                    }
                    .padding(.horizontal,30)
                    .padding(.bottom)
                    .frame(width: 320)
                    
                    HStack{
                        SecureField("סיסמה",text:$password)
                            .autocorrectionDisabled()
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.white)
                                    .overlay(RoundedRectangle(cornerRadius: 15)
                                            .stroke(lineWidth: 2)
                                            .foregroundColor(.black)
                                            .shadow(color: Color.black.opacity(0.3),
                                                    radius: 3,
                                                    x: 3,
                                                    y: 3)
                                    )
                            )
                    }
                    .padding(.horizontal,30)
                    .padding(.bottom,20)
                    .frame(width: 320)
                    
                    VStack{
                        if(!email.isValid() || !isValidPassword(password)){
                            Text(text)
                                .foregroundColor(.red)
                                .bold()
                        }else{
                            Text(text)
                        }
                        
                        Button (action:{
                            saveUserData(name:name, email:email, password:password)
                            text = ""
                            Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
                                if let error = error {
                                    if(email.count != 0 && password.count != 0){
                                        text = "שם, אימייל או סיסמה לא נכונים"
                                    }else{
                                        text = "הפרטים חסרים"
                                    }
                                    print(error)
                                    return
                                }
                                if let authResult = authResult {
                                    withAnimation{
                                        self.currentShowingView = "login"
                                    }
                                    presentationMode.wrappedValue.dismiss()

                                    print(authResult.user.uid)
                                    return
                                }
                            }
                        }){
                            Text("סיום")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hue: 0.505, saturation: 0.711, brightness: 0.587))
                                    .padding(5)
                                            
                                )
                                .frame(width: 100)
                        }
                        .padding(.top,15)
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                        Button{
                            showLoginView = true
                            text = ""
                            presentationMode.wrappedValue.dismiss()

                        }label: {
                            Text("חזור")
                                .foregroundColor(.white)
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hue: 0.505, saturation: 0.711, brightness: 0.587))
                                    .padding(5)
                                            
                                )
                                .frame(width: 100)
                        }
                        .shadow(color: Color.black.opacity(0.3),
                                radius: 3,
                                x: 3,
                                y: 3)
                    }
                    Image("ask")
                        .resizable()
                        .ignoresSafeArea()
                }
            }     
        }
    }
}


