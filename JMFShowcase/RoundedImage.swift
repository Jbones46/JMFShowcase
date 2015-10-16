//
//  RoundedImage.swift
//  JMFShowcase
//
//  Created by Justin Ferre on 10/16/15.
//  Copyright © 2015 Justin Ferre. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = 4.0
        self.clipsToBounds = true
    }

}
