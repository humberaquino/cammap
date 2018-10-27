//
//  UIViewContoller+Utils.swift
//  CamMap
//
//  Created by Humberto Aquino on 10/26/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit

func simpleAlert(title: String, message: String, doneTitle: String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: doneTitle, style: .cancel, handler: { _ in
        alert.dismiss(animated: true, completion: nil)
    }))
    return alert
}

extension UIViewController {
    func presentSimpleAlert(title: String, message: String, doneTitle: String) {
        let alert = simpleAlert(title: title, message: message, doneTitle: doneTitle)
        present(alert, animated: true, completion: nil)
    }
}
