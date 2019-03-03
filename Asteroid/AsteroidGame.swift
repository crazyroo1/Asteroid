//
//  AsteroidGame.swift
//  Asteroid
//
//  Created by Turner Eison on 2/28/19.
//  Copyright © 2019 Turner Eison. All rights reserved.
//

import Foundation
import SpriteKit
struct PhysicsCategories {
    static let player: UInt32 = 0x1 << 1
    static let plorb: UInt32 = 0x1 << 2
    static let worldBorder: UInt32 = 0x1 << 3
    static let paint: UInt32 = 0x1 << 4
}
class AsteroidGame: SKScene, SKPhysicsContactDelegate {
    
    enum fireState {
        case canFire
        case didFire
        case cannotFire
    }
    
    private var lastUpdateTime: TimeInterval = 0
    
    let player = SKSpriteNode(imageNamed: "brush")
    let dUp = SKSpriteNode(imageNamed: "d")
    let dRight = SKSpriteNode(imageNamed: "d")
    let dDown = SKSpriteNode(imageNamed: "d")
    let dLeft = SKSpriteNode(imageNamed: "d")
    let dNode = SKNode()
    let fireButton = SKSpriteNode(imageNamed: "fire")
    
    var isTouchingLeft = false
    var isTouchingRight = false
    var isTouchingUp = false
    var isTouchingDown = false
    var isTouchingFire = false
    
    var fireable = fireState.canFire
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        scene?.physicsWorld.gravity = CGVector.zero
        scene?.physicsBody = SKPhysicsBody(edgeLoopFrom: (scene?.frame)!)
        scene?.physicsBody?.categoryBitMask = PhysicsCategories.worldBorder
        scene?.physicsBody?.collisionBitMask = PhysicsCategories.player
        scene?.physicsBody?.isDynamic = false
        
        player.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "brush"), alphaThreshold: 0.5, size: player.size)
        player.physicsBody?.categoryBitMask = PhysicsCategories.player
        player.physicsBody?.contactTestBitMask = PhysicsCategories.plorb
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        scene?.addChild(player)
        
        dUp.xScale = 3
        dDown.xScale = 3
        dRight.xScale = 3
        dLeft.xScale = 3
        dRight.zRotation = 3 * CGFloat.pi / 2
        dDown.zRotation = CGFloat.pi
        dLeft.zRotation = CGFloat.pi / 2
        dUp.position = CGPoint(x: 0, y: dUp.frame.height / 2)
        dRight.position = CGPoint(x: dRight.frame.width / 2, y: 0)
        dDown.position = CGPoint(x: 0, y: -dDown.frame.height / 2)
        dLeft.position = CGPoint(x: -dLeft.frame.width / 2, y: 0)
        dNode.addChild(dUp)
        dNode.addChild(dRight)
        dNode.addChild(dDown)
        dNode.addChild(dLeft)
        dNode.zPosition = 9
        dNode.position = CGPoint(x: scene!.frame.maxX - dUp.frame.height * 1.5, y: scene!.frame.minY + dUp.frame.height * 1.5)
        scene?.addChild(dNode)
        
        fireButton.position = CGPoint(x: -dNode.position.x, y: dNode.position.y)
        fireButton.zPosition = 9
        scene?.addChild(fireButton)
        
        let create = SKAction.run {
            self.scene!.addChild(self.plorbCreator())
        }
        let delay = SKAction.wait(forDuration: 1)
        let sequence = SKAction.sequence([create, delay])
        let repeatForever = SKAction.repeatForever(sequence)
        self.run(repeatForever)
        
    }
    
    func plorbCreator() -> SKSpriteNode {
        let standardPlorbHealth: Plorb.HP = 10
//        let blobby = SKSpriteNode(imageNamed: "blobby\(Int.random(in: 1...2))")
        let plorbType = Int.random(in: 1...2)
//        let plorbType = 1
        var health: Plorb.HP
        switch plorbType {
        case 1:
            health = standardPlorbHealth
        case 2:
            health = standardPlorbHealth * 2
        default:
            health = standardPlorbHealth
        }
        
        let plorb = Plorb(texture: SKTexture(imageNamed: "plorb\(plorbType)"), color: .black, size: SKTexture(imageNamed: "plorb\(plorbType)").size(), health: health)
        plorb.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "plorb\(plorbType)"), alphaThreshold: 0.5, size: plorb.size)
        plorb.physicsBody?.categoryBitMask = PhysicsCategories.plorb
        plorb.physicsBody?.contactTestBitMask = PhysicsCategories.player | PhysicsCategories.paint
        plorb.physicsBody?.collisionBitMask = PhysicsCategories.player | PhysicsCategories.paint
        
        
        plorb.position = CGPoint(x: CGFloat.random(in: scene!.frame.minX...scene!.frame.maxX), y: scene!.frame.maxY + plorb.frame.height / 2)
        plorb.physicsBody?.allowsRotation = false
        plorb.physicsBody?.linearDamping = 0
        plorb.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -5...5), dy: -200)
        
        
        return plorb
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let p = touch.location(in: scene!)
            
            if dNode.contains(p) {
                let pos = touch.location(in: dNode)
                if dUp.contains(pos) {
                    isTouchingUp = true
                }
                if dRight.contains(pos) {
                    isTouchingRight = true
                }
                if dDown.contains(pos) {
                    isTouchingDown = true
                }
                if dLeft.contains(pos) {
                    isTouchingLeft = true
                }
            }
            if(fireButton.contains(p) && isTouchingFire == false) {
                isTouchingFire = true
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let p = touch.previousLocation(in: scene!)
            if fireButton.contains(p) {
                fireable = .canFire
                isTouchingFire = false
            } else {
                isTouchingUp = false
                isTouchingDown = false
                isTouchingLeft = false
                isTouchingRight = false
            }
        }
    }
    
    func fire() {
        let paintNumber = Int.random(in: 1...3)
        let paint = SKSpriteNode(imageNamed: "paint\(paintNumber)")
        paint.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "paint\(paintNumber)"), alphaThreshold: 0.8, size: paint.size)
        paint.physicsBody?.linearDamping = 0
        paint.physicsBody?.categoryBitMask = PhysicsCategories.paint
