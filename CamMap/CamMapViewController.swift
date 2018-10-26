//
//  CamMapViewController.swift
//  CamMap
//
//  Created by Humberto Aquino on 10/26/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import AVFoundation
import Foundation
import MapKit
import UIKit

class CamMapViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!

    var mapHeight: CGFloat = 250

    var stackView: UIStackView!
    var previewView: UIView!
    var mapView: MKMapView!

    var captureButton: UIButton!

    var protraitConstrains: [NSLayoutConstraint]!
    var landscapeConstrains: [NSLayoutConstraint]!

    var capturePhotoOutput: AVCapturePhotoOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView()
        previewView = UIView()

        view.backgroundColor = UIColor.white
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Can't capture device: video")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)

            captureSession = AVCaptureSession()
            captureSession.addInput(input)

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            previewView.layer.addSublayer(videoPreviewLayer)

            captureSession.startRunning()
        } catch {
            print(error)
        }

        captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.addTarget(self, action: #selector(takePicture(_:)), for: .touchUpInside)

        view.addSubview(mapView)
        view.addSubview(previewView)
        view.addSubview(captureButton)

        configureContraints()
        updateLayoutConstraints()

        // Get an instance of ACCapturePhotoOutput class
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        // Set the output on the capture session
        captureSession?.addOutput(capturePhotoOutput)
    }

    func configureContraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        protraitConstrains = [
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.30),

            previewView.topAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            previewView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            previewView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]

        landscapeConstrains = [
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.30),

            previewView.topAnchor.constraint(equalTo: self.view.topAnchor),
            previewView.leftAnchor.constraint(equalTo: self.mapView.rightAnchor),
            previewView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]
    }

    @objc
    func takePicture(_: Any) {
        print("Take pic")

        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        // Call capturePhoto method by passing our photo settings and a
        // delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    func updateLayoutConstraints() {
        let portrait = UIDevice.current.orientation != .landscapeLeft && UIDevice.current.orientation != .landscapeRight
        if portrait {
            NSLayoutConstraint.deactivate(landscapeConstrains)
            NSLayoutConstraint.activate(protraitConstrains)
        } else {
            NSLayoutConstraint.deactivate(protraitConstrains)
            NSLayoutConstraint.activate(landscapeConstrains)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateVideoPreviewLayerSize()
    }

    func updateVideoPreviewLayerSize() {
        videoPreviewLayer.frame = previewView.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Update camera orientation
        let videoOrientation: AVCaptureVideoOrientation
        switch UIDevice.current.orientation {
        case .portrait:
            videoOrientation = .portrait
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        default:
            videoOrientation = .portrait
        }
        videoPreviewLayer.connection?.videoOrientation = videoOrientation

        // Update view constraints
        updateLayoutConstraints()
    }
}

extension CamMapViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings _: AVCaptureResolvedPhotoSettings,
                     bracketSettings _: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // get captured image

        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        // Convert photo same buffer to a jpeg image data by using // AVCapturePhotoOutput
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        // Initialise a UIImage with our image data
        let capturedImage = UIImage(data: imageData, scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
}
