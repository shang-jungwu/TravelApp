//
//  TravelCustomTextField.swift
//  Travel
//
//  Created by SoniaWu on 2024/1/17.
//

import UIKit
import SnapKit

class TravelCustomTextField: UITextField, UITextFieldDelegate {

    var textPadding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    private func setup() {
        self.textAlignment = .left
//        self.contentScaleFactor = 0.5
        self.backgroundColor = .white
        self.textColor = .black
        self.layer.cornerRadius = 15
       
        delegate = self

   }



}
