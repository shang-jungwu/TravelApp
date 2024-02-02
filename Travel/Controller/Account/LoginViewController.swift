//
//  LoginViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit
import SPAlert
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {

//    lazy var searchVC = SearchViewController()
    lazy var tabBarVC = TabBarController()
    lazy var registerVC = RegisterViewController()

    let uiSettingUtility = UISettingUtility()
    
    lazy var travelPersonImageView = UIImageView(image: UIImage(named: "stripy-travel-plans-around-the-world"))

    lazy var accountTextField: TravelCustomTextField = TravelCustomTextField()

    lazy var passwordTextField: TravelCustomTextField = TravelCustomTextField()

    func setupTextField() {
        accountTextField.delegate = self
        uiSettingUtility.textFieldSetting(accountTextField, placeholder: "account(email)", keyboard: .emailAddress, autoCapitalize: .none)

        passwordTextField.delegate = self
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

        if let account = accountTextField.text, let password = passwordTextField.text {
            
            guard account != "", password != "" else {
                let textBlankAlert = AlertAppleMusic17View(title: "不可留空", subtitle: nil, icon: .error)
                textBlankAlert.present(on: self.view)
                return
            }
           
            checkUserStatus(account: account, password: password) { [weak self] in
                guard let self = self else { return }
                let scene = UIApplication.shared.connectedScenes.first {
                    $0.activationState == .foregroundActive
                }
                if let windowScene = scene as? UIWindowScene {
                    windowScene.keyWindow?.rootViewController = self.tabBarVC
                }
                print("show main vc")
            }
        }


        
    }
    
    func checkUserStatus(account: String, password: String, completion: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        Auth.auth().signIn(withEmail: account, password: password) { result, error in
            guard error == nil else {
                if let error = error {
                    let errorAlertView = AlertAppleMusic17View(title: error.localizedDescription, subtitle: nil, icon: .error)
                    errorAlertView.present(on: self.view)
                }
                defaults.set(false, forKey: "LoggedIn")
                return
            }
            defaults.set(true, forKey: "LoggedIn")
            print("User logged in")
            completion()
        }
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
        view.backgroundColor = UIColor(r: 239, g: 239, b: 244, a: 1)
        setupNav()
        setupUI()
        setupTextField()
    }
    
    func setupNav() {
        self.navigationItem.title = "User Login"
        self.navigationController?.navigationBar.prefersLargeTitles = true
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
   }

}
