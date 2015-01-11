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
    
    var contentCreated = false
    
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
    
    
    

    
    
    

    
    
    
    
    
    
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    // Scene Update Helpers
    
    // Invader Movement Helpers
    
    // Bullet Helpers
    
    // User Tap Helpers
    
    // HUD Helpers
    
    // Physics Contact Helpers
    
    // Game End Helpers
    
}
