//
//  ViewController.swift
//  Restroom Review
//

import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI
import Cosmos

class UsersReviewTableCell: UITableViewCell {
    @IBOutlet weak var restroomName: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var rating: CosmosView!
}

class LoginViewController: UIViewController, FUIAuthDelegate {
    let userModel = UserModel()
    let restroomModel = RestroomModel()
    let reviewModel = ReviewModel()

    @IBOutlet weak var reviewTableView: UITableView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var reviews: [Review] = []
    
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
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
        super.viewDidLoad()
    }

    func showUserInfo(user: User) {
        usernameLabel.text = user.displayName
        Task {
            do {
                reviews = try await reviewModel.getReviewsByUser(userID: user.uid)
                for review in reviews {
                    if let reviewOrigin = review.restroom {
                        review.restroom = try await restroomModel.getRestroomName(restroomID: reviewOrigin)
                    }
                }
                await MainActor.run {
                    reviewTableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
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

extension FUIAuthBaseViewController {
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}

extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UsersReviewTableCell") as? UsersReviewTableCell else {
            return UITableViewCell()
        }
        let review = reviews[indexPath.row]
        
        cell.restroomName.text = review.restroom ?? "No name"
        cell.rating.rating = review.rating
        cell.content.text = review.content
        return cell
    }
}
