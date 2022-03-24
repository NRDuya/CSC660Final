//
//  ViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI

class LoginViewController: UIViewController, FUIAuthDelegate {
    let userModel = UserModel()

    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user: User = user {
                self.showUserInfo(user: user)
            } else {
                self.showLoginVC()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func showUserInfo(user: User) {
        usernameLabel.text = user.displayName
        
        // populate user reviews
    }
    
    @IBAction func viewSavedBathrooms(_ sender: UIButton) {
        print("PUSH")
    }

    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
        } catch let err {
          print(err)
        }
    }
    
    func showLoginVC() {
        let authUI = FUIAuth.defaultAuthUI()
        guard let authUI: FUIAuth = authUI else {
            return
        }
        let providers = [FUIEmailAuth()]
        authUI.providers = providers
        authUI.delegate = self
        let authViewController = authUI.authViewController()
        authViewController.modalPresentationStyle = .overCurrentContext
        self.present(authViewController, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let user = user else {
            return
        }
        guard let displayName = user.displayName else {
            return
        }
        // Add user to firebase database
        userModel.logUser(uid: user.uid, displayName: displayName)
    }
}

extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
