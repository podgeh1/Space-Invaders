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
    
    //enumerations for different bullets
    //I'll use BulletTyoe to share the same bullet code for both the invaders and the ship
    enum BulletType {
        case ShipFiredBulletType
        case InvaderFiredBulletType
    }
    
    //properties for bullets
    let kShipFiredBulletName = "shipFiredBullet"
    let kInvaderFiredBulletName = "invaderFiredBullet"
    let kBulletSize = CGSizeMake(4, 8)
    
    
    //initialise the tap queue to an empty array
    var tapQueue: Array<Int> = []
    
    
    //delclare property for CoreMotion
    let motionManager: CMMotionManager = CMMotionManager()
    
    // Private GameScene Properties
    
    var contentCreated = false
    
    //invaders move in a fixed pattern-> right, right, down, left, left, down, right, right etc.
    //InvaderMovementDirection can be used to keep track of the invaders progress through this pattern
    enum InvaderMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    
    
    //initialise invader movement
    //invaders begin by moving to the right
    var invaderMovementDirection: InvaderMovementDirection = .Right
    //invaders haven't moved yet, so set the time to zero
    var timeOfLastMove: CFTimeInterval = 0.0
    //Invaders take 1 second for each move. Each step left, right or down takes 1 second
    var timePerMove: CFTimeInterval = 1.0
    
    
    
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
    
    
//    var contentCreated = false
    
