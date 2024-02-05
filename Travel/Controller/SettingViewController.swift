//
//  ProfileViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
import FirebaseAuth

class SettingViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    let uiSettingUtility = UISettingUtility()
    let firebaseAuthUtility = FirebaseAuthUtility()
    
    lazy var loginVC = LoginViewController()
    lazy var userNameLabel = UILabel()
       

    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: [])
        button.setTitleColor(.white, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.backgroundColor = .systemOrange
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.addTarget(self, action: #selector(popToLoginVC), for: .touchUpInside)
        return button
    }()

    @objc func popToLoginVC() {
        do {
            try Auth.auth().signOut()
            userDefaults.set(false, forKey: "LoggedIn")
        } catch {
            print(error)
        }
        
        let scene = UIApplication.shared.connectedScenes.first {
            $0.activationState == .foregroundActive
        }
        if let windowScene = scene as? UIWindowScene {
            windowScene.keyWindow?.rootViewController = UINavigationController(rootViewController: loginVC)
            
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
            }
            print("pop to root vc")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        
        setupNav()
        setupUI()
    }

    func setupNav() {
        self.navigationItem.title = "Profile"
    }

    func setupUI() {
        view.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        uiSettingUtility.labelSettings(label: userNameLabel, fontSize: 26, fontWeight: .bold, color: .black, alignment: .center, numOfLines: 0)
        userNameLabel.text = "Hi, \(firebaseAuthUtility.getUserName()) !"
        
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(50)
        }
    }

    

    

}
