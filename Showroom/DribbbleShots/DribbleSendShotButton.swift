//
//  DribbleSendShotButton.swift
//  Showroom
//
//  Created by Dmitry Nesterenko on 26/07/2018.
//  Copyright © 2018 Alex K. All rights reserved.
//

import UIKit

private let kDribbleSendShotButtonImageViewLeadingSpace: CGFloat = 5

class DribbleSendShotButton: UIButton {

    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewWidth = imageView?.bounds.size.width ?? 0
        let titleLabelWidth = titleLabel?.bounds.width ?? 0
        let width = titleLabelWidth + kDribbleSendShotButtonImageViewLeadingSpace + imageViewWidth
        
        titleLabel?.frame.origin.x = round(bounds.midX - width / 2)
        imageView?.frame.origin.x = (titleLabel?.frame.maxX ?? 0) + kDribbleSendShotButtonImageViewLeadingSpace
    }
    
}
