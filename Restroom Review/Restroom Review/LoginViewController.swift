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

    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.showUserInfo(user:user)
            } else {
                self.showLoginVC()
            }
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemFill
        label.textAlignment = .center
        return label
    }()

    private let logOutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemRed
        button.setTitle("Log out", for: .normal)
        return button
    }()
    
    func showUserInfo(user:User) {
        nameLabel.frame = CGRect(x: 20, y: view.bounds.height / 3, width: view.bounds.width - 40, height: 50)
        logOutButton.frame = CGRect(x: 20, y: view.bounds.height / 3 + 50,  width: view.bounds.width - 40, height: 50)
        logOutButton.addTarget(self, action: #selector(logoutButtonPressed), for:.touchUpInside)
        view.addSubview(nameLabel)
        view.addSubview(logOutButton)
    }
    
    @objc func logoutButtonPressed() {
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
