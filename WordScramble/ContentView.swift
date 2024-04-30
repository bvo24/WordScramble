//
//  ContentView.swift
//  WordScramble
//
//  Created by Brian Vo on 4/29/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var errorState = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    Text("\(score)")
                        .font(.title)
                }
                
                Section{
                
                    
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                    
                }
                Section{
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            
                            
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        }
                        
                }
            }
            .navigationTitle("\(rootWord)")
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $errorState){
                Button("Ok"){ }
            }message:{
                Text(errorMessage)
            }
            .toolbar{
                Button("New Game", action: startGame)
            }
        }
        
        
    }
    
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines )
        
        guard answer.count > 0 else {return}
        
        guard isShort(word: answer) else{
            wordError(title: "Too short", message: "Longer than 3 letters pls")
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Use a another word!", message: "You used it already")
            return
        }
        guard isPossible(word: answer) else{
            wordError(title: "This word doesn't fit", message: "Make sure you use as many letters as \(rootWord) has")
            return
        }
        guard isRealWord(word: answer) else{
            wordError(title: "Word doesn't exist", message: "Real word please")
            return
        }
        
        guard isRoot(word: answer) else{
            wordError(title: "Root as Answer", message: "Be a little more creative")
            return
        }
        
        
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        score += answer.count * usedWords.count
        
        
        
    }
    
    func startGame(){
        usedWords.removeAll()
        score = 0
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Silkwork"
                return
            }
        }
        
        fatalError("Could not start game")
    }
    
    func isOriginal(word : String) -> Bool{
        !usedWords.contains(word)
    }
    func isPossible(word : String) ->Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false;
            }
        }
        return true
        
    }
    
    func isRealWord(word : String) -> Bool{
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
        
    }
    
    func wordError(title : String, message : String){
        errorTitle = title
        errorMessage = message
        errorState = true
    }
    
    func isShort(word : String) -> Bool{
        !(word.count <= 3)
    }
    func isRoot(word : String) ->Bool{
       !( word == rootWord)
    }
    
    
    
    
    
}

#Preview {
    ContentView()
}
