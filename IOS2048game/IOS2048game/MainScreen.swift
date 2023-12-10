//
//  MainScreen.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/13/23.
//

import SwiftUI
import GameKit

enum GridSize: Int, Hashable {
    case fourByFour = 4, fiveByFive = 5, sixBySix = 6
}

struct MainScreen: View {
    @StateObject private var gameCenterHandler = GameCenterHandler()
    private let gameCenterDelegate = GameCenterViewControllerDelegate()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Checks if the authentication view needs to be presented
                if gameCenterHandler.isPresentingAuthView {
                    GameCenterAuthenticator(presentationController: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
                            .edgesIgnoringSafeArea(.all)
                            .onDisappear() {
                                // Reset the view variable so it won't re-appear
                                gameCenterHandler.isPresentingAuthView = false
                            }
                }
                
                HStack(spacing: 0) {
                    Text("2").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.red)
                    Text("0").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.green)
                    Text("4").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.blue)
                    Text("8").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.orange)
                }
                .padding(100)
                
                Spacer()

                // Simple navigation buttons that will bring user to the GameView
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
                    .padding(.bottom)

                Spacer()

                // Lower Leaderboard and Achievements buttons
                VStack {
                    HStack {
                        Button("LeaderBoard") {
                            // Action to show leaderboard
                            showLeaderboard()
                        }
                        .padding()

                        Button("Achievements") {
                            // Action to show achievements
                            showAchievements()
                        }
                        .padding()
                    }
                    .padding(.bottom, 0) // Moves the HStack lower down on the screen
                }

                Spacer()
            }
            .navigationTitle("Main Menu")
            .navigationBarHidden(true)
        }
    }
    
    // Function to show the achievements viewController
    private func showAchievements() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        // Create GameCenterViewController with the state of .achievements
        let achievementsViewController = GKGameCenterViewController(state: .achievements)
        achievementsViewController.gameCenterDelegate = gameCenterDelegate
        // Present the achievementsViewController
        rootViewController.present(achievementsViewController, animated: true, completion: nil)
    }

    // Function to show the leaderboard viewController
    private func showLeaderboard() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        // Create GameCenterViewController with the state of .leaderboards
        let leaderboardViewController = GKGameCenterViewController(state: .leaderboards)
        leaderboardViewController.gameCenterDelegate = gameCenterDelegate
        // Hardcode the leaderboardIdentifier since we only have one leaderboard
        leaderboardViewController.leaderboardIdentifier = "highestScore"
        // Present the leaderboardViewController
        rootViewController.present(leaderboardViewController, animated: true, completion: nil)
    }
}


// Previews
struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
