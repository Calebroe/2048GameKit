//
//  GameCenterHandler.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/30/23.
//

import Foundation
import GameKit

class GameCenterHandler {
    // Function that authenticates the local user and displays a Game Center access point in the top-left corner.
    func authenticateUser() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { vc, err in
            guard err == nil else {
                print(err?.localizedDescription ?? "")
                return
            }
            GKAccessPoint.shared.location = .topLeading // Top-left corner
            GKAccessPoint.shared.showHighlights = true // Displays highlights such as achievements or recent highscore
            GKAccessPoint.shared.isActive = localPlayer.isAuthenticated // Enables or disables Game Center access point based on local player's authentication state
        }
    }
}
