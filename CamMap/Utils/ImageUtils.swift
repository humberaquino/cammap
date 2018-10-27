//
//  ImageUtils.swift
//  CamMap
//
//  Created by Humberto Aquino on 10/26/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class ImageUtils {
    static func loadImage(named: String) -> UIImage? {
        let podBundle = Bundle(for: ImageUtils.self)
        let image = UIImage(named: named, in: podBundle, compatibleWith: nil)
        return image
    }
}
