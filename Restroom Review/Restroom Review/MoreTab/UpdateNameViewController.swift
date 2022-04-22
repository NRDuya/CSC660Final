//
//  UpdateNameViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI

class UpdateNameViewController: UIViewController {
    let userModel = UserModel()
    
    @IBOutlet weak var displayName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func updateName(_ sender: UIButton) {
        if let name = displayName.text, name.isEmpty {
            dismiss(animated: true)
            return
        }

        let user = Auth.auth().currentUser
        guard let user = user, let name = displayName.text, name != user.displayName else {
            return
        }
        let profileChangeRequest = user.createProfileChangeRequest()
        profileChangeRequest.displayName = name
        Task {
            do {
                try await profileChangeRequest.commitChanges()
                
            } catch {
                print(error)
            }
        }
        userModel.logUser(uid: user.uid, displayName: name)
        dismiss(animated: true)
    }
}
