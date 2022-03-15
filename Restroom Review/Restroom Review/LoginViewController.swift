//
//  ViewController.swift
//  Restroom Review
//
//  Created by Nathaniel Duya on 3/4/22.
//

import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.showUserInfo(user:user)
            } else {
                self.showLoginVC()
            }
        }
    }

    func showUserInfo(user:User) {
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
        
        let authViewController = authUI.authViewController()
        authViewController.modalPresentationStyle = .overCurrentContext
        self.present(authViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
