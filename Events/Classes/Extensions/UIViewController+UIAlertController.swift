//
//  UIViewController+UIAlertController.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

protocol AlertPresentable: AnyObject {
    func showAlert(_ message: String, title: String, handler: ((UIAlertAction) -> Void)?)
}

extension AlertPresentable where Self: UIViewController {
    func showAlert(_ message: String, title: String = "", handler: ((UIAlertAction) -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: handler))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
