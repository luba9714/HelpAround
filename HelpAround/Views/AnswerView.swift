//
//  AnswerView.swift
//  HelpAround
//
//  Created by Luba Gluhov on 11/07/2023.
//
import FirebaseFirestore
import SwiftUI

struct AnswerView: View {
    @State private var userAnswer: String = ""
    let question: Question
    @State private var show = false
    @StateObject private var locationManager = LocationManager()
    let collectionRef = Firestore.firestore().collection("answers")
    @State private var answers: [Answer] = []
    
    var body: some View {
        ZStack{
            Color(red: 0.506, green: 0.812, blue: 0.82).edgesIgnoringSafeArea(.all)
            
             Image("ask")
                    .resizable()
                    .scaledToFit()
            .frame(maxWidth: 200, maxHeight: .infinity, alignment: .bottom) // << here !!
            
            Image("frame3")
                .resizable()
                .ignoresSafeArea()
                .frame(width: 340,height: 500)
                .cornerRadius(35)
                .opacity(0.6)
            VStack{
                HStack{
                    Text(question.text)
                        .padding(.bottom,10)
                        .background(
                            Image("chatleftwhite")
                                .resizable()
                                .frame(width: 200,height: 120)
                                .shadow(color: Color.black.opacity(0.6),
                                        radius: 3,
                                        x: 3,
                                        y: 3)
                        )
                }
                .padding(.top,140)
                .padding(.trailing,-40)
                displayQuestions()
                HStack{
                    Button{
                        if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                            //    if(answers.count < 3 || answers.isEmpty){
                            guard let userLocation = locationManager.userLocation else {
                                print("Location not available")
                                return
                            }
                            let answer = Answer(id: UUID().uuidString, questionId: question.id, text: userAnswer, location: GeoPoint(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), time: Date())
                            
                            answers.append(answer)
                            let answerData: [String: Any] = [
                                "id": answer.id,
                                "questionId": answer.questionId,
                                "text": answer.text,
                                "location": answer.location,
                                "time": answer.time
                            ]
                            collectionRef.document(answer.id).setData(answerData) { error in
                                if let error = error {
                                    print("Error saving answer: \(error.localizedDescription)")
                                } else {
                                    print("answer saved successfully")
                                }
                            }
                            show = true
                            userAnswer = ""
                            // }else{
                            //add coment
                            //}
                        }
                    }label: {
                        if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30,height: 30)
                                .foregroundColor(Color(red: 0.506, green: 0.812, blue: 0.82))
                        }else{
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 30,height: 30)
                                .foregroundColor(Color(red: 0.506, green: 0.812, blue: 0.82))
                                .opacity(0.4)
                        }
                    }
                    HStack{
                        if(UserDefaults.standard.bool(forKey: "IsLoggedIn")){
                            TextField("תשובה",text:$userAnswer)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.506, green: 0.812, blue: 0.82))
                                        .frame(height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(lineWidth: 1)
                                                .foregroundColor(.black)
                                                .shadow(color: Color.black.opacity(0.3),
                                                        radius: 3,
                                                        x: 3,
                                                        y: 3)
                                        )  
                                )
                        }else{
                            TextField("תשובה",text:$userAnswer)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.506, green: 0.812, blue: 0.82))
                                        .frame(height: 40)
                                        .opacity(0.4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(lineWidth: 1)
                                                .foregroundColor(.black)
                                                .shadow(color: Color.black.opacity(0.3),
                                                        radius: 3,
                                                        x: 3,
                                                        y: 3)
                                                .opacity(0.4)
                                        )
                                )
                                .disabled(true)
                        }
                    }
                    .frame(width: 200)
                                        
                }
                .padding(.bottom,60)
                .frame(maxWidth: 200, maxHeight: .infinity, alignment: .center)
            }
        }
    }
    
    func fetchQuestions() {
        let collectionRef = Firestore.firestore().collection("answers")
        collectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents available")
                return
            }
            
            self.answers = documents.compactMap { queryDocumentSnapshot in
                let data = queryDocumentSnapshot.data()
                guard let id = data["id"] as? String,
                      let questionId = data["questionId"] as? String,
                      let text = data["text"] as? String,
                      let locationData = data["location"] as? GeoPoint,
                      let time = data["time"] as? Timestamp else {
                    return nil
                }
                
                let location = GeoPoint(latitude: locationData.latitude, longitude: locationData.longitude)
                let question = Answer(id: id, questionId: questionId ,text: text, location: location, time: time.dateValue())
                return question
            }
        }
    }
    func displayQuestions() -> some View {
        GeometryReader { geometry in
                    ScrollView {
                        VStack {
                            ForEach(answers, id: \.id) { answer in
                                // GeometryReader { geometry in
                                if(answer.questionId == question.id){
                                    HStack {
                                    Text(answer.text)
                                        .padding()
                                        .background(
                                            Image("chatrightblue")
                                                .resizable()
                                                .frame(width: 200, height: 110)
                                                .shadow(color: Color.black.opacity(0.6),
                                                        radius: 3,
                                                        x: 3,
                                                        y: 3)
                                            
                                        )
                                        Text(answer.timeAgoString())
                                            .font(.callout)
                                            .fontWeight(.thin)
                                            .foregroundColor(Color.black)
                                            .padding(.top,50)
                                }
                                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2.8)
                                
                                Spacer()
                            }
                        }
                    }
                }
                    .frame(width: geometry.size.width + 30, height: geometry.size.height + 40)
            .onAppear {
                fetchQuestions()
            }
        }
    }
    
    

}

struct AnswerView_Previews: PreviewProvider {
    static var previews: some View {
        AnswerView(question: Question(id: "1", text: "Example Question", location: GeoPoint(latitude: 0, longitude: 0),time: Date()))

    }
}
