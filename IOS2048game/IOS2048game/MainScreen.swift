//
//  MainScreen.swift
//  IOS2048game
//
//  Created by Caleb on 11/13/23.
//

import SwiftUI
import GameKit

enum GridSize: Int, Hashable {
    case fourByFour = 4, fiveByFive = 5, sixBySix = 6
}

struct MainScreen: View {
    
    @State private var showingSettings = false
    @State var gameCenterHandler = GameCenterHandler()
    let localPlayer = GKLocalPlayer.local
//    @StateObject var playerManager = PlayerManager()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("2048")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.top, 50)

                Spacer()

//                NavigationLink("New Game - 4x4", destination: GameView(playerManager: playerManager, gridSize: .fourByFour))
                NavigationLink("New Game - 4x4", destination: GameView(gridSize: .fourByFour))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

//                NavigationLink("New Game - 5x5", destination: GameView(playerManager: playerManager, gridSize: .fiveByFive))
                NavigationLink("New Game - 5x5", destination: GameView(gridSize: .fiveByFive))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

//                NavigationLink("New Game - 6x6", destination: GameView(playerManager: playerManager, gridSize: .sixBySix))
                NavigationLink("New Game - 6x6", destination: GameView(gridSize: .sixBySix))
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom)

                // Continue Game and Settings buttons...
                // Settings button with drop-down menu
                Button("Settings") {
                    showingSettings = true
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()

                // Lower Leaderboard and Achievements buttons
                VStack {
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
                    .padding(.bottom, 0) // Moves the HStack lower down on the screen
                }

                Spacer()
            }
            .navigationTitle("Main Menu")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                // This is the settings view that will be presented as a sheet.
//                SettingsView(showingSettings: $showingSettings, playerManager: playerManager)
                SettingsView(showingSettings: $showingSettings)

            }
        }
        .onAppear {
            gameCenterHandler.authenticateUser()
        }
//        .onAppear {
//            playerManager.authenticatePlayer()
//        }
    }
}



struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
