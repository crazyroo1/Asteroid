//
//  Plorb.swift
//  Asteroid
//
//  Created by Turner Eison on 3/1/19.
//  Copyright © 2019 Turner Eison. All rights reserved.
//

import Foundation
import SpriteKit
class Plorb: SKSpriteNode {
    
    public typealias HP = Int
    
    private var hp = 0
    
    ///Gets the health of the Plorb
    public var health: HP {
        get {
            return hp
        }
    }
    
    init(texture: SKTexture?, color: UIColor, size: CGSize, health: HP) {
        super.init(texture: texture, color: color, size: size)
        self.hp = health
    }
    
    public func damage(by damage: HP) {
        hp -= damage
        if hp <= 0 {
            die()
        }
    }
    
    private func die() {
        //implement death
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
