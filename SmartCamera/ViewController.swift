//
//  ViewController.swift
//  SmartCamera
//
//  Created by De La Cruz, Eduardo on 13/11/2018.
//  Copyright © 2018 De La Cruz, Eduardo. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let infoLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Here is where we startup the camera
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        setupPercentageLabel()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // go to https://developer.apple.com/machine-learning/build-run-models/ and download the model and set it in model down VGG16 for VGG16 build model etc etc
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        guard let model = try? VNCoreMLModel(for: VGG16().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
            
            // Perhaps check the err
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.infoLabel.text = "The object detected is: \(firstObservation.identifier) with a confidence of \(firstObservation.confidence * 100)%"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    private func setupPercentageLabel() {
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        infoLabel.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
//        infoLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        infoLabel.font = UIFont(descriptor: infoLabel.font.fontDescriptor, size: 20)
        infoLabel.numberOfLines = 0
    }
}
