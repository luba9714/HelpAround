//
//  HelpAroundApp.swift
//  HelpAround
//
//  Created by Luba Gluhov on 09/07/2023.
//

import SwiftUI
import FirebaseCore

@main
struct HelpAroundApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
