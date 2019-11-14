//
//  GameScene.swift
//  Sushi Neko
//
//  Created by Make School Loner on 11/10/19.
//  Copyright © 2019 Make School. All rights reserved.
//

import SpriteKit

/* Tracking enum for use with character and sushi side */
enum Side {
    case left, right, none
}

enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
    
    /* Game objects */
    var sushiBasePiece: SushiPiece!
    /* Cat Character */
    var character: Character!
    /* Sushi tower array */
    var sushiTower: [SushiPiece] = []
    /* Game management */
    var state: GameState = .title
    var playButton: MSButtonNode!
    var healthBar: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var health: CGFloat = 1.0 {
        didSet {
            if health > 1.0 {
                health = 1.0
            }
            healthBar.xScale = health
        }
    }
    var score: Int = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    
    
    func addTowerPiece(side: Side) {
       /* Add a new sushi piece to the sushi tower */

       /* Copy original sushi piece */
       let newPiece = sushiBasePiece.copy() as! SushiPiece
       newPiece.connectChopsticks()

       /* Access last piece properties */
       let lastPiece = sushiTower.last

       /* Add on top of last piece, default on first piece */
       let lastPosition = lastPiece?.position ?? sushiBasePiece.position
       newPiece.position.x = lastPosition.x
       newPiece.position.y = lastPosition.y + 55

       /* Increment Z to ensure it's on top of the last piece, default on first piece*/
       let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
       newPiece.zPosition = lastZPosition + 1

       /* Set side */
       newPiece.side = side

       /* Add sushi to scene */
       addChild(newPiece)

       /* Add sushi piece to the sushi tower */
       sushiTower.append(newPiece)
    }
    
    func addRandomPieces(total: Int) {
        /* Add random sushi pieces to the sushi tower */

        for _ in 1...total {

            /* Need to access last piece properties */
            let lastPiece = sushiTower.last!

            /* Need to ensure we don't create impossible sushi structures */
            if lastPiece.side != .none {
                addTowerPiece(side: .none)
            } else {

                /* Random Number Generator */
                let rand = arc4random_uniform(100)

                if rand < 45 {
                    /* 45% Chance of a left piece */
                    addTowerPiece(side: .left)
                } else if rand < 90 {
                    /* 45% Chance of a right piece */
                    addTowerPiece(side: .right)
                } else {
                    /* 10% Chance of an empty piece */
                    addTowerPiece(side: .none)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if state == .gameOver || state == .title { return }
        if state == .ready { state = .playing }
        
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if location.x > size.width / 2 {
            character.side = .right
        } else {
            character.side = .left
        }
        
        if let firstPiece = sushiTower.first as SushiPiece? {
            if character.side == firstPiece.side {
                gameOver()
                return
            }
            health += 0.065
            /* Increment score */
            score += 1
            /* Remove from sushi tower array */
            sushiTower.removeFirst()
            firstPiece.flip(character.side)
            /* Add a new sushi piece to the top of the sushi tower */
            addRandomPieces(total: 1)
        }
        
    }
    
    func moveTowerDown() {
        
        var n: CGFloat = 0
        
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    func gameOver() {
        state = .gameOver
        
        let turnRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.50)
        
        sushiBasePiece.run(turnRed)
        for sushiPiece in sushiTower {
            sushiPiece.run(turnRed)
        }
        
        character.run(turnRed)
        
        playButton.selectedHandler = {
            let skView = self.view as SKView?
            
            guard let scene = GameScene(fileNamed: "GameScene") as GameScene? else {
                return
            }
            
            scene.scaleMode = .aspectFill
            
            skView?.presentScene(scene)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        /* Connect game object */
        sushiBasePiece = (childNode(withName: "sushiBasePiece") as! SushiPiece)
        character = (childNode(withName: "character") as! Character)
        
        /* UI game objects */
        playButton = (childNode(withName: "playButton") as! MSButtonNode)
        
        /* Setup chopstick connections */
        sushiBasePiece.connectChopsticks()
        
        /* Manually stack the start of the tower */
//        addTowerPiece(side: .none)
//        addTowerPiece(side: .right)
        addRandomPieces(total: 10)
        
        playButton.selectedHandler = {
            self.state = .ready
        }
        
        healthBar = (childNode(withName: "healthBar") as! SKSpriteNode)
        scoreLabel = (childNode(withName: "scoreLabel") as! SKLabelNode)
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveTowerDown()
        
        if state != .playing { return }
        
        health -= 0.01
        if health < 0 {
            gameOver()
        }
    }
}
