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
                GKAccessPoint.shared.location = .topLeading
                GKAccessPoint.shared.showHighlights = true
                GKAccessPoint.shared.isActive = self.localPlayer.isAuthenticated
            } else {
                // Handle error
                print(error?.localizedDescription ?? "")
                return
            }
        }
    }
}

