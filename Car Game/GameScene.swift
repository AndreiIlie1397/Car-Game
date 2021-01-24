//
//  GameScene.swift
//  Car Game
//
//  Created by Andrei on 09/04/2020.
//  Copyright © 2020 Andrei. All rights reserved.
//

import SpriteKit
import GameplayKit

struct ColliderType {
    static let CAR_COLLIDER : UInt32 = 0
    static let ITEM_COLLIDER : UInt32 = 1
    static let ITEM_COLLIDER_1 : UInt32 = 2
    static let GLONT_COLLIDER : UInt32 = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var topCar = SKSpriteNode()
    var bottomCar = SKSpriteNode()
    
    var slowmo_top = SKSpriteNode()
    var fastforward_top = SKSpriteNode()
    var gloante_top = SKSpriteNode()
    
    var slowmo_bottom = SKSpriteNode()
    var fastforward_bottom = SKSpriteNode()
     var gloante_bottom = SKSpriteNode()
    
    var score_top = SKLabelNode()
    var score_bottom = SKLabelNode()
    
    var topGlont = SKSpriteNode(imageNamed: "line")
    var bottomGlont = SKSpriteNode(imageNamed: "line")
    
    var topTraficItem = SKSpriteNode(imageNamed: "line")
    var bottomTraficItem = SKSpriteNode(imageNamed: "line")
    
    var canMove = false
    
    var topCarAt = false
    var bottomCarAt = false
    
    var topCarToMove = true
    var bottomCarToMove = true
    
    var top_slowmo = false
    var top_fastforward = false
    
    var bottom_slowmo = false
    var bottom_fastforward = false
    
    var top_gloante = 10
    var bottom_gloante = 10
    
    var top_glont = false
    var bottom_glont = false
    
    static var top = false //daca castiga top devine true
    static var bottom = false //daca castiga bottom devine true
    
    let CarMinimumX : CGFloat = -140 //punctul minim pentru a misca masina
    let CarMaximumX : CGFloat = 140 //punctul maxim pentru a misca masina
    
    var centerPoint : CGFloat!
    
    let second = 10.0 //durata puterilor
    
    var score_t = 0 {
        didSet {
            score_top.text = "\(score_t)"
        }
    }
    var score_b = 0 {
        didSet {
            score_bottom.text = "\(score_b)"
        }
    }
    