//    //initialise invader movement
//    //invaders begin by moving to the right 
//    var invaderMovementDirection: InvaderMovementDirection = .Right
//    //invaders haven't moved yet, so set the time to zero
//    var timeOfLastMove: CFTimeInterval = 0.0
//    //Invaders take 1 second for each move. Each step left, right or down takes 1 second
//    var timePerMove: CFTimeInterval = 1.0
    
    
    
    // Object Lifecycle Management
    
    
    
    
    
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            
            //get accelerometer data through CMMotionManager
            //by using the motion manager anf it's accelerometer data, I can control the ships movement
            motionManager.startAccelerometerUpdates()
            
            //ensure the scene can receive tap events from the user
            userInteractionEnabled = true
        }
    }
    
    func createContent() {
        
//        let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//        
//        invader.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
//        
//        self.addChild(invader)
        
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
        
        //add an edge loop (physiscs body) around the boundary of the screen to collide with the ship
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        
        //display the invaders on the screen
        setupInvaders()
        
        
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
    
    
    func makeShip() -> SKNode {
            let ship = SKSpriteNode(color: SKColor.greenColor(), size: kShipSize)
            ship.name = kShipName
        
            //create physics body for ship (Here I created a rectangular physics body which is the same size as the ship)
            ship.physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)
        
            //is the ship moved using the physics simulator? - yes
            //the ship can be subject to things such as collisions and outside forces because it's dynamic
            ship.physicsBody!.dynamic = true
        
            //is the ship affected by gravity? - no, otherwise it might drop off the screen
            ship.physicsBody!.affectedByGravity = false
        
            //give the ship an arbitrary mass so its movement feels natural
            ship.physicsBody!.mass = 0.02
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
    
    
    //makeBulletOfType() method is used to create a rectangular sprite with a color and a name (so I can find it later in my scene)
    func makeBulletOfType(bulletType: BulletType) -> SKNode! {
        
        var bullet: SKNode!
        
        switch (bulletType) {
        case .ShipFiredBulletType:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kShipFiredBulletName
        case .InvaderFiredBulletType:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName
            break;
        default:
            bullet = nil
        }
        
        return bullet
    }
    
    

    
    
    
    
    
    
    
    
    // Scene Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //process user taps
        processUserTapsForUpdate(currentTime)
        
        //move the ship
        //processUserMotionForUpdate will get called 60 times per second as the scene updates
        processUserMotionForUpdate(currentTime)
        
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
        
        //determine the invaders movement
        //I call determineInvaderMovementDirection here because I want the invader movement direction to change only when the invaders are actually moving
        determineInvaderMovementDirection()
        
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
    
    
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        //get the ship from the scene so i can move it
        let ship = childNodeWithName(kShipName) as SKSpriteNode
        
        //get the accelerometer data form the motion manager
        //It is an optional -- a variable that can hold either a value or no value
        //if let data -- checks if there is a value in accelerometerData: if this is the case, assign it to the constant data to use it safely within the if's scope
        if let data = motionManager.accelerometerData {
            
            //if the device is oriented with the screen facing up + home button at the button, then tilting the devices to the right produces data.acceleration.x > 0, therefore tilting to the left produces data.acceleration.x < 0 and if the device is laid down flat it will produce data.acceleration == 0 (or as long as it's close to 0.2)
            //fabs returns the absolute value of x
            if (fabs(data.acceleration.x) > 0.2) {
                
                
                //Physics: need small values to move the ship a little and large values to move the ship a lot
                //the ships physicsBody is created in makeShip()
                ////here I will apply a force to the ships physics body in the same direction as data.acceleration.x
                ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 0))
                
                
            }
        }
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        //Loop over tapQueue
        for tapCount in self.tapQueue {
            if tapCount == 1 {
                //If the queue entry is a single tap
                self.fireShipBullets()
            }
            //remove the tap from the queue
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    
    
    
    
    
    // Invader Movement Helpers

    func determineInvaderMovementDirection() {
    
    // 1 -- keep a reference to the current invaderMoveDirection so i can reference it in step 2
    var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
    
    // 2 -- loop over all invaders and invoke the block with the invader as an argument
    enumerateChildNodesWithName(kInvaderName) { node, stop in
        switch self.invaderMovementDirection {
    case .Right:
            //3 -- if the right corner of the invader touches the right side of the scene, the invader will move down then left
            //if the invaders right edge is within one point of the right edge of the scene, it's about to move off the scene. Set proposedMovementDirection so the invader will move down then left.
            //You compare the invaders frame with the scene width
            if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                proposedMovementDirection = .DownThenLeft
                stop.memory = true
        }
    case .Left:
            //4 -- if the invaders left edge is 1 point from the left edge of the scen,  move down then right
            if (CGRectGetMinX(node.frame) <= 1.0) {
                proposedMovementDirection = .DownThenRight
                
                stop.memory = true
        }
    case .DownThenLeft:
            //5 -- if the invader is moving downThenLeft then they've moved down at this point so they should move left
            //How this works willl become more obvious when I implement determineInvaderMovementDirection with moveInvadersForUpdate()
            proposedMovementDirection = .Left
            stop.memory = true
    case .DownThenRight:
                //6 -- if the invader is moving downThenRight they've already moved down at this point so they should just move right
                proposedMovementDirection = .Right
                stop.memory = true
    default:
        break
        }
    }
    
    //7 -- if the proposedMovementDirection is different from the current invaderMovementDirection, update the current invader direction to the proposed movement direction
    if (proposedMovementDirection != invaderMovementDirection) {
        invaderMovementDirection = proposedMovementDirection
    }
    }
    


    
    
    // Bullet Helpers
    
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
        
        
        //bulletAction will move the bullet to its desired destination and then removes it from the scene
        //The next action will then take place after the previous action has completed
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        
        //play the sound to show that the bullet was fired
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        
        //move the bullet and play the sound at the same time by putting them in the same group
        //A group will run its action in parallel NOT sequentially
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        
        //make the bullet appear on sceen and start it's actions by adding it to the scene
        addChild(bullet)
    }
    
    
    func fireShipBullets() {
        
        let existingBullet = self.childNodeWithName(kShipFiredBulletName)
        
        //only fire a bullet if there isn't one currently on the screen. -- takes time to reload
        if existingBullet == nil {
            
            if let ship = self.childNodeWithName(kShipName) {
                if let bullet = self.makeBulletOfType(.ShipFiredBulletType) {
                    
                    //set the bullets position to be at the top of the ship
                    bullet.position = CGPointMake(ship.position.x, ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
                    
                    //set the bullets destination to be just off the top of the screen. 
                    let bulletDestination = CGPointMake(ship.position.x, self.frame.size.height + bullet.frame.size.height / 2)
                    
                    //fire!!!!!!!!!!!!!
                    self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "Laser_Shoot2.wav")
                }
            }
        }
    }
    
    
    
    
    
    
    // User Tap Helpers
    //tell the receiver when one or more fingers touch down in a view
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    //tell the receiver a finger or more has moved on the view
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    //tell the receiver a system event(e.g. low memory) has cancelled a touch event
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        
    }
    
    
    //I added the above 3 empty stub methods because apple recommends doing so when you override touchesEnded() without calling super()
    //tell the receiver when a finger has been lifted off the view
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        //touch has the value where you can touch anything
        if let touch : AnyObject = touches.anyObject() {
            
            //if the user taps once
            if(touch.tapCount == 1) {
                
                //add a tap to the queue
                //all the queue needs to know is that a tap occured i.e. I'll use the integer 1 as a mnemonic for a single tap
                self.tapQueue.append(1)
            }
        }
    }
    
    
    
    // HUD Helpers
    
    
    
    
    
    // Physics Contact Helpers
    
    
    
    
    
    
    
    // Game End Helpers
    
}
