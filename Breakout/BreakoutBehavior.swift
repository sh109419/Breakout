//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by hyf on 17/9/7.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit

@objc protocol BreakoutBehaviorDelegate {
    func gotMark(_ mark: Int)
    func gameOver(_ playerWon: Bool)
}

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    
    private struct CollisionBorders {
        static let LeftWall = "Left Wall"
        static let TopWall = "Top Wall"
        static let RightWall = "Right Wall"
        static let Paddle = "Paddle"
        static let Brick = "Brick"
    }

    
    var breakoutBehaviorDelegate: BreakoutBehaviorDelegate?
    
    private lazy var  collider: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.collisionDelegate = self
        return collider
    } ()
    
    private let ballBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.elasticity = 1.0
        dib.friction = 0
        dib.resistance = 0
        dib.allowsRotation = false
        return dib
    } ()
    
    let gravity = UIGravityBehavior()// gravity for paddle
    
    func clear() {
        collider.removeAllBoundaries()
        collider.items.forEach{ collider.removeItem($0) }
        ballBehavior.items.forEach{ ballBehavior.removeItem($0) }
        gravity.items.forEach{ gravity.removeItem($0) }
        brickCount = 0
    }

    override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(ballBehavior)
        //addChildBehavior(gravity)
    }
    
    func addWall() {
        if let frameSize = self.dynamicAnimator?.referenceView?.frame.size {
             collider.addBoundary(withIdentifier: CollisionBorders.TopWall as NSCopying, from: CGPoint(x: 0, y: 0), to: CGPoint(x: frameSize.width, y: 0))
             collider.addBoundary(withIdentifier: CollisionBorders.LeftWall as NSCopying, from: CGPoint(x: 0, y: frameSize.height), to: CGPoint(x: 0, y: 0))
             collider.addBoundary(withIdentifier: CollisionBorders.RightWall as NSCopying, from: CGPoint(x: frameSize.width, y: 0), to: CGPoint(x: frameSize.width, y: frameSize.height))
        }
       
    }
    
    private var brickCount = 0
    
    func addBrick(_ brick: UIView) {
        if let referenceView = dynamicAnimator?.referenceView {
            referenceView.addSubview(brick)
            brickCount += 1
            brick.tag = brickCount
            collider.addBoundary(withIdentifier: CollisionBorders.Brick + String(brick.tag) as NSCopying, for: UIBezierPath(rect: brick.frame))
        }
    }
    
    func addPaddle(_ paddle: UIView) {
        if let referenceView = dynamicAnimator?.referenceView {
            referenceView.addSubview(paddle)
            collider.addBoundary(withIdentifier: CollisionBorders.Paddle as NSCopying, for: UIBezierPath(rect: paddle.frame))
            updatePaddlePosition(paddle)
            gravity.addItem(paddle)
        }
    }
    
    func updatePaddlePosition(_ paddle: UIView) {
        collider.removeBoundary(withIdentifier: CollisionBorders.Paddle as NSCopying)
        // oval: 如果角碰到球，能使球向上弹起
        collider.addBoundary(withIdentifier: CollisionBorders.Paddle as NSCopying, for: UIBezierPath(ovalIn: paddle.frame))
    }
    
    func addBall(_ ball: BallView) {
        if let referenceView = dynamicAnimator?.referenceView {
            referenceView.addSubview(ball)
            collider.addItem(ball)
            ballBehavior.addItem(ball)
            pushBall(ball)
        }
    }
    
    private var gameLevel = 0
    
    func newLevel() {
        gameLevel += 1
    }
    
    func newGame() {
        gameLevel = 0
    }
    
    private func pushBall(_ ball: UIView) {
       
        if let animator = dynamicAnimator {
            let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.instantaneous)
            pushBehavior.action = {
                pushBehavior.removeItem(ball)
                animator.removeBehavior(pushBehavior)
            }
            pushBehavior.addItem(ball)
            //pushBehavior.pushDirection = CGVector(dx: 0.5, dy: 0.5)
            pushBehavior.angle = randomAngle(in: CGFloat.pi*1/4..<CGFloat.pi*3/4)
            //pushBehavior.angle = CGFloat.pi / 2
            pushBehavior.magnitude = CGFloat((Settings.sharedInstance.ballSpeed + Float(gameLevel * 100)) / 1000)
            print(pushBehavior.magnitude)
            //pushBehavior.magnitude = 0.25
            //var velocity : CGPoint = CGPoint(x: CGFloat(0), y: CGFloat(0))
            //velocity.x = CGFloat(pushBehavior.magnitude * cos(pushBehavior.angle))
            //velocity.y = CGFloat(pushBehavior.magnitude * sin(pushBehavior.angle))
            //breakoutBehavior.startBall(ball, velocity: velocity)
            //ballBehavior.addLinearVelocity(velocity, for: ball)

            animator.addBehavior(pushBehavior)
            pushBehavior.active = true
            action = {
                if ball.center.y > (self.dynamicAnimator?.referenceView!.frame.maxY)! {
                    if let delegate = self.breakoutBehaviorDelegate {
                        delegate.gameOver(false)
                        print("game over")
                    }
                }
            }
 
        }
        
        remainingBricks = Settings.sharedInstance.numberOfBricks
    }
    
    func randomAngle(in range: Range<CGFloat>) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UInt32.max)*(range.upperBound-range.lowerBound)+range.lowerBound
    }

    // uicollisionddelegate
    
    private var remainingBricks = 0
    
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        guard let view = dynamicAnimator?.referenceView, let identifier = identifier as? String, identifier.range(of: CollisionBorders.Brick) != nil else {
            //item.center.x = p.x + 10
            return
        }
    
        let brickTag = Int(identifier.substring(from: CollisionBorders.Brick.endIndex))
        if let brickView = view.viewWithTag(brickTag!) {
            remainingBricks -= 1
            if let delegate = breakoutBehaviorDelegate {
                delegate.gotMark(10)
                if remainingBricks == 0 {
                    delegate.gameOver(true)
                }
            }
            collider.removeBoundary(withIdentifier: identifier as NSCopying)
            //brickView.removeFromSuperview()
            UIView.animate(withDuration: 0.3,
                           animations: { brickView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)},
                           completion: { _ in brickView.removeFromSuperview() }
            )
        }
    }
    
}
