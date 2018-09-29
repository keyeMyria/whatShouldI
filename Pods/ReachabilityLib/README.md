# ReachabilityLib
<p align="center">
<img width="200" height="200" src="https://github.com/WrathChaos/ReachabilityLib/blob/master/Screenshots/internet_logo.png">
</p>
<p align="center">
<a href="https://github.com/WrathChaos/ReachabilityLib">
<img src="https://img.shields.io/cocoapods/l/ReachabilityLib.svg"
alt="License">
</a>
<a href="https://github.com/WrathChaos/ReachabilityLib">
<img src="https://img.shields.io/cocoapods/p/ReachabilityLib.svg"
alt="platform">
</a>
<a href="https://github.com/WrathChaos/ReachabilityLib">
<img src="https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg"
alt="Cocoapods">
</a>
<a href="https://github.com/WrathChaos/ReachabilityLib">
<img src="https://img.shields.io/cocoapods/dt/ReachabilityLib.svg"
alt="Downloads">
</a>
</p>


<p align="center">
<a href="https://github.com/WrathChaos/MaterialColor">
<img src="http://img.shields.io/travis/wrathchaos/MaterialColor.svg"
alt="Build">
</a>
<a href="https://github.com/WrathChaos/MaterialColor">
<img src="https://img.shields.io/github/issues/WrathChaos/MaterialColor.svg"
alt="Issues">
</a>
<a href="https://github.com/WrathChaos/MaterialColor">
<img src="https://img.shields.io/badge/Swift-3.0-blue.svg"
alt="Swift 3.0">
</a>
<a href="https://github.com/WrathChaos/MaterialColor">
<img src="https://img.shields.io/cocoapods/v/MaterialColor.svg"
alt="Pod Version">
</a>
</p>


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<p align="center">
<img align="left" width="350" height="600" src="https://github.com/WrathChaos/ReachabilityLib/blob/master/Screenshots/screenshot.png">
</br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br>

## Requirements
- iOS 9.0+
- Xcode 8.1, 8.2, 8.3
- Swift 3.0, 3.1, 3.2

## Installation

ReachabilityLib is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ReachabilityLib"
```

## Usage
```ruby
import ReachabilityLib
```

```ruby
if !reachability.isInternetAvailable(){
print("No internet connection")
// Notification Banner comes from top and alert the user (Optional)
reachability.showNetworkAlert(title: "Internet Connection is not available", subtitle: "Please check your internet connection and try again.", autoDismiss: false)
} else {
print("Yay! Internet Connection")
// Notification Banner comes from top and alert the user (Optional)
reachability.showBanner(title: "Perfect Network Connection!", subtitle: "Yay! We have a nice & smooth network connection", style: .success, autoDismiss: true)
}
```

## Future Enhancements

- [x] Complete a working Example
- [ ] Add Carthage installation option
- [ ] Add Swift Package Manager installation option
- [ ] XCode 9 compatibility and tests
- [ ] Swift 4 compatibility and tests
- [ ] [ Add Quick Testing ](https://github.com/Quick/Quick)


## Author

FreakyCoder, kurayogun@gmail.com

## License

ReachabilityLib is available under the MIT license. See the LICENSE file for more info.
