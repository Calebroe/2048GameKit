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
    @State private var showingSettings = false
    @State private var showingLeaderboard = false
    @State private var showingAchievements = false
    
    private let gameCenterDelegate = GameCenterViewControllerDelegate()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Text("2").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.red)
                    Text("0").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.green)
                    Text("4").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.blue)
                    Text("8").font(.system(size: 60)).fontWeight(.heavy).foregroundColor(.orange)
                }
                .padding(100)
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
                
                if gameCenterHandler.isPresentingAuthView {
                    GameCenterAuthenticator(presentationController: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
                            .edgesIgnoringSafeArea(.all)
                            .onDisappear() {
                                // Reset the view variable so it won't re-appear
                                gameCenterHandler.isPresentingAuthView = false
                            }
                }
            }
            .navigationTitle("Main Menu")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                // This is the settings view that will be presented as a sheet.
                SettingsView(showingSettings: $showingSettings)
            }
        }
    }
    
    private func showAchievements() {
           guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
           let achievementsViewController = GKGameCenterViewController()
           achievementsViewController.gameCenterDelegate = gameCenterDelegate
           achievementsViewController.viewState = .achievements
           rootViewController.present(achievementsViewController, animated: true, completion: nil)
       }

    private func showLeaderboard() {
       guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
       let leaderboardViewController = GKGameCenterViewController(state: .leaderboards)
       leaderboardViewController.gameCenterDelegate = gameCenterDelegate
       // Set your leaderboard identifier
       leaderboardViewController.leaderboardIdentifier = "Your_Leaderboard_Identifier"
       rootViewController.present(leaderboardViewController, animated: true, completion: nil)
    }
}




struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
