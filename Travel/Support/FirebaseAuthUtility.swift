//
//  FirebaseAuthUtility.swift
//  Travel
//
//  Created by SoniaWu on 2024/2/2.
//

import Foundation
import FirebaseAuth

struct FirebaseAuthUtility {
    
    
    func getUserName() -> String {
        if let user = Auth.auth().currentUser {
            if let displayName = user.displayName {
                return displayName
            }
        }
        return ""
    }
}
