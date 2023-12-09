//
//  GameCenterHandler.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/30/23.
//

import Foundation
import GameKit
import SwiftUI


struct GameCenterAuthenticator: UIViewControllerRepresentable {
    class Coordinator: NSObject, GKLocalPlayerListener {
        var parent: GameCenterAuthenticator

        init(parent: GameCenterAuthenticator) {
            self.parent = parent
        }

        func player(_ player: GKPlayer, wantsToPresent viewController: UIViewController) {
            parent.presentationController.present(viewController, animated: true, completion: nil)
        }
    }

    var presentationController: UIViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<GameCenterAuthenticator>) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<GameCenterAuthenticator>) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}


class GameCenterHandler: ObservableObject {
    static let shared = GameCenterHandler()
    var localPlayer = GKLocalPlayer.local
    
    @Published var isPresentingAuthView = false
    
    init() {
        localPlayer.authenticateHandler = { viewController, error in
            if viewController != nil {
                // Set value to present view controller to authenticate user
                GameCenterHandler.shared.isPresentingAuthView = true
            } else if self.localPlayer.isAuthenticated {
                 // Player is authenticated
            } else {
                // Handle error
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }
    
    // Report highscores to Game Center
    func reportScore(score: Int, leaderboardID: String) {
        if localPlayer.isAuthenticated {
            let leaderboardScore = GKLeaderboardScore()
            leaderboardScore.leaderboardID = leaderboardID
            leaderboardScore.value = score
            leaderboardScore.player = self.localPlayer

            GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { (leaderboards, error) in
                if let error = error {
                    print("Error loading leaderboards: \(error.localizedDescription)")
                    return
                }

                guard let leaderboard = leaderboards?.first else {
                    print("Leaderboard not found")
                    return
                }

                GKLeaderboard.submitScore(Int(leaderboardScore.value), context: 0, player: leaderboardScore.player, leaderboardIDs: [leaderboardScore.leaderboardID]) { (error) in
                    if let error = error {
                        print("Error reporting score: \(error.localizedDescription)")
                    } else {
                        print("Score reported successfully!")
                    }
                }
            }
        } else {
            print("Player is not authenticated.")
        }
    }
    
    // Report achievements to Game Center
    func reportAchievement(achievementID: String, percentComplete: Double) {
        if localPlayer.isAuthenticated {
            let achievement = GKAchievement(identifier: achievementID)
            achievement.percentComplete = percentComplete
            achievement.showsCompletionBanner = true // This will show the default UI banner
            
            GKAchievement.report([achievement]) { (error) in
                if let error = error {
                    print("Error reporting achievement: \(error.localizedDescription)")
                } else {
                    print("Achievement reported successfully!")
                }
            }
        } else {
            print("Player is not authenticated.")
        }
    }
}

class GameCenterViewControllerDelegate: NSObject, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
