//
//  SignUpVC.swift
//  TextSnap
//
//  Created by Steven on 8/24/17.
//  Copyright © 2017 Steven. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class SignUpVC: UIViewController {
    
    @IBOutlet weak var userImagePicker: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var signUpBtn: UIButton!
    
    var userUid: String!
    
    var emailField: String!
    
    var passwordField: String!
    
    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    var username: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        
        //imagePicker.delegate =
        
        imagePicker.allowsEditing = true

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            userImagePicker.image = image
            
            imageSelected = true
        } else {
            print("image wasnt selected")
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUser(img: String){
        let userData = [
        "username": username!,
        "userImg": img
        ]
        
        KeychainWrapper.standard.set(userUid, forKey: "uid")
        
        let location = Database.database().reference().child("users").child(userUid)
        
        location.setValue(userData)
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    func uploadImg(){
    
        if usernameField.text == nil{
            signUpBtn.isEnabled = false
        } else{
            
            username = usernameField.text
            
            signUpBtn.isEnabled = true
        }
        guard let imag = userImagePicker.image, imageSelected == true else{
            print("image needs to be selected")
            
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(imag, 0.2){
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            
            metadata.contentType = "image/jpg"
            
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) {(metadat, error)in
                if error != nil{
                print("did not upload image")
                } else {
                    print("uploaded")
                    let downloadURl = metadata.downloadURL()?.absoluteString
                    
                    if let url = downloadURl {
                        self.setUser(img: url)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool){
        if let _ = KeychainWrapper.standard.string(forKey: "uid"){
        
            performSegue(withIdentifier: "toMessage", sender: nil)
        }
    }
    
    @IBAction func creatAccount (_ sender: AnyObject){
        Auth.auth().createUser(withEmail: emailField, password: passwordField,completion: {(user,error)in
            
            if error != nil {
                print("cant creat user")
            } else{
                if let user = user {
                self.userUid = user.uid
                }
            }
        
        })
    }
    
    @IBAction func selectdImgPicker (_ sender: AnyObject){
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel (_ sender: AnyObject){
        dismiss(animated: true, completion: nil)
    }


}
