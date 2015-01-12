//
//  GameScene.swift
//  Space Invaders
//
//  Created by Padraig Hession on 1/11/15.
//  Copyright (c) 2015 Hession. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    
    // Private GameScene Properties
    
    //invaders move in a fixed pattern-> right, right, down, left, left, down, right, right etc.
    //InvaderMovementDirection can be used to keep track of the invaders progress through this pattern
    enum InvaderMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    // Define the different types of enemies
    enum InvaderType {
        case A
        case B
        case C }
    // Define the size of the invaders and define how they will be laid out in a grid of rows and columns
    let kInvaderSize = CGSize(width:24, height:16)
    let kInvaderGridSpacing = CGSize(width:12, height:12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    
    
    //  Define the name of the invaders to identify them
    let kInvaderName = "invader"
    
    
    
    //Define the size of the ship 
    let kShipSize = CGSize(width: 30, height: 16)
    
    //Define the name of the ship to identify it
    let kShipName = "ship"
    
    
    
    
    //add constraints for the HUD - Heads Up Display
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    
    var contentCreated = false
    
    //initialise invader movement
    //invaders begin by moving to the right 
    var invaderMovementDirection: InvaderMovementDirection = .Right
    //invaders haven't moved yet, so set the time to zero
    var timeOfLastMove: CFTimeInterval = 0.0
    //Invaders take 1 second for each move. Each step left, right or down takes 1 second
    var timePerMove: CFTimeInterval = 1.0
    
    
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
        }
    }
    
    func createContent() {
        
//        let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//        
//        invader.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        
//        self.addChild(invader)
        
        //display the invaders on the screen
        setupInvaders()
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
        
        //display the ship on the screen
        setupShip()
        
        //call setup method for the HUD
        setupHud()
    }
    
    
    func makeInvaderOfType(invaderType: InvaderType) -> (SKNode) {
    //Use the invaderType parameter to determine the color of the invader
    var invaderColor: SKColor
    
        switch(invaderType) {
        case .A:
            invaderColor = SKColor.redColor()
        case .B:
            invaderColor = SKColor.greenColor()
        case .C:
            invaderColor = SKColor.blueColor()
        default:
            invaderColor = SKColor.blueColor()
    }
    
    //call the initialiser SKSpriteNode to initialise a sprite that renders as a rectangle of the given color invaderColor of size kInvaderSize
        let invader = SKSpriteNode(color: invaderColor, size: kInvaderSize)
        invader.name = kInvaderName
        return invader
    
    }
    
    
    //method to setup the invaders position in the scene and which invader type each invader should have
    func setupInvaders() {
        //declare and set the base origin
        let baseOrigin = CGPoint(x:size.width / 3, y:180)
        // loop over the rows
        for var row = 1; row <= kInvaderRowCount; row++ {
            //choose a single invader type for all invaders in this row based on row number
            var invaderType: InvaderType
            if row % 3 == 0 {
                invaderType = .A
            } else if row % 3 == 1 {
                invaderType = .B
            } else {
                invaderType = .C
            }
            //do some math to figure out where the first invader in this row should be positioned
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)
            
            
            //loop over the columns
            for var col = 1; col <= kInvaderColCount; col++ {
                //create an invader for the current row and column and add it to the scene
                var invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)
                
                //update the invader position so that it is correct for the next invader
                invaderPosition = CGPoint(x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, y: invaderPositionY)
            }
            
            
        }
    }
    
    
    
    
    func setupShip() {
        //create a ship using makeShip()
                let ship = makeShip()
                
        //place the ship on the screen
                //In SpriteKit, the origin is at the lower left corner of the screen.
                //The anchorPoint is based on a unit square where (0,0) is the lower left corner of the sprites area and (1,1) is the top right 
                //Since SKSpriteNode has a default anchorPoint of (0.5, 0.5), i.e. it's center, the ships position is the position of it's center 
                //Positioning the ship at kShipSize.height / 2.0 means half of it will protrude below it's position and the other half will protrude above
                ship.position = CGPoint(x:size.width / 2.0, y: kShipSize.height / 2.0)
                addChild(ship)
    }
    
    
    func makeShip() -> (SKNode) {
            let ship = SKSpriteNode(color: SKColor.greenColor(), size: kShipSize)
            ship.name = kShipName
            return ship
    }
    
    
    
    //Setuo HUD
    func setupHud() {
                //give the scorelabel a name (soo i can update it later when I need to update the displayed score)
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        
        //color the score label green
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = NSString(format: "Score: %04u", 0)
        
        //position the score label
        println(size.height)
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        
        //Give the health label a name so I can access it later when I need to update the displayed health
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        //Color the health label red 
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = NSString(format: "Health: %.1f%%", 100.0)
        
        
        //Position the health label below the score label
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        addChild(healthLabel)
        
                    
    }
    
    

    
    
    
    
    
    
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //move invaders
        moveInvadersForUpdate(currentTime)
    }
    
    
    // Scene Update Helpers
    
    //ready to make the invaders move
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        //If it's not time to move, then exit the method.
        //moveInvadersForUpdate is involed 60 times per second but I don't want the invaders to move that often since the movement would be too fast
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        //remember: the scene holds the invaders as child nodes (I added them to the scene using addChild() in setupInvaders())
        //invoking enumerateChildNodesWithName() loops over the invaders because they're named kInvaderName -- This makes the loop skip my ship and HUDs
        //the block moves the invaders 10 pixels either left right or down depending on the values of invaderMovementDirection
        enumerateChildNodesWithName(kInvaderName, usingBlock: {
            (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .Left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .DownThenLeft, .DownThenRight:
                    node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .None:
                break
            default:
                break
            }
            
            
            //record that the invaders have just moved, so that the next time this method is invoked (1/60th of a second from now), the invaders won't move again till the set time period of one second has elapsed
            self.timeOfLastMove = currentTime
        
        })
    }
    
    
    
    
    
    
    // Invader Movement Helpers

    
    
    
    // Bullet Helpers
    
    // User Tap Helpers
    
    // HUD Helpers
    
    // Physics Contact Helpers
    
    // Game End Helpers
    
}
