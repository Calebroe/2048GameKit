//
//  GameCenterHandler.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/30/23.
//

import GameKit
import SwiftUI


struct GameCenterAuthenticator: UIViewControllerRepresentable {
    class Coordinator: NSObject, GKLocalPlayerListener {
        var parent: GameCenterAuthenticator

        init(parent: GameCenterAuthenticator) {
            self.parent = parent
        }

        // Presents the Game Center authentication viewController
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
    static let shared = GameCenterHandler() // Singleton to make sure only one instance is create/used
    var localPlayer = GKLocalPlayer.local // Variable containing the local player
    
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
            let leaderboardScore = GKLeaderboardScore() // Create leaderboard object
            leaderboardScore.leaderboardID = leaderboardID // Assign the unique identifier
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
            let achievement = GKAchievement(identifier: achievementID) // Create achievement object with unique identifier
            achievement.percentComplete = percentComplete
            // All of our achievements will either be 0 or 100 percent complete so the showCompletionBanner will always be set to true
            achievement.showsCompletionBanner = true // This will show the default UI banner for achievement completion
            
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
