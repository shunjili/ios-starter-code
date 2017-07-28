//
//  ViewController.swift
//  HelloWorld
//
//  Created by shunji_li on 10/29/16.
//  Copyright © 2016 shunji_li. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.yellow
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)

      // Initialize the captureSession object.
      captureSession = AVCaptureSession()

      // Set the input device on the capture session.
      captureSession?.addInput(input)
      // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)

    } catch {
      // If any error occurs, simply print it out and don't continue any more.
      print(error)
      return
    }
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    let captureMetadataOutput = AVCaptureMetadataOutput()
    captureSession?.addOutput(captureMetadataOutput)

    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    // Start video capture.
    captureSession?.startRunning()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  var captureSession:AVCaptureSession?
  var videoPreviewLayer:AVCaptureVideoPreviewLayer?
  var qrCodeFrameView:UIView?


}

