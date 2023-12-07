//
//  GameView.swift
//  IOS2048game
//
//  Created by Caleb and Cody on 11/13/23.
//

import SwiftUI
import GameKit

struct GameView: View {
    let gridSize: GridSize
    @State private var grid: [[Int]]
    @State private var score: Int = 0
    @State private var gameTime = 0
    @State private var highScore: Int = 0 // Initialized later
    @State private var moveCount: Int = 0
    @State private var isGameOver = false
    @State private var isGameWon = false
    @State private var endlessMode = false
    @StateObject private var gameCenterHandler = GameCenterHandler() // This needs to be in scope
    @State private var gameStarted = false // Example state to track if the game has started
    @State private var timer: Timer?
    @State private var highestTile = 0
    
    @Environment(\.presentationMode) var presentationMode
    
    init(gridSize: GridSize) {
        self.gridSize = gridSize
        let size = gridSize.rawValue
        _grid = State(initialValue: Array(repeating: Array(repeating: 0, count: size), count: size))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            gameTitle
            modeText
            scoreRow
            
            VStack(spacing: 5) {
                ForEach(0..<grid.count, id: \.self) { i in
                    HStack(spacing: 5) {
                        ForEach(0..<grid[i].count, id: \.self) { j in
                            Text(grid[i][j] == 0 ? "" : "\(grid[i][j])")
                                .frame(width: gridSize == .sixBySix ? 60 : 70, height: gridSize == .sixBySix ? 60 : 70)
                                .background(backgroundColor(for: grid[i][j]))
                                .foregroundColor(textColor(for: grid[i][j]))
                                .font(Font.system(size: gridSize == .sixBySix ? 18 : 24, weight: .bold, design: .default))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            
            timeAndMoveCount
            newGameButton
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .onAppear {
            highScore = UserDefaults.standard.integer(forKey: highScoreKey)
            startNewGame()
        }
        .gesture(DragGesture(minimumDistance: 20).onEnded(handleSwipe))
        .overlay(gameOverOverlay)
        .overlay(gameWonOverlay)
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Text("Main Menu")
            }
            .foregroundColor(.white)
            .padding(5)
            .background(Color.gray)
            .cornerRadius(8)
        }
    }

    // Game Logic
    private func startNewGame() {
        score = 0
        gameTime = 0
        moveCount = 0
        let size = gridSize.rawValue
        grid = Array(repeating: Array(repeating: 0, count: size), count: size)
        addNumber()
        addNumber()
        isGameOver = false
        isGameWon = false
        endlessMode = false
        gameStarted = true
        checkForAchievements()
        startGameTimer()
    }

    private func addNumber() {
        var emptyCells = [(Int, Int)]()
        for i in 0..<grid.count {
            for j in 0..<grid[i].count {
                if grid[i][j] == 0 {
                    emptyCells.append((i, j))
                }
            }
        }
        if let (x, y) = emptyCells.randomElement() {
            grid[x][y] = Int.random(in: 1...2) * 2
        }
    }

    // Movement and merging logic
    private func moveRight() {
        var moved = false
        for i in 0..<grid.count {
            var line = grid[i].filter { $0 != 0 }
            let missing = grid[i].count - line.count
            line = Array(repeating: 0, count: missing) + line

            for j in (1..<line.count).reversed() {
                if line[j] == line[j-1] && line[j] != 0 {
                    line[j] *= 2
                    score += line[j]
                    line[j-1] = 0
                    moved = true
                }
            }
            line = line.filter { $0 != 0 }
            line = Array(repeating: 0, count: grid[i].count - line.count) + line
            
            if grid[i] != line {
                moved = true
                grid[i] = line
            }
        }
        if moved {
            moveCount += 1 // Increment move count
            addNumber()
        }
        updateHighScore()
        updateTotalPlayTime()
        checkForGameWon()
        checkForGameOver()
        checkForAchievements()
    }

    private func moveLeft() {
        var moved = false
        for i in 0..<grid.count {
            var line = grid[i].filter { $0 != 0 }
            var index = 0
            while index < line.count - 1 {
                if line[index] == line[index + 1] && line[index] != 0 {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index + 1)
                    moved = true
                }
                index += 1
            }
            let missing = grid[i].count - line.count
            line += Array(repeating: 0, count: missing)
            if grid[i] != line {
                moved = true
                grid[i] = line
            }
        }
        if moved {
            moveCount += 1 // Increment move count
            addNumber()
            updateHighScore()
            updateTotalPlayTime()
            checkForGameWon()
            checkForGameOver()
            checkForAchievements()
        }
    }

    private func moveDown() {
        var moved = false
        for j in 0..<grid[0].count {
            var line = [Int]()
            for i in (0..<grid.count).reversed() {
                if grid[i][j] != 0 {
                    line.append(grid[i][j])
                }
            }
            var index = 0
            while index < line.count - 1 {
                if line[index] == line[index + 1] {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index + 1)
                    index += 1
                    moved = true
                }
                index += 1
            }
            let missing = grid.count - line.count
            line += Array(repeating: 0, count: missing).reversed()
            for i in 0..<grid.count {
                if grid[i][j] != line.reversed()[i] {
                    moved = true
                    grid[i][j] = line.reversed()[i]
                }
            }
        }
        if moved {
            moveCount += 1 // Increment move count
            addNumber()
            updateHighScore()
            updateTotalPlayTime()
            checkForGameWon()
            checkForGameOver()
            checkForAchievements()
        }
    }

