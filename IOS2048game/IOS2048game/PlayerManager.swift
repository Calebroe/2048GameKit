//
//  PlayerManager.swift
//  IOS2048game
//
//  Created by Cody Peyerk on 11/29/23.
//

import Foundation
import GameKit

class PlayerManager: ObservableObject {
    @Published var inGame = false
    @Published var isGameOver = false
    @Published var authenticationState = PlayerAuthSate.authenticating
    @Published var score = 0
    
    var localPlayer = GKLocalPlayer.local
    
    var rootViewController: UIViewController? {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return windowScene?.windows.first?.rootViewController
    }
    
    func authenticatePlayer()  {
        GKLocalPlayer.local.authenticateHandler = { [self] vc, err in
            if let viewController = vc {
                rootViewController?.present(viewController, animated: true)
                return
            }
            if let error = err {
                authenticationState = .authError
                print(error.localizedDescription)
                return
            }
            
            if localPlayer.isAuthenticated {
                authenticationState = .authenticated
            } else {
                authenticationState = .unauthenticated
            }
        }
    }
    
}
