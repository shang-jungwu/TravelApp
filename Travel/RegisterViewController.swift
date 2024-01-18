//
//  SignUpViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import FirebaseAuth


class RegisterViewController: UIViewController {

    lazy var userNameTextField = TravelCustomTextField()
    lazy var accountTextField = TravelCustomTextField()
    lazy var passwordTextField = TravelCustomTextField()
    lazy var pwdDoubleCheckTextField = TravelCustomTextField()
    
    lazy var dobStackView = UIStackView()
    lazy var yearTextField = TravelCustomTextField()
    lazy var monthTextField = TravelCustomTextField()
    lazy var dayTextField = TravelCustomTextField()
    
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: [])
        button.setTitleColor(UIColor.systemGreen, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.addTarget(self, action: #selector(createNewAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func createNewAccount() {
        print("register")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNav()
        setupUI()
    }

    func setupNav() {
        self.navigationItem.title = "Register"
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    
    func setupUI() {
        view.addSubview(userNameTextField)
        userNameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        textFieldSetting(userNameTextField, placeholder: "user name", keyboard: .default)
        
        view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        textFieldSetting(accountTextField, placeholder: "account", keyboard: .emailAddress)
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(accountTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        textFieldSetting(passwordTextField, placeholder: "password", keyboard: .default)
        
        view.addSubview(pwdDoubleCheckTextField)
        pwdDoubleCheckTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        textFieldSetting(pwdDoubleCheckTextField, placeholder: "password doble check", keyboard: .default)
        
        view.addSubview(dobStackView)
        dobStackView.snp.makeConstraints { make in
            make.top.equalTo(pwdDoubleCheckTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        setupDobStackView()
        
        view.addSubview(registerButton)
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(dobStackView.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
        
    }
    
    func setupDobStackView() {
        dobStackView.axis = .horizontal
        dobStackView.distribution = .fillEqually
        dobStackView.spacing = 10
        
        dobStackView.addArrangedSubview(yearTextField)
        textFieldSetting(yearTextField, placeholder: "year", keyboard: .numberPad)
        dobStackView.addArrangedSubview(monthTextField)
        textFieldSetting(monthTextField, placeholder: "month", keyboard: .numberPad)
        dobStackView.addArrangedSubview(dayTextField)
        textFieldSetting(dayTextField, placeholder: "day", keyboard: .numberPad)
    }
    
    @objc func returnRegisterResult() {
        if let name = userNameTextField.text, let account = accountTextField.text, let pwd = passwordTextField.text, let pwdDoubleCheck = pwdDoubleCheckTextField.text {
            if name != "", account != "", pwd != "", pwdDoubleCheck != "" {
                if pwd != pwdDoubleCheck {
                    showAlert(title: "註冊失敗", message: "兩次密碼不一致", status: false)
                } else {
                    createUser(email: account, pwd: pwd)
                    
                }
            } else {
                showAlert(title: "註冊失敗", message: "欄位空缺", status: false)
            }
        }
        
    }
    
    func createUser(email: String, pwd: String) {
        print("create new account")
    }
    
    func showAlert(title: String, message: String, status: Bool) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let successAction = UIAlertAction(title: "OK", style: .cancel) { action in
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
        }
        let failAction = UIAlertAction(title: "OK", style: .destructive)
        
        if status {
            alert.addAction(successAction)
        } else {
            alert.addAction(failAction)
        }
        
        self.present(alert, animated: true)
    }
    
    
    
    func textFieldSetting(_ sender: TravelCustomTextField, placeholder: String, keyboard: UIKeyboardType) {
        sender.placeholder = placeholder
        sender.layer.cornerRadius = 15
        sender.layer.borderWidth = 2
        sender.layer.borderColor = UIColor.systemCyan.cgColor
        sender.keyboardType = keyboard
    }
    

    

}
