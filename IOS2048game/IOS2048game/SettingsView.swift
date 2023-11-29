//
//  SettingsView.swift
//  IOS2048game
//
//  Created by Caleb on 11/28/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showingSettings: Bool // Binding to control the visibility from the MainScreen

    var body: some View {
        VStack {
            // Use a draggable indicator at the top of the sheet
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 40, height: 5)
                .padding()
            // settings content here
            Text("Settings")
                .font(.largeTitle)
            
            // Other settings options...
            Button("Reset Achievements") {
                //logic to reset achievements
            }
            .padding()
            .background(Color.cyan)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // Other settings options...
            Button("Reset Highscore") {
                //logic to reset highscore
            }
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // Other settings options...
            Button("Theme") {
                //logic to display a picker with theme options
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            // Other settings options...
            Button("Close") {
                showingSettings = false
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .gesture(
            DragGesture().onEnded { value in
                // Dismiss the sheet if the swipe down gesture is detected
                if value.translation.height > 50 {
                    showingSettings = false
                }
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showingSettings: .constant(true))
    }
}
