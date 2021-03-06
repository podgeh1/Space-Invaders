//
//  GameScene.swift
//  Space Invaders
//
//  Created by Padraig Hession on 1/11/15.
//  Copyright (c) 2015 Hession. All rights reserved.
//

import SpriteKit
import CoreMotion

//Use SKPhysicsContactDelegate to declare the scene as a delegate for the physics engine
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //properties for the end of the game
    let kMinInvaderBottomHeight: Float = 32.0
    var gameEnding: Bool = false
    var gameWinning: Bool = false
    
    //properties for the HUD
    //ship health starts @ 100% but i'll store it as a no ranging from 0 to 1
    var score: Int = 0
    var shipHealth: Float = 1.0
    
    //create a queue to store contacts until they can be processed via update
    var contactQueue = Array<SKPhysicsContact>()
    
    //create different types of categories for different types of physics bodies
    //I'll do this by defining different category bitmasks
    //A bitmask is a way of stuffing multiple on/off variables into a single 32bit int
    //A bitmask can have 32 distint values when stored as a UInt32
    //Each of the following 5 bodies will define 5 different types of physics bodies
    //The no to the right of << guarantees each bitmask is unique
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    
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
        case C
    }
    // Define the size of the invaders and define how they will be laid out in a grid of rows and columns
    let kInvaderSize = CGSize(width:24, height:16)
    let kInvaderGridSpacing = CGSize(width:12, height:12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6

    
    
    //  Define the name of the invaders to identify them
    let kInvaderName = "invader"
    
    
    
    //Define the size of the ship 
    let kShipSize = CGSize(width:30, height:16)
    
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
        
//        let gameSplashScreen: GameSplashScreen = GameSplashScreen(size: self.size)
//        
//        view.presentScene(gameSplashScreen, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
            
            //get accelerometer data through CMMotionManager
            //by using the motion manager anf it's accelerometer data, I can control the ships movement
            motionManager.startAccelerometerUpdates()
            
            //ensure the scene can receive tap events from the user
            userInteractionEnabled = true
            
            //initialise an empty contact queue + set the scene as the contact delegate of the physics engine
            physicsWorld.contactDelegate = self
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
        
        
        //set the category for the physics body of the scene
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        
        //display the invaders on the screen
        setupInvaders()
        
        
        //display the ship on the screen
        setupShip()
        
        //call setup method for the HUD
        setupHud()
    }
    
    
    func loadInvaderTexturesOftype(invaderType: InvaderType) -> Array<SKTexture> {
        var prefix: String
        
        switch(invaderType) {
        case .A:
            prefix = "InvaderA"
        case .B:
            prefix = "InvaderB"
        case .C:
            prefix = "InvaderC"
        default:
            prefix = "InvaderC"
        }
        //load a pair of sprite images for each invader type + create SKTexture objects from them
        return [SKTexture(imageNamed: String(format: "%@_00@2x.png", prefix)), SKTexture(imageNamed: String(format: "%@_01@2x.png", prefix))]
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {
        
        let invaderTextures = self.loadInvaderTexturesOftype(invaderType)
        
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = kInvaderName
        
        //animate the 2 images in a continuous animation loop
        invader.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(invaderTextures, timePerFrame: self.timePerMove)))
        
        //create a physics body for the invader
        invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
        //the invader is not moved by a physics simulator i.e. dynamic == false
        invader.physicsBody!.dynamic = false
        //create a category for the physics body of the invader
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        //the invader cannot detect contact with anything
        invader.physicsBody!.contactTestBitMask = 0x0
        //the invader cannot come detect collision with anything
        invader.physicsBody!.collisionBitMask = 0x0
        
        return invader
        
    }
    
