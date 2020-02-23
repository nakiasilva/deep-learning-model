//
//  ChatLogController.swift
//  ChatApplication
//
//  Created by Yash on 9/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ChatLogController: UICollectionViewController,UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var appUser: AppUser? {
        didSet {
            //Set the title of the chat log with that of the seletced app user
            navigationItem.title = appUser?.name
            
            //Observe for the messages sent to and recieved fro the selected app user
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = appUser?.uid  else { return }
        let userMessagesRef  = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
        let messageId = snapshot.key
        let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                
                let message = Message(dictionary: dictionary)
                //Append the messages
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    //Scroll down so as to show the latest message
                    self.collectionView.scrollToBottom()
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    lazy var inputTextField :UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(20, 0, 10)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.layer.cornerRadius = 20
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 55, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
        setupKeyboardObservers()
        setKeyboardDismiss()
    }
    
    func setKeyboardDismiss() {
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func setupKeyboardObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
         self.collectionView.scrollToBottom()
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 70, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            let keyBoardHeight = keyboardSize.height - 20
            self.containerViewBottomAnchor?.constant = -keyBoardHeight
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        containerViewBottomAnchor?.constant = 0
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 55, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        let message =  messages[indexPath.item]
        cell.textView.text = message.text
        
        if let seconds = message.timeStamp?.doubleValue {
            let timeStampDate = Date(timeIntervalSince1970: seconds)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            cell.timestampLabel.text = dateFormatter.string(from: timeStampDate)
            
            dateFormatter.dateFormat = "dd/MM/yyyy"
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true

            cell.dateLabel.text = dateFormatter.string(from: timeStampDate)
            
            if indexPath.item>0, let prevSeconds = messages[indexPath.item-1].timeStamp?.doubleValue {
                let prevTimeStampDate = Date(timeIntervalSince1970: prevSeconds)
                if NSCalendar.current.isDate(timeStampDate, inSameDayAs:prevTimeStampDate) == true{
                    cell.removeDateView()
                } else {
                    cell.displayDateView()
                }
            } else {
                cell.displayDateView()
            }
        }
        
        //Setup up the chat bubbles based on the sender and reciever (blue and gray chat bubbles)
        setupCell(cell: cell, message: message)
        
        if let text = message.text  {
            //Set the width of the chat bubble and make the text view visible
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 20
            cell.textView.isHidden = false
        } else if message.imageURL != nil {
            //set the width of the bubble if the image content is an image
            cell.bubbleWidthAnchor?.constant = 215
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let messageImageURL = message.imageURL {
            //Messsage is of the type image -> Load the image and show the image view
            cell.messageImageView.loadImageFromCache(withURLString: messageImageURL)
            cell.messageImageView.isHidden = false
            cell.timestampLabel.isHidden = true
            //check if the content was classified as obsene or not
            if (message.porn ?? 0.0 > message.non_porn ?? 0.0) {
                cell.setMask(pornConfidence: message.porn)
            } else {
                cell.unsetMask()
            }
        } else {
            //Message is not an image -> hide the image view
            cell.messageImageView.isHidden = true
            cell.timestampLabel.isHidden = false
            cell.unsetMask()
        }
        if message.fromId == Auth.auth().currentUser?.uid {
            //if the message is from the logged in user, use the blue right aligned chat bubble
            cell.bubbleView.backgroundColor =  ChatMessageCell.blueColor
            cell.textView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
            cell.timestampLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.unsetMask()
        } else {
            //use the left aligned grey chat bubble
            cell.bubbleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.textView.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.timestampLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 50
        
        let message = messages[indexPath.item]
        
        //Compute the height of the chat bubble
        if let text = message.text {
            //message of type text
            height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue,let imageHeight = message.imageHeight?.floatValue {
            //Maintain the images proportions. The constant multiplier (215) as set to be the same as the width of the image bubble view
            height = CGFloat(imageHeight/imageWidth * 215)
        }
        
        height = height + 40
        
        if indexPath.item>0, let seconds = message.timeStamp?.doubleValue,let prevSeconds = messages[indexPath.item-1].timeStamp?.doubleValue {
            let timeStampDate = Date(timeIntervalSince1970: seconds)
            let prevTimeStampDate = Date(timeIntervalSince1970: prevSeconds)
            if NSCalendar.current.isDate(timeStampDate, inSameDayAs:prevTimeStampDate) == true{
                height = height - 40
            }
        } 
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func  estimatedFrameForText(text: String) -> CGRect {
        //The width (200) is the same as the width specified in the width constraint of the textView and the bubbleView in the ChatMessageCell class
        let size = CGSize(width: 200, height: 800)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        //The font size 16 is set below to be the same as the font size set for the test view in the ChatMessageCell class
        return NSString(string: text + "  HH:MM AA").boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        containerView.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 0.95)
        containerView.translatesAutoresizingMaskIntoConstraints = false
    
        //Add containerView
        view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        let imageButton = UIButton(type: .system)
        imageButton.setImage(UIImage(named: "photoIcon.png"), for: .normal)
        
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.addTarget(self, action: #selector(presentImagePickerActionSheet), for: .touchUpInside)
        containerView.addSubview(imageButton)
        imageButton.leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor, constant: 15).isActive = true
        imageButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).isActive = true
        imageButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        inputTextField.leftAnchor.constraint(equalTo: imageButton.rightAnchor, constant: 15).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -35).isActive = true
        
        //Setup the separator
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    
    @objc func presentImagePickerActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            self.handleUploadTap( sourceType: UIImagePickerController.SourceType.camera)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { action in
            self.handleUploadTap(sourceType: UIImagePickerController.SourceType.photoLibrary)
        }
        
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
        actionSheet.view.subviews.flatMap({$0.constraints}).filter{ (one: NSLayoutConstraint)-> (Bool)  in
            return (one.constant < 0) && (one.secondItem == nil) &&  (one.firstAttribute == .width)
        }.first?.isActive = false
    }
    
    @objc func handleUploadTap(sourceType: UIImagePickerController.SourceType) {
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
            sendImage(image: selectedImage)
        }
        
        dismiss(animated: true)
    }  
    
    func sendImage(image: UIImage) {
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
             to: "http://45.113.235.180:80/inceptionV3/test",
             method: .post,
             encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let jsonResponse = response.result.value as? [String: Any] {
                            if let url = jsonResponse["url"], let porn = jsonResponse["porn"], let non_porn = jsonResponse["non_porn"] {
                                //Sucessfully recieved and parsed response
                                self.sendMessage(withImageURL: url as! String, image: image,porn: porn as! Double,non_porn: non_porn as! Double)
                            }
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            })
        }
    }
    
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @objc func handleSend(){
        if (inputTextField.text == "") {return}
        let properties = ["text":inputTextField.text!] as [String : AnyObject]
        sendMessage(withProperties: properties)
    }
    
    private func sendMessage(withImageURL imageURL : String, image: UIImage, porn: Double, non_porn: Double) {
        let properties = ["imageURL":imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height, "porn": porn, "non_porn": non_porn] as [String : AnyObject]
        sendMessage(withProperties: properties)
    }
    
    private func sendMessage(withProperties properties: [String: AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = appUser!.uid!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSDate().timeIntervalSince1970
        
        var values = ["toId": toId,"fromId":  fromId,"timeStamp": Int(timeStamp)] as [String : AnyObject]
        //Add the properties passed as part of the input parameter to the values dictionary
        properties.forEach({values[$0] = $1})
        childRef.updateChildValues(values as [AnyHashable : Any])
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            guard let messageId = childRef.key else { return }
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessageRef.updateChildValues([messageId:1])
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))

        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                //Calculate the zoomed in heiht to preserve the original image ratio
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            })
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //Animate zoom out
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true 
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (completed) in
                zoomOutImageView.removeFromSuperview()
            }
        }
    }
}
