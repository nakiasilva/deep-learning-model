//
//  ViewController.swift
//  APITest
//
//  Created by Yash on 15/9/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Alamofire
import CoreML
import Vision

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let inferenceTimeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let statusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let lewdView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nonLewdView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "-"
        label.textAlignment = .right
        //label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return label
    }()
    
    let statusCaptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "Status:"
        label.textAlignment = .left
        //label.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        return label
    }()
    
    let inferenceTimeCaptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "Inference Time:"
        label.textAlignment = .left
        //label.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        return label
    }()
    
    let lewdCaptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "Porn:"
        label.textAlignment = .left
        //label.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        return label
    }()
    
    let nonLewdCaptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "Non-Porn:"
        label.textAlignment = .left
        //label.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        return label
    }()
    
    let lewdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "-"
        label.textAlignment = .right
        //label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return label
    }()
    
    let inferenceTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "-"
        label.textAlignment = .right
        //label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return label
    }()

    let nonLewdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.text = "-"
        label.textAlignment = .right
        //label.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return label
    }()
    
    let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.8
        return imageView
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background")
        //imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var realTimeButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.7026434076)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.setTitle("Real Time", for: .normal )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(presentRealtimeActionSheet), for: .touchUpInside)
        return button
    }()
    
    lazy var sendRequestButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.7026434076)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.setTitle("Clasify Image", for: .normal )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(presentDeepLearningModelActionSheet), for: .touchUpInside)
        return button
    }()

    lazy var selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.6959278682)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.setTitle("Select Image", for: .normal )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.addTarget(self, action: #selector(presentImagePickerActionSheet), for: .touchUpInside)
        return button
    }()
    
    @objc func presentRealtimeActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let mobileNetV1OnDevice = UIAlertAction(title: "MobileNet V1 (On Device)", style: .default) { action in
            self.presentRealTimeView(realTimeModelName: "frames_mv1")
        }
        
        let mobileNetV2OnDevice = UIAlertAction(title: "MobileNet V2 (On Device)", style: .default) { action in
            self.presentRealTimeView(realTimeModelName: "frames_mv1")
        }

        actionSheet.addAction(mobileNetV1OnDevice)
        actionSheet.addAction(mobileNetV2OnDevice)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
        actionSheet.view.subviews.flatMap({$0.constraints}).filter{ (one: NSLayoutConstraint)-> (Bool)  in
            return (one.constant < 0) && (one.secondItem == nil) &&  (one.firstAttribute == .width)
            }.first?.isActive = false
    }
    
    @objc func presentRealTimeView(realTimeModelName: String) {
        let realTimeViewController = RealTimeViewController()
        realTimeViewController.modalPresentationStyle = .fullScreen
        realTimeViewController.modelName = realTimeModelName
        realTimeViewController.mainViewController = self
        let navController = UINavigationController(rootViewController: realTimeViewController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
    
    @objc func presentImagePickerActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            self.selectImage( sourceType: UIImagePickerController.SourceType.camera)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.selectImage(sourceType: UIImagePickerController.SourceType.photoLibrary)
        }
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
        actionSheet.view.subviews.flatMap({$0.constraints}).filter{ (one: NSLayoutConstraint)-> (Bool)  in
            return (one.constant < 0) && (one.secondItem == nil) &&  (one.firstAttribute == .width)
            }.first?.isActive = false
        
    }
    
    @objc func presentDeepLearningModelActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let inception = UIAlertAction(title: "Inception V3", style: .default) { action in
            self.classifyImage(modelUrl: "http://45.113.235.180:80/inceptionV3/test")
        }
        
        let mobileNet = UIAlertAction(title: "MobileNet 2", style: .default) { action in
            self.classifyImage(modelUrl: "http://45.113.235.180:80/mobilenetV2/test")
        }
        
        let yolo = UIAlertAction(title: "MobileNet 1", style: .default) { action in
            self.classifyImage(modelUrl: "http://45.113.235.180:80/mobilenetV1/test")
        }
        
        let mobileNetV1OnDevice = UIAlertAction(title: "MobileNet V1 (On Device)", style: .default) { action in
            self.callOnDeviceModel(witModelName: "frames_mv1")
        }
        
        let mobileNetV2OnDevice = UIAlertAction(title: "MobileNet V2 (On Device)", style: .default) { action in
            self.callOnDeviceModel(witModelName: "frames_mv2")
        }

        actionSheet.addAction(inception)
        actionSheet.addAction(mobileNet)
        actionSheet.addAction(yolo)
        actionSheet.addAction(mobileNetV1OnDevice)
         actionSheet.addAction(mobileNetV2OnDevice)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
        actionSheet.view.subviews.flatMap({$0.constraints}).filter{ (one: NSLayoutConstraint)-> (Bool)  in
            return (one.constant < 0) && (one.secondItem == nil) &&  (one.firstAttribute == .width)
            }.first?.isActive = false
        
    }
    
    @objc func selectImage(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker =  editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker =  originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            imageView.image = selectedImage
        }
        
        dismiss(animated: true)
    }
    
    fileprivate func setupApplicationBackground() {
        //Add Background Image View
        view.addSubview(backgroundImageView)
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //Add Blur View
        view.addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    fileprivate func setupStatViews() {
        //Add the status view
        view.addSubview(statusView)
        setupStatusView()
        statusView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        statusView.topAnchor.constraint(equalTo: realTimeButton.bottomAnchor, constant: 10).isActive = true
        statusView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        statusView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Add the lewd view
        view.addSubview(lewdView)
        setupLewdView()
        lewdView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lewdView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 10).isActive = true
        lewdView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        lewdView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        //Add the non-lewd view
        view.addSubview(nonLewdView)
        setupNonLewdView()
        nonLewdView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nonLewdView.topAnchor.constraint(equalTo: lewdView.bottomAnchor, constant: 10).isActive = true
        nonLewdView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        nonLewdView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Add the inference time view
        view.addSubview(inferenceTimeView)
        setupInferenceTimeView()
        inferenceTimeView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inferenceTimeView.topAnchor.constraint(equalTo: nonLewdView.bottomAnchor, constant: 10).isActive = true
        inferenceTimeView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        inferenceTimeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func setupImageView() {
        //Add the imageView
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.image = UIImage(named: "defaultImage")
    }
    
    fileprivate func setupButtons() {
        //Add the "Select Image" button
        view.addSubview(selectImageButton)
        selectImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        selectImageButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        selectImageButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //Add the "Classify Image" button
        view.addSubview(sendRequestButton)
        sendRequestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendRequestButton.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 10).isActive = true
        sendRequestButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        sendRequestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        //Add the "Real Time" button
        view.addSubview(realTimeButton)
        realTimeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        realTimeButton.topAnchor.constraint(equalTo: sendRequestButton.bottomAnchor, constant: 10).isActive = true
        realTimeButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        realTimeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup the application's UI
        setupApplicationBackground()
        setupImageView()
        setupButtons()
        setupStatViews()
    }
    
    func setupInferenceTimeView() {
        //Add the inferenceTimeCaptionLabel and set its constraints
        inferenceTimeView.addSubview(inferenceTimeCaptionLabel)
        inferenceTimeCaptionLabel.leftAnchor.constraint(equalTo: inferenceTimeView.leftAnchor).isActive = true
        inferenceTimeCaptionLabel.topAnchor.constraint(equalTo: inferenceTimeView.topAnchor).isActive = true
        inferenceTimeCaptionLabel.bottomAnchor.constraint(equalTo: inferenceTimeView.bottomAnchor).isActive = true
        inferenceTimeCaptionLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        //Add the inferenceTimeLabel and set its constraints
        inferenceTimeView.addSubview(inferenceTimeLabel)
        inferenceTimeLabel.rightAnchor.constraint(equalTo: inferenceTimeView.rightAnchor).isActive = true
        inferenceTimeLabel.topAnchor.constraint(equalTo: inferenceTimeView.topAnchor).isActive = true
        inferenceTimeLabel.bottomAnchor.constraint(equalTo: inferenceTimeView.bottomAnchor).isActive = true
        inferenceTimeLabel.leftAnchor.constraint(equalTo: inferenceTimeCaptionLabel.rightAnchor).isActive = true
    }
    
    func setupNonLewdView() {
        //Add the nonLewdCaptionLabel and set its constraints
        nonLewdView.addSubview(nonLewdCaptionLabel)
        nonLewdCaptionLabel.leftAnchor.constraint(equalTo: nonLewdView.leftAnchor).isActive = true
        nonLewdCaptionLabel.topAnchor.constraint(equalTo: nonLewdView.topAnchor).isActive = true
        nonLewdCaptionLabel.bottomAnchor.constraint(equalTo: nonLewdView.bottomAnchor).isActive = true
        nonLewdCaptionLabel.widthAnchor.constraint(equalToConstant: 110).isActive = true
        
        //Add the nonLewdLabel and set its constraints
        nonLewdView.addSubview(nonLewdLabel)
        nonLewdLabel.rightAnchor.constraint(equalTo: nonLewdView.rightAnchor).isActive = true
        nonLewdLabel.topAnchor.constraint(equalTo: nonLewdView.topAnchor).isActive = true
        nonLewdLabel.bottomAnchor.constraint(equalTo: nonLewdView.bottomAnchor).isActive = true
        nonLewdLabel.leftAnchor.constraint(equalTo: nonLewdCaptionLabel.rightAnchor).isActive = true
    }
    
    func setupLewdView() {
        //Add the lewdCaptionLabel and set its constraints
        lewdView.addSubview(lewdCaptionLabel)
        lewdCaptionLabel.leftAnchor.constraint(equalTo: lewdView.leftAnchor).isActive = true
        lewdCaptionLabel.topAnchor.constraint(equalTo: lewdView.topAnchor).isActive = true
        lewdCaptionLabel.bottomAnchor.constraint(equalTo: lewdView.bottomAnchor).isActive = true
        lewdCaptionLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        //Add the lewdLabel and set its constraints
        lewdView.addSubview(lewdLabel)
        lewdLabel.rightAnchor.constraint(equalTo: lewdView.rightAnchor).isActive = true
        lewdLabel.topAnchor.constraint(equalTo: lewdView.topAnchor).isActive = true
        lewdLabel.bottomAnchor.constraint(equalTo: lewdView.bottomAnchor).isActive = true
        lewdLabel.leftAnchor.constraint(equalTo: lewdCaptionLabel.rightAnchor).isActive = true
    }
    
    func setupStatusView() {
        //Add the statusCaptionLabel and set its constraints
        statusView.addSubview(statusCaptionLabel)
        statusCaptionLabel.leftAnchor.constraint(equalTo: statusView.leftAnchor).isActive = true
        statusCaptionLabel.topAnchor.constraint(equalTo: statusView.topAnchor).isActive = true
        statusCaptionLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor).isActive = true
        statusCaptionLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        //Add the statusLabel and set its constraints
        statusView.addSubview(statusLabel)
        statusLabel.rightAnchor.constraint(equalTo: statusView.rightAnchor).isActive = true
        statusLabel.topAnchor.constraint(equalTo: statusView.topAnchor).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: statusView.bottomAnchor).isActive = true
        statusLabel.leftAnchor.constraint(equalTo: statusCaptionLabel.rightAnchor).isActive = true
    }
    
    func classifyImage(modelUrl: String) {
        
        if let image = imageView.image {
            self.resetStats()
            self.statusLabel.text = "Sending Request"
            
            let start = DispatchTime.now()
            
            
            if let data = image.jpegData(compressionQuality: 0.2) {
                let parameters: Parameters = ["access_token" : "file"]
                
                // Start Alamofire
                Alamofire.upload(multipartFormData: { multipartFormData in
                    for (key,value) in parameters {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                    multipartFormData.append(data, withName: "file", fileName: "file",mimeType: "image/jpeg")
                },
                usingThreshold: UInt64.init(),
                to: modelUrl,//http://45.113.235.180:80/inceptionV3/test
                method: .post,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                        case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    if let jsonResponse = response.result.value as? [String: Any] {
                                        if let _ = jsonResponse["url"], let porn = jsonResponse["porn"] as? Double, let non_porn = jsonResponse["non_porn"] as? Double {
                                            //Sucessfully recieved and parsed response
                                            
                                                self.lewdLabel.text = "\(Double(round(10000*porn)/10000)*100)%"
                                                self.nonLewdLabel.text = "\(Double(round(10000*non_porn)/10000)*100)%"
                                            
                                            
                                                let end = DispatchTime.now()
                                                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                                                let timeInterval = Double(nanoTime) / 1_000_000 // Technically could overflow for long running tests
                                                self.inferenceTimeLabel.text = "\(Int(round(timeInterval))) ms"
                                            
                                            
                                                self.statusLabel.text = "Complete"
                                        }
                                    }
                                }
                        case .failure(let encodingError):
                            print(encodingError)
                    }
                })
            }
        }
        
    }
    
    func resetStats() {
        lewdLabel.text = "-"
        nonLewdLabel.text = "-"
        inferenceTimeLabel.text = "-"
    }
    
    func callOnDeviceModel(witModelName modelName:String) {
        guard let pickedImage = imageView.image else { return }
        resetStats()
        statusLabel.text = "Sending Request"
        print (modelName)
        print (type(of: modelName))
        
        let start = DispatchTime.now()
        
        
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
        
        // Create vision request
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation] else { fatalError("Unexpected results") }
            
            // Update the main UI thread with our result
            DispatchQueue.main.async {[weak self] in
                for result in results {
                    print (result)
                    let confidence = Float(round(Float(result.confidence)*10000))
                    if result.identifier == "non porn" {
                        self?.nonLewdLabel.text = " \(confidence/100)%"
                    } else {
                        self?.lewdLabel.text = " \(confidence/100)%"
                    }
                }
                
                let end = DispatchTime.now()
                let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
                let timeInterval = Double(nanoTime) / 1_000_000 // Technically could overflow for long running tests
                self?.inferenceTimeLabel.text = "\(Int(round(timeInterval))) ms"
                
                self?.statusLabel.text = "Completed"
            }
        }
        
        guard let ciImage = CIImage(image: pickedImage)
            else { fatalError("Cannot read picked image")}
        
        // Run the classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    
}

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