//    func makeInvaderOfType(invaderType: InvaderType) -> (SKNode) {
//    //Use the invaderType parameter to determine the color of the invader
//    var invaderColor: SKColor
//    
//        switch(invaderType) {
//        case .A:
//            invaderColor = SKColor.redColor()
//        case .B:
//            invaderColor = SKColor.greenColor()
//        case .C:
//            invaderColor = SKColor.blueColor()
//        default:
//            invaderColor = SKColor.blueColor()
//    }
//    
//    //call the initialiser SKSpriteNode to initialise a sprite that renders as a rectangle of the given color invaderColor of size kInvaderSize
//        let invader = SKSpriteNode(color: invaderColor, size: kInvaderSize)
//        invader.name = kInvaderName
//        
//        
//        //create a physics body for the invader
//        invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
//        //the invader is not moved by a physics simulator i.e. dynamic == false
//        invader.physicsBody!.dynamic = false
//        //create a category for the physics body of the invader
//        invader.physicsBody!.categoryBitMask = kInvaderCategory
//        //the invader cannot detect contact with anything
//        invader.physicsBody!.contactTestBitMask = 0x0
//        //the invader cannot come detect collision with anything
//        invader.physicsBody!.collisionBitMask = 0x0
//        
//        return invader
//    
//    }
    
    
    //method to setup the invaders position in the scene and which invader type each invader should have
    func setupInvaders() {
        //declare and set the base origin
        let baseOrigin = CGPoint(x:size.width / 3, y:180) //(138,180)
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
            //do some math to figure out where the FIRST invader in this row should be positioned
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
                ship.position = CGPoint(x:size.width / 2.0, y:kShipSize.height / 2.0)
                addChild(ship)
    }
    
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(imageNamed: "Ship@2x.png")
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
        
            //set the category for the physics body of the ship
            ship.physicsBody!.categoryBitMask = kShipCategory
            //DONT detect CONTACT between ship and other physics bodies
            ship.physicsBody!.contactTestBitMask = 0x0
            //DO detect COLLISION between ship and the scenes outer edges (so it will bounce back)
            ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        
            return ship
    }
    
    
    
    //Setuo HUD
    func setupHud() {
                //give the scorelabel a name (soo i can update it later when I need to update the displayed score)
        let scoreLabel = SKLabelNode(fontNamed: "Space Age")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        
        //color the score label green
        scoreLabel.fontColor = SKColor(red: 0.58, green: 0.90, blue: 0.43, alpha: 1.00)
        scoreLabel.text = NSString(format: "Score: %04u", 0)
        
        //position the score label
        println(size.height)
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        
        //Give the health label a name so I can access it later when I need to update the displayed health
        let healthLabel = SKLabelNode(fontNamed: "Space Age")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        //Color the health label red 
        healthLabel.fontColor = SKColor(red: 1.00, green: 0.42, blue: 0.43, alpha: 1.00)
        //set the hud text based on the actual health of the ship
        healthLabel.text = String(format: "Health: %.1f%%", self.shipHealth * 100.0)
        
        
        
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
            //bullet.name = kShipFiredBulletName
            
            //create a physics body for the ship bullet
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            //the ship bullet is controlled by physics simulation
            //by setting dynamic to true the ship bullets can detect contact
            bullet.physicsBody!.dynamic = true
            //the ship bullet is not affected by gravity
            bullet.physicsBody!.affectedByGravity = false
            //set the category of the physics body of the ship bullet
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            //the ship bullet must detect contact with an invaders physical body
            //the reason why I'm setting the ships bullet to detect contact with an invader and not letting the invader have contact with the ships bullet is because: When sprite kit checks for contact between any two physics bodies, only one of the bodies need to declare that it should test for contact with the other body
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            //the ship bullet must NOT detect collision with another entity
            bullet.physicsBody!.collisionBitMask = 0x0
            
            bullet.name = kShipFiredBulletName
            
        case .InvaderFiredBulletType:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
//            bullet.name = kInvaderFiredBulletName
            
            
            //create a physical body for the invader bullet
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            //the invader bullet is controlled by a physics simulator
            bullet.physicsBody!.dynamic = true
            //the invader bullet is not affected by gravity
            bullet.physicsBody!.affectedByGravity = false
            //set the category for the invader bullet physics body
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            //the invader bullet must detect contact with the ships physical body
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            //the invader must NOT detect collision with any entities
            bullet.physicsBody!.collisionBitMask = 0x0
            
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
        
        //check if the game is won
        if self.isGameWon() {
            self.wonGame()
        }
        
        //check if the game is over
        if self.isGameOver() {
            self.endGame()
        }
        //call the contact queue handler
        processContactsForUpdate(currentTime)
        
        //tell the invaders to fire!!!!!!!
        fireInvaderBulletsForUpdate(currentTime)
        
        //process user taps - tell the ship to fire!!!!!!!
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
    
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        
        let existingBullet = self.childNodeWithName(kInvaderFiredBulletName)
        
        //only fire a bullet if it's not already on the screen
        if existingBullet == nil {
            
            var allInvaders = Array<SKNode>()
            
            //collect all invaders currently on the screen
            self.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                
                allInvaders.append(node)
            }
            
            if allInvaders.count > 0 {
                
                //select an invader at random
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                
                let invader = allInvaders[allInvadersIndex]
                
                //create a bullet + fire it below the selected invader
                let bullet = self.makeBulletOfType(.InvaderFiredBulletType)
                bullet.position = CGPointMake(invader.position.x, invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                
                //make the bullet travel straight down and move off the bottom of the screen
                let bulletDestination = CGPointMake(invader.position.x, -(bullet.frame.size.height / 2))
                
                //fire off the invaders bullet
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "Laser_Shoot23.wav")
            }
            
        }
        
    }
    
    
    //drain the contact queue -- by calling handleContact for each contact in the queue + then removing the conatct
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    
    
    
    
    // Invader Movement Helpers
    
    func adjustInvaderMovementToTimePerMove(newTimerPerMove: CFTimeInterval) {
        //ignore crazt values, a value less than or equal to zero would mean the invader would move infinitely fast or backwards
        if newTimerPerMove <= 0 {
            return
        }
        
        //set timePerMove to the given value -> this will increase the speed in moveInvadersForUpdate()
        let ratio: CGFloat = CGFloat(self.timePerMove / newTimerPerMove)
        self.timePerMove = newTimerPerMove
        
        self.enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            node.speed = node.speed * ratio
        }
    }
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        //get the ship from the scene so i can move it
        if let ship = self.childNodeWithName(kShipName) as? SKSpriteNode {
            
            //get the accelerometer data form the motion manager
            //It is an optional -- a variable that can hold either a value or no value
            //if let data -- checks if there is a value in accelerometerData: if this is the case, assign it to the constant data to use it safely within the if's scope
            if let data = motionManager.accelerometerData {
                
                //if the device is oriented with the screen facing up + home button at the bottom, then tilting the devices to the right produces data.acceleration.x > 0, therefore tilting to the left produces data.acceleration.x < 0 and if the device is laid down flat it will produce data.acceleration == 0 (or as long as it's close to 0.2)
                //fabs returns the absolute value of x
                if (fabs(data.acceleration.x) > 0.2) {
                    
                    
                    //Physics: need small values to move the ship a little and large values to move the ship a lot
                    //the ships physicsBody is created in makeShip()
                    ////here I will apply a force to the ships physics body in the same direction as data.acceleration.x
                    ship.physicsBody!.applyForce(CGVectorMake(40.0 * CGFloat(data.acceleration.x), 0))
                    
                }
                
                
            }
        }
    }


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
                
                //invoke adjustInvaderMovementToTimePerMove
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
                stop.memory = true
        }
    case .Left:
            //4 -- if the invaders left edge is 1 point from the left edge of the scen,  move down then right
            if (CGRectGetMinX(node.frame) <= 1.0) {
                proposedMovementDirection = .DownThenRight
                
                //invoke adjustInvaderMovementToTimePerMove
                self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
                
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
        self.addChild(bullet)
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
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent) {
        
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
    
    //update the score + score label
    func adjustScoreBy(points: Int) {
        
        //update the score
        self.score += points
        
        //make score a label
        let score = self.childNodeWithName(kScoreHudName) as SKLabelNode
        
        //update the text of the score label
        score.text = String(format: "Score: %04u", self.score)
    }
    
    //update the health and health label
    func adjustShipHealthBy(healthAdjustment: Float) {
        
        //ensure the ships health doesn't go negative
        self.shipHealth = max(self.shipHealth + healthAdjustment, 0)
        
        //make health a label
        let health = self.childNodeWithName(kHealthHudName) as SKLabelNode
        
        //update the text of the health label
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
        
    }
    
    
    
    
    
    // Physics Contact Helpers
    
    //didBeginContact can execute at any time but I'm going to call it in update()
    //when 2 physics bodies make contact this function will be called
    //therefore it records the contacts to the queue so it can be called later
    func didBeginContact(contact: SKPhysicsContact!) {
        if contact != nil {
            self.contactQueue.append(contact)
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        //dont allow the same contact twice
        //ensure I haven't already handled this contact and removed it's nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        var nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        
        //containsObject is not implemented in swift array i.e. I'm going cast the Array to NSArray in order to get access to NSArray's methods
        //check if ship and invader bullet have made contact
        if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kInvaderFiredBulletName) {
            
            //If invader bullet hits the ship, play sound
            self.runAction(SKAction.playSoundFileNamed("Explosion18.wav", waitForCompletion: false))
            
            //deduct -0.334 from health
            self.adjustShipHealthBy(-0.334)
            
            if self.shipHealth <= 0.0 {
                //if the ship has no health remove both the invader bullet and the ship
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
            } else {
                //if the ship still has health
                let ship = self.childNodeWithName(kShipName)!
                
                //dim the ships sprite
                ship.alpha = CGFloat(self.shipHealth)
                
                //remove the bullet
                if contact.bodyA.node == ship {
                    
                    contact.bodyB.node!.removeFromParent()
                } else {
                    contact.bodyA.node!.removeFromParent()
                }
                
            }
            
        } else if ((nodeNames as NSArray).containsObject(kInvaderName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName)) {
            
            //if the ship bullet hits an invader, remove the invader and the ship bullet and play an explosion sound
            self.runAction(SKAction.playSoundFileNamed("Explosion26.wav", waitForCompletion:false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            //add 100 points to score when invader is hit by ship bullet
            self.adjustScoreBy(100)
        }
    }
    
    
    
    
    
    
    
    // Game End Helpers
    
    func isGameOver() -> Bool {
        
        
        //Iterate through invaders to check if any are too low
        var invaderTooLow = false
        
        //iterate through the invaders - if min Y value of the invader is less than the mininmum value I defined(kMinInvaderBottomHeight) - set invaderTooLow to true
        self.enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            if (Float(CGRectGetMinY(node.frame)) <= self.kMinInvaderBottomHeight) {
                
                invaderTooLow = true
                stop.memory = true
            }
        }
        
        //set pointer to the ship
        let ship = self.childNodeWithName(kShipName)
        
        //return whether game is over or not. If invader is too low or ship is destroyed, then the game is over
        return invaderTooLow || ship == nil
    }
    
    func endGame() {
        //end the game only once
        if !self.gameEnding {
            
            self.gameEnding = true
            
            //stop accelerometer updates
            self.motionManager.stopAccelerometerUpdates()
            
            //Show the GameOverScene
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    }
    
    
    // Game Win Helpers
    
    func isGameWon() -> Bool {
        
        //Get remaining invaders
        let invader = self.childNodeWithName(kInvaderName)
        
        //return whether the game is won or not. If there is no invaders left in the scene the game is won
        return invader == nil
        
    }
    
    func wonGame() {
        if !self.gameWinning {
            self.gameWinning = true
            
            //stop the accelerometer updates
            self.motionManager.stopAccelerometerUpdates()
            
            //Show the GameWonScene
            let gameWonScene: GameWonScene = GameWonScene(size: self.size)
            
            view!.presentScene(gameWonScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
            
            
        }
        
    }

    
}
