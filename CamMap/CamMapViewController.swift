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

public protocol CamMapDelegate: class {
    func camMapDidComplete(images: [UIImage], location: CLLocationCoordinate2D?)
    func camMapDidCancel()
    func camMapHadFailure(error: CamMapError)
    func camMapPermissionFailure(type: PermType, details: String)
}

public enum CamMapError: Error {
    case noVideo
    case cantStartCapture(Error)
    case locationFailed(Error)
    case photoJPEGFailed
    case imageDataTransformation
    case cantSaveImage(Error?)
}

public enum PermType {
    case location
    case camera
    case photos
}

public class CamMapViewController: UIViewController {
    // Params
    public var regionRadius: CLLocationDistance = 400
    public var shouldStorePhotos = true

    // Map and Location
    var locationManager = CLLocationManager()
    var mapView: MKMapView!
    var zoomLevel: Float = 14.0
    var selectedCoordinate: CLLocationCoordinate2D?
    var centerMapPin: UIImageView!

    // Camera
    var previewView: UIView!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    var images: [UIImage] = []

    // Actions
    var captureButton: UIButton!
    var completeButton: UIButton!

    // Layout
    var protraitConstrains: [NSLayoutConstraint]!
    var landscapeConstrains: [NSLayoutConstraint]!

    // Delegate
    public weak var delegate: CamMapDelegate?

    // MARK: - Life cycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateVideoPreviewLayerSize()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Only request is location is not selected
        if selectedCoordinate != nil {
            return
        }

        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        if let location = locationManager.location {
            centerMapOnLocation(location: location)
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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

    // MARK: - Setup UI

    func setupUI() {
        setupMap()
        setupCamera()
        setupButtons()

        configureViewsAndConstrains()
        updateLayoutConstraints()
    }

    func setupMap() {
        // Map
        mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true

        let image = ImageUtils.loadImage(named: "drop-pin")
        centerMapPin = UIImageView(image: image)
        centerMapPin.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(centerMapPinTapped(_:)))
        centerMapPin.addGestureRecognizer(tapRecognizer)
    }

