//
//  RangeSelectorViewController.swift
//  ChatApplication
//
//  Created by Yash on 25/10/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Lottie

class RangeSelectorViewController: UIViewController {
    
    var newMessageController: NewMessageController?
    
    //UI Component Declarations
    lazy var animatedView: AnimationView = {
        let view = AnimationView(name: "location")
        view.animationSpeed = 1
        view.loopMode = .autoReverse//.loop
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let rangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 76 , weight: .semibold)
        label.textAlignment = .center
        label.text = "100km"
        label.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var rangeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 200
        slider.value = 100
        slider.tintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        slider.thumbTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In View Controller")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setupUIElements()
    }
    
    func setupUIElements() {
        view.addSubview(rangeSlider)
        view.addSubview(rangeLabel)
        view.addSubview(animatedView)
        rangeSlider.addTarget(self, action: #selector(sliderInAction), for: .valueChanged)
    
        rangeSlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -30).isActive = true
        rangeSlider.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
        rangeSlider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
        rangeSlider.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        rangeLabel.bottomAnchor.constraint(equalTo: rangeSlider.topAnchor).isActive = true
        rangeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        rangeLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        rangeLabel.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        animatedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        animatedView.bottomAnchor.constraint(equalTo: rangeLabel.topAnchor).isActive = true
        animatedView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        animatedView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        startAnimation()
        
    }
    
    func startAnimation() {
        animatedView.play()
    }
    
    @objc func sliderInAction() {
        rangeLabel.text = "\(Int(rangeSlider.value))km"
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }

    @objc func handleDone() {
        newMessageController?.range = Int(rangeSlider.value)
        newMessageController?.configureLocationManager()
        dismiss(animated: true, completion: nil)
    }
}
