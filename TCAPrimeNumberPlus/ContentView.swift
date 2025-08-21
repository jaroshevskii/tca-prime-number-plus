//
//  ContentView.swift
//  TCAPrimeNumberPlus
//
//  Created by Sasha Jaroshevskii on 8/21/25.
//

import Combine
import SwiftUI


final class AppState: ObservableObject {
    @Published var count = 0
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

struct CounterView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Text("+")
                }
            }
            
            Button(action: {}) {
                Text("Is this prime?")
            }
            
            Button(action: {}) {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    CounterView(state: state)
                } label: {
                    Text("Conter demo")
                }
                NavigationLink {
                    EmptyView()
                } label: {
                    Text("Favorite primes")
                }
            }
            .navigationTitle("State management")
        }
    }
}

#Preview {
    ContentView(state: AppState())
}

#Preview {
    NavigationView {
        CounterView(state: AppState())
    }
}
