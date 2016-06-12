//
//  ViewController.swift
//  RoboVision
//
//  Created by Neeraj Kaul on 6/12/16.
//  Copyright © 2016 Adiyan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
import Firebase
import FirebaseAnalytics
import FirebaseDatabase
import Alamofire

class ViewController: UIViewController {
    //Instance Variables
    var ref: FIRDatabaseReference?
    var stopped = false;
    var currentMaxAccelX: Double = 0.0
    var currentMaxAccelY: Double = 0.0
    var currentMaxAccelZ: Double = 0.0
    
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    
    var movementManager = CMMotionManager()
    
    @IBOutlet weak var accX: UILabel!
    @IBOutlet weak var accY: UILabel!
    @IBOutlet weak var accZ: UILabel!
    @IBOutlet weak var maxAccX: UILabel!
    @IBOutlet weak var maxAccY: UILabel!
    @IBOutlet weak var maxAccZ: UILabel!
    
    
    @IBOutlet weak var rotX: UILabel!
    @IBOutlet weak var rotY: UILabel!
    @IBOutlet weak var rotZ: UILabel!
    @IBOutlet weak var maxRotX: UILabel!
    @IBOutlet weak var maxRotY: UILabel!
    @IBOutlet weak var maxRotZ: UILabel!
    override func viewDidLoad() {
        self.ref = FIRDatabase.database().reference();
        currentMaxAccelX = 0
        currentMaxAccelY = 0
        currentMaxAccelZ = 0
        
        currentMaxRotX = 0
        currentMaxRotY = 0
        currentMaxRotZ = 0
        
        movementManager.gyroUpdateInterval = 0.2
        movementManager.accelerometerUpdateInterval = 0.2
        
        //Start Recording Data
        
        movementManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!) { (accelerometerData: CMAccelerometerData?, NSError) -> Void in
            
            self.outputAccData(accelerometerData!.acceleration)
            if(NSError != nil) {
                print("\(NSError)")
            }
        }
        
        movementManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (gyroData: CMGyroData?, NSError) -> Void in
            self.outputRotData(gyroData!.rotationRate)
            if (NSError != nil){
                print("\(NSError)")
            }
            
            
        })
        
        
        
        
    }
    
    @IBAction func stopStartPressed(sender: AnyObject) {
        if (self.stopped) {
            self.stopped = false
        } else {
            self.stopped = true;
            self.ref!.child("directions").setValue("stop") 
        }
    }
    

    func outputAccData(acceleration: CMAcceleration){
        if !self.stopped {
            accX?.text = "\(acceleration.x).2fg"
            if fabs(acceleration.x) > fabs(currentMaxAccelX)
            {
                currentMaxAccelX = acceleration.x
            }
            
            accY?.text = "\(acceleration.y).2fg"
            if fabs(acceleration.y) > fabs(currentMaxAccelY)
            {
                currentMaxAccelY = acceleration.y
            }
            
            accZ?.text = "\(acceleration.z).2fg"
            if fabs(acceleration.z) > fabs(currentMaxAccelZ)
            {
                currentMaxAccelZ = acceleration.z
            }
            
            if(acceleration.y > 0.6){
                self.ref!.child("directions").setValue("forward")
            }else if(acceleration.y < -0.6){
                print("backward")
                self.ref!.child("directions").setValue("backward")
            }
            if(acceleration.x > 0.6){
                self.ref!.child("directions").setValue("right")        }else if(acceleration.z < -0.6){
                self.ref!.child("directions").setValue("left")        }
            
            maxAccX?.text = "\(currentMaxAccelX).2f"
            maxAccY?.text = "\(currentMaxAccelY).2f"
            maxAccZ?.text = "\(currentMaxAccelZ).2f"
        }
        
        
    }
    
    func outputRotData(rotation: CMRotationRate){
        
        
        rotX?.text = "\(rotation.x).2fr/s"
        if fabs(rotation.x) > fabs(currentMaxRotX)
        {
            currentMaxRotX = rotation.x
        }
        
        rotY?.text = "\(rotation.y).2fr/s"
        if fabs(rotation.y) > fabs(currentMaxRotY)
        {
            currentMaxRotY = rotation.y
        }
        
        rotZ?.text = "\(rotation.z).2fr/s"
        if fabs(rotation.z) > fabs(currentMaxRotZ)
        {
            currentMaxRotZ = rotation.z
        }
        
        
        
        
        maxRotX?.text = "\(currentMaxRotX).2f"
        maxRotY?.text = "\(currentMaxRotY).2f"
        maxRotZ?.text = "\(currentMaxRotZ).2f"
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func resetMaxValues(sender: AnyObject) {
        
        
        currentMaxAccelX = 0
        currentMaxAccelY = 0
        currentMaxAccelZ = 0
        
        currentMaxRotX = 0
        currentMaxRotY = 0
        currentMaxRotZ = 0
    }
    

}

