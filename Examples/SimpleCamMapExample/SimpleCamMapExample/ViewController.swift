//
//  ViewController.swift
//  SimpleCamMapExample
//
//  Created by Humberto Aquino on 10/26/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import UIKit
import SnapKit
import CamMap

class ViewController: UIViewController {

    var openButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        openButton = UIButton(type: .system)
        openButton.setTitle("Open", for: .normal)
        openButton.addTarget(self, action: #selector(openCamMap(_:)), for: .touchUpInside)

        view.addSubview(openButton)

        openButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view).offset(-50)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalTo(self.view)
        }
        view.backgroundColor = UIColor.white
    }

    @objc
    func openCamMap(_: Any) {
        let vc = CamMapViewController()
        present(vc, animated: true, completion: nil)
    }

}

