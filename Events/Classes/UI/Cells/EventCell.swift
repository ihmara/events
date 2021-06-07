//
//  EventCell.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

final class EventCell: UITableViewCell, NibLoadableView, AccessoryViewActionCell {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    private lazy var customSelectedBackgroundView: UIView = {
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = UIColor.japaneseLaurel.withAlphaComponent(0.4)
        return backgroundView
    }()
    
    var action: (() -> Void)?

    @IBAction func chnageEventState(_ sender: UIButton) {
        action?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = customSelectedBackgroundView
        titleLable.accessibilityIdentifier = EventsAccessibility.EventCell.title
        detailsLabel.accessibilityIdentifier = EventsAccessibility.EventCell.detailsLabel
        actionButton.accessibilityIdentifier = EventsAccessibility.EventCell.actionButton
    }
}

extension EventCell: ConfigurableCell {
    func configure(with cellViewModel: CellViewModeling) {
        guard let eventCellViewModel = cellViewModel as? EventCellViewModel else { return }
        titleLable?.text = eventCellViewModel.title
        detailsLabel?.text = eventCellViewModel.details
        let buttonImage = eventCellViewModel.isSelected ? #imageLiteral(resourceName: "favorite-icon") : #imageLiteral(resourceName: "unfavorite-icon")
        actionButton.setImage(buttonImage, for: .normal)
    }
}
