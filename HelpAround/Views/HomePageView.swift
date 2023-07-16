//
//  HomePageView.swift
//  HelpAround
//
//  Created by Luba Gluhov on 09/07/2023.
//

import SwiftUI
import Firebase
import CoreLocation
import FirebaseAuth



struct HomePageView: View {
    @State private var textValue: String = ""
    @State private var value: String = ""
    @State private var id: String = ""
    @State private var counter: Int = 1
    @State private var currentViewShowing: String  = "login"
    //@State private var userLocation: CLLocation?
    @StateObject private var locationManager = LocationManager()
    
    var userLocation: CLLocation? {
            locationManager.userLocation
        }




    @State private var question: Question = Question(id: "", text: "", location: GeoPoint(latitude: 0, longitude: 0),time: Date())



    @State private var showAddView = false
    @State private var showLoginView = false
    @State  private var showPopup = false
    @State private var showConversationView = false

    @State private var questions: [Question] = []
    
    @Environment(\.presentationMode) var presentationMode

    let collectionRef = Firestore.firestore().collection("questions")


    var body: some View {
        NavigationView{

            
            ZStack{
                
                Color(red: 0.506, green: 0.812, blue: 0.82).edgesIgnoringSafeArea(.all)
                NavigationLink(destination: AuthView(), isActive: $showLoginView) {
                    EmptyView()
                }
                .hidden()

                
                NavigationLink(destination: AnswerView(question: question), isActive: $showConversationView) {
                    EmptyView()
                }
                .hidden()
                
                VStack {
                    HStack{
                        Text("שאלות של אנשים בקרבתך")
                            .padding(.top,40)
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.black)
                            .toolbar {
                                if(!UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        HStack{
                                            Text("שלום אורח")
                                                .padding(.horizontal,20)
                                                .blur(radius: showPopup ? 10 : 0)
                                            Button{
                                                showLoginView=true
                                                presentationMode.wrappedValue.dismiss()

                                            }label: {
                                                Text("לכניסה")
                                                    .foregroundColor(.black)
                                                    .underline()
                                                    .padding(.horizontal,-20)
                                                    .font(.headline)
                                                    .blur(radius: showPopup ? 10 : 0)
                                                
                                            }
                                        }
                                    }
                                }
                                if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: logout) {
                                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                                .imageScale(.large)
                                                .padding(8)
                                                .foregroundColor(.black)
                                                .background(
                                                    Circle()
                                                        .foregroundColor(Color(hue: 0.505, saturation: 0.859, brightness: 0.717))
                                                )
                                                .shadow(color: Color.black.opacity(0.3),
                                                        radius: 3,
                                                        x: 3,
                                                        y: 3)
                                                .blur(radius: showPopup ? 10 : 0)
                                        }
                                        .padding(.trailing,-10)
                                    }
                                }
                                if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button{
                                            showPopup=true
                                        }label: {
                                            Image(systemName: "plus")
                                                .imageScale(.large)
                                                .foregroundColor(.black)
                                                .padding(8)
                                                .background(
                                                    Circle()
                                                        .foregroundColor(Color(hue: 0.505, saturation: 0.859, brightness: 0.717))
                                                )
                                                .shadow(color: Color.black.opacity(0.3),
                                                        radius: 3,
                                                        x: 3,
                                                        y: 3)
                                                .blur(radius: showPopup ? 10 : 0)
                                            
                                        }
                                    }
                                }
                            }
                    }
                    Spacer()
                    ZStack{
                        Image("ask")
                            .resizable()
                            .ignoresSafeArea()
                            .padding(.top,300)
                        displayQuestions()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear{locationManager.requestLocation()}
            .blur(radius: showPopup ? 10 : 0)
        }
        .navigationBarBackButtonHidden(true)
        .popupNavigationView(horizontalPadding: 40, show: $showPopup){
            questionPopup()
        }
    }
    
    func fetchQuestions() {
        let collectionRef = Firestore.firestore().collection("questions")
        
        collectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents available")
                return
            }
            
            self.questions = documents.compactMap { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                guard let id = data["id"] as? String,
                      let text = data["text"] as? String,
                      let locationData = data["location"] as? GeoPoint,
                      let time = data["time"] as? Timestamp else {
                    return nil
                }
                let questionLocation = CLLocation(latitude: locationData.latitude, longitude: locationData.longitude)
                let distance = userLocation?.distance(from: questionLocation) ?? 0
                if distance <= 5000 {
                    return Question(id: id, text: text, location: locationData, time:time.dateValue())
                } else {
                    return nil
                }

            }
        }
    }
    func displayQuestions() -> some View {
        ScrollView{
            VStack{
                ForEach(questions, id: \.id) { questionTemp in
                    HStack{
                        Button{
                            question=questionTemp
                            showConversationView=true
                        }label: {
                            Text(questionTemp.text)
                                .foregroundColor(.black)
                                .padding(.bottom,15)
                                .frame(width: 200)
                                .background(
                                    Image("chatleftwhite")
                                        .resizable()
                                        .frame(width: 200,height: 150)
                                        .shadow(color: Color.black.opacity(0.6),
                                                radius: 3,
                                                x: 3,
                                                y: 3)
                                    )
                        }

                    }
                    .padding(.top,60)
                    .frame(width: 400)
                }
            }
        }.onAppear {
            fetchQuestions()
        }
    }
    
    
    func logout() {
            do {
                UserDefaults.standard.set(false, forKey: "IsLoggedIn")
                try Auth.auth().signOut()
                presentationMode.wrappedValue.dismiss() // Dismiss the current view

            } catch let error as NSError {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    
    
    func questionPopup() -> some View{
        VStack{
            Button(){
                withAnimation{showPopup.toggle()}
            }label: {
                Image(systemName: "xmark")
                    .bold()
                    .foregroundColor(.black)
            }
            .padding(.trailing,220)
            .padding(.top,10)
            Text("שאלה חדשה")
                .font(.title)
                .bold()
                .foregroundColor(.black)
            Spacer()
            Text("הכנס שאלה:")
                .padding()
                .frame( maxHeight: .infinity, alignment: .top) // << here !!
                VStack(alignment: .trailing) {
                    TextEditor(text: $textValue)
                        .frame(width: 160 ,height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 2))
                }.padding(.bottom,10)
            Button (action:{
                guard let userLocation = locationManager.userLocation else {
                            print("Location not available")
                            return
                        }
                let question = Question(id: UUID().uuidString, text: textValue, location: GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), time: Date())
                questions.append(question)
                    let questionData: [String: Any] = [
                        "id": question.id,
                        "text": question.text,
                        "location": question.location,
                        "time": question.time
                    ]
                collectionRef.document(question.id).setData(questionData) { error in
                        if let error = error {
                            print("Error saving question: \(error.localizedDescription)")
                        } else {
                            print("Question saved successfully")
                            //isShowingPopup = false
                        }
                    }
                textValue=""
                withAnimation{showPopup.toggle()}
            }){
                Text("שלח")
                    .foregroundColor(.black)
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.23, green: 0.728, blue: 0.744))
                        .padding(5)
                                
                    )
                    .frame(width: 80)
            }
            .shadow(color: Color.black.opacity(0.2),
                    radius: 2,
                    x: 2,
                    y: 2)
            .padding(.bottom,25)
           Spacer()
        }
        
    }
}


struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
