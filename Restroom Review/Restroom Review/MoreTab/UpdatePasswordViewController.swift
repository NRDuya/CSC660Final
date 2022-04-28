//
//  UpdatePasswordViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI

class UpdatePasswordViewController: UIViewController {
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func updatePassword(_ sender: UIButton) {
        guard let password = newPassword.text, let cpassword = confirmPassword.text else {
            return
        }
        
        guard password == cpassword else {
            let alert = UIAlertController(title: "Passwords must match", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
            return
        }
        
        guard password.count >= 6 else {
            let alert = UIAlertController(title: "Password must be at least 6 characters long", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
            return
        }
        
        let user = Auth.auth().currentUser
        guard let user = user else {
            return
        }
        user.updatePassword(to: password)
        dismiss(animated: true)
    }
    
}
