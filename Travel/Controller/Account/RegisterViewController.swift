//
//  SignUpViewController.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/18.
//

import UIKit
import SnapKit
import SPAlert
import FirebaseAuth


class RegisterViewController: UIViewController {

    let uiSettingUtility = UISettingUtility()

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
        button.setTitleColor(UIColor.systemOrange, for: [])
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemOrange.cgColor
        button.addTarget(self, action: #selector(returnRegisterResult), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = TravelAppColor.lightGrayBackgroundColor
        
        setupNav()
        setupUI()
        setupTextField()
        setupDobStackView()
    }

    func setupNav() {
        self.navigationItem.title = "Register"
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

        view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(userNameTextField.snp.bottom).offset(20)
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

        view.addSubview(pwdDoubleCheckTextField)
        pwdDoubleCheckTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }

        view.addSubview(dobStackView)
        dobStackView.snp.makeConstraints { make in
            make.top.equalTo(pwdDoubleCheckTextField.snp.bottom).offset(20)
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
        
    }
    
    func setupDobStackView() {
        dobStackView.axis = .horizontal
        dobStackView.distribution = .fillEqually
        dobStackView.spacing = 10
        
        dobStackView.addArrangedSubview(yearTextField)
        dobStackView.addArrangedSubview(monthTextField)
        dobStackView.addArrangedSubview(dayTextField)
    }
    
    @objc func returnRegisterResult() {
        if let name = userNameTextField.text, let account = accountTextField.text, let pwd = passwordTextField.text, let pwdDoubleCheck = pwdDoubleCheckTextField.text {

            if name != "", account != "", pwd != "", pwdDoubleCheck != "" {
                if pwd != pwdDoubleCheck {
                    showAlert(title: "註冊失敗", message: "密碼不一致", status: false)
                } else {
                    createUser(account: account, pwd: pwd) {
                        if let nav = self.navigationController {
                            nav.popToRootViewController(animated: true)
                        }
                    }
                
                }
            } else {
                showAlert(title: "註冊失敗", message: "欄位空缺", status: false)
            }
        }
        
    }
    
    func createUser(account: String, pwd: String, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: account, password: pwd) {
            [weak self] result, error in
            guard let self = self else { return }
            guard let user = result?.user, error == nil else {
                if let error = error {
                    let alertView = AlertAppleMusic17View(title: error.localizedDescription, subtitle: nil, icon: .error)
                    alertView.present(on: self.view)
                }
                
                print(error?.localizedDescription as Any)
                return
            }
            if let userName = self.userNameTextField.text {
                self.changeUserProfile(displayName: userName)
                completion()
            }
            
            print("emai:\(user.email ?? ""), uid:\(user.uid)")
//            completion()
        }
    
    }
    
    func changeUserProfile(displayName: String) {
        let changeReuest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeReuest?.displayName = displayName
        changeReuest?.commitChanges(completion: { error in
            guard error == nil else {
                if let error = error {
                    print("error:",error.localizedDescription)
                }
                return
            }
        })
        
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
    
    
    
    func setupTextField() {
        userNameTextField.delegate = self
        uiSettingUtility.textFieldSetting(userNameTextField, placeholder: "user name", keyboard: .default, autoCapitalize: .none)
        
        accountTextField.delegate = self
        uiSettingUtility.textFieldSetting(accountTextField, placeholder: "account(email)", keyboard: .emailAddress, autoCapitalize: .none)
        
        passwordTextField.delegate = self
        uiSettingUtility.textFieldSetting(passwordTextField, placeholder: "password", keyboard: .default, autoCapitalize: .none)
        
        pwdDoubleCheckTextField.delegate = self
        uiSettingUtility.textFieldSetting(pwdDoubleCheckTextField, placeholder: "password doble check", keyboard: .default, autoCapitalize: .none)
        
        yearTextField.delegate = self
        uiSettingUtility.textFieldSetting(yearTextField, placeholder: "year", keyboard: .numberPad, autoCapitalize: .none)
        
        monthTextField.delegate = self
        uiSettingUtility.textFieldSetting(monthTextField, placeholder: "month", keyboard: .numberPad, autoCapitalize: .none)
        
        dayTextField.delegate = self
        uiSettingUtility.textFieldSetting(dayTextField, placeholder: "day", keyboard: .numberPad, autoCapitalize: .none)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       self.view.endEditing(true)
   }

}
