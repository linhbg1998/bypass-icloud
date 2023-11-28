//
//  HIDDeviceMonitor.swift
//  USBDeviceSwift
//
//  Created by Artem Hruzd on 6/14/17.
//  Copyright © 2017 Artem Hruzd. All rights reserved.
//

import Cocoa
import Foundation
import IOKit.hid

class USBDetector: NSObject {    
    func monitorUSBEvent() {
        var portIterator: io_iterator_t = 0
        let matchingDict = IOServiceMatching(kIOUSBDeviceClassName)
        let gNotifyPort: IONotificationPortRef = IONotificationPortCreate(kIOMasterPortDefault)
        let runLoopSource: Unmanaged<CFRunLoopSource>! = IONotificationPortGetRunLoopSource(gNotifyPort)
        let gRunLoop: CFRunLoop! = CFRunLoopGetCurrent()
        CFRunLoopAddSource(gRunLoop, runLoopSource.takeRetainedValue(), CFRunLoopMode.defaultMode)
        let observer = Unmanaged.passUnretained(self as AnyObject).toOpaque()
        _ = IOServiceAddMatchingNotification(gNotifyPort,
                                             kIOMatchedNotification,
                                             matchingDict,
                                             deviceAdded,
                                             observer,
                                                 &portIterator)
        Thread.sleep(forTimeInterval: 5)
        deviceAdded(refCon: nil, iterator: portIterator)
    }

    func showUSBConnectedNotification(name: String) -> Void {
        if !(name.contains("Root") || name.contains("Built-in") || name.contains("Host") || name.contains("Internal")){
            let notification = NSUserNotification()
            notification.title = "USB Device Connected"
            notification.informativeText = name
            notification.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

func deviceAdded(refCon: UnsafeMutableRawPointer?, iterator: io_iterator_t) {
    var kr: kern_return_t = KERN_FAILURE
    while case let usbDevice = IOIteratorNext(iterator), usbDevice != 0 {
        var deviceNameAsCFString = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        defer { deviceNameAsCFString.deallocate() }
       
        var deviceNameCString:[CChar] = [CChar](repeating: 0, count: 128)
        kr = IORegistryEntryGetName(usbDevice, &deviceNameCString)
        
        if(kr != kIOReturnSuccess) {
            print("Error getting device name")
        }
        
        let name = String.init(cString: &deviceNameCString)
        print(name)
        
        USBDetector().showUSBConnectedNotification(name: name)
        IOObjectRelease(usbDevice)
    }
}

protocol USBDetectorDelegate{
    func deviceAdded(name: String)
}
