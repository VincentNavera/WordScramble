//
//  ContentView.swift
//  WordScramble
//
//  Created by Vincio on 7/17/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "Word Scramble"
    @State private var newWord = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var score = 0
    @State private var timeRemaining = 30
    @State private var timerDone = false
    @State private var showTimer = false
    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()


    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if showTimer {
                        Button(action: resetWord, label: {
                            Text("Skip Word")
                        })
                        Spacer()
                        Text("\(timeRemaining)")
                            .font(.system(size: 50, design: .rounded)).foregroundColor(timeRemaining > 5 ? .black : .red)
                            .onReceive(timer, perform: { _ in
                                if self.timeRemaining > 0 {
                                    self.timeRemaining -= 1
                                } else {
                                    timerDone = true
                                    alertTitle = "Your total points is \(score)"
                                    alertMessage = "Time's Up!"
                                    showAlert = true
                                }
                            })
                        Spacer()
                        Text("Score: \(score)")


                    } else {
                        Button(action: startNewGame, label: {
                            Text("Start Game")
                        })

                    }

                }
                .padding()

                if showTimer {
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()


                    List(usedWords, id: \.self) {
                        Image(systemName: "\($0.count).circle")
                        Text($0)
                    }
                }




            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button(action: startOver, label: {
                if showTimer {
                    VStack {
                        Image(systemName: "gobackward")
                        Text("Reset")
                    }
                }


            }))
            .alert(isPresented: $showAlert) { Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: !timerDone ? .default(Text("OK")) : .cancel(Text("Start Over"), action: startOver))
            }

        }

    }
    func addPoints(word: String) {
        score += word.count > 4 ? (word.count - 3) * 2 : 1

    }
    func addNewWord() {
        let answer =  newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 else {
            wordError(title: "Word has 3 letters or less", message: "Make it longer")
            return}
        guard  isNotSame(word: answer) else {
            wordError(title: "Word is the same as the root word", message: "Be original")
            return
        }


        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }

        usedWords.insert(answer, at: 0)
        newWord = ""
        addPoints(word: answer)
    }

    func resetWord() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")

                rootWord = allWords.randomElement() ?? "default"
                return
            }
        }
        fatalError("Could not load start.txt from bundle")
    }

    func hasMoreThanThreeLetters(word: String) -> Bool {
        word.count > 3
    }

    func isNotSame(word: String) -> Bool {
        word != rootWord
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }

        }
            return true

    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }

    func wordError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
        newWord = ""
    }

    func startNewGame() {
        resetWord()
        usedWords = [String]()
        showTimer = true
        newWord = ""
    }

    func startOver() {
        rootWord = "Word Scramble"
        score = 0
        timeRemaining = 31
        showTimer = false
        usedWords = [String]()
        timerDone = false
        newWord = ""

    }


}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
