//
//  BounceButton.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import UIKit

class BounceButton: UIButton {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateButton {
            super.sendActions(for: .touchUpInside)
        }
    }
    
    private func animateButton(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        } completion: { _ in
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 10,
                           options: .allowUserInteraction,
                           animations: {
                            self.transform = .identity
                           },
                           completion: { _ in completion() })
        }
    }

}
