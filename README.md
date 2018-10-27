# 📷+🗺+⚡️ = CamMap

CamMap is a swift library that helps apps take photos and grab locations at the same time.

![Sample screenshot](Images/ss1.jpeg?raw=true)

## Features 🚀

- [x] Capture images as JPEG
- [x] Use the current location as soon as possible.
- [x] Floating pin for better selecting the coordinates. Tap to save the location.
- [x] Drag and drop pin within the map.
- [x] Store photos in the device. Provide a configurable flag to turn it off.
- [x] Handle portrait and landscape nicely.

# Installation 💻

### Using [CocoaPods](http://cocoapods.org/)

Add `pod 'CamMap'` to your `Podfile` and run `pod install`. Also add `use_frameworks!` to the `Podfile`.

```
use_frameworks!
pod 'CamMap'
```

### Usage

Import it first:

```
import CamMap
```

Then implement the delegate protocol:

```
extension YouViewController: CamMapDelegate {
    func camMapDidComplete(images: [UIImage], location: CLLocationCoordinate2D?) {
        // This method gets called if the user took at least one pic
    }

    func camMapDidCancel() {
        // Or this gets called if the user cancelled the action
    }

    func camMapHadFailure(error: CamMapError) {
        // Is called when there's a non recoverall issue with the camera or location maanger
    }

    func camMapPermissionFailure(type: PermType, details: String) {
        // Gets call if there is a missing permission
    }
}
```

And within a method from YouViewController present the view controller:

```
let vc = CamMapViewController()
vc.delegate = self
present(vc, animated: true, completion: nil)
```

## Permissions

You need to add the following elements to your Info.plist file, oherwise the app will crash with a related message.

- NSLocationWhenInUseUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryAddUsageDescription

## Code sample

You can find a simple example within this repo. To try it please clone it and then execute:

```
cd Examples/SimpleCamMapExample/
pod install
open SimpleCamMapExample.xcworkspace
```

# Roadmap 🏁

- [x] Better action buttons
- [x] Indicate how many photos were taken
- [ ] Be able to cancel/close the controller after one photo got in
- [ ] Customizable map and camera sizes
- [ ] Be able to delete selected photos
- [ ] Better permission handling

# Author

Humber Aquino <humber@ogahunt.com> [@goku2](https://twitter.com/goku2)

# License

CamMap is released under the MIT license.
See LICENSE for details.
