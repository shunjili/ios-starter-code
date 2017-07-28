//
//  ViewController.swift
//  HelloWorld
//
//  Created by shunji_li on 10/29/16.
//  Copyright © 2016 shunji_li. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.yellow

    setUpVideoSession()
    setUpQRBox()
    setUpMessageLabel()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  var captureSession:AVCaptureSession?
  var videoPreviewLayer:AVCaptureVideoPreviewLayer?
  var qrCodeFrameView:UIView?

  fileprivate var messageLabel: UILabel!

  private func setUpMessageLabel() {
    messageLabel = UILabel()
    messageLabel.text = "Nothing"
    view.addSubview(messageLabel)

    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    messageLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
  }

  private func setUpQRBox() {
    qrCodeFrameView = UIView()

    if let qrCodeFrameView = qrCodeFrameView {
      qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
      qrCodeFrameView.layer.borderWidth = 2
      view.addSubview(qrCodeFrameView)
      view.bringSubview(toFront: qrCodeFrameView)
    }
  }

  private func setUpVideoSession() {
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
}

extension QRScanViewController: AVCaptureMetadataOutputObjectsDelegate {
  func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects == nil || metadataObjects.count == 0 {
      qrCodeFrameView?.frame = CGRect.zero
      messageLabel.text = "No QR code is detected"
      return
    }

    // Get the metadata object.
    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

    if metadataObj.type == AVMetadataObjectTypeQRCode {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds

      if metadataObj.stringValue != nil {
        messageLabel.text = metadataObj.stringValue
        if let url = URL(string: metadataObj.stringValue) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      }
    }
  }
}
