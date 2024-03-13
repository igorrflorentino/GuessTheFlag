//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Igor Florentino on 21/02/24.
//

import SwiftUI

struct FlagImage: View {
    var countryName: String
    var body: some View {
        Image(countryName)
            .shadow(radius: 10)
            .clipShape(.buttonBorder)
    }
}

struct largeWhiteTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.bold())
            .foregroundColor(.white)
    }
}

extension View {
    func largeWhiteTitleStyle() -> some View{
        modifier(largeWhiteTitle())
    }
}

struct ContentView: View {
    
    static private var allCountries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]
    
    @State private var countries = allCountries.shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var scoreMessage = ""
    @State private var score = 0
    @State private var questionCounter = 0
    @State private var showingResults = false
	@State private var selectedFlag = -1
    
    let scoreIncriseBy = 1
    let gameLength = 2
    
    var body: some View {
        ZStack{
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack{
                Spacer()
                Text("Guess the flag")
                    .largeWhiteTitleStyle()
                VStack (spacing:15){
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    ForEach(0..<3){ number in
                        Button {
								flagTapped(number)
                        }label: {
                            FlagImage(countryName: countries[number])
						}
						.rotation3DEffect(
							.degrees(selectedFlag == number ? 360:0),
							axis: (x: 0.0, y: 1.0, z: 0.0)
						)
						.opacity(selectedFlag == -1 || selectedFlag == number ? 1:0.25)
						.saturation(selectedFlag == -1 || selectedFlag == number ? 1:0)
						.animation(.default, value: selectedFlag)
					}
                }.frame(maxWidth: .infinity)
                    .padding(.vertical,20)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                Spacer()
                Spacer()
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                Spacer()
            }.padding()
        }.alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(scoreMessage)
        }
        .alert("Game over!", isPresented: $showingResults) {
            Button("Start Again", action: newGame)
        } message: {
            Text("Your final score was \(score) from \(questionCounter) questions answered.")
        }
    }
    
	func flagTapped (_ number: Int) {
		selectedFlag = number
		if number == correctAnswer {
			scoreTitle = "Correct!"
			scoreMessage = "You earned \(scoreIncriseBy)"
			score += 1
		} else {
			let needsTHE = ["US", "UK"]
			if needsTHE.contains(countries[number]){
				scoreTitle = "Wrong! that's the flag of the \(countries[number])"
			} else {
				scoreTitle = "Wrong! that's the flag of \(countries[number])"
			}
			scoreMessage = "No points earned"
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4){
			if questionCounter >= gameLength {
				showingScore = true
				showingResults = true
			} else {
				showingScore = true
			}
		}
		questionCounter += 1
	}
    
    func askQuestion() {
        if !showingResults{
            countries.remove(at: correctAnswer)
            countries.shuffle()
            correctAnswer = Int.random(in: 0...2)
			selectedFlag = -1
        }
    }
    
    func newGame(){
        questionCounter = 0
        score = 0
        showingResults = false
        countries = Self.allCountries
        askQuestion()
    }
}

#Preview {
    ContentView()
}
