//
//  UITableViewCellExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return className
    }
}

extension UITableViewCell: ReusableView {}

protocol CellViewModeling {
    var reusableIdentifier: String { get }
}

protocol ConfigurableCell {
    func configure(with cellViewModel: CellViewModeling)
}

protocol AccessoryViewActionCell: AnyObject {
    var action: (() -> Void)? { get set }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
}
