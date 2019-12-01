//
//  ViewController.swift
//  Image Classifier
//
//  Created by Ruel Lafuente on 01/12/2019.
//  Copyright © 2019 LafuenteR. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var imageClassifierLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        
         guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let capturePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(capturePreviewLayer)
        capturePreviewLayer.frame = view.frame
        capturePreviewLayer.bounds.size.height = self.view.bounds.size.height - 200
        print(view.frame, "hehe")
        
        let captureDataOutput = AVCaptureVideoDataOutput()
        captureDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(captureDataOutput)
        
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        print("hey")
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard let squeezeNetmodel = try? VNCoreMLModel(for: SqueezeNet().model) else { return }
        
        let coreMLRequest = VNCoreMLRequest(model: squeezeNetmodel) { (finishedRequest, Error) in
            
            print("hoooy")
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
                self.imageClassifierLabel.text = String(firstObservation.identifier) + " - " + String(firstObservation.confidence)
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: imageBuffer, options: [:]).perform([coreMLRequest])
    }


}

