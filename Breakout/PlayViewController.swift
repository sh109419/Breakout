//
//  FirstViewController.swift
//  Breakout
//
//  Created by hyf on 17/3/3.
//  Copyright © 2017年 hyf. All rights reserved.
//

import UIKit
import CoreMotion

class PlayViewController: UIViewController, BreakoutBehaviorDelegate, UIDynamicAnimatorDelegate {
    
    private struct Constants {
        static let BrickClearnace: CGFloat = 4.0
        static let WidthHeightRatio: CGFloat = 1 / 3
        static let BottomSpace: CGFloat = 20.0
        static let BallSize: CGFloat = 20.0
    }

    @IBOutlet weak var playView: UIView!
    private var paddleView: UIView?
    
    let breakoutBehavior = BreakoutBehavior()
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self.playView)
        animator.delegate = self
        return animator
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutBehavior.breakoutBehaviorDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newGame()
        print(Settings.sharedInstance.paddleSize)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseTimer()
        clear()
    }

    private func clear() {
        breakoutBehavior.clear()
        playView.subviews.forEach{ $0.removeFromSuperview() }
    }

    private func setUp() {
        breakoutBehavior.addWall()
        addBricks(countPerRow: 5, totalCount: Settings.sharedInstance.numberOfBricks)
        addPaddle()
        addBall()
    }

    private func addBricks(countPerRow: Int, totalCount: Int) {
        let brickWidth = (playView.bounds.width - Constants.BrickClearnace * CGFloat(countPerRow-1)) / CGFloat(countPerRow)
        let brickHeight = brickWidth * Constants.WidthHeightRatio
        let brickSize: CGSize = CGSize(width: brickWidth, height: brickHeight)
        var col: Int
        var row: Int
        for index in 0..<totalCount {
            row = index / countPerRow
            col = index - row * countPerRow
            let brick = UIView()
            brick.frame.size = brickSize
            brick.frame.origin = CGPoint(x: playView.bounds.origin.x + (brickWidth+Constants.BrickClearnace) * CGFloat(col), y: playView.bounds.origin.y + (brickHeight+Constants.BrickClearnace) * CGFloat(row))
            brick.backgroundColor = UIColor.brown
            breakoutBehavior.addBrick(brick)
        }
    }

    private let paddleSizeOffset: [CGFloat] = [0.8, 1, 1.2]
    
    private func addPaddle() {
        let paddleWidth = playView.bounds.width / 5 * paddleSizeOffset[Settings.sharedInstance.paddleSize.rawValue]
        let paddleHeight = paddleWidth / 4
        let paddleSize: CGSize = CGSize(width: paddleWidth, height: paddleHeight)
        let paddle = UIView()
        paddle.frame.size = paddleSize
        paddle.frame.origin = CGPoint(x: playView.bounds.midX - paddleWidth/2, y: playView.bounds.maxY - paddleHeight - Constants.BottomSpace)
        paddle.backgroundColor = UIColor.lightGray
        breakoutBehavior.addPaddle(paddle)
        paddleView = paddle // for gesture
        paddleAccelerometer() // start accelerometer
    }

    private func addBall() {
        let ballView = BallView(frame: CGRect(x: 0, y: paddleView!.frame.minY-Constants.BallSize, width: Constants.BallSize, height: Constants.BallSize))
        ballView.center.x = paddleView!.center.x
        breakoutBehavior.addBall(ballView)
        animator.updateItem(usingCurrentState: ballView)
    }
    
    // pan gesture
    @IBAction func panPaddle(_ sender: UIPanGestureRecognizer) {
        paddleMove(sender)
    }
    
    private func makePaddleWithinView() {
        if let paddle = paddleView {
            // don't over left wall
            if paddle.frame.origin.x < CGFloat(0) {
                paddle.frame.origin.x = 0
            }
            // don't over right wall
            let maxOriginX = playView.frame.width - paddle.frame.width
            if paddle.frame.origin.x > maxOriginX {
                paddle.frame.origin.x = maxOriginX
            }
        }
    }
    
    private func paddleMove(_ recognizer: UIPanGestureRecognizer) {
        if let paddle = paddleView, recognizer.state == .changed || recognizer.state == .ended {
            paddle.center.x += recognizer.translation(in: playView).x * 1.5
            
            // 球垂直弹跳，陷入死循环？？？？？？没有左右限制可以解除死循环
            makePaddleWithinView()
        
            recognizer.setTranslation(CGPoint.zero, in: playView)
            
            breakoutBehavior.updatePaddlePosition(paddleView!)
        }
        
    }

    //Mark: - accelerometer
    private let motionManager = CMMotionManager()
    
    private func paddleAccelerometer() {
        motionManager.accelerometerUpdateInterval = 1/60
        
        if motionManager.isAccelerometerAvailable {
            let queue = OperationQueue.current
            motionManager.startAccelerometerUpdates(to: queue!, withHandler: {
                [unowned self] (accelerometerData, error) in
                //动态设置paddel位置
                if let dx = accelerometerData?.acceleration.x {
                    let posX = (self.paddleView?.center.x)! + CGFloat(dx) * 10.0
                    self.paddleView?.center.x = posX
                    self.makePaddleWithinView()
                    self.breakoutBehavior.updatePaddlePosition(self.paddleView!)
                }
            })
        }
    }
    
    //MARK: - UIDynamicAnimatorDelegate
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
       // print("pause")
        
        // When the animators pauses, if there are no longer active items in the reference view and that the game is currently active, reinitalize the game.
      /*  print("did pause")
        if animator.items(in: animator.referenceView!.bounds).isEmpty {
            //gameIsActive = false
            //ballView = nil
            gameOver(false)
            print("game over")
        }*/
    }

    // breakoutbehaviordelegate
    
    func gotMark(_ mark: Int) {
        score += mark
    }

    func gameOver(_ playerWon: Bool) {
        if (playerWon) {
            let alert = UIAlertController(title: "You won", message: "Play new level.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {(UIAlertAction) -> Void in self.newLevel() }))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "You lost", message: "Try again!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel,
                                          handler: {(UIAlertAction) -> Void in self.newGame()}
            ))
            present(alert, animated: true, completion: nil)
        }
        // stop animator
        stopAnimator()
        pauseTimer()
    }

    private func newGame() {
        startAnimator()
        clear()
        breakoutBehavior.newGame()
        setUp()
        score = 0
        startTimer()
    }
    
    private func newLevel() {
        startAnimator()
        clear()
        breakoutBehavior.newLevel()
        setUp()
        resumeTimer()
    }
    
    private func startAnimator() {
        animator.addBehavior(breakoutBehavior)
    }
    
    private func stopAnimator() {
        animator.removeBehavior(breakoutBehavior)
    }
    
    //timer & score
    
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var timerLabel: UILabel!
    

    // record time by second
    private var count = 0 {
        didSet {
            timerLabel.text = String(format: "%02d:%02d", count/60, count%60)
        }
    }
    
    // record score
    private var score = 0 {
        didSet {
            scoreLabel.text = score.description
        }
    }

    private var timer: Timer!
    
    private func pauseTimer() {
        timer.invalidate()
    }
    
    private func resumeTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self, selector: #selector(self.addTime),
            userInfo: nil,
            repeats: true
        )
    }
    
    private func startTimer() {
        count = 0
        resumeTimer()
    }
    
    @objc func addTime() {
        count += 1
    }
    
}

