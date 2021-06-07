//
//  UIViewController+ActivityIndicator.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

private var kActivityIndicatorAssociatedObjectKey: UInt8 = 0

protocol ActivityIndicatorPresentable: AnyObject {
    func showActivityIndicator(withText text: String?)
    func hideActivityIndicator()
}

extension ActivityIndicatorPresentable where Self: UIViewController {
    func showActivityIndicator(withText text: String?) {
        DispatchQueue.main.async {
            ///check if activity indicator is already showed
            if (objc_getAssociatedObject(self, &kActivityIndicatorAssociatedObjectKey) as? UIView) != nil {
                return
            }
            
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            self.view.addSubview(contentView)

            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                contentView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
            
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 15
            contentView.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                stackView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
                stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor)
            ])
            
            let activityColor = UIColor.japaneseLaurel
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.accessibilityIdentifier = EventsAccessibility.activityIndicator
            activityIndicator.style = .large
            activityIndicator.color = activityColor
            activityIndicator.startAnimating()
            stackView.addArrangedSubview(activityIndicator)
            
            if let text = text {
                let label = UILabel()
                label.textAlignment = .center
                label.textColor = activityColor
                label.font = .boldSystemFont(ofSize: 16)
                label.text = text
                stackView.addArrangedSubview(label)
            }
            
            objc_setAssociatedObject(self, &kActivityIndicatorAssociatedObjectKey, contentView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            guard let activityIndicator = objc_getAssociatedObject(self, &kActivityIndicatorAssociatedObjectKey)
                    as? UIView else { return }
            activityIndicator.removeFromSuperview()
            objc_setAssociatedObject(self, &kActivityIndicatorAssociatedObjectKey,
                                     nil,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
