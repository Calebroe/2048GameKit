//
//  GameCenterHandler.swift
//  IOS2048game
//
//  Created by Cody Peyerk on 11/30/23.
//

import Foundation
import GameKit

class GameCenterHandler {
    func authenticateUser() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { vc, err in
            guard err == nil else {
                print(err?.localizedDescription ?? "")
                return
            }
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = localPlayer.isAuthenticated
        }
    }
}
