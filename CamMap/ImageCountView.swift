//
//  ImageCountView.swift
//  CamMap
//
//  Created by Humberto Aquino on 10/27/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

class ImageCountView: UIView {
    var originalImage: UIImage?
    var previewImageView: UIImageView!
    var currentCount: Int = 0
    var countLabel: UILabel!

    convenience init() {
        self.init(frame: CGRect.zero)
        render()
    }

    private func render() {
        previewImageView = UIImageView()
        previewImageView.layer.cornerRadius = 5.0
        previewImageView.clipsToBounds = true

        // Core attrs
        countLabel = UILabel()
        countLabel.textColor = UIColor.white
        countLabel.font = UIFont.boldSystemFont(ofSize: 23)
        countLabel.textAlignment = .center

        // Shadow
        countLabel.layer.shadowColor = UIColor.black.cgColor
        countLabel.layer.shadowRadius = 3.0
        countLabel.layer.shadowOpacity = 0.8
        countLabel.layer.shadowOffset = .zero
        countLabel.layer.masksToBounds = false

        addSubview(previewImageView)
        addSubview(countLabel)

        bringSubviewToFront(countLabel)
    }

    // Core method to interact with the view's state

    func updateWith(image: UIImage, count: Int) {
        originalImage = image
        currentCount = count

        previewImageView.frame = bounds

        let width: CGFloat = 40
        let height: CGFloat = 30
        let x = bounds.width / 2 - width / 2
        let y = bounds.height / 2 - height / 2
        countLabel.frame = CGRect(x: x, y: y, width: width, height: height)

        previewImageView.image = image
        countLabel.text = "\(count)"
    }
}
