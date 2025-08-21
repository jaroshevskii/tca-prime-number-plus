//
//  TCAPrimeNumberPlusApp.swift
//  TCAPrimeNumberPlus
//
//  Created by Sasha Jaroshevskii on 8/21/25.
//

import SwiftUI

@main
struct TCAPrimeNumberPlusApp: App {
    let state = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
        }
    }
}
