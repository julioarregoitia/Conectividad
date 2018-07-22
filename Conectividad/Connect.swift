//
//  Connect.swift
//  Field Test
//
//  Created by Julio Cesar on 12/5/17.
//  Copyright © 2017 Julio Cesar. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Connect
{
//    static var reachabilityPingWeb: Reachability?
//    static var reachabilityPingNauta: Reachability?
//    static var reachabilityWifiCellular: Reachability?
    public static var conexiones:[Int: Bool] = [:]
    public static var viaConexion:[Int: Conectividad.Connection] = [:]
    
    public class func startHost(_ reachibility: inout Conectividad?, hostname: String?, identifier at: Int) {
        stopNotifier(&reachibility)
        setupReachability(&reachibility, hostName: hostname, useClosures: true, identifier: at)
        startNotifier(&reachibility)
        /*
        switch at {
        case 0:
            stopNotifier(&reachabilityPingWeb)
            setupReachability(&reachabilityPingWeb, hostName: hostname, useClosures: false, identifier: at)
            startNotifier(&reachabilityPingWeb)
            
        case 1:
            stopNotifier(&reachabilityPingNauta)
            setupReachability(&reachabilityPingNauta, hostName: hostname, useClosures: false, identifier: at)
            startNotifier(&reachabilityPingNauta)
            
        case 2:
            stopNotifier(&reachabilityWifiCellular)
            setupReachability(&reachabilityWifiCellular, hostName: hostname, useClosures: false, identifier: at)
            startNotifier(&reachabilityWifiCellular)

        default:
            break
        }
        */

    }
    
    public class func setupReachability(_ reachability: inout Conectividad?, hostName: String?, useClosures: Bool, identifier:Int)
    {
        let reachabilityLocal: Conectividad?
        if let hostName = hostName {
            reachabilityLocal = Conectividad(hostname: hostName, identifier: identifier)
            print("--- set up with host name: \(hostName)")
        } else {
            reachabilityLocal = Conectividad(identifier: identifier)
        }
        reachability = reachabilityLocal
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                self.isReachable(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.isNotReachable(reachability)
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachability)
        }
    }
    
   public class func startNotifier(_ reachability: inout Conectividad?) {
        print("--- start notifier")
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    public class func stopNotifier(_ reachability: inout Conectividad?) {
        print("--- stop notifier")
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
        reachability = nil
    }
    
    class func isReachable(_ reachability: Conectividad) {
        print("\(reachability.description) - \(reachability.connection)")
        
        self.conexiones.updateValue(true, forKey: reachability.identifier)
        self.viaConexion.updateValue(reachability.connection, forKey: reachability.identifier)
        
    }
    
    class func isNotReachable(_ reachability: Conectividad) {
        print("\(reachability.description) - \(reachability.connection)")
        
        self.conexiones.updateValue(false, forKey: reachability.identifier)
        self.viaConexion.updateValue(reachability.connection, forKey: reachability.identifier)
        
    }
    
    
    @objc class func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Conectividad
        
        if reachability.connection != .none {
            isReachable(reachability)
        } else {
            isNotReachable(reachability)
        }
    }
    
    class func removeObservers()
    {
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
    }
}


