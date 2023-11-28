//
//  MainScreen.swift
//  IOS2048game
//
//  Created by Caleb on 11/13/23.
//

import SwiftUI

enum GridSize: Int, Hashable {
    case fourByFour = 4, fiveByFive = 5, sixBySix = 6
}

struct MainScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("2048")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 50)

                Spacer()

                NavigationLink("New Game - 4x4", destination: GameView(gridSize: .fourByFour))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                NavigationLink("New Game - 5x5", destination: GameView(gridSize: .fiveByFive))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                NavigationLink("New Game - 6x6", destination: GameView(gridSize: .sixBySix))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                // Continue Game and Settings buttons...

                Spacer()

                HStack {
                    Button("LeaderBoard") {
                        // Action to show leaderboard
                    }
                    .padding()

                    Button("Achievements") {
                        // Action to show achievements
                    }
                    .padding()
                }

                Spacer()
            }
            .navigationTitle("Main Menu")
            .navigationBarHidden(true)
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
