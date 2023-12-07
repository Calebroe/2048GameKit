//
//  AchievementsView.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 12/5/23.
//

import SwiftUI
import GameKit


struct AchievementsView: UIViewControllerRepresentable {
    
    let delegate = GameCenterViewControllerDelegate()

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        showAchievements(viewController: viewController)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func showAchievements(viewController: UIViewController) {
        let achievementsViewController = GKGameCenterViewController()
        achievementsViewController.gameCenterDelegate = delegate
        achievementsViewController.viewState = .achievements

        viewController.present(achievementsViewController, animated: true, completion: nil)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
    }
}
