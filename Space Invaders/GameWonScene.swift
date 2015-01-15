//
//  GameWonScene.swift
//  Space Invaders
//
//  Created by Padraig Hession on 1/15/15.
//  Copyright (c) 2015 Hession. All rights reserved.
//

import UIKit
import SpriteKit

class GameWonScene: SKScene {
    
    //Private GameScene Properties
    var contentCreated = false
    
    //Object Lifecycle Management
    
    //Scene setup and Content Creation
    
    override func didMoveToView(view: SKView) {
        if(!self.contentCreated){
            self.createContent()
            contentCreated = true
        }
    }
    
    func createContent() {
        //create game won label
        let gameWonLabel = SKLabelNode(fontNamed: "Courier")
        gameWonLabel.fontSize = 50
        gameWonLabel.fontColor = SKColor.whiteColor()
        gameWonLabel.text = "You Won!!"
        gameWonLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height)
        
        self.addChild(gameWonLabel)
        
        
        //create tap label 
        let tapLabel = SKLabelNode(fontNamed: "Courier")
        tapLabel.fontSize = 25
        tapLabel.fontColor = SKColor.whiteColor()
        tapLabel.text = "(Tap to Play Again)"
        tapLabel.position = CGPointMake(self.size.width/2, gameWonLabel.frame.origin.y - gameWonLabel.frame.size.height - 40)
        
        addChild(tapLabel)
        
        self.backgroundColor = SKColor.blackColor()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesCancelled(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .AspectFill
        
        self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontalWithDuration(1.0))
    }
    
}
