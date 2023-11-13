//
//  ContentView.swift
//  IOS2048game
//
//  Created by Caleb on 11/13/23.
//

import SwiftUI

struct ContentView: View {
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score: Int = 0
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "highScore")

    var body: some View {
        VStack(spacing: 20) {
            Text("SCORE: \(score)")
                .font(.headline)
            Text("HIGH SCORE: \(highScore)")
                .font(.headline)

            VStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { i in
                    HStack(spacing: 5) {
                        ForEach(0..<4, id: \.self) { j in
                            Text(grid[i][j] == 0 ? "" : "\(grid[i][j])")
                                .frame(width: 70, height: 70)
                                .background(backgroundColor(for: grid[i][j]))
                                .foregroundColor(textColor(for: grid[i][j]))
                                .font(Font.system(size: grid[i][j] == 0 ? 20 : 24, weight: .bold, design: .default))
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)

            Button("New Game") {
                startNewGame()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear(perform: startNewGame)
        .gesture(DragGesture(minimumDistance: 20).onEnded(handleSwipe))
    }

    // Game Logic
    private func startNewGame() {
        score = 0
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        addNumber()
        addNumber()
    }

    private func addNumber() {
        var emptyCells = [(Int, Int)]()
        for i in 0..<4 {
            for j in 0..<4 {
                if grid[i][j] == 0 {
                    emptyCells.append((i, j))
                }
            }
        }
        if let (x, y) = emptyCells.randomElement() {
            grid[x][y] = Int.random(in: 1...2) * 2
        }
    }

    private func handleSwipe(_ value: DragGesture.Value) {
        let delta = value.translation
        if abs(delta.width) > abs(delta.height) {
            if delta.width > 0 {
                moveRight()
            } else {
                moveLeft()
            }
        } else {
            if delta.height > 0 {
                moveDown()
            } else {
                moveUp()
            }
        }
    }
    
    // Movement and merging logic
    // ...
    private func moveRight() {
        var moved = false
        for i in 0..<4 {
            var line = grid[i].filter { $0 != 0 }
            let missing = 4 - line.count
            line = Array(repeating: 0, count: missing) + line

            for j in (1..<4).reversed() {
                if line[j] == line[j-1] && line[j] != 0 {
                    line[j] *= 2
                    score += line[j]
                    line[j-1] = 0
                    moved = true
                }
            }
            line = line.filter { $0 != 0 }
            while line.count < 4 {
                line.insert(0, at: 0)
            }
            if grid[i] != line {
                moved = true
                grid[i] = line
            }
        }
        if moved {
            addNumber()
        }
        updateHighScore()
    }

    // Move tiles to the left
    private func moveLeft() {
        var moved = false
        for i in 0..<4 {
            var line = grid[i].filter { $0 != 0 } // Remove all zeros
            let originalLine = line
            var index = 0
            while index < line.count - 1 {
                if line[index] == line[index + 1] {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index + 1)
                    moved = true
                }
                index += 1
            }
            let missing = 4 - line.count
            line += Array(repeating: 0, count: missing) // Append zeros at the end
            if line != originalLine {
                moved = true
            }
            grid[i] = line
        }
        if moved {
            addNumber()
            updateHighScore()
        }
    }
    
    // Move tiles down
    private func moveDown() {
        var moved = false
        for j in 0..<4 {
            var line = [Int]()
            for i in 0..<4 {
                if grid[i][j] != 0 {
                    line.append(grid[i][j])
                }
            }
            let originalLine = line
            var index = line.count - 1
            while index > 0 {
                if line[index] == line[index - 1] {
                    line[index] *= 2
                    score += line[index]
                    line.remove(at: index - 1)
                    index -= 1
                    moved = true
                }
                index -= 1
            }
            let missing = 4 - line.count
            line = Array(repeating: 0, count: missing) + line // Insert zeros at the beginning
            if line != originalLine.reversed() {
                moved = true
            }
            for i in 0..<4 {
                grid[i][j] = line.reversed()[i]
            }
        }
        if moved {
            addNumber()
            updateHighScore()
        }
    }
    
    // Move tiles up
    private func moveUp() {
        var moved = false
        for j in 0..<4 {
            var line = [Int]()
            for i in 0..<4 {
                if grid[i][j] != 0 {
                    line.append(grid[i][j])
                }
            }
            let originalLine = line
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
            let missing = 4 - line.count
            line += Array(repeating: 0, count: missing) // Append zeros at the end
            if line != originalLine {
                moved = true
            }
            for i in 0..<4 {
                grid[i][j] = line[i]
            }
        }
        if moved {
            addNumber()
            updateHighScore()
        }
    }

    // Utility functions
    private func backgroundColor(for value: Int) -> Color {
        switch value {
        case 2: return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 4: return Color(red: 0.92, green: 0.85, blue: 0.72)
        case 8: return Color.orange
        case 16: return Color.red
        case 32: return Color.pink
        case 64: return Color.purple
        case 128, 256, 512, 1024, 2048: return Color.yellow
        default: return Color.gray
        }
    }
    
    private func textColor(for value: Int) -> Color {
        return value < 8 ? Color.black : Color.white
    }

    private func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "highScore")
        }
    }
}

// Implement the remaining move functions with similar logic
// ...

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