//        paint.physicsBody?.contactTestBitMask = PhysicsCategories.plorb
        paint.physicsBody?.collisionBitMask = PhysicsCategories.plorb
        paint.physicsBody?.mass = 1000
        paint.zPosition = -1
        paint.position = CGPoint(x: player.position.x, y: player.position.y + player.frame.height / 2 + paint.frame.height / 2)
        paint.physicsBody?.velocity = CGVector(dx: 0, dy: 2000)
        scene?.addChild(paint)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        if isTouchingDown {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -5))
        }
        if isTouchingLeft {
            player.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 0))
        }
        if isTouchingRight {
            player.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 0))
        }
        if isTouchingUp {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5))
        }
        
        if isTouchingFire == true && fireable == .canFire {
            fire()
            fireable = .didFire
        }
        
        for node in scene!.children {
            if let node = node as? SKSpriteNode {
                if !scene!.frame.insetBy(dx: -player.frame.height, dy: -player.frame.height).contains(node.position) {
                    node.removeFromParent()
                }
            }
        }
        
        self.lastUpdateTime = currentTime
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        //player and plorb
        if((contact.bodyA.categoryBitMask == PhysicsCategories.player && contact.bodyB.categoryBitMask == PhysicsCategories.plorb) || (contact.bodyB.categoryBitMask == PhysicsCategories.player && contact.bodyA.categoryBitMask == PhysicsCategories.plorb)) {
            gameOver()
        }
        
        //paint and plorb
        if((contact.bodyA.categoryBitMask == PhysicsCategories.paint && contact.bodyB.categoryBitMask == PhysicsCategories.plorb)) {
            (contact.bodyB.node as! Plorb).damage(by: 5)
            contact.bodyA.node?.removeFromParent()
        }
        if((contact.bodyB.categoryBitMask == PhysicsCategories.paint && contact.bodyA.categoryBitMask == PhysicsCategories.plorb)) {
            (contact.bodyA.node as! Plorb).damage(by: 5)
            contact.bodyB.node?.removeFromParent()
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
    }
    
    func gameOver() {
        
    }
}

extension CGFloat {
    public func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if x < min {
            return min
        }
        if x > max {
            return max
        }
        return x
    }
}
