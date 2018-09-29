//
//  Reachability.swift
//  Pods
//
//  Created by Kuray ÖĞÜN on 27/07/2017.
//
//

import UIKit
import SystemConfiguration
import NotificationBannerSwift
import MaterialColor

public class Reachability {
    
    public init(){}
    
    public func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    public func showNetworkAlert(title: String, subtitle: String, autoDismiss: Bool){
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.autoDismiss = autoDismiss
        banner.show()
    }
    
    // Banner Style Available : .danger | .info | .success | .none | .warnings
    public func showBanner(title: String, subtitle: String, style: BannerStyle, autoDismiss: Bool){
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style)
        banner.autoDismiss = false
        banner.show()
        print("Banner : \(String(describing: banner.frame))")
    }
}