    func setupCamera() {
        // Camera
        previewView = UIView()
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            delegate?.camMapHadFailure(error: CamMapError.noVideo)
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

            // Get an instance of ACCapturePhotoOutput
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput.isHighResolutionCaptureEnabled = true
            // Set the output on the capture session
            captureSession.addOutput(capturePhotoOutput)
        } catch {
            delegate?.camMapHadFailure(error: CamMapError.cantStartCapture(error))
        }
    }

    func setupButtons() {
        // Buttons
        captureButton = UIButton(type: .system)
        captureButton.setTitle("Capture", for: .normal)
        captureButton.addTarget(self, action: #selector(takePicture(_:)), for: .touchUpInside)

        completeButton = UIButton(type: .system)
        completeButton.setTitle("Cancel", for: .normal)
        completeButton.addTarget(self, action: #selector(completeAction(_:)), for: .touchUpInside)
    }

    func configureViewsAndConstrains() {
        view.addSubview(centerMapPin)
        view.addSubview(mapView)
        view.addSubview(previewView)
        view.addSubview(captureButton)
        view.addSubview(completeButton)
        view.bringSubviewToFront(centerMapPin)

        mapView.translatesAutoresizingMaskIntoConstraints = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false

        centerMapPin.translatesAutoresizingMaskIntoConstraints = false
        completeButton.translatesAutoresizingMaskIntoConstraints = false

        protraitConstrains = [
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.30),

            previewView.topAnchor.constraint(equalTo: self.mapView.bottomAnchor),
            previewView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            previewView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            previewView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            centerMapPin.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            centerMapPin.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
            centerMapPin.widthAnchor.constraint(equalToConstant: 35),
            centerMapPin.heightAnchor.constraint(equalToConstant: 35),

            captureButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 35),
            captureButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),

            completeButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            completeButton.widthAnchor.constraint(equalToConstant: 100),
            completeButton.heightAnchor.constraint(equalToConstant: 35),
            completeButton.leftAnchor.constraint(equalTo: self.captureButton.rightAnchor, constant: 30),
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

            centerMapPin.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            centerMapPin.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
            centerMapPin.widthAnchor.constraint(equalToConstant: 35),
            centerMapPin.heightAnchor.constraint(equalToConstant: 35),

            captureButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 100),
            captureButton.heightAnchor.constraint(equalToConstant: 35),
            captureButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

            completeButton.topAnchor.constraint(equalTo: self.captureButton.bottomAnchor, constant: 30),
            completeButton.widthAnchor.constraint(equalToConstant: 100),
            completeButton.heightAnchor.constraint(equalToConstant: 35),
            completeButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30),
        ]
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

    // MARK: - Actions

    @objc
    func takePicture(_: Any) {
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

    @objc
    func completeAction(_: Any) {
        if images.count == 0 {
            delegate?.camMapDidCancel()
        } else {
            let selectedLocation = identifySelectedLocation()
            delegate?.camMapDidComplete(images: images, location: selectedLocation)
        }
    }

    @objc
    func centerMapPinTapped(_: UIGestureRecognizer) {
        locationManager.stopUpdatingLocation()

        // Get the center of the map in coordiantes
        let center = mapView.centerCoordinate

        // Remove the image
        centerMapPin.isUserInteractionEnabled = false
        centerMapPin.isHidden = true

        // Place a Marker
        selectedCoordinate = center

        let annotation = MKPointAnnotation()

        annotation.coordinate = selectedCoordinate!
        mapView.addAnnotation(annotation)

        centerMapOnLocation(location: CLLocation(latitude: center.latitude, longitude: center.longitude))
    }

    // MARK: - Utils

    func identifySelectedLocation() -> CLLocationCoordinate2D {
        guard let selectedCoordinate = self.selectedCoordinate else {
            return mapView.centerCoordinate
        }
        return selectedCoordinate
    }

    func updateVideoPreviewLayerSize() {
        videoPreviewLayer.frame = previewView.bounds
    }

    func markCompleteState() {
        completeButton.setTitle("Done", for: .normal)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CamMapViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error _: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            delegate?.camMapHadFailure(error: CamMapError.photoJPEGFailed)
            return
        }

        let capturedImage = UIImage(data: imageData, scale: 1.0)
        guard let image = capturedImage else {
            delegate?.camMapHadFailure(error: CamMapError.imageDataTransformation)
            return
        }

        images.append(image)
        markCompleteState()

        if shouldStorePhotos {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func image(_: UIImage, didFinishSavingWithError error: NSError?, contextInfo _: UnsafeRawPointer) {
        if let error = error {
            delegate?.camMapHadFailure(error: CamMapError.cantSaveImage(error as Error))
            return
        }

        // TODO: Show some indication that the image got saved
    }
}

// MARK: - CLLocationManagerDelegate

extension CamMapViewController: CLLocationManagerDelegate {
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
    }

    public func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        centerMapOnLocation(location: location)
        locationManager.stopUpdatingLocation()
    }

    // Handle authorization for the location manager
    public func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            delegate?.camMapPermissionFailure(type: .location, details: "Location access was restricted.")
        case .denied:
            delegate?.camMapPermissionFailure(type: .location, details: "User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            delegate?.camMapPermissionFailure(type: .location, details: "Location status not determined.")
        default:
            // No op
            break
        }
    }

    // Handle location manager errors.
    public func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        delegate?.camMapHadFailure(error: CamMapError.locationFailed(error))
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func replaceMarkerWithSelectedCoordiante() {
        guard let selectedCoordinate = selectedCoordinate else { return }

        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        mapView.addAnnotation(annotation)
    }
}

// MARK: - MKMapViewDelegate

extension CamMapViewController: MKMapViewDelegate {
    public func mapView(_: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState _: MKAnnotationView.DragState) {
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            view.dragState = .none
        default: break
        }
    }

    public func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "locationPin")

            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true

            return pinAnnotationView
        }

        return nil
    }
}
