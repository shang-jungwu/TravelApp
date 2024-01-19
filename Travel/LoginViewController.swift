//
//  LoginViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
//import FirebaseAuth

class LoginViewController: UIViewController {

//    lazy var searchVC = SearchViewController()
    lazy var tabBarVC = TabBarController()
    lazy var registerVC = RegisterViewController()

    lazy var accountTextField: TravelCustomTextField = {
        let textField =  TravelCustomTextField()
        textField.placeholder = "account"
        textField.layer.cornerRadius = 15
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemCyan.cgColor
        return textField
    }()

    lazy var passwordTextField: TravelCustomTextField = {
        let textField =  TravelCustomTextField()
        textField.placeholder = "password"
        textField.layer.cornerRadius = 15
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemCyan.cgColor
        return textField
    }()
    

    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: [])
        button.setTitleColor(.systemCyan, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemCyan.cgColor
        button.addTarget(self, action: #selector(pushSearchVC), for: .touchUpInside)
        return button
    }()

    @objc func pushSearchVC() {
        let userDefaults = UserDefaults.standard
        if accountTextField.text != "", passwordTextField.text != "" {
            userDefaults.set(true, forKey: "LoggedIn")
        } else {
            userDefaults.set(false, forKey: "LoggedIn")
        }

        let scene = UIApplication.shared.connectedScenes.first {
            $0.activationState == .foregroundActive
        }
        if let windowScene = scene as? UIWindowScene {
            windowScene.keyWindow?.rootViewController = tabBarVC

        }

        print("show search vc")
    }
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: [])
        button.setTitleColor(.systemCyan, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemCyan.cgColor
        button.addTarget(self, action: #selector(showRegisterVC), for: .touchUpInside)
        return button
    }()
    
    @objc func showRegisterVC() {
        if let nav = self.navigationController {
            nav.pushViewController(registerVC, animated: true)
            print("Push to RegisterVC")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNav()
        setupUI()
    }
    
    func setupNav() {
        self.navigationItem.title = "User Login"
    }

    func setupUI() {
        view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }

        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(accountTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }

        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
        view.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }

    }

    

} // class end
