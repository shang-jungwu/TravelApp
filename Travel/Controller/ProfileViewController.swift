//
//  ProfileViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit

class ProfileViewController: UIViewController {

    lazy var loginVC = LoginViewController()

    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: [])
        button.setTitleColor(UIColor.systemGreen, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.addTarget(self, action: #selector(popToLoginVC), for: .touchUpInside)
        return button
    }()

    @objc func popToLoginVC() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(false, forKey: "LoggedIn")

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
        view.backgroundColor = .white
        
        setupNav()
        setupUI()
    }

    func setupNav() {
        self.navigationItem.title = "Profile"
    }

    func setupUI() {
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(50)
        }
    }

    

}
