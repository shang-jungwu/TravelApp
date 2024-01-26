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

    let uiSettingUtility = UISettingUtility()
    
    lazy var travelPersonImageView = UIImageView(image: UIImage(named: "stripy-travel-plans-around-the-world"))

    lazy var accountTextField: TravelCustomTextField = TravelCustomTextField()
//    {
//        let textField = TravelCustomTextField()
//        textField.layer.cornerRadius = 15
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.systemRed.cgColor
//        return textField
//    }()

    lazy var passwordTextField: TravelCustomTextField = TravelCustomTextField()
//    {
//        let textField =  TravelCustomTextField()
//        textField.layer.cornerRadius = 15
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.systemRed.cgColor
//        return textField
//    }()

    func setupTextField() {
        uiSettingUtility.textFieldSetting(accountTextField, placeholder: "account", keyboard: .default, autoCapitalize: .none)

        uiSettingUtility.textFieldSetting(passwordTextField, placeholder: "password", keyboard: .default, autoCapitalize: .none)

    }
    

    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: [])
        button.setTitleColor(.systemRed, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemRed.cgColor
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
        button.setTitleColor(.systemOrange, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
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
        setupTextField()
    }
    
    func setupNav() {
        self.navigationItem.title = "User Login"
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

    func setupUI() {
        
        view.addSubview(travelPersonImageView)
        travelPersonImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(200)
        }
        travelPersonImageView.contentMode = .scaleAspectFill
        
        view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(travelPersonImageView.snp.bottom).offset(80)
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
        
        view.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }

        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(registerButton.snp.top).offset(-20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
       

    }

    

} // class end