    private func moveUp() {
        var moved = false
        for j in 0..<grid[0].count {
            var line = [Int]()
            for i in 0..<grid.count {
                if grid[i][j] != 0 {
                    line.append(grid[i][j])
                }
            }
            var index = 0
            while index < line.count - 1 {
                if line[index] == line[index + 1] {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index + 1)
                    index += 1
                    moved = true
                }
                index += 1
            }
            let missing = grid.count - line.count
            line += Array(repeating: 0, count: missing)
            for i in 0..<grid.count {
                if grid[i][j] != line[i] {
                    moved = true
                    grid[i][j] = line[i]
                }
            }
        }
        if moved {
            moveCount += 1 // Increment move count
            addNumber()
            updateHighScore()
            updateTotalPlayTime()
            checkForGameWon()
            checkForGameOver()
            checkForAchievements()
        }
    }
    
    // Utility functions
    private func checkForGameOver() {
        if !grid.flatMap({ $0 }).contains(0) && !isMovePossible() {
            isGameOver = true
            stopGameTimer()
            
        }
        
    }
    
    private func checkForGameWon() {
        if grid.flatMap({ $0 }).contains(2048) && !endlessMode {
            print("Testing!!!")
            isGameWon = true
        }
    }
    
    private func checkForHighestTile() {
        if grid.flatMap({ $0 }).contains(256) {
            highestTile = 256
        }
        if grid.flatMap({ $0 }).contains(512) {
            highestTile = 512
        }
        if grid.flatMap({ $0 }).contains(1024) {
            highestTile = 1024
        }
        if grid.flatMap({ $0 }).contains(2048) {
            highestTile = 2048
        }
    }
    
    private func checkForAchievements() {
        // Example conditions
        if gameStarted {
            gameCenterHandler.reportAchievement(achievementID: "startFirstGame", percentComplete: 100)
        }
        if isGameOver {
            gameCenterHandler.reportAchievement(achievementID: "finishFirstGame", percentComplete: 100)
        }
        if isGameWon {
            gameCenterHandler.reportAchievement(achievementID: "wonFirstGame", percentComplete: 100)
        }
        
        checkForHighestTile()
        
        if highestTile >= 256 {
            gameCenterHandler.reportAchievement(achievementID: "tile256", percentComplete: 100)
        }
        if highestTile >= 512 {
            gameCenterHandler.reportAchievement(achievementID: "tile512", percentComplete: 100)
        }
        if highestTile >= 1024 {
            gameCenterHandler.reportAchievement(achievementID: "tile1024", percentComplete: 100)
        }
        if highestTile >= 2048 {
            gameCenterHandler.reportAchievement(achievementID: "tile2048", percentComplete: 100)
        }
        // Check for time-based achievements
        let totalPlayTime = retrieveTotalPlayTime() // Retrieve this from persistent storage
        checkTimeBasedAchievements(playTime: totalPlayTime)
    }
    
    private func checkTimeBasedAchievements(playTime: Int) {
        // Time is in seconds, so convert hours to seconds for comparison
        if playTime >= 1 * 3600 { // 1 hour
            gameCenterHandler.reportAchievement(achievementID: "hour1Playtime", percentComplete: 100)
        }
        if playTime >= 10 * 3600 { // 10 hours
            gameCenterHandler.reportAchievement(achievementID: "hour10Playtime", percentComplete: 100)
        }
        if playTime >= 25 * 3600 { // 25 hours
            gameCenterHandler.reportAchievement(achievementID: "hour25Playtime", percentComplete: 100)
        }
        if playTime >= 50 * 3600 { // 50 hours
            gameCenterHandler.reportAchievement(achievementID: "hour50Playtime", percentComplete: 100)
        }
        if playTime >= 75 * 3600 { // 75 hours
            gameCenterHandler.reportAchievement(achievementID: "hour75Playtime", percentComplete: 100)
        }
        if playTime >= 100 * 3600 { // 100 hours
            gameCenterHandler.reportAchievement(achievementID: "hour100Playtime", percentComplete: 100)
        }
        // ... Add checks for other time-based achievements
    }

    private func retrieveTotalPlayTime() -> Int {
        // Retrieve the total playtime from UserDefaults or your own persistence layer
        // Example:
        return UserDefaults.standard.integer(forKey: "TotalPlayTime")
    }
    
    // Start a timer when the game starts
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.gameTime += 1
        }
    }

    // Call this function to update the total play time in UserDefaults
    private func updateTotalPlayTime() {
        let currentTotalPlayTime = UserDefaults.standard.integer(forKey: "TotalPlayTime")
        let newTotalPlayTime = currentTotalPlayTime + gameTime
        UserDefaults.standard.set(newTotalPlayTime, forKey: "TotalPlayTime")
    }

    // Call this function when the game ends or pauses
    private func stopGameTimer() {
        timer?.invalidate()
        timer = nil
        updateTotalPlayTime() // Make sure to update the total play time when the game ends
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func isMovePossible() -> Bool {
        for i in 0..<grid.count {
            for j in 0..<grid[i].count {
                let tile = grid[i][j]
                if (i < grid.count - 1 && tile == grid[i + 1][j]) ||
                   (j < grid[i].count - 1 && tile == grid[i][j + 1]) {
                    return true
                }
            }
        }
        return false
    }
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width as CGFloat
        let verticalAmount = value.translation.height as CGFloat

        if abs(horizontalAmount) > abs(verticalAmount) {
            if horizontalAmount > 0 {
                moveRight()
            } else {
                moveLeft()
            }
        } else {
            if verticalAmount > 0 {
                moveDown()
            } else {
                moveUp()
            }
        }
    }

    private func backgroundColor(for value: Int) -> Color {
        switch value {
        case 2: return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 4: return Color(red: 0.92, green: 0.85, blue: 0.72)
        case 8: return Color.orange
        case 16: return Color.red
        case 32: return Color.cyan
        case 64: return Color.purple
        case 128, 256, 512, 1024, 2048: return Color.yellow
        case 4096: return Color.cyan
        default: return Color.gray
        }
    }
        
    private func textColor(for value: Int) -> Color {
        return value < 8 ? Color.black : Color.white
    }

    private var highScoreKey: String {
        "highScore\(gridSize.rawValue)x\(gridSize.rawValue)"
    }

    private func updateHighScore() {
        let currentHighScore = UserDefaults.standard.integer(forKey: highScoreKey)
        if score > currentHighScore {
            UserDefaults.standard.set(score, forKey: highScoreKey)
            highScore = score // Update the current high score state
        } else {
            highScore = currentHighScore // Set to the saved high score if not beaten
        }
    }

    // Game won Overlay
    private var gameWonOverlay: some View {
        Group {
            if isGameWon {
                Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("2048 Achieved!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    Text("Your score this game was \(score), your time was \(formatTime(gameTime)), you made \(moveCount) moves")
                       .font(.headline)
                       .foregroundColor(.white)
                       .multilineTextAlignment(.center)
                       .padding()
                    Button("Restart") {
                        isGameWon = false
                        startNewGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Text("Endless mode - Go as far as you can!")
                       .font(.headline)
                       .foregroundColor(.white)
                       .multilineTextAlignment(.center)
                       .padding()
                    Button("Continue") {
                        isGameWon = false
                        endlessMode = true
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Button("Main Menu") {
                        // Add logic to navigate back to MainScreen
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // Game over Overlay
    private var gameOverOverlay: some View {
        Group {
            if isGameOver {
                Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    Text("Your score this game was \(score), your time was \(formatTime(gameTime)), you made \(moveCount) moves")
                       .font(.headline)
                       .foregroundColor(.white)
                       .multilineTextAlignment(.center)
                       .padding()
                    Button("Restart") {
                        isGameOver = false
                        startNewGame()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    Button("Main Menu") {
                        // Add logic to navigate back to MainScreen
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
        }
    }

    // Rest of the GameView code...
    
    // Score view method
    private func scoreView(title: String, score: Int) -> some View {
        VStack {
            Text(title)
                .font(.headline)
            Text(formatScore(score))
                .font(.title2)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 2)
        )
    }

    // Utility function to format score
    private func formatScore(_ score: Int) -> String {
        if score > 999 {
            let formattedScore = Double(score) / 1000.0
            return String(format: "%.1fK", formattedScore)
        } else {
            return "\(score)"
        }
    }
}

extension GameView {
    var gameTitle: some View {
        HStack(spacing: 0) {
            Text("2").font(.largeTitle).fontWeight(.heavy).foregroundColor(.red)
            Text("0").font(.largeTitle).fontWeight(.heavy).foregroundColor(.green)
            Text("4").font(.largeTitle).fontWeight(.heavy).foregroundColor(.blue)
            Text("8").font(.largeTitle).fontWeight(.heavy).foregroundColor(.orange)
        }
    }
    
    var modeText: some View {
        Group {
            if endlessMode {
                Text("Endless Mode!!")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
    }
    
    var scoreRow: some View {
        HStack {
            scoreView(title: "SCORE", score: score)
            scoreView(title: "HIGH SCORE", score: highScore)
        }
    }
    
    var timeAndMoveCount: some View {
            HStack {
                Text("Time: \(formatTime(gameTime))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Moves: \(moveCount)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }

        var newGameButton: some View {
            Button("New Game") {
                startNewGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(gridSize: .fourByFour)

    }
}
