//
//  RelTimeViewController.swift
//  APITest
//
//  Created by Yash on 29/10/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import AVKit
import Vision

class RealTimeViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var mainViewController: MainViewController?
    var modelName:String = ""
    let nonPornLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8036971831)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 25
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let pornLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8036971831)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 25
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        //Start the camera
        let captureSession = AVCaptureSession()
        //captureSession.sessionPreset = .photo
        
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
        
        setupIdentifierConfidenceLabel()
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    
    fileprivate func setupIdentifierConfidenceLabel() {
        view.addSubview(nonPornLabel)
        nonPornLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        nonPornLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        nonPornLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        nonPornLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(pornLabel)
        pornLabel.bottomAnchor.constraint(equalTo: nonPornLabel.topAnchor, constant: -8).isActive = true
        pornLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        pornLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        pornLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(footerView)
        footerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        footerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        footerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48 ).isActive = true
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let mlModel:MLModel
               
        if modelName == "frames_mv1" {
           //Use the MobileNet v1 model
           mlModel = frames_mv1().model
        } else if modelName == "frames_mv2" {
            //Use the MobileNet v2 model
            mlModel = frames_mv2().model
        } else{
        //Use the fefault model (MobileNet v1 model)
        mlModel = frames_mv1().model
        }
        
        guard let model = try? VNCoreMLModel(for: mlModel) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            DispatchQueue.main.async {
                for result in results {
                    let confidence = Float(round(Float(result.confidence)*10000))
                    if result.identifier == "non porn" {
                       self.nonPornLabel.text = "Non-Porn: \(confidence/100)%"
                    } else {
                        self.pornLabel.text = "Porn: \(confidence/100)%"
                    }
                }
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}
