//
//  ViewController.swift
//  GuideBot
//
//  Created by Sohan Vichare on 6/11/16.
//  Copyright © 2016 Sohan Vichare. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAnalytics
import FirebaseInstanceID
import FirebaseDatabase
import AVFoundation
import ChameleonFramework

class ViewController: UIViewController {
    
    var ref: FIRDatabaseReference?
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var hasStartedBool = false;
    let stillImageOutput = AVCaptureStillImageOutput()
    var timer: NSTimer?
    var previousKey = ""
    var counter = 0
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    private lazy var client : ClarifaiClient = ClarifaiClient(appID: clarifaiClientID, appSecret: clarifaiClientSecret)
    @IBOutlet var startEndButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up button
        startEndButton.backgroundColor = UIColor.flatSkyBlueColor()
        startEndButton.tintColor = UIColor.whiteColor();
        startEndButton.layer.cornerRadius = 15
        //set up firebase
        self.ref = FIRDatabase.database().reference();
        //set up AVcapturesession
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        beginSession()
                    }
                }
            }
        }
    }
    
    @IBAction func startOrEndLiveStreamButtonClicked(sender: AnyObject) {
        if (!hasStartedBool) {
            //not streaming
            startEndButton.backgroundColor = UIColor.flatWatermelonColor()
            startEndButton.setTitle("Stop GUIDEBOT", forState: UIControlState.Normal)
            timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.takePicture), userInfo: nil, repeats: true)
            hasStartedBool = true;
        } else {
            print("stopped")
            startEndButton.backgroundColor = UIColor.flatSkyBlueColor()
            startEndButton.setTitle("Start GUIDEBOT", forState: UIControlState.Normal)
            timer?.invalidate()
            timer = nil;
            hasStartedBool = false;
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        self.previewLayer!.frame = self.view.bounds
        if self.previewLayer!.connection.supportsVideoOrientation {
            self.previewLayer!.connection.videoOrientation = self.interfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addImageToFirebase(image: UIImage) {
        print("adding..")
        let imageData:NSData = UIImageJPEGRepresentation(image, 0.3)!
        let strBase64:String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        let key = self.ref!.child("images").childByAutoId().key
        let imageUpdate = ["/images/\(key)": strBase64];
        self.ref!.updateChildValues(imageUpdate);
        if self.counter == 10 {
            self.ref!.child("images").removeValue()
            self.counter = 0
        } else {
            self.counter = self.counter + 1
        }
    }
    
    func beginSession() {
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        } catch {
            print("error");
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!);
        self.view.bringSubviewToFront(startEndButton)
        captureSession.startRunning()
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    func interfaceOrientationToVideoOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .Portrait:
            return .Portrait
        case .PortraitUpsideDown:
            return .PortraitUpsideDown
        case .LandscapeLeft:
            return .LandscapeLeft
        case .LandscapeRight:
            return .LandscapeRight
        default:
            break
        }
        return .Portrait
    }
    
    func recognizeImageAndReadout(image: UIImage) {
        // Scale down the image. This step is optional. However, sending large images over the
        // network is slow and does not significantly improve recognition performance.
        /**let size = CGSizeMake(320, 320 * image.size.height / image.size.width)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()**/
        let jpeg = UIImageJPEGRepresentation(image, 0.9)!
        
        // Send the JPEG to Clarifai for standard image tagging.
        client.recognizeJpegs([jpeg]) {
            (results: [ClarifaiResult]?, error: NSError?) in
            if error != nil {
                print("Error: \(error)\n")
            } else {
                //readout
                let str = results![0].tags[0]
                print(str)
                self.myUtterance = AVSpeechUtterance(string: results![0].tags[0]);
                self.myUtterance.rate = 0.4
                self.synth.speakUtterance(self.myUtterance)
                //post to firebase
                let key = self.ref!.child("recognizedObjects").childByAutoId().key
                let textUpdate = ["/recognizedObjects/\(key)": str];
                self.ref!.updateChildValues(textUpdate);
            }
        }
    }
    
    func takePicture(sender: UITapGestureRecognizer) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                self.addImageToFirebase(UIImage(data: imageData)!)
                self.recognizeImageAndReadout(UIImage(data: imageData)!)
            }
        }
    }
    

}