    func setUp() {
        topCar = self.childNode(withName: "topCar") as! SKSpriteNode
        bottomCar = self.childNode(withName: "bottomCar") as! SKSpriteNode
        
        slowmo_bottom = self.childNode(withName: "slow-mo_bottom") as! SKSpriteNode
        slowmo_bottom.texture = SKTexture(imageNamed: "slow-mo")
        
        fastforward_bottom = self.childNode(withName: "fast-forward_bottom") as! SKSpriteNode
        fastforward_bottom.texture = SKTexture(imageNamed: "fast-forward")
        
        gloante_bottom = self.childNode(withName: "gloante_bottom") as! SKSpriteNode
        gloante_bottom.texture = SKTexture(imageNamed: "gloante")
        
        slowmo_top = self.childNode(withName: "slow-mo_top") as! SKSpriteNode
        slowmo_top.texture = SKTexture(imageNamed: "slow-mo")
        
        fastforward_top = self.childNode(withName: "fast-forward_top") as! SKSpriteNode
        fastforward_top.texture = SKTexture(imageNamed: "fast-forward")
        
        gloante_top = self.childNode(withName: "gloante_top") as! SKSpriteNode
        gloante_top.texture = SKTexture(imageNamed: "gloante")
        
        topCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        topCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        topCar.physicsBody?.collisionBitMask = 0
        
        bottomCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        bottomCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        bottomCar.physicsBody?.collisionBitMask = 0
        
        topGlont.physicsBody?.categoryBitMask = ColliderType.GLONT_COLLIDER
        topGlont.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        topGlont.physicsBody?.collisionBitMask = 3
 
        bottomGlont.physicsBody?.categoryBitMask = ColliderType.GLONT_COLLIDER
        bottomGlont.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        bottomGlont.physicsBody?.collisionBitMask = 3
    }
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x:0.5, y:0.5)
        setUp()
        physicsWorld.contactDelegate = self
        
        score_top = SKLabelNode(fontNamed: "score_top")
        score_top.position = CGPoint(x: 275, y: 100)
        score_top.zRotation = .pi
        addChild(score_top)
        
        score_bottom = SKLabelNode(fontNamed: "score_bottom")
        score_bottom.position = CGPoint(x: -275, y: -100)
        addChild(score_bottom)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(GameScene.Trafic), userInfo: nil, repeats: true)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if canMove {
            move(topSide: topCarToMove)
            move(bottomSide: bottomCarToMove)
        }
        
        showRoadStrip()
        showGlont()
        
        if(top_fastforward == true) {
            top_fastforwardRoadStrip() //top confera fast-forward pentru bottom
        } else if(top_slowmo == true){
            top_slowmoRoadStrip() //top confera slow-mo pentru top
        } else if(bottom_fastforward == true){
            bottom_fastforwardRoadStrip() //bottom confera fast-forward pentru top
        } else if(bottom_slowmo == true){
            bottom_slowmoRoadStrip() //bottom confera slow-mo pentru bottom
        } else {
            showObstacle()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
      
        if(contact.bodyA.node?.name == "topCar" && contact.bodyB.node?.name == "line") { //coliziune top
            score_b += 1
        } else if(contact.bodyA.node?.name == "bottomCar" && contact.bodyB.node?.name == "line1") { //coliziune bottom
            score_t += 1
        }
        
        if(score_t == 10){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                GameScene.top = true
                let finishScene = SKScene(fileNamed: "FinishGame")!
                finishScene.scaleMode = .aspectFill
                self.view?.presentScene(finishScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
            }
        } else if(score_b == 10){
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                GameScene.bottom = true
                let finishScene = SKScene(fileNamed: "FinishGame")!
                finishScene.scaleMode = .aspectFill
                self.view?.presentScene(finishScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            let touchedNode = self.atPoint(touchLocation)
            let name = touchedNode.name
            if(touchLocation.y > 0 && (touchLocation.x < 225 && touchLocation.x > -225)  && name != "topCar"){ //ecranul din partea de sus
                if topCarAt {
                    topCarAt = false
                    topCarToMove = true
                } else {
                    topCarAt = true
                    topCarToMove = false
                }
            } else if(touchLocation.y < 0 && (touchLocation.x < 225 && touchLocation.x > -225) && name != "bottomCar") { //ecranul din partea de jos
                if bottomCarAt {
                    bottomCarAt = false
                    bottomCarToMove = true
                } else {
                    bottomCarAt = true
                    bottomCarToMove = false
                }
            }
            canMove = true
            
            if(name == "topCar"){
                if(top_gloante > 0){
                    if(top_glont == false){
                        top_glont = true
                        top_gloante = top_gloante - 1
                        createTopGlont()
                }
                } else {
                    top_glont = false
                    gloante_top.removeFromParent()
                }
            } else if(name == "bottomCar"){
                if(bottom_gloante > 0){
                    if(bottom_glont == false){
                        bottom_glont  = true
                        bottom_gloante = bottom_gloante - 1
                        createBottomGlont()
                    }
                } else {
                    bottom_glont = false
                    gloante_bottom.removeFromParent()
                }
            }
            
            if((touchLocation.x >= -300 && touchLocation.x <= -250) && (touchLocation.y >= 275 && touchLocation.y <= 325) && name == "fast-forward_top"){
                top_fastforward = true
                fastforward_top.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    self.top_fastforward = false
                }
            } else if((touchLocation.x >= -300 && touchLocation.x <= -250) && (touchLocation.y >= 175 && touchLocation.y <= 225) && name == "slow-mo_top"){
                top_slowmo = true
                slowmo_top.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    self.top_slowmo = false
                }
            } else if((touchLocation.x >= 250 && touchLocation.x <= 300) && (touchLocation.y >= -125 && touchLocation.y <= -75) && name == "fast-forward_bottom"){
                bottom_fastforward = true
                fastforward_bottom.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    self.bottom_fastforward = false
                }
            } else if((touchLocation.x >= 250 && touchLocation.x <= 300) && (touchLocation.y >= -225 && touchLocation.y <= -175) && name == "slow-mo_bottom"){
                bottom_slowmo = true
                slowmo_bottom.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + second) {
                    self.bottom_slowmo = false
                }
            }
        }
    }
    
    @objc func createRoadStrip() { //creare drum
        let topRoadStrip = SKShapeNode(rectOf:CGSize(width: 10, height: 50))
        topRoadStrip.strokeColor = SKColor.white
        topRoadStrip.fillColor = SKColor.white
        topRoadStrip.name = "topRoadStrip"
        topRoadStrip.zPosition = 10
        topRoadStrip.position.x = 0
        topRoadStrip.position.y = 0
        addChild(topRoadStrip)
        
        let bottomRoadStrip = SKShapeNode(rectOf:CGSize(width: 10, height: 50))
        bottomRoadStrip.strokeColor = SKColor.white
        bottomRoadStrip.fillColor = SKColor.white
        bottomRoadStrip.name = "bottomRoadStrip"
        bottomRoadStrip.zPosition = 10
        bottomRoadStrip.position.x = 0
        bottomRoadStrip.position.y = 0
        addChild(bottomRoadStrip)
    }
    
    @objc func showRoadStrip() { //afiseaza drumul
            enumerateChildNodes(withName: "topRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y += 5
        })
        
        enumerateChildNodes(withName: "bottomRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= 5
        })
    }
    
    func showObstacle(){ //afiseaza obstacolele (varianta default)
        enumerateChildNodes(withName: "line", using: { (topCar, stop) in
            let wall = topCar as! SKSpriteNode
            wall.position.y += 5
            if(wall.position.y > 660){
              wall.removeFromParent()
            }
        })
        
        enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
            let wall = bottomCar as! SKSpriteNode
            wall.position.y -= 5
             if(wall.position.y < -660){
               wall.removeFromParent()
            }
        })
    }
    
    @objc func createTopGlont(){
        topGlont.size = CGSize(width: 20, height: 200)
        topGlont.zRotation = .pi/2
        topGlont.name = "topGlont"
        topGlont.zPosition = 10
        topGlont.position.x = topCar.position.x
        topGlont.position.y = topCar.position.y
        addChild(topGlont)
    }
    
    @objc func createBottomGlont(){
        bottomGlont.size = CGSize(width: 20, height: 200)
        bottomGlont.zRotation = .pi/2
        bottomGlont.name = "bottomGlont"
        bottomGlont.zPosition = 10
        bottomGlont.position.x = bottomCar.position.x
        bottomGlont.position.y = bottomCar.position.y
        addChild(bottomGlont)
    }
    
    @objc func showGlont(){
        enumerateChildNodes(withName: "topGlont", using: { (topGlont, stop) in
            let glont = topGlont as! SKSpriteNode
            glont.position.y -= 10
            if(glont.position.x != self.topTraficItem.position.x){
                if(glont.position.y <= 0){
                    self.top_glont = false
                    glont.removeFromParent()
                }
            } else if(glont.position.x == self.topTraficItem.position.x){
                if(glont.position.y <= 0){
                    self.top_glont = false
                    self.topTraficItem.removeFromParent()
                    glont.removeFromParent()
                } else if(glont.position.y <= self.topTraficItem.position.y){
                    self.top_glont = false
                    self.topTraficItem.removeFromParent()
                    glont.removeFromParent()
                }
            }
        })
        
        enumerateChildNodes(withName: "bottomGlont", using: { (bottomGlont, stop) in
            let glont = bottomGlont as! SKSpriteNode
            glont.position.y += 10
            if(glont.position.x != self.topTraficItem.position.x){
                if(glont.position.y >= 0){
                    self.bottom_glont = false
                    glont.removeFromParent()
                }
            } else if(glont.position.x == self.bottomTraficItem.position.x){
                if(glont.position.y >= 0){
                    self.bottom_glont = false
                    self.bottomTraficItem.removeFromParent()
                    glont.removeFromParent()
                } else if(glont.position.y >= self.bottomTraficItem.position.y){
                    self.bottom_glont = false
                    self.bottomTraficItem.removeFromParent()
                    glont.removeFromParent()
                }
            }
        })
    }
    
    func top_fastforwardRoadStrip() {//top confera fast-forward pentru bottom
        if(bottom_slowmo == true){
            if(bottom_fastforward == true){
                if(top_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(top_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            } else if(bottom_fastforward == false){
                if(top_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(top_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        } else if(bottom_slowmo == false){
            if(bottom_fastforward == true){
                if(top_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                } else if(top_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                }
            } else if(bottom_fastforward == false){
                if(top_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                } else if(top_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                }
            }
        }
    }

    func top_slowmoRoadStrip() { //top confera slow-mo pentru top
        if(bottom_fastforward == true){
            if(bottom_slowmo == true){
                if(top_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(top_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                }
            } else if(bottom_slowmo == false){
                if(top_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                } else if(top_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        } else if(bottom_fastforward == false) {
            if(bottom_slowmo == true){
                if(top_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(top_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                }
            }else if(bottom_slowmo == false){
                if(top_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                } else if(top_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        }
    }

    func bottom_fastforwardRoadStrip() { //bottom confera fast-forward pentru top
        if(top_slowmo == true){
            if(top_fastforward == true){
                if(bottom_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(bottom_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                }
            } else if(top_fastforward == false){
                if(bottom_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                } else if(bottom_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        } else if(top_slowmo == false){
            if(top_fastforward == true){
                if(bottom_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(bottom_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 10})
                }
            } else if(top_fastforward == false){
                if(bottom_slowmo == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                } else if(bottom_slowmo == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        }
    }

    func bottom_slowmoRoadStrip() { //bottom confera slow-mo pentru bottom
        if(top_fastforward == true){
            if(top_slowmo == true){
                if(bottom_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(bottom_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            } else if(top_slowmo == false){
                if(bottom_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                } else if(bottom_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 5})
                }
            }
        } else if(top_fastforward == false){
            if(top_slowmo == true){
                if(bottom_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                } else if(bottom_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 2})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                }
            } else if(top_slowmo == false){
                if(bottom_fastforward == true){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 10})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                } else if(bottom_fastforward == false){
                    enumerateChildNodes(withName: "line", using: { (topCar, stop) in
                        let wall = topCar as! SKSpriteNode
                        wall.position.y += 5})
                    enumerateChildNodes(withName: "line1", using: { (bottomCar, stop) in
                        let wall = bottomCar as! SKSpriteNode
                        wall.position.y -= 2})
                }
            }
        }
    }
    
    func move(topSide:Bool){
        if (topSide == true){
            topCar.position.x -= 10
            if topCar.position.x < CarMinimumX {
                topCar.position.x = CarMinimumX
            }
        } else if(topSide == false){
            topCar.position.x += 10
            if topCar.position.x > CarMaximumX {
                topCar.position.x = CarMaximumX
            }
        }
    }
    
    func move(bottomSide:Bool){
        if (bottomSide == true){
            bottomCar.position.x -= 10
            if bottomCar.position.x < CarMinimumX {
                bottomCar.position.x = CarMinimumX
            }
        } else  if(bottomSide == false){
            bottomCar.position.x += 10
            if bottomCar.position.x > CarMaximumX {
                bottomCar.position.x = CarMaximumX
            }
        }
    }
    
    @objc func Trafic(){
        topTraficItem = SKSpriteNode(imageNamed: "line")
        topTraficItem.size = CGSize(width: 210, height: 150)
        topTraficItem.name = "line"
        topTraficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        topTraficItem.zPosition = 10
        
        bottomTraficItem = SKSpriteNode(imageNamed: "line")
        bottomTraficItem.size = CGSize(width: 210, height: 150)
        bottomTraficItem.name = "line1"
        bottomTraficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        bottomTraficItem.zPosition = 10
        
        let randomNum = Int.random(in: 1...2)
        switch randomNum {
        case 1:
            topTraficItem.position.x = -140
            bottomTraficItem.position.x = -140
            break
        case 2:
            topTraficItem.position.x = 140
            bottomTraficItem.position.x = 140
            break
        default:
            topTraficItem.position.x = -140
            bottomTraficItem.position.x = -140
        }
        topTraficItem.position.y = 0
        topTraficItem.physicsBody = SKPhysicsBody(circleOfRadius: topTraficItem.size.height/8)
        topTraficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        topTraficItem.physicsBody?.collisionBitMask = 0
        topTraficItem.physicsBody?.collisionBitMask = 3
        topTraficItem.physicsBody?.affectedByGravity = false
        addChild(topTraficItem)
        
        bottomTraficItem.position.y = 0
        bottomTraficItem.physicsBody = SKPhysicsBody(circleOfRadius: bottomTraficItem.size.height/8)
        bottomTraficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        bottomTraficItem.physicsBody?.collisionBitMask = 0
        bottomTraficItem.physicsBody?.collisionBitMask = 3
        bottomTraficItem.physicsBody?.affectedByGravity = false
        addChild(bottomTraficItem)
    }
}
