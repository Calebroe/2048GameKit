//
//  LeaderboardView.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 12/5/23.
//

import SwiftUI
import GameKit


struct LeaderboardView: UIViewControllerRepresentable {
    var leaderboardIdentifier: String
    let gameCenterDelegate = GameCenterViewControllerDelegate()

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        showLeaderboard(viewController: viewController)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func showLeaderboard(viewController: UIViewController) {
        let leaderboardViewController = GKGameCenterViewController(state: .leaderboards)
        leaderboardViewController.gameCenterDelegate = gameCenterDelegate
        leaderboardViewController.leaderboardIdentifier = leaderboardIdentifier

        viewController.present(leaderboardViewController, animated: true, completion: nil)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Update this field with proper ID
        LeaderboardView(leaderboardIdentifier: "HELP")
    }
}
