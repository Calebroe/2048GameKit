//
//  IOS2048gameApp.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/13/23.
//

import SwiftUI

@main
struct IOS2048gameApp: App {
    @StateObject private var gameCenterHandler = GameCenterHandler()
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .onAppear() {
                    if gameCenterHandler.isPresentingAuthView {
                        GameCenterAuthenticator(presentationController: UIApplication.shared.windows.first?.rootViewController ?? UIViewController())
                                .edgesIgnoringSafeArea(.all)
                                .onDisappear() {
                                    // Reset the view variable so it won't re-appear
                                    gameCenterHandler.isPresentingAuthView = false
                                }
                    }
                }
        }
    }
}
