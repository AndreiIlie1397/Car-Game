//
//  FinishGame.swift
//  Car Game
//
//  Created by Andrei on 16/04/2020.
//  Copyright © 2020 Andrei. All rights reserved.
//

import Foundation
import SpriteKit

class FinishGame: SKScene{
    
    var startGame = SKLabelNode()
    var castigator = SKLabelNode()
    
    let top = GameScene.top
    let bottom = GameScene.bottom
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        
        if(top == true){ //top a castigat
            castigator.text = "Playerul top a castigat"
            castigator.fontSize = 60
            castigator.position.y = 100
            addChild(castigator)
        } else if(bottom == true){ //bottom a castigat
            castigator.text = "Playerul bottom a castigat"
            castigator.fontSize = 60
            castigator.position.y = 100
            addChild(castigator)
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame"{
                GameScene.top = false
                GameScene.bottom = false
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(1)))
            }
        }
    }
}
