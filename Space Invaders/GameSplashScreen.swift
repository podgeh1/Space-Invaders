//
//  GameSplashScreen.swift
//  Space Invaders
//
//  Created by Padraig Hession on 1/21/15.
//  Copyright (c) 2015 Hession. All rights reserved.
//

import UIKit
import SpriteKit


class GameSplashScreen: SKScene {
    
    //Private GameSplashScreen Properties
    var contentCreated = false
    
    //Object Lfecycle Management
    
    
    //Scene Setup and content creation
    
    //call didMoveToView immediately after a scene has been presented by a view
    override func didMoveToView(view: SKView) {
        if(!self.contentCreated) {
            createContent()
            contentCreated = true
        }
    }
    
    func createContent() {
        //CREATE THE SPACE INVADERS LABEL
        let spaceInvaderLabel = SKLabelNode(fontNamed: "Space Age")
        spaceInvaderLabel.fontSize = 50
        spaceInvaderLabel.fontColor = SKColor.whiteColor()
        spaceInvaderLabel.text = "Space Invaders"
        spaceInvaderLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height)
        
        self.addChild(spaceInvaderLabel)
        
        //create play game button
        let playGameButton = SKLabelNode(fontNamed: "Space Age")
        playGameButton.fontSize = 25
        playGameButton.fontColor = SKColor.whiteColor()
        playGameButton.text = "Tap to Play"
        playGameButton.position = CGPointMake(self.size.width/2, spaceInvaderLabel.frame.origin.y - spaceInvaderLabel.frame.size.height - 40)
        
        addChild(playGameButton)
        
        self.backgroundColor = SKColor.blackColor()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .AspectFill
        
        self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontalWithDuration(1.0))
    }
    
}
