//
//  GameMenu.swift
//  Crash
//
//  Created by Robin Naggi on 1/23/19.
//  Copyright © 2019 Robin Naggi. All rights reserved.
//

import Foundation
import SpriteKit

class GameMenu: SKScene {
    
    var startGame = SKLabelNode() // Start game label
    var bestScore = SKLabelNode() // best score label
    var gameSetting = Setting.sharedInstance // highed score of the game
    
    
    
    /// Linkes the label as a button
    ///
    /// - Parameter view: <#view description#>
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        bestScore = self.childNode(withName: "bestScore") as! SKLabelNode
        bestScore.text = "BEST: \(gameSetting.highScore)"
    }
    
    /// Finds the location of where the user touched the screen
    ///
    /// - Parameters:
    ///   - touches: touch location
    ///   - event: <#event description#>
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame" {
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: SKTransition.doorsOpenVertical(withDuration: TimeInterval(2)))
            }
        }
    }
}
