//
//  GameScene.swift
//  CrashyPlane
//
//  Created by Jesse S on 9/10/15.
//  Copyright (c) 2015 Jesse S. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player: SKSpriteNode!
    
    var scoreLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createPlayer()
        createSky()
        createBackground()
        createGround()
        initRocks()
        createScore()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
    }
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode (texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width / 6, y: frame.height * 0.75)
        
        addChild(player)
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animateWithTextures([playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatActionForever(animation)
        
        player.runAction(runForever)
    }
    
    func createSky () {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67))
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33))
        
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1)
        
        topSky.position = CGPoint(x: CGRectGetMidX(frame), y: frame.size.height)
        bottomSky.position = CGPoint(x: CGRectGetMidX(frame), y: bottomSky.frame.height / 2)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    func createBackground () {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat (1 * i), y: 100)
            
            addChild(background)
            
            let moveLeft = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            background.runAction(moveForever)
        }
    }
    
    func createGround () {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2)
            
            addChild(ground)
            
            let moveLeft = SKAction.moveByX(-groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveByX(groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatActionForever(moveLoop)
            
            ground.runAction(moveForever)
        }
    }
    
    func createRocks() {
        // 1. Create top and bottom rock sprites. They are both the same graphic, but we're going to rotate the top one and flip it horizontally so that the two rocks form a spiky death for the player.
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.zRotation = CGFloat(M_PI)
        topRock.xScale = -1.0
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        
        // 2. Create a third sprite that is a large red rectangle. This will be positioned just after the rocks and will be used to track when the player has passed through the rocks safely – if they touch that red rectangle, they should score a point. (Don't worry, we'll make it invisible later!)
        let rockCollision = SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 32, height: frame.height))
        rockCollision.name = "scoreDetect"
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        
        
        // 3. Use the new GKRandomDistribution class in iOS 9's GameplayKit to generate a random number in a range. This will be used to determine where the safe gap in the rocks should be.
        let xPosition = frame.width + topRock.frame.width
        
        let max = Int(frame.height / 3)
        
        if #available(iOS 9.0, *) {
            let rand = GKRandomDistribution(lowestValue: -100, highestValue: max)
            let yPosition = CGFloat(rand.nextInt())
            // this next value affects the width of the gap between rocks
            // make it smaller to make your game harder – if you're feeling evil!
            let rockDistance: CGFloat = 70
            
            // 4. Position the rocks just off the right edge of the screen, then animate them across to the left edge. When they are safely off the left edge, remove them from the game.
            topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
            bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
            rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: CGRectGetMidY(frame))
            
            let endPosition = frame.width + (topRock.frame.width * 2)
            
            let moveAction = SKAction.moveByX(-endPosition, y: 0, duration: 5.8)
            let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
            topRock.runAction(moveSequence)
            bottomRock.runAction(moveSequence)
            rockCollision.runAction(moveSequence)
            
        }
        
        else {
            // TODO: Handle for iOS 8
        }
    }
    
    func initRocks() {
        let create = SKAction.runBlock { [unowned self] in
            self.createRocks()
        }
        
        let wait = SKAction.waitForDuration(3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatActionForever(sequence)
        
        runAction(repeatForever)
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPointMake(CGRectGetMaxX(frame) - 20, CGRectGetMaxY(frame) - 40)
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.blackColor()
        
        addChild(scoreLabel)
    }

}











