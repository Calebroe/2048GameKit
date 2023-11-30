//
//  Misc.swift
//  IOS2048game
//
//  Created by Cody Peyerk on 11/29/23.
//

import Foundation

enum PlayerAuthSate: String {
    case authenticating = "Logging in to Game Center..."
    case unauthenticated = "Please sign in to Game Center to play."
    case authenticated = ""
    case authError = "There was an error logging in to Game Center"
}
