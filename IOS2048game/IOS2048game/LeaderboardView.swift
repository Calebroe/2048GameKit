//
//  LeaderboardView.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 12/5/23.
//

import SwiftUI
import GameKit


//struct LeaderboardView: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> some UIViewController {
//        GKGameCenterViewController(state: .leaderboards)
//    }
//
//    func updateUIViewController( _ uiViewController: UIViewControllerType, context: Context) {}
//}

struct LeaderboardView: UIViewControllerRepresentable {
    var leaderboardIdentifier: String

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        showLeaderboard(viewController: viewController)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func showLeaderboard(viewController: UIViewController) {
        let leaderboardViewController = GKGameCenterViewController()
        leaderboardViewController.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        leaderboardViewController.viewState = .leaderboards
        leaderboardViewController.leaderboardIdentifier = leaderboardIdentifier

        viewController.present(leaderboardViewController, animated: true, completion: nil)
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView(leaderboardIdentifier: "HELP")
    }
}
