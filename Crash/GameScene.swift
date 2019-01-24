//
//  GameScene.swift
//  Crash
//
//  Created by Robin Naggi on 1/18/19.
//  Copyright © 2019 Robin Naggi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var leftCar = SKSpriteNode()
    var rightCar = SKSpriteNode()
    var trees = SKSpriteNode()
    
    var canMove = false
    var leftCarToMoveLeft = true
    var rightCarToMoveRight = true
    
    var leftCarAtRight = false
    var rightCarAtLeft = false
    
    
    var centerPoint: CGFloat!
    
    let leftCarMinX: CGFloat = -230
    let leftCarMaxX: CGFloat = -100
    
    let rightCarMinX: CGFloat = 100
    let rightCarMaxX: CGFloat = 230
    
    var countDown = 6
    var killStop = true
    
    var scoreText = SKLabelNode()
    var score = 0
    
    var gameSetting = Setting.sharedInstance
    
    var orangeCarSpeed = CGFloat(15.0)
    var redCarSpeed = CGFloat(15.0)
    
    
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        
        physicsWorld.contactDelegate = self
        //makes the roadstrips
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createRoadStrip), userInfo: nil, repeats: true)
        // starts the count down
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameScene.startCountDown), userInfo: nil, repeats: true)
        //makes the left traffic
        Timer.scheduledTimer(timeInterval: TimeInterval(Traffic().randonCarTraffic(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftTraffic), userInfo: nil, repeats: true)
        //makes the right traffic
        Timer.scheduledTimer(timeInterval: TimeInterval(Traffic().randonCarTraffic(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightTraffic), userInfo: nil, repeats: true)
        //removes the objects that are off the screen
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.removeItems), userInfo: nil, repeats: true)
        //makes all the left trees
        Timer.scheduledTimer(timeInterval: TimeInterval( Traffic().randonCarTraffic(firstNumber: 0.2, secondNumber: 1)), target: self, selector: #selector(GameScene.makeLeftTrees), userInfo: nil, repeats: true)
        //makes all the right trees
        Timer.scheduledTimer(timeInterval: TimeInterval( Traffic().randonCarTraffic(firstNumber: 0.2, secondNumber: 1)), target: self, selector: #selector(GameScene.makeRightTree), userInfo: nil, repeats: true)
        //makes all the middle trees
        Timer.scheduledTimer(timeInterval: TimeInterval( Traffic().randonCarTraffic(firstNumber: 4, secondNumber: 9)), target: self, selector: #selector(GameScene.makeRock), userInfo: nil, repeats: true)
        
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime) {
            Timer.scheduledTimer(timeInterval: TimeInterval(1.5), target: self, selector: #selector(GameScene.scoreUpdate), userInfo: nil, repeats: true)
        }
        
    }
    
    
    /// For every frame per second this update method will get called
    ///i.e 60 times per sec
    
    /// - Parameter currentTime: <#currentTime description#>
    override func update(_ currentTime: TimeInterval) {
        if canMove {
            move(leftSide: leftCarToMoveLeft)
            moveRight(rightSide: rightCarToMoveRight)
        }
        
        showRoadStrip()
        
        if score % 10 == 0, score > 1 {
            orangeCarSpeed += 0.02
            redCarSpeed += 0.02
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar" {
            firstBody = contact.bodyA
            secBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secBody = contact.bodyA
        }
        
        firstBody.node?.removeFromParent()
        secBody.node?.removeFromParent()
        
        afterCollision()
    }
    
    
    /// Checks to see where the touch on the screen happened
    /// left or right of the centerPoint
    
    /// - Parameters:
    ///   - touches: <#touches description#>
    ///   - event: <#event description#>
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if touchLocation.x > centerPoint {
                if rightCarAtLeft {
                    rightCarAtLeft = false
                    rightCarToMoveRight = true
                } else {
                    rightCarAtLeft = true
                    rightCarToMoveRight = false
                }
            } else {
                if leftCarAtRight {
                    leftCarAtRight = false
                    leftCarToMoveLeft = true
                } else {
                    leftCarAtRight = true
                    leftCarToMoveLeft = false
                }
            }
            
            canMove = true
        }
    }
    
    
    /// linkes to two cars to the game scene form sks
    func setUp() {
        leftCar = self.childNode(withName: "leftCar") as! SKSpriteNode
        rightCar = self.childNode(withName: "rightCar") as! SKSpriteNode
        centerPoint = self.frame.width / self.frame.height
        
        leftCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        leftCar.physicsBody?.contactTestBitMask = ColliderType.Item_COLLIDER
        leftCar.physicsBody?.collisionBitMask = 0
        
        rightCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rightCar.physicsBody?.contactTestBitMask = ColliderType.Item_COLLIDER_1
        rightCar.physicsBody?.collisionBitMask = 0
        
        let scoreCard = SKShapeNode(rect: CGRect(x: -self.size.width/2 + 70, y: self.size.height/2 - 130, width: 180, height: 80), cornerRadius: 20)
        
        scoreCard.zPosition = 4
        scoreCard.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreCard.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreCard)
        
        scoreText.name = "Score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
        
    }
    
    /// Makes the left and right strip of the road
    @objc func createRoadStrip() {
        
        let leftRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -165.5
        leftRoadStrip.position.y = 700
        addChild(leftRoadStrip)
        
        let rightRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 170.5
        rightRoadStrip.position.y = 700
        addChild(rightRoadStrip)
    }
    
    func showRoadStrip() {
        
        enumerateChildNodes(withName: "leftRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= self.orangeCarSpeed + 1
        } )
        
        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let strip = roadStrip as! SKShapeNode
            strip.position.y -= self.orangeCarSpeed + 1
        } )
        
        enumerateChildNodes(withName: "orangeCar", using: { (leftCar, stop) in
            let car = leftCar as! SKSpriteNode
            car.position.y -= self.orangeCarSpeed
        } )
        
        enumerateChildNodes(withName: "greenCar", using: { (rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            car.position.y -= self.redCarSpeed
        } )
        
        enumerateChildNodes(withName: "leftTree",using: { (trees, stop) in
            let tree = trees as! SKSpriteNode
            tree.position.y -= 25
        } )
        
        enumerateChildNodes(withName: "rightTree",using: { (trees, stop) in
            let tree = trees as! SKSpriteNode
            tree.position.y -= 25
        } )
        
        enumerateChildNodes(withName: "rock",using: { (trees, stop) in
            let tree = trees as! SKSpriteNode
            tree.position.y -= 25
        } )
    }
    
    
    /// After the strips or cars are off the screen we will remove them form the memory
    @objc func removeItems() {
        for child in children {
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
        
    }
    
    func move(leftSide: Bool) {
        if leftSide {  //moving left
            leftCar.position.x -= 25
            if leftCar.position.x < leftCarMinX {
                leftCar.position.x = leftCarMinX
            }
        } else {
            leftCar.position.x += 25
            if leftCar.position.x > leftCarMaxX {
                leftCar.position.x = leftCarMaxX
            }
        }
    }
    
    func moveRight(rightSide: Bool) {
        if rightSide {
            rightCar.position.x += 20
            if rightCar.position.x > rightCarMaxX
            {
                rightCar.position.x = rightCarMaxX
            }
        } else {
            rightCar.position.x -= 20
            if rightCar.position.x < rightCarMinX {
                rightCar.position.x = rightCarMinX
            }
        }
    }
    
    @objc func leftTraffic() {
        if !killStop  {
            let leftTrafficItem: SKSpriteNode!
            let randomNumber = Traffic().randonCarTraffic(firstNumber: 1, secondNumber: 8)
            switch Int(randomNumber) {
            case 1...4:
                leftTrafficItem = SKSpriteNode(imageNamed: "orangeCar")
                leftTrafficItem.name = "orangeCar"
                break
            case 5...8:
                leftTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                leftTrafficItem.name = "greenCar"
                break
            default:
                leftTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                leftTrafficItem.name = "greenCar"
                
            }
            leftTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            leftTrafficItem.zPosition = 10
            let randomNum = Traffic().randonCarTraffic(firstNumber: 1, secondNumber: 10)
            switch randomNum {
            case 1...4:
                leftTrafficItem.position.x = -230
            case 5...10:
                leftTrafficItem.position.x = -100
            default:
                leftTrafficItem.position.x = -230
            }
            leftTrafficItem.position.y = 700
            leftTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: leftTrafficItem.size.height/2)
            leftTrafficItem.physicsBody?.categoryBitMask = ColliderType.Item_COLLIDER
            leftTrafficItem.physicsBody?.collisionBitMask = 0
            leftTrafficItem.physicsBody?.affectedByGravity = false
            leftTrafficItem.physicsBody?.allowsRotation = true
            addChild(leftTrafficItem)
        }
    }
    
    @objc func rightTraffic() {
        if !killStop {
            let rightTrafficItem: SKSpriteNode!
            let randomNumber = Traffic().randonCarTraffic(firstNumber: 1, secondNumber: 8)
            switch Int(randomNumber) {
            case 1...4:
                rightTrafficItem = SKSpriteNode(imageNamed: "orangeCar")
                rightTrafficItem.name = "orangeCar"
                break
            case 5...8:
                rightTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                rightTrafficItem.name = "greenCar"
                break
            default:
                rightTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                rightTrafficItem.name = "greenCar"
                
            }
            rightTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            rightTrafficItem.zPosition = 10
            let randomNum = Traffic().randonCarTraffic(firstNumber: 1, secondNumber: 10)
            switch randomNum {
            case 1...4:
                rightTrafficItem.position.x = 230
            case 5...10:
                rightTrafficItem.position.x = 100
            default:
                rightTrafficItem.position.x = 230
            }
            rightTrafficItem.position.y = 700
            rightTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: rightTrafficItem.size.height/2)
            rightTrafficItem.physicsBody?.categoryBitMask = ColliderType.Item_COLLIDER_1
            rightTrafficItem.physicsBody?.collisionBitMask = 0
            rightTrafficItem.physicsBody?.affectedByGravity = false
            rightTrafficItem.physicsBody?.allowsRotation = true
            addChild(rightTrafficItem)
        }
    }
    
    @objc func makeLeftTrees() {
        let tree: SKSpriteNode!
        tree = SKSpriteNode(imageNamed: "tree")
        tree.name = "leftTree"
        tree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tree.zPosition = 10
        tree.size.width = 70.0
        tree.size.height = 70.0
        tree.position.x = -310
        tree.position.y = 700
        
        addChild(tree)
    }
    
    @objc func makeRightTree() {
        let tree: SKSpriteNode!
        tree = SKSpriteNode(imageNamed: "tree")
        tree.name = "rightTree"
        tree.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tree.zPosition = 10
        tree.size.width = 70.0
        tree.size.height = 70.0
        tree.position.x = 310
        tree.position.y = 700
        
        addChild(tree)
    }
    
    @objc func makeRock() {
        let rock: SKSpriteNode!
        rock = SKSpriteNode(imageNamed: "rock")
        rock.name = "rock"
        rock.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rock.zPosition = 10
        rock.size.width = 80.0
        rock.size.height = 80.0
        let randomNum = Traffic().randonCarTraffic(firstNumber: 1, secondNumber: 5)
        switch randomNum {
        case 1:
            rock.position.x = 0
            print("in case 1")
        case 2:
            rock.position.x = -230
            print("in case 2")
        case 3:
            rock.position.x = 230
            print("in case 3")
        case 4:
            rock.position.x = 100
            print("in case 4")
        case 5:
            rock.position.x = -100
            print("in case 5")
        default:
            rock.position.x = Traffic().randonCarTraffic(firstNumber: -100, secondNumber: 100)
            print("in case default")
        }

        rock.position.y = 700
        
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rock.size.height/2)
        rock.physicsBody?.allowsRotation = true
        rock.physicsBody?.friction = 10.0
        
        addChild(rock)
    }
    
    
    
    func afterCollision() {
        if gameSetting.highScore < score {
            gameSetting.highScore = score
        }
        let menuScene = SKScene(fileNamed: "GameMenu")!
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(2)))
    }
    
    @objc func startCountDown() {
        if countDown >= 0 {
            if countDown == 0{
                self.killStop = false
            }
            if countDown < 6, countDown > 0{
                let countDownLabel = SKLabelNode()
                countDownLabel.fontName = "AvenirNext-Bold"
                countDownLabel.fontColor = SKColor.white
                countDownLabel.fontSize = 300
                countDownLabel.text = String(countDown)
                countDownLabel.position = CGPoint(x: 0 , y: 0)
                countDownLabel.zPosition = 300
                countDownLabel.name = "cLabel"
                countDownLabel.horizontalAlignmentMode = .center
                addChild(countDownLabel)
                
                let deadTime = DispatchTime.now() + 0.5
                DispatchQueue.main.asyncAfter(deadline: deadTime, execute: {
                    countDownLabel.removeFromParent()
                } )
            }
            countDown -= 1
        }
    }
    
    @objc func scoreUpdate() {
        if !killStop {
            score += 1
            scoreText.text = String(score)
        }
    }
    
    
}
