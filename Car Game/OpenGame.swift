//
//  OpenGame.swift
//  Car Game
//
//  Created by Andrei on 16/04/2020.
//  Copyright © 2020 Andrei. All rights reserved.
//

import Foundation
import SpriteKit

class OpenGame: SKScene{
    var startGame = SKLabelNode()
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame"{
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(1)))
            }
        }
    }
}
