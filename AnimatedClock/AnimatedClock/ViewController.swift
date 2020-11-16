//
//  ViewController.swift
//  AnimatedClock
//
//  Created by Alumno on 23/05/2017.
//  Copyright © 2017 Alumno. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, UIDynamicAnimatorDelegate {

    // MARK: - Variables
    var timer = Timer()
    var animator:UIDynamicAnimator? = nil;
    let gravity = UIGravityBehavior()
    let collider = UICollisionBehavior()
    let motionManager = CMMotionManager()
    let motionQueue = OperationQueue()
    
    
    // MARK: - Constants
    
    @IBOutlet weak var secondsHand: UIImageView!
    @IBOutlet weak var minutesHand: UIImageView!
    @IBOutlet weak var hoursHand: UIImageView!
    @IBOutlet weak var clockContainer: UIView!
    
    
    // MARK: - Portrait Mode
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - System Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.prepareImages()
        
        self.configureClock()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.configureClock), userInfo: nil, repeats: true);
        
        if(self.motionManager.isAccelerometerAvailable){
            self.motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: {(motion, error) in
                let grav : CMAcceleration = motion!.gravity;
                
                let x = CGFloat(grav.x);
                let y = CGFloat(grav.y);
                var p = CGPoint(x: x, y: y)
                
                p.x = p.x / 7
                p.y = p.y / 7
                
                let v = CGVector(dx: p.x, dy: -p.y);
                self.gravity.gravityDirection = v;
                
                DispatchQueue.main.async {
                    self.rotateClock(x: x, y: y)
                }
            })
        } else {
            print("Accelerometer not available")
        }
        
        self.createAnimatorOptions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Configuration
    
    /**
     Place the hands of the clock in their corresponding position
     */
    func configureClock() {
        
        let date = Date()
        
        let seconds = Calendar.current.component(.second, from: date)
        let minutes = Calendar.current.component(.minute, from: date)
        let hour = Calendar.current.component(.hour, from: date)
        
        self.secondsHand.transform = CGAffineTransform(rotationAngle: (CGFloat(seconds) * (2 * .pi / 60)))
        self.minutesHand.transform = CGAffineTransform(rotationAngle: (CGFloat(minutes) * (2 * .pi / 60)))
        self.hoursHand.transform = CGAffineTransform(rotationAngle: (CGFloat(hour) * (2 * .pi / 12)))

    }
    
    /**
     Place the anchor point of the images
     */
    func prepareImages() {
        self.secondsHand.layer.anchorPoint.y = 0.5
        self.minutesHand.layer.anchorPoint.y = 0.5
        self.hoursHand.layer.anchorPoint.y = 0.5
    }
    
    // MARK: - Animations
    
    /**
     Create and assign behaviors to animator and assigns the animator to the view containing the clock
     */
    func createAnimatorOptions() {
        self.animator = UIDynamicAnimator(referenceView:self.view);
        
        self.animator?.delegate = self
        
        self.collider.addItem(clockContainer)
        self.collider.translatesReferenceBoundsIntoBoundary = true
        
        self.animator?.addBehavior(collider)
        
        self.gravity.addItem(clockContainer);
        self.animator?.addBehavior(gravity);
        
    }
    
    // MARK: - Rotate Clock
    
    /**
     Rotate clock according to gravity
     */
    func rotateClock(x : CGFloat, y : CGFloat) {
        var angle = Float(atan2(x, -y))
        angle = -1 * angle
        angle = (angle > 0 ? angle : (2 * Float.pi + angle)) * 360 / (2 * Float.pi)
        self.clockContainer.transform = CGAffineTransform(rotationAngle: (CGFloat(angle) * (.pi / 180)))
    }
    
    // MARK: - Delegate
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        animator.removeBehavior(gravity)
        gravity.gravityDirection = CGVector(dx: 0.0, dy: 0.1)
        animator.addBehavior(gravity)
    }
    
}

