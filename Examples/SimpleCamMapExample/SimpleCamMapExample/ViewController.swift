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
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var openButton: UIButton!
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self

        openButton = UIButton(type: .system)
        openButton.setTitle("Open", for: .normal)
        openButton.tintColor = UIColor.white
        openButton.addTarget(self, action: #selector(openCamMap(_:)), for: .touchUpInside)

        view.addSubview(openButton)

        openButton.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        view.backgroundColor = UIColor.darkGray
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Request permission to use map
        locationManager?.requestAlwaysAuthorization()
    }

    @objc
    func openCamMap(_: Any) {
        let vc = CamMapViewController()
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }

}

extension ViewController: CamMapDelegate {
    func camMapDidComplete(images: [UIImage], location: CLLocationCoordinate2D?) {
        print("Completed. Got \(images.count) images and Location: \(String(describing: location))")
        self.dismiss(animated: false, completion: nil)
    }

    func camMapDidCancel() {
        print("Cancelled")
        self.dismiss(animated: false, completion: nil)
    }

    func camMapPermissionFailure(type: PermType, details: String) {
        print("Permission failure: \(details)")
        self.dismiss(animated: false, completion: nil)
    }

    func camMapHadFailure(error: CamMapError) {
        print("Unexpected error: \(error)")
        self.dismiss(animated: false, completion: nil)
    }

}
