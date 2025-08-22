//
//  ContentView.swift
//  TCAPrimeNumberPlus
//
//  Created by Sasha Jaroshevskii on 8/21/25.
//

import Combine
import SwiftUI

struct WolframAlphaResult: Decodable {
    let queryresult: QueryResult

    struct QueryResult: Decodable {
        let pods: [Pod]

        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]

            struct SubPod: Decodable {
                let plaintext: String
            }
        }
    }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    let wolframAlphaApiKey = "RTLRGW5LL2"
    
    var components = URLComponents(
        string: "https://api.wolframalpha.com/v2/query"
    )!
    components.queryItems = [
        URLQueryItem(name: "input", value: query),
        URLQueryItem(name: "format", value: "plaintext"),
        URLQueryItem(name: "output", value: "JSON"),
        URLQueryItem(name: "appid", value: wolframAlphaApiKey),
    ]

    URLSession.shared
        .dataTask(
            with: components.url(relativeTo: nil)!
        ) { data, response, error in
            callback(
                data.flatMap {
                    try? JSONDecoder()
                        .decode(WolframAlphaResult.self, from: $0)
                }
            )
        }
        .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
      }
      .flatMap(Int.init)
    )
  }
}

final class AppState: ObservableObject {
    @Published var count = 0
    @Published var favoritePrimes: [Int] = []
}

private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

struct PrimeAlert: Identifiable {
    let prime: Int
    
    var id: Int { self.prime }
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShow = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
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
            
            Button(action: { self.isPrimeModalShow = true }) {
                Text("Is this prime?")
            }
            
            Button(action: self.nthPrimeButtonAction) {
                Text("What is the \(ordinal(self.state.count)) prime?")
            }
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShow) {
            IsPrimeModalView(state: self.state)
        }
        .alert(item: self.$alertNthPrime) { alert in
            Alert(
                title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
                dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        
        nthPrime(self.state.count) { prime in
            self.alertNthPrime = prime.map(PrimeAlert.init)
            self.isNthPrimeButtonDisabled = false
        }
    }
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
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
                    FavoritePrimesView(state: state)
                } label: {
                    Text("Favorite primes")
                }
            }
            .navigationTitle("State management")
        }
    }
}

struct IsPrimeModalView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        VStack {
            if isPrime(self.state.count) {
                Text("\(self.state.count) is prime 🎉")
                if self.state.favoritePrimes.contains(self.state.count) {
                    Button {
                        self.state.favoritePrimes.removeAll { $0 == self.state.count }
                    } label: {
                        Text("Remove from favorites primes")
                    }
                } else {
                    Button {
                        self.state.favoritePrimes.append(self.state.count)
                    } label: {
                        Text("Save to favorite primes")
                    }

                }
            } else {
                Text("\(self.state.count) is not prime :(")
            }
        }
    }
}

struct FavoritePrimesView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationTitle(Text("Favorite primes"))
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

#Preview {
    IsPrimeModalView(state: AppState())
}
