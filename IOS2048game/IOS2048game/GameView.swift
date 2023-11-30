//
//  GameView.swift
//  IOS2048game
//
//  Created by Caleb on 11/13/23.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var playerManger: PlayerManager
    let gridSize: GridSize
    @State private var grid: [[Int]]
    @State private var score: Int = 0
    @State private var highScore: Int = 0 // Initialized later
    @State private var moveCount: Int = 0
    @State private var isGameOver = false

    @Environment(\.presentationMode) var presentationMode
    
    @State private var gameTime = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(playerManager: PlayerManager, gridSize: GridSize) {
        self.gridSize = gridSize
        self.playerManger = playerManager
        let size = gridSize.rawValue
        _grid = State(initialValue: Array(repeating: Array(repeating: 0, count: size), count: size))
    }

    var body: some View {
        VStack(spacing: 20) {
            // Big 2048 title with each letter in different color
            HStack(spacing: 0) {
                Text("2").font(.largeTitle).fontWeight(.heavy).foregroundColor(.red)
                Text("0").font(.largeTitle).fontWeight(.heavy).foregroundColor(.green)
                Text("4").font(.largeTitle).fontWeight(.heavy).foregroundColor(.blue)
                Text("8").font(.largeTitle).fontWeight(.heavy).foregroundColor(.orange)
            }

            // Subtitle text
            Text("Merge tiles to get the 2048 tile!")
                .font(.headline)
                .foregroundColor(.gray)

            // Score and High Score display
            HStack {
                scoreView(title: "SCORE", score: score)
                scoreView(title: "HIGH SCORE", score: highScore)
            }

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
            // Time and Move Count in HStack
            HStack {
                Text("Time: \(formatTime(gameTime))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading) // Aligns to left

                Text("Moves: \(moveCount)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .trailing) // Aligns to right
            }

            
            Button("New Game") {
                startNewGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
        .onReceive(timer) { _ in
            if !isGameOver {
                gameTime += 1
            }
        }
        .onAppear {
            highScore = UserDefaults.standard.integer(forKey: highScoreKey)
            startNewGame()
        }
        .gesture(DragGesture(minimumDistance: 20).onEnded(handleSwipe))
        .overlay(gameOverOverlay)
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
        checkForGameOver()
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
            checkForGameOver()
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
            checkForGameOver()
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
            checkForGameOver()
        }
    }


    // Utility functions
    private func checkForGameOver() {
        if !grid.flatMap({ $0 }).contains(0) && !isMovePossible() {
            isGameOver = true
            updateHighScore() // Ensure the high score is updated when the game is over
        }
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

    // Game Over Overlay
    private var gameOverOverlay: some View {
        Group {
            if isGameOver {
                Color.black.opacity(0.75).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
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

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(playerManager: PlayerManager(), gridSize: .fourByFour)
    }
}
