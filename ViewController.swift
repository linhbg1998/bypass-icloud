//
//  ViewController.swift
//  GSMUNLOCKINFO
//
//  Created by linh on 22/09/2023.
//
//import Cocoa
import os
import IOKit
import ZIPFoundation
import IOKit.usb
import SystemConfiguration
import Foundation
import WebKit


var usbWatcher1: USBWatcher? = nil

class ViewController: NSViewController, NSTextViewDelegate, NSTextStorageDelegate, NSTextFieldDelegate, NSApplicationDelegate, USBWatcherDelegate, NSUserNotificationCenterDelegate, WKNavigationDelegate{
    
       
    
    var downloadTask: URLSessionDownloadTask?
    var downloadTaskResumeData: Data?
    var webView: WKWebView!
    
    
    
    func IProxy() {
        DispatchQueue.global().async {
            let tg = self.chucnang.titleOfSelectedItem!;
            let bootram = self.menu1.titleOfSelectedItem!
            if((tg).contains("GSM Signal")) || ((bootram).contains("BOOT16.5>")){
                
                if let resourceURL = Bundle.main.url(forResource: "htools/libs/iproxy", withExtension: nil) {
                    let iproxyPath = resourceURL.path
                    
                    
                    
                    let task = Process()
                    task.launchPath = "/usr/bin/env"
                    task.arguments = [iproxyPath, "2222", "44"]
                    let pipe = Pipe()
                    task.standardOutput = pipe
                    
                    task.launch()
                    task.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    if let output = String(data: data, encoding: .utf8) {
                        print("iproxy output: \(output)")
                        
                    }
                    
                    
                    
                } else {
                    print("Failed to locate iproxy resource file.")
                }
                
            }else{
                if let resourceURL = Bundle.main.url(forResource: "htools/libs/iproxy", withExtension: nil) {
                    let iproxyPath = resourceURL.path
                    
                    
                    
                    let task = Process()
                    task.launchPath = "/usr/bin/env"
                    task.arguments = [iproxyPath, "2222", "22"]
                    let pipe = Pipe()
                    task.standardOutput = pipe
                    
                    task.launch()
                    task.waitUntilExit()
                    
                    let data = pipe.fileHandleForReading.readDataToEndOfFile()
                    if let output = String(data: data, encoding: .utf8) {
                        print("iproxy output: \(output)")
                        
                    }
                    
                    
                    
                } else {
                    print("Failed to locate iproxy resource file.")
                }
                
                
                
                
            }
            
            
        }
    }
    
    
    
    
    
    func downloadFileFromURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        downloadTask = session.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    func resumeDownload() {
        guard let resumeData = downloadTaskResumeData else {
            print("Resume data not found")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        downloadTask = session.downloadTask(withResumeData: resumeData)
        downloadTask?.resume()
    }
    func grantWritePermissionToDirectory() {
        let directoryPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/.hrdeciddata/ramdiskFiles")
            .path
        
        let process = Process()
        process.launchPath = "/bin/chmod"
        process.arguments = ["+w", directoryPath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        if process.terminationStatus == 0 {
            print("Quyền ghi đã được cấp cho thư mục.")
        } else {
            print("Lỗi khi cấp quyền ghi cho thư mục: \(output ?? "")")
        }
    }
    func grantWritePermissionToDirectory1() {
        let directoryPath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/.BACKUPMDM")
            .path
        
        let process = Process()
        process.launchPath = "/bin/chmod"
        process.arguments = ["+w", directoryPath]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        process.launch()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        if process.terminationStatus == 0 {
            print("Quyền ghi đã được cấp cho thư mục.")
        } else {
            print("Lỗi khi cấp quyền ghi cho thư mục: \(output ?? "")")
        }
    }
    
    
    
    
    func sendData(_ data: String) {
            // Implement the data handling logic here
            print(data)
        }
    
    var username = NSUserName()
    var deviceDetectionHandler:Bool = true
    var deviceDetectiondfu:Bool = true
    var devicedfu:Bool = true
    var gasterProcess1: Process?
        var gasterProcess2: Process?
        var timer: Timer?
    
    
    func deviceAdded(_ device: io_object_t, serialNumber: String?) {
        if self.devicedfu == true {
            if "\(String(describing: device.name()))" == "iPhone" || "\(String(describing: device.name()))" == "iPad" {
                HIENTHI.stringValue = "Normal"
                chedo.stringValue = "Normal";
                self.btnStartDFU.title = "EXIT"
                
            }
            if "\(device.name())" == "Apple Mobile Device (Recovery Mode)" {
                HIENTHI.stringValue = "Recovery";
                chedo.stringValue = "Recovery";
            }
            if "\(device.name())" == "Apple Mobile Device (DFU Mode)" {
                
                HIENTHI.stringValue = "DFU";
                chedo.stringValue = "DFU";
                
            }
   
        }
        
        if self.deviceDetectiondfu == true {
            if "\(device.name())" == "iPhone" || "\(device.name())" == "iPad" {
                HIENTHI.stringValue = "Normal"
                chedo.stringValue = "Normal";
                self.btnStartDFU.isHidden = false
                self.re.isHidden = false
                self.lblStep1.stringValue = ""
                self.lblStep2.stringValue = ""
                self.lblStep3.stringValue = ""
                self.lblPowerBtn.stringValue = ""
                self.lblHomeBtn.stringValue = ""
                self.lblVolumeBtn.stringValue = ""
                self.lblDFUStatus.stringValue = "Please put your device into Recovery mode. Select 'go to Recovery' to enter Recovery."
                self.re.title = "go to Recovery"

                print("\(device.serialNumber())")
                self.btnStartDFU.title = "EXIT"
                
                
            }
            if "\(device.name())" == "Apple Mobile Device (Recovery Mode)" {

                cpid.stringValue = iRecoveryInfo("CPID");
                
                HIENTHI.stringValue = iRecoveryInfo("MODE");
                chedo.stringValue = iRecoveryInfo("MODE");
                recoOpened1()
                self.btnStartDFU.isHidden = false
                
                recoOpened1()
                self.btnStartDFU.title = "START"
                checkid()
                
                
            }
            if "\(device.name())" == "Apple Mobile Device (DFU Mode)" {
                chedo.stringValue = iRecoveryInfo("MODE");
                HIENTHI.stringValue = iRecoveryInfo("MODE");
                self.lblDFUStatus.stringValue = "Device entered DFU mode successfully."
                self.re.isHidden = true
                
                self.btnStartDFU.isHidden = false
                self.re.title = ""
                self.lblStep1.stringValue = ""
                self.lblStep2.stringValue = ""
                self.lblStep3.stringValue = ""
                self.lblPowerBtn.stringValue = ""
                self.lblHomeBtn.stringValue = ""
                self.lblVolumeBtn.stringValue = ""
                self.lblDFUStatus.stringValue = "Device entered DFU mode successfully."
                self.btnStartDFU.title = "EXIT"
            }
   
        }
        if self.deviceDetectionHandler == true {
        print("Device connected \(device.name())")
            if "\(device.name())" == "PongoOS USB Device" {
               // _ = shell("killall -9 .linh");
            }
        if "\(device.name())" == "iPhone" || "\(device.name())" == "iPad" {
            sleep(2);
            let partyPath2 = Bundle.main.url(forResource: "htools/libs/ideviceinfo", withExtension: "")
            let ideviceinfo: String = partyPath2!.path
            
            print("Device hello \(device.name()!)")
            hienthi.stringValue = ""
           ecid.stringValue = shell("(printf '%016X\n' $(" + ideviceinfo + " -k UniqueChipID))");
          
            chedo.stringValue = "Normal";
            
            ios.stringValue = DeviceInfo("ProductVersion");
           ecid.stringValue = shell("(printf '%016X\n' $(" + ideviceinfo + " -k UniqueChipID))");
            HIENTHI.stringValue = "Normal"
            chedo.stringValue = "Normal";
            MODEL.stringValue = DeviceInfo("HardwareModel");
            MODEL.stringValue = DeviceInfo("HardwareModel");
            SN.stringValue = DeviceInfo("SerialNumber");
            namethietbi.stringValue = ModelHello("\(DeviceInfo("ProductType"))")
            namethietbi.stringValue = ModelHello("\(DeviceInfo("ProductType"))")
            helloOpened();
            helloOpened();
            let ecidValue = self.ecid.stringValue
                    // Post a notification with the ecid value
                    NotificationCenter.default.post(name: NSNotification.Name("ECIDNotification"), object: ecidValue)
            
            
                self.checkapi { success in
                if success {
                    DispatchQueue.main.async {
                    self.dangky.isHidden = true
                    }
                } else {
                    DispatchQueue.main.async {
                    self.dangky.isHidden = false
                   
                }
            }
            }
            
            
            
            
            
            
        }
        if "\(device.name())" == "Apple Mobile Device (Recovery Mode)" {
            print("Device Recovery \(device.name())")
            sleep(2);
            hienthi.stringValue = ""
          
            ecid.stringValue = shell("(printf '%016X\n' " + iRecoveryInfo("ECID") + ")");
            ios.stringValue = "";
            ecid.stringValue = shell("(printf '%016X\n' " + iRecoveryInfo("ECID") + ")");
            cpid.stringValue = iRecoveryInfo("CPID");
            chedo.stringValue = iRecoveryInfo("MODE");
            MODEL.stringValue = iRecoveryInfo("MODEL");
            HIENTHI.stringValue = iRecoveryInfo("MODE");
            SN.stringValue = iRecoveryInfo("SRNM");
            
            
            namethietbi.stringValue = ModelHello("\(iRecoveryInfo("PRODUCT"))")
            namethietbi.stringValue = ModelHello("\(iRecoveryInfo("PRODUCT"))")
            recoOpened()
            recoOpened()
            let ecidValue = self.ecid.stringValue
                 
                    NotificationCenter.default.post(name: NSNotification.Name("ECIDNotification"), object: ecidValue)
            
            
            
            self.checkapi { success in
            if success {
                DispatchQueue.main.async {
                self.dangky.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                
                self.dangky.isHidden = false
               
            }
        }
        }
            
        }
        if "\(device.name())" == "Apple Mobile Device (DFU Mode)" {
            print("Device \(device.name())")
            sleep(2);
            ecid.stringValue = shell("(printf '%016X\n' " + iRecoveryInfo("ECID") + ")");
            ios.stringValue = "";
            ecid.stringValue = shell("(printf '%016X\n' " + iRecoveryInfo("ECID") + ")");
            cpid.stringValue = iRecoveryInfo("CPID");
            chedo.stringValue = iRecoveryInfo("MODE");
            
            namethietbi.stringValue = ModelHello("\(iRecoveryInfo("PRODUCT"))")
            namethietbi.stringValue = ModelHello("\(iRecoveryInfo("PRODUCT"))")
            
            
            
            
            MODEL.stringValue = iRecoveryInfo("MODEL");
            MODEL.stringValue = iRecoveryInfo("MODEL");
            hienthi.textColor = NSColor.systemRed
            hienthi.stringValue = "VUI LÒNG THOÁT CHẾ ĐỘ DFU VÀ ĐƯ VỀ CHẾ ĐỘ RECOVERY VỚI MÁY PASSCODE VÀ CHẾ ĐỘ BÌNH THƯỜNG VỚI THIẾT BỊ HELLO"
            
            HIENTHI.stringValue = iRecoveryInfo("MODE");
            let ecidValue = self.ecid.stringValue
                    

                    // Post a notification with the ecid value
                    NotificationCenter.default.post(name: NSNotification.Name("ECIDNotification"), object: ecidValue)
            
            dfuOpened1()
            dfuOpened1()
            self.checkapi { success in
            if success {
                DispatchQueue.main.async {
                self.dangky.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                
                self.dangky.isHidden = false
               
            }
        }
        }
            
        }
        
        }
    }
    func deviceRemoved(_ device: io_object_t) {
        print("Device noconnected \(device.name()!)")
        if self.deviceDetectiondfu == true {
            HIENTHI.stringValue = "connect"
            self.btnStartDFU.isHidden = false
            self.re.isHidden = true
            self.re.title = ""
            self.btnStartDFU.title = "EXIT"
            self.lblStep1.stringValue = ""
            self.lblStep2.stringValue = ""
            self.lblStep3.stringValue = ""
            self.lblPowerBtn.stringValue = ""
            self.lblHomeBtn.stringValue = ""
            self.lblVolumeBtn.stringValue = ""
            self.lblDFUStatus.stringValue = " Please connect the device"
           // self.checkboot.isHidden = true
            self.menu1.isHidden = true
            
            
        }
        
        
        
        if self.deviceDetectionHandler == true {
           
            //print(device.getInfo())
            
        ios.stringValue = "";
           ecid.stringValue = "";
            SN.stringValue = "";
            namethietbi.stringValue = "";
       
            hienthi.stringValue = "VUI LÒNG KẾT NỐI THIẾT BỊ"
            portisClosed()
            portisClosed()
            DispatchQueue.main.async {
                self.dangky.isHidden = true
            }
        }
    }
  //phụ thuộc
    func dfu(){
        self.devicedfu = true;
        if (self.btnStartDFU.title == "EXIT") {
            devicedfu = true
            deviceDetectionHandler = true;
            if (HIENTHI.stringValue == "Normal"){
                deviceDetectionHandler = true;
                deviceDetectiondfu = false;
                portisClosed();
                helloOpened();
                self.btnStartDFU.isHidden = false
                self.re.isHidden = false
                self.lblStep1.stringValue = ""
                self.lblStep2.stringValue = ""
                self.lblStep3.stringValue = ""
                self.lblPowerBtn.stringValue = ""
                self.lblHomeBtn.stringValue = ""
                self.lblVolumeBtn.stringValue = ""
                self.lblDFUStatus.stringValue = "Please put your device into Recovery mode. Select 'go to Recovery' to enter Recovery."
                self.re.title = "go to Recovery"

                
                
                self.btnStartDFU.title = "EXIT"
                
                
                
            }
            if (HIENTHI.stringValue == "Recovery"){
                deviceDetectionHandler = true;
                deviceDetectiondfu = false;
                portisClosed();
                recoOpened();
                
                
            }
            if (HIENTHI.stringValue == "DFU"){
                deviceDetectionHandler = true;
                deviceDetectiondfu = false;
                portisClosed();
                dfuOpened1();
                
                
            }
        }
        if (HIENTHI.stringValue == "Normal"){
            deviceDetectionHandler = true;
            deviceDetectiondfu = false;
            portisClosed();
            helloOpened();
            
        }
        
        
        let xtx = self.ttx.stringValue
        if (self.HIENTHI.stringValue == "Recovery"){
            deviceDetectionHandler = false
            DispatchQueue.main.async {
            
                self.btnStartDFU.isHidden = true
            self.lblStep1.textColor = .systemGray
            self.lblStep2.textColor = .black
                self.lblDFUStatus.stringValue = "Time to put the device into DFU mode. Locate the buttons as marked below on your device and check the instructions on the right before clicking Start."
                self.lblStep1.stringValue = " 1. Click Start"
                
                self.lblStep2.stringValue = String(format: "2. Press and hold the Power and %@ buttons together (5)")
                self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(xtx) button (10)"
                
                
            }
        DispatchQueue.global(qos: .userInitiated).async {
            self.devicedfu = true
            var time = 0
            let max = 5
            while time < max {
                sleep(1)
                time += 1
                if time == 1 {
                    self.deviceDetectionHandler = false
                    self.deviceDetectiondfu = false
                    self.devicedfu = true;
                    let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                    let irecovery: String = partyPath1!.path
                    _ = self.shell("" + irecovery + " -n");
                    
                    
                }
                if( "\(max - time)" == "0") {
                    
                    self.devicedfu = true;
                    self.deviceDetectiondfu = false;
                                    }
                
                DispatchQueue.main.async {
                    self.lblStep1.textColor = .systemGray
                    self.lblStep2.textColor = .black
                    self.lblStep1.stringValue = " 1. Click Start"
                    self.lblStep2.stringValue = String(format: "2. Press and hold the Power and %@ buttons together (%d)", xtx, (max - time))
                    self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(xtx) button (10)"
                }
            }

            DispatchQueue.main.async {
                self.lblStep2.textColor = .systemGray
                self.lblStep3.textColor = .black
                self.lblStep3.stringValue = String(format: "3. Release the Power button BUT KEEP HOLDING the %@ button (10)", xtx)
                self.lblPowerBtn.isHidden = true
            }
            self.devicedfu = true;
            self.deviceDetectiondfu = false;
            
            time = 0
            let max2 = 10
            while time < max2 {
                sleep(1)
                time += 1
                
                
                    DispatchQueue.main.async {
                        if ("\(self.HIENTHI.stringValue)" == "DFU") {
                        self.btnStartDFU.isHidden = false
                        self.btnStartDFU.title = "Start"
                        self.lblDFUStatus.stringValue = "Device entered DFU mode successfully."
                        sleep(1)
                    }
                }
                if( "\(max2 - time)" == "0") {
                    self.devicedfu = true
                    self.deviceDetectiondfu = true;
                    DispatchQueue.main.async {
                    if ("\(self.HIENTHI.stringValue)" != "DFU") {
                       
                                        self.lblStep1.textColor = .black
                            self.lblStep2.textColor = .systemGray
                            self.lblStep3.textColor = .systemGray
                            self.lblPowerBtn.isHidden = false
                            self.lblStep2.stringValue = "2. Press and hold the Power and \(xtx) buttons together (5)"
                            self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(xtx) button (10)"
                            self.btnStartDFU.isHidden = false
                            self.btnStartDFU.title = "Retry"
                            self.lblDFUStatus.stringValue = "Whoops, the device didn't enter DFU mode Click Retry to try again."
                        self.bootdfu()
                        
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.lblStep1.stringValue = " 1. Click Start"
                    self.lblStep3.stringValue = String(format: "3. Release the Power button BUT KEEP HOLDING the %@ button (%d)", xtx, (max2 - time))
                }
            }
            DispatchQueue.main.async {
                
                if self.HIENTHI.stringValue.contains("DFU") {
                    
                    
                    self.deviceDetectiondfu = false;
                    self.deviceDetectionHandler = true;
                    self.bootdfu()
                    self.checkrddownload()
                    
                }
            }
        }

        
       
        if (HIENTHI.stringValue != "DFU") {
           
            DispatchQueue.main.async {                self.lblStep1.textColor = .black
                self.lblStep2.textColor = .systemGray
                self.lblStep3.textColor = .systemGray
                self.lblPowerBtn.isHidden = false
                self.lblStep2.stringValue = "2. Press and hold the Power and \(xtx) buttons together (5)"
                self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(xtx) button (10)"
                self.btnStartDFU.isHidden = false
                self.btnStartDFU.title = "Retry"
                self.lblDFUStatus.stringValue = "Whoops, the device didn't enter DFU mode Click Retry to try again."
                self.deviceDetectiondfu = true
                
            }
        }
        
        }
    }
    func checkid() {
        DispatchQueue.main.async {
            if (self.cpid.stringValue == "0x8015") || (self.cpid.stringValue == "0x8010") || (self.cpid.stringValue == "0x8011"){
                
                self.lblPowerBtn.stringValue = "-- Power Button"
                self.lblVolumeBtn.stringValue = "Volume Down --"
                
                let btnText = "Volume down"
                self.lblVolumeBtn.isHidden = false
                self.lblHomeBtn.isHidden = true
                self.imgPhone.image = NSImage(named: "a11")
                self.lblStep1.stringValue = " 1. Click Start"
                
                self.lblStep2.stringValue = "2. Press and hold the Power and \(btnText) buttons together (5)"
                self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(btnText) button (10)"
                self.ttx.stringValue = "Volume down"
                
                
            } else {
                self.lblPowerBtn.stringValue = "-- Power Button"
                self.lblHomeBtn.stringValue = "-- Home Button"
                
                
                
                let btnText = "Home"
                self.lblVolumeBtn.isHidden = true
                self.lblHomeBtn.isHidden = false
                self.imgPhone.image = NSImage(named: "a9")
                self.lblStep1.stringValue = " 1. Click Start"
                self.lblStep2.stringValue = "2. Press and hold the Power and \(btnText) buttons together (5)"
                self.lblStep3.stringValue = "3. Release the Power button BUT KEEP HOLDING the \(btnText) button (10)"
                self.ttx.stringValue = "Home"
                
            }
            
        }
        }
    
    
    
    
    
    func shell(_ command:String)->String{
        let task = Process();
        task.launchPath = "/bin/bash";
        task.arguments = ["-c", command];
        let pipe = Pipe();
        task.standardOutput = pipe;
        task.launch();
        let data = pipe.fileHandleForReading.readDataToEndOfFile();
        let output: String = NSString(data:data, encoding: String.Encoding.utf8.rawValue)! as String;
        task.waitUntilExit();
        return output.trimmingCharacters(in: .newlines);
    }
    
    
    
    
    
    
    func DeviceInfo(_ Info:String)->String{
                let partyPath1 = Bundle.main.url(forResource: "htools/libs/ideviceinfo", withExtension: "")
                let ideviceinfo: String = partyPath1!.path
             let Infos:String = shell("" + ideviceinfo + " | grep -w " + Info + " | awk '{printf $NF}'");
             return Infos;
            }
        func DeviceInfo1(_ Info:String)->String{
                    let partyPath1 = Bundle.main.url(forResource: "htools/libs/ideviceinfo", withExtension: "")
                    let ideviceinfo: String = partyPath1!.path
                 let Infos:String = shell("" + ideviceinfo + " -k " + Info + "");
                 return Infos;
                }
        func makeHTTPRequest(urlString: String, completionHandler: @escaping (String?, Error?) -> Void) {
            if let url = URL(string: urlString) {
                let session = URLSession.shared
                let task = session.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        completionHandler(nil, error)
                    } else if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            completionHandler(responseString, nil)
                        }
                    }
                }
                task.resume()
            } else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
                completionHandler(nil, error)
            }
        }
    func PairDevice(){
        let partyPath1 = Bundle.main.url(forResource: "htools/libs/idevicepair", withExtension: "")
        let idevicepair: String = partyPath1!.path
        
        
        if(shell("\(idevicepair) pair").contains("ERROR")){
            BoxShow("Mở khóa màn hình trong thiết bị của bạn và nhấn tin cậy!", Buttontext:"OK")
            PairDevice()
        }
    }
    
    
    
    
        func iRecoveryInfo(_ Info:String)->String{
                    let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                    let irecovery: String = partyPath1!.path
                    
                    let Ret:String = shell("" + irecovery + " -q | grep -w " + Info + " | awk '{printf $NF}'");
                    return Ret;
                }
    func iRecoveryIF(_ Info1:String)->String{
                    let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                    let irecovery: String = partyPath1!.path
                    
                    let Ret = shell("" + irecovery + " -f " + Info1 + "");
                    print(Ret)
                    return Ret;
        
       
        
                }
    func iRecoveryIF2(_ Info2:String)->String{
                    let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                    let irecovery: String = partyPath1!.path
                    let Ret:String = shell("" + irecovery + " -c " + Info2 + "");
        print(Ret)
                    return Ret;
        
                }
        //SSH
    func sshpass12(_ Info2: String) -> String {
        let partyPath1 = Bundle.main.url(forResource: "htools/libs/sshpass", withExtension: "")
        let sshpass: String = partyPath1!.path



        let Ret:String = shell("" + sshpass + " -p 'alpine' ssh -o StrictHostKeyChecking=no root@localhost -p 2222 '" + Info2 + "'");
        return Ret;// Return an empty string if any connection/authentication issues occur
    }
        //SSHUP
        func sshpass13(_ Info3:String)->String{
                        let partyPath1 = Bundle.main.url(forResource: "htools/libs/sshpass", withExtension: "")
                        let sshpass: String = partyPath1!.path
                        
            let Ret:String  = shell("" + sshpass + " -p alpine scp -rP 2222 -o StrictHostKeyChecking=no " + Info3 + "");
                        return Ret;
                    }
       // SSH TAI
        func sshpass14(_ Info4:String)->String{
                        let partyPath1 = Bundle.main.url(forResource: "htools/libs/sshpass", withExtension: "")
                        let sshpass: String = partyPath1!.path
                        
                        let Ret:String = shell("" + sshpass + " -p alpine scp -P 2222 -rp root@localhost:" + Info4 + "");
                        return Ret;
                    }
        //registration Check end
        func ModelHello(_ Info:String)->String{
        
                    switch "\(Info)"
                    {
                        case "iPhone1,1":
                            return /*"m68ap",    0x00, 0x8900 */ "iPhone  2G";
                        case "iPhone1,2":
                            return /*82ap",    0x04, 0x8900 */ "iPhone  3G";
                        case "iPhone2,1":
                            return /*88ap",    0x00, 0x8920 */ "iPhone  3Gs";
                        case "iPhone3,1":
                            return /*90ap",    0x00, 0x8930 */ "iPhone  4 (GSM)";
                        case "iPhone3,2":
                            return /*90bap",   0x04, 0x8930 */ "iPhone  4 (GSM) R2 2012";
                        case "iPhone3,3":
                            return /*92ap",    0x06, 0x8930 */ "iPhone  4 (CDMA)";
                        case "iPhone4,1":
                            return /*94ap",    0x08, 0x8940 */ "iPhone  4s";
                        case "iPhone5,1":
                            return /*41ap",    0x00, 0x8950 */ "iPhone  5 (GSM)";
                        case "iPhone5,2":
                            return /*42ap",    0x02, 0x8950 */ "iPhone  5 (Global)";
                        case "iPhone5,3":
                            return /*48ap",    0x0a, 0x8950 */ "iPhone  5c (GSM)";
                        case "iPhone5,4":
                            return /*49ap",    0x0e, 0x8950 */ "iPhone  5c (Global)";
                        case "iPhone6,1":
                            return /*51ap",    0x00, 0x8960 */ "iPhone  5s (GSM)";
                        case "iPhone6,2":
                            return /*53ap",    0x02, 0x8960 */ "iPhone  5s (Global)";
                        case "iPhone7,1":
                            return /*56ap",    0x04, 0x7000 */ "iPhone  6 Plus";
                        case "iPhone7,2":
                            return /*61ap",    0x06, 0x7000 */ "iPhone  6";
                        case "iPhone8,1":
                            return /*71ap",    0x04, 0x8000 */ "iPhone  6s";
                        case "iPhone8,2":
                            return /*66ap",    0x06, 0x8000 */ "iPhone  6s Plus";
                        case "iPhone8,4":
                            return /*69ap",    0x02, 0x8003 */ "iPhone  SE (1st gen)";
                        case "iPhone9,1":
                            return /*"d10ap",    0x08, 0x8010 */ "iPhone  7 (Global)";
                        case "iPhone9,2":
                            return /*"d11ap",    0x0a, 0x8010 */ "iPhone  7 Plus (Global)";
                        case "iPhone9,3":
                            return /*"d101ap",   0x0c, 0x8010 */ "iPhone  7 (GSM)";
                        case "iPhone9,4":
                            return /*"d111ap",   0x0e, 0x8010 */ "iPhone  7 Plus (GSM)";
                        case "iPhone10,1":
                            return /*20ap",    0x02, 0x8015*/ "iPhone  8 (Global)";
                        case "iPhone10,2":
                            return /*21ap",    0x04, 0x8015*/ "iPhone  8 Plus (Global)";
                        case "iPhone10,3":
                            return /*22ap",    0x06, 0x8015*/ "iPhone  X (Global)";
                        case "iPhone10,4":
                            return /*201ap",   0x0a, 0x8015*/ "iPhone  8 (GSM)";
                        case "iPhone10,5":
                            return /*211ap",   0x0c, 0x8015*/ "iPhone  8 Plus (GSM)";
                        case "iPhone10,6":
                            return /*221ap",   0x0e, 0x8015*/ "iPhone  X (GSM)";
                    case "iPhone11,2":
                        return /*321ap",   0x0e, 0x8020*/ "iPhone  XS";
                    case "iPhone11,4":
                        return /*331ap",   0x0a, 0x8020*/ "iPhone  XS Max (China)";
                    case "iPhone11,6":
                        return /*331pap",  0x1a, 0x8020*/ "iPhone  XS Max";
                    case "iPhone11,8":
                        return /*"n841ap",   0x0c, 0x8020 */ "iPhone  XR";
                    case "iPhone12,1":
                        return /*"n104ap",   0x04, 0x8030 */ "iPhone  11";
                    case "iPhone12,3":
                        return /*421ap",   0x06, 0x8030*/ "iPhone  11 Pro";
                    case "iPhone12,5":
                        return /*431ap",   0x02, 0x8030*/ "iPhone  11 Pro Max";
                    case "iPhone12,8":
                        return /*79ap",    0x10, 0x8030*/ "iPhone  SE (2nd gen)";
                    case "iPhone13,1":
                        return /*52gap",   0x0A, 0x8101*/ "iPhone  12 mini";
                    case "iPhone13,2":
                        return /*53gap",   0x0C, 0x8101*/ "iPhone  12";
                    case "iPhone13,3":
                        return /*53pap",   0x0E, 0x8101*/ "iPhone  12 Pro";
                    case "iPhone13,4":
                        return /*54pap",   0x08, 0x8101*/ "iPhone  12 Pro Max";
                    case "iPhone14,2":
                        return /*63ap",    0x0C, 0x8110*/ "iPhone  13 Pro";
                    case "iPhone14,3":
                        return /*64ap",    0x0E, 0x8110*/ "iPhone  13 Pro Max";
                   case "iPhone14,4":
                        return /*16ap",    0x08, 0x8110*/ "iPhone  13 mini";
                    case "iPhone14,5":
                        return /*17ap",    0x0A, 0x8110*/ "iPhone  13";
                    case "iPhone14,6":
                        return /*49ap",    0x10, 0x8110*/ "iPhone  SE (3rd gen)";
                    case "iPhone14,7":
                        return /*27ap",    0x18, 0x8110*/ "iPhone  14";
                    case "iPhone14,8":
                        return /*28ap",    0x1A, 0x8110*/ "iPhone  14 Plus";
                    case "iPhone15,2":
                        return /*73ap",    0x0C, 0x8120*/ "iPhone  14 Pro";
                    case "iPhone15,3":
                        return /*74ap",    0x0E, 0x8120*/ "iPhone  14 Pro Max";
                        //iPAD
                    case "iPad1,1":  return /*k48ap",    0x02, 0x8930*/ "iPad";
                    case "iPad2,1":  return /*k93ap",    0x04, 0x8940*/ "iPad 2 (WiFi)";
                    case "iPad2,2":  return /*k94ap",    0x06, 0x8940*/ "iPad 2 (GSM)";
                    case "iPad2,3":  return /*k95ap",    0x02, 0x8940*/ "iPad 2 (CDMA)";
                    case "iPad2,4":  return /*k93aap",   0x06, 0x8942*/ "iPad 2 (WiFi) R2 2012";
                    case "iPad2,5": return /*p105ap",   0x0a, 0x8942*/ "iPad mini (WiFi)";
                    case "iPad2,6": return /*p106ap",   0x0c, 0x8942*/ "iPad mini (GSM)" ;
                    case "iPad2,7": return /*p107ap",   0x0e, 0x8942*/ "iPad mini (Global)" ;
                    case "iPad3,1": return /*j1ap",     0x00, 0x8945*/ "iPad (3rd gen, WiFi)" ;
                    case "iPad3,2": return /*j2ap",     0x02, 0x8945*/ "iPad (3rd gen, CDMA)" ;
                    case "iPad3,3": return /*j2aap",    0x04, 0x8945*/ "iPad (3rd gen, GSM)" ;
                    case "iPad3,4": return /*p101ap",   0x00, 0x8955*/ "iPad (4th gen, WiFi)" ;
                    case "iPad3,5": return /*p102ap",   0x02, 0x8955*/ "iPad (4th gen, GSM)" ;
                    case "iPad3,6": return /*p103ap",   0x04, 0x8955*/ "iPad (4th gen, Global)" ;
                    case "iPad4,1": return /*j71ap",    0x10, 0x8960*/ "iPad Air (WiFi)" ;
                    case "iPad4,2": return /*j72ap",    0x12, 0x8960*/ "iPad Air (Cellular)" ;
                    case "iPad4,3": return /*j73ap",    0x14, 0x8960*/ "iPad Air (China)" ;
                    case "iPad4,4": return /*j85ap",    0x0a, 0x8960*/ "iPad mini 2 (WiFi)" ;
                    case "iPad4,5": return /*j86ap",    0x0c, 0x8960*/ "iPad mini 2 (Cellular)" ;
                    case "iPad4,6": return /*j87ap",    0x0e, 0x8960*/ "iPad mini 2 (China)" ;
                    case "iPad4,7": return /*j85map",   0x32, 0x8960*/ "iPad mini 3 (WiFi)" ;
                    case "iPad4,8": return /*j86map",   0x34, 0x8960*/ "iPad mini 3 (Cellular)" ;
                    case "iPad4,9": return /*j87map",   0x36, 0x8960*/ "iPad mini 3 (China)" ;
                    case "iPad5,1": return /*j96ap",    0x08, 0x7000*/ "iPad mini 4 (WiFi)" ;
                    case "iPad5,2": return /*j97ap",    0x0A, 0x7000*/ "iPad mini 4 (Cellular)" ;
                    case "iPad5,3": return /*j81ap",    0x06, 0x7001*/ "iPad Air 2 (WiFi)" ;
                    case "iPad5,4": return /*j82ap",    0x02, 0x7001*/ "iPad Air 2 (Cellular)" ;
                    case "iPad6,3": return /*j127ap",   0x08, 0x8001*/ "iPad Pro 9.7-inch (WiFi)" ;
                    case "iPad6,4": return /*j128ap",   0x0a, 0x8001*/ "iPad Pro 9.7-inch (Cellular)" ;
                    case "iPad6,7": return /*j98aap",   0x10, 0x8001*/ "iPad Pro 12.9-inch (1st gen, WiFi)" ;
                    case "iPad6,8": return /*j99aap",   0x12, 0x8001*/ "iPad Pro 12.9-inch (1st gen, Cellular)" ;
                    case "iPad6,11": return /*0x10, 0x8000*/ "iPad (5th gen, WiFi)" ;
                    case "iPad6,12": return /*j72sap",   0x12, 0x8000*/ "iPad (5th gen, Cellular)" ;
                    case "iPad7,1": return /*j120ap",   0x0C, 0x8011*/ "iPad Pro 12.9-inch (2nd gen, WiFi)" ;
                    case "iPad7,2": return /*j121ap",   0x0E, 0x8011*/ "iPad Pro 12.9-inch (2nd gen, Cellular)" ;
                    case "iPad7,3": return /*j207ap",   0x04, 0x8011*/ "iPad Pro 10.5-inch (WiFi)" ;
                    case "iPad7,4": return /*j208ap",   0x06, 0x8011*/ "iPad Pro 10.5-inch (Cellular)" ;
                    case "iPad7,5": return /*j71bap",   0x18, 0x8010*/ "iPad (6th gen, WiFi)" ;
                    case "iPad7,6": return /*j72bap",   0x1A, 0x8010*/ "iPad (6th gen, Cellular)" ;
                    case "iPad7,11": return /*j171ap",   0x1C, 0x8010*/ "iPad (7th gen, WiFi)" ;
                    case "iPad7,12": return /*j172ap",   0x1E, 0x8010*/ "iPad (7th gen, Cellular)" ;
                    case "iPad8,1": return /*j317ap",   0x0C, 0x8027*/ "iPad Pro 11-inch (1st gen, WiFi)" ;
                    case "iPad8,2": return /*j317xap",  0x1C, 0x8027*/ "iPad Pro 11-inch (1st gen, WiFi, 1TB)" ;
                    case "iPad8,3": return /*j318ap",   0x0E, 0x8027*/ "iPad Pro 11-inch (1st gen, Cellular)" ;
                    case "iPad8,4": return /*j318xap",  0x1E, 0x8027*/ "iPad Pro 11-inch (1st gen, Cellular, 1TB)" ;
                    case "iPad8,5": return /*j320ap",   0x08, 0x8027*/ "iPad Pro 12.9-inch (3rd gen, WiFi)" ;
                    case "iPad8,6": return /*j320xap",  0x18, 0x8027*/ "iPad Pro 12.9-inch (3rd gen, WiFi, 1TB)" ;
                    case "iPad8,7": return /*j321ap",   0x0A, 0x8027*/ "iPad Pro 12.9-inch (3rd gen, Cellular)" ;
                    case "iPad8,8": return /*j321xap",  0x1A, 0x8027*/ "iPad Pro 12.9-inch (3rd gen, Cellular, 1TB)" ;
                    case "iPad8,9": return /*j417ap",   0x3C, 0x8027*/ "iPad Pro 11-inch (2nd gen, WiFi)" ;
                    case "iPad8,10": return /*j418ap",   0x3E, 0x8027*/ "iPad Pro 11-inch (2nd gen, Cellular)" ;
                    case "iPad8,11": return /*j420ap",   0x38, 0x8027*/ "iPad Pro 12.9-inch (4th gen, WiFi)" ;
                    case "iPad8,12": return /*j421ap",   0x3A, 0x8027*/ "iPad Pro 12.9-inch (4th gen, Cellular)" ;
                    case "iPad11,1": return /*j210ap",   0x14, 0x8020*/ "iPad mini (5th gen, WiFi)" ;
                    case "iPad11,2": return /*j211ap",   0x16, 0x8020*/ "iPad mini (5th gen, Cellular)" ;
                    case "iPad11,3": return /*j217ap",   0x1C, 0x8020*/ "iPad Air (3rd gen, WiFi)" ;
                    case "iPad11,4": return /*j218ap",   0x1E, 0x8020*/ "iPad Air (3rd gen, Cellular)" ;
                    case "iPad11,6": return /*j171aap",  0x24, 0x8020*/ "iPad (8th gen, WiFi)" ;
                    case "iPad11,7": return /*j172aap",  0x26, 0x8020*/ "iPad (8th gen, Cellular)" ;
                    case "iPad12,1": return /*j181ap",   0x18, 0x8030*/ "iPad (9th gen, WiFi)" ;
                    case "iPad12,2": return /*j182ap",   0x1A, 0x8030*/ "iPad (9th gen, Cellular)" ;
                    case "iPad13,1": return /*j307ap",   0x04, 0x8101*/ "iPad Air (4th gen, WiFi)" ;
                    case "iPad13,2": return /*j308ap",   0x06, 0x8101*/ "iPad Air (4th gen, Cellular)" ;
                    case "iPad13,4": return /*j517ap",   0x08, 0x8103*/ "iPad Pro 11-inch (3rd gen, WiFi)" ;
                    case "iPad13,5": return /*j517xap",  0x0A, 0x8103*/ "iPad Pro 11-inch (3rd gen, WiFi, 2TB)" ;
                    case "iPad13,6": return /*j518ap",   0x0C, 0x8103*/ "iPad Pro 11-inch (3rd gen, Cellular)" ;
                    case "iPad13,7": return /*j518xap",  0x0E, 0x8103*/ "iPad Pro 11-inch (3rd gen, Cellular, 2TB)" ;
                    case "iPad13,8": return /*j522ap",   0x18, 0x8103*/ "iPad Pro 12.9-inch (5th gen, WiFi)" ;
                    case "iPad13,9": return /*j522xap",  0x1A, 0x8103*/ "iPad Pro 12.9-inch (5th gen, WiFi, 2TB)" ;
                    case "iPad13,10": return /*j523ap",   0x1C, 0x8103*/ "iPad Pro 12.9-inch (5th gen, Cellular)" ;
                    case "iPad13,11": return /*j523xap",  0x1E, 0x8103*/ "iPad Pro 12.9-inch (5th gen, Cellular, 2TB)" ;
                    case "iPad13,16": return /*j407ap",   0x10, 0x8103*/ "iPad Air (5th gen, WiFi)" ;
                    case "iPad13,17": return /*j408ap",   0x12, 0x8103*/ "iPad Air (5th gen, Cellular)" ;
                    case "iPad13,18": return /*j271ap",   0x14, 0x8101*/ "iPad (10th gen, WiFi)" ;
                    case "iPad13,19": return /*j272ap",   0x16, 0x8101*/ "iPad (10th gen, Cellular)" ;
                    case "iPad14,1": return /*j310ap",   0x04, 0x8110*/ "iPad mini (6th gen, WiFi)" ;
                    case "iPad14,2": return /*j311ap",   0x06, 0x8110*/ "iPad mini (6th gen, Cellular)" ;
                    case "iPad14,3": return /*j617ap",   0x08, 0x8112*/ "iPad Pro 11-inch (4th gen, WiFi)" ;
                    case "iPad14,4": return /*j618ap",   0x0A, 0x8112*/ "iPad Pro 11-inch (4th gen, Cellular)" ;
                    case "iPad14,5": return /*j620ap",   0x0C, 0x8112*/ "iPad Pro 12.9-inch (6th gen, WiFi)" ;
                    case "iPad14,6": return /*j621ap",   0x0E, 0x8112*/ "iPad Pro 12.9-inch (6th gen, Cellular)" ;
                        default:
                            return "Conecta tu Dispositivo..."
                    }

            //end of model list
            }
        
    //kết nối
    func checkapi(completion: @escaping (Bool) -> Void) {
       
        self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/panel/api/api21.php?ecid=\(self.ecid.stringValue)&sn=\(self.SN.stringValue)&pt=\(self.MODEL.stringValue)") { (responseString, error) in
                if let error = error {
                    print("Error: \(error)")
                    completion(false) // Indicate failure via completion handler
                } else if let responseString = responseString {
                    
                    
                    if responseString == "1" {
                        completion(true);// self.dangky.isHidden = true
                    } else {
                       // self.dangky.isHidden = false
                        self.BoxShow("Thiết bị của bạn chưa đăng ký", Buttontext: "OK")
                        completion(false) // Indicate failure via completion handler
                    }
                }
            }
        
    }
    
   //mở chức năng
    func portisClosed() {
        DispatchQueue.main.async {
                      self.exit.isHidden = true
             self.ver.isHidden = true
            self.namethietbi.isHidden = true
            self.ecid.isHidden = true
            self.chedo.isHidden = true
            self.ios.isHidden = true
            self.copy1.isHidden = true
            self.boxngach.isHidden = true
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = true
            self.zalo.isHidden = true
            self.web.isHidden = true
            self.dangky.isHidden = true
            self.ngonngu.isHidden = true
            self.tickhello.isHidden = true
            self.batdau.isHidden = true
            self.chucnang.isHidden = true
            self.menu1.isHidden = true
           
          
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true

        }
    }
    func bootdfu() {
        DispatchQueue.main.async {
        
            self.exit.isHidden = true
             self.ver.isHidden = true
            self.namethietbi.isHidden = true
            self.ecid.isHidden = true
            self.chedo.isHidden = true
            self.ios.isHidden = true
            self.copy1.isHidden = true
            self.boxngach.isHidden = true
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = true
            self.zalo.isHidden = true
            self.web.isHidden = true
            self.dangky.isHidden = true
            self.ngonngu.isHidden = true
            self.tickhello.isHidden = true
            self.batdau.isHidden = true
            self.chucnang.isHidden = true
            self.menu1.isHidden = true
            
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true

        }
    }
    func CHECKRA1N() {
        DispatchQueue.main.async {
            self.exit.isHidden = true
            self.ver.isHidden = false
            self.namethietbi.isHidden = false
            self.ecid.isHidden = false
            self.chedo.isHidden = false
            self.ios.isHidden = false
           self.copy1.isHidden = false
            self.boxngach.isHidden = false
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = false
            self.zalo.isHidden = false
            self.web.isHidden = false
            self.dangky.isHidden = true
            self.ngonngu.isHidden = false
            self.tickhello.isHidden = false
            self.batdau.isHidden = false
            self.chucnang.isHidden = false
            self.menu1.isHidden = true
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true
  
            self.chucnang.removeAllItems()
           // self.chucnang.addItems(withTitles: ["GSM Signal", "Bypass MEID (NS)", "Backup Passcode", "Activate Passcode", "BYPASS RAMDISK"])
            self.chucnang.addItems(withTitles: ["GSM Signal", "BYPASS RAMDISK"])
            
        }
    }
    
    
    func helloOpened() {
        DispatchQueue.main.async {
            self.exit.isHidden = true
            self.ver.isHidden = false
            self.namethietbi.isHidden = false
            self.ecid.isHidden = false
            self.chedo.isHidden = false
            self.ios.isHidden = false
           self.copy1.isHidden = false
            self.boxngach.isHidden = false
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = false
            self.zalo.isHidden = false
            self.web.isHidden = false
            self.dangky.isHidden = true
            self.ngonngu.isHidden = false
            self.tickhello.isHidden = false
            self.batdau.isHidden = false
            self.chucnang.isHidden = false
            self.menu1.isHidden = true
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true
  
            self.chucnang.removeAllItems()
            self.chucnang.addItems(withTitles: ["BOOT RAMDISK", "BYPASS MDM", "BYPASS CHECKRA1N","Fix Notification" , "BLOCK OTA", "CHECK LOCK", "TẠO TUỲ CHỈNH SN"])
        }
    }
    func dfuOpened1() {
        DispatchQueue.main.async {
            self.exit.isHidden = true
            self.ver.isHidden = false
            self.namethietbi.isHidden = false
            self.ecid.isHidden = false
            self.chedo.isHidden = false
            self.ios.isHidden = false
           self.copy1.isHidden = false
            self.boxngach.isHidden = false
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = false
            self.zalo.isHidden = false
            self.web.isHidden = false
            self.dangky.isHidden = true
            self.ngonngu.isHidden = false
            self.tickhello.isHidden = true
            self.batdau.isHidden = true
            self.chucnang.isHidden = true
            self.menu1.isHidden = true
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true

            self.hienthi.textColor = NSColor.systemRed
            
            
            self.hienthi.stringValue = "VUI LÒNG THOÁT CHẾ ĐỘ DFU VÀ ĐƯ VỀ CHẾ ĐỘ RECOVERY VỚI MÁY PASSCODE VÀ CHẾ ĐỘ BÌNH THƯỜNG VỚI THIẾT BỊ HELLO"
            
            
            
            
        }
    }
    func dfuhello() {
        DispatchQueue.main.async {
            self.ver.isHidden = true
           self.namethietbi.isHidden = true
           self.ecid.isHidden = true
           self.chedo.isHidden = true
           self.ios.isHidden = true
           self.copy1.isHidden = true
           self.boxngach.isHidden = true
           self.hienthi.isHidden = true
           self.boxngach1.isHidden = true
           self.zalo.isHidden = true
           self.web.isHidden = true
           self.dangky.isHidden = true
           self.ngonngu.isHidden = true
           self.tickhello.isHidden = true
           self.batdau.isHidden = true
           self.chucnang.isHidden = true
           self.menu1.isHidden = true
           
            self.exit.isHidden = true
           //dfu
           self.re.isHidden = false
           self.ttx.isHidden = true
            self.btnStartDFU.title = "EXIT"
            
           self.btnStartDFU.isHidden = false
           self.lblDFUStatus.isHidden = true
           self.lblStep1.isHidden = true
           self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
           self.lblPowerBtn.isHidden = true
           self.lblHomeBtn.isHidden = true
           self.lblVolumeBtn.isHidden = true
           
           self.imgPhone.isHidden = false
           self.HIENTHI.isHidden = false
           
           self.cpid.isHidden = true
           
            
        }
    }
    func dfuOpened() {
        DispatchQueue.main.async {
            self.ver.isHidden = true
           self.namethietbi.isHidden = true
           self.ecid.isHidden = true
           self.chedo.isHidden = true
           self.ios.isHidden = true
           self.copy1.isHidden = true
           self.boxngach.isHidden = true
           self.hienthi.isHidden = true
           self.boxngach1.isHidden = true
           self.zalo.isHidden = true
           self.web.isHidden = true
           self.dangky.isHidden = true
           self.ngonngu.isHidden = true
           self.tickhello.isHidden = true
           self.batdau.isHidden = true
           self.chucnang.isHidden = true
           self.menu1.isHidden = true
          
            
            self.exit.isHidden = true
           //dfu
           self.re.isHidden = false
           self.ttx.isHidden = false
           self.btnStartDFU.isHidden = false
           self.lblDFUStatus.isHidden = false
           self.lblStep1.isHidden = false
           self.lblStep2.isHidden = false
           self.lblStep3.isHidden = false
           self.lblPowerBtn.isHidden = false
           self.lblHomeBtn.isHidden = false
           self.lblVolumeBtn.isHidden = false
           
           self.imgPhone.isHidden = false
           self.HIENTHI.isHidden = false
           
           self.cpid.isHidden = false
           
            
        }
    }
    func recoOpened() {
        DispatchQueue.main.async {
            self.exit.isHidden = true
            self.ver.isHidden = false
            self.namethietbi.isHidden = false
            self.ecid.isHidden = false
            self.chedo.isHidden = false
            self.ios.isHidden = false
           self.copy1.isHidden = false
            self.boxngach.isHidden = false
            self.hienthi.isHidden = false
            self.boxngach1.isHidden = false
            self.zalo.isHidden = false
            self.web.isHidden = false
            self.dangky.isHidden = true
            self.ngonngu.isHidden = false
            self.tickhello.isHidden = true
            self.batdau.isHidden = false
            self.chucnang.isHidden = true
            self.menu1.isHidden = true
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.cpid.isHidden = true
            self.exit.isHidden = true
            self.chucnang.removeAllItems()
            self.chucnang.addItems(withTitles: ["BOOT RAMDISK"])
        }
    }
    func recoOpened1() {
        DispatchQueue.main.async {
            self.ver.isHidden = true
            self.namethietbi.isHidden = true
            self.ecid.isHidden = true
            self.chedo.isHidden = true
            self.ios.isHidden = true
            self.copy1.isHidden = true
            self.boxngach.isHidden = true
            self.hienthi.isHidden = true
            self.boxngach1.isHidden = true
            self.zalo.isHidden = true
            self.web.isHidden = true
            self.dangky.isHidden = true
            self.ngonngu.isHidden = true
            self.tickhello.isHidden = true
            self.batdau.isHidden = true
            self.chucnang.isHidden = true
            self.menu1.isHidden = false
            //dfu
           
            self.re.isHidden = true
            self.ttx.isHidden = false
            self.btnStartDFU.isHidden = false
            self.lblDFUStatus.isHidden = false
            self.lblStep1.isHidden = false
            self.lblStep2.isHidden = false
            self.lblStep3.isHidden = false
            self.lblPowerBtn.isHidden = false
            self.lblHomeBtn.isHidden = false
            self.lblVolumeBtn.isHidden = false
            self.exit.isHidden = false
            self.imgPhone.isHidden = false
            self.HIENTHI.isHidden = false
            
            self.cpid.isHidden = false
            let boardid = self.iRecoveryInfo("MODEL");
            
            
            let strings = ["d20ap", "d21ap", "d201ap", "d22ap", "d211ap", "d221ap", "j71bap", "j71sap", "j71tap", "j72bap", "j72sap", "j72tap", "j98aap", "j98aap", "j99aap", "j120ap", "j121ap", "j127ap", "j128ap", "j171ap", "j172ap", "j207ap", "j208ap"]
            let strings2 = ["j71bap", "j72bap", "j171ap", "j172ap"]
            let strings3 = ["n51ap", "n53ap", "n61ap", "n56ap", "j71ap", "j72ap", "j73ap", "j85ap", "j86ap", "j87ap", "j85map", "j86map", "j87map"]
                
                
                if strings.contains(boardid){
                    if strings.contains(boardid){
                        self.menu1.removeAllItems()
                        self.menu1.addItems(withTitles: ["BOOT13", "BOOT14", "BOOT15", "BOOT15P", "BOOT16.4.1<", "BOOT16.5>", "BOOT16.4.1<P", "BOOT16.5>P2", "BOOT17"])
                    }else{
                        self.menu1.removeAllItems()
                        self.menu1.addItems(withTitles: ["BOOT13", "BOOT14", "BOOT15", "BOOT15P", "BOOT16.4.1<", "BOOT16.5>", "BOOT16.4.1<P", "BOOT16.5>P2"])
                        
                    }
                }else{
                    if strings3.contains(boardid){
                        self.menu1.removeAllItems()
                        self.menu1.addItems(withTitles: ["BOOT12"])
                    } else{
 
                        self.menu1.removeAllItems()
                        self.menu1.addItems(withTitles: ["BOOT13", "BOOT14", "BOOT15", "BOOT15P"])
                        
                    }
                    
                }
            
                
                    
               
                
            }
            
            
            
            
        }
    func ramdiskOpened() {
        DispatchQueue.main.async {
            self.ver.isHidden = false
            self.namethietbi.isHidden = false
            self.ecid.isHidden = false
            self.chedo.isHidden = false
            self.ios.isHidden = false
            self.copy1.isHidden = false
            self.boxngach.isHidden = false
            self.hienthi.isHidden = false
           // self.boxngach1.isHidden = false
            self.zalo.isHidden = false
            self.web.isHidden = false
            self.dangky.isHidden = true
            self.ngonngu.isHidden = false
            self.tickhello.isHidden = true
            self.batdau.isHidden = false
            self.chucnang.isHidden = false
            self.menu1.isHidden = true
            //dfu
            self.re.isHidden = true
            self.ttx.isHidden = true
            self.btnStartDFU.isHidden = true
            self.lblDFUStatus.isHidden = true
            self.lblStep1.isHidden = true
            self.lblStep2.isHidden = true
            self.lblStep3.isHidden = true
            self.lblPowerBtn.isHidden = true
            self.lblHomeBtn.isHidden = true
            self.lblVolumeBtn.isHidden = true
            
            self.imgPhone.isHidden = true
            self.HIENTHI.isHidden = true
            
            self.cpid.isHidden = true
            self.exit.isHidden = true
            self.chucnang.removeAllItems()
            self.chucnang.addItems(withTitles: ["BACKUP PASSCODE", "ACTIVATION PASSCODE", "ReBoot", "FactoryReset", "Fix Notification", "ON Baseband", "OFF Baseband", "Check IOS","RAMDISK MDM"])
    }
    }

        //Show alert box start
        func BoxShow(_ Texto:String, Buttontext:String){
            DispatchQueue.main.async {
            let alert = NSAlert();
            
            alert.messageText = Texto
            alert.addButton(withTitle: Buttontext)
            alert.runModal()
        
            }
            
        }
    func tg1(tgg: String) -> String? {
        var input = tgg // Use 'var' to make 'input' mutable

        let tg = self.ngonngu.titleOfSelectedItem!

        if "\(tgg)\(tg)" == "SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG OKEN" {
            input = "SSH MOUNT PARTS USER DATA OK" // Assign the new value to the outer 'input'
        }

        if "\(tgg)\(tg)" == "Đã copy thành công ECID:EN" {
            input = "Successfully copied ECID:" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Phát hiện bản sao lưu đã có trên pc bạn muốn ghi đè lên bản sao lưu không.?:EN" {
            input = "Detect that a backup already exists on your PC. Do you want to overwrite the backup?" // Assign the new value to the outer 'input'
        }

        if "\(tgg)\(tg)" == "Thiết bị của bạn là iPad WIFI vui lòng thay đổi sn của bạn để tạo file kích hoạt. Vui lòng chọn Tạo kích hoạt tuỳ chỉnh SNEN" {
            input = "Your device is iPad WIFI please change your sn to generate the activation file. Please select Create Custom Trigger SN" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG NGEN" {
            input = "SSH MOUNT PARTS USER DATA NG" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Thiết bị chưa vào DFUEN" {
            input = "Device has not entered DFU" // Assign the new value to the outer 'input'
        }
        
    if "\(tgg)\(tg)" == "Giải nén file ramdiskEN" {
        input = "Extract the ramdisk file" // Assign the new value to the outer 'input'
    }
        if "\(tgg)\(tg)" == "Kiểm tra thiết bị vào PWNDEN" {
            input = "Check PWND input device" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Thiết bị vào PWND lỗi vui lòng thử lạiEN" {
            input = "PWND input device error, please try again" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Boot ramdisk thất bại vui lòng thử lạiEN" {
            input = "Boot ramdisk failed, please try again" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "RAMDISK KHỞI ĐỘNG THÀNH CÔNGEN" {
            input = "RAMDISK STARTED SUCCESSFULLY" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "RLỗi kết nối Ramdisk, vui lòng BOOT RAMDISK lạiEN" {
            input = "Ramdisk connection error, please BOOT RAMDISK again" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Thiết bị chưa vào DFUEN" {
            input = "Device has not entered DFU" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Xoá iOS successfullyEN" {
            input = "Delete iOS successfully" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Nếu một trong các thông báo NG vui lòng kiểm tra lại.EN" {
            input = "If one of the NG messages please check again." // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Phát hiện xem bản sao lưu đã có trên hệ thống web mà bạn muốn ghi đè lên bản sao lưu chưa.?EN" {
            input = "Detect if the backup is already on the web system that you want to overwrite the backup.?" // Assign the new value to the outer 'input'
        }
        
        if "\(tgg)\(tg)" == "Bạn có muốn xoá thiết bị của bạn về hello không?EN" {
            input = "Do you want to wipe your device back to hello?" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "THIẾT BỊ KHÔNG TRUY CẬP ĐƯỢC PHẦN VÙNG NGƯỜI DÙNG VUI LÒNG BOOT LẠI RAMDISKEN" {
            input = "DEVICE CANNOT ACCESS USER SECTION PLEASE REBOOT RAMDISK" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Bạn có muốn chặn OTA không?EN" {
            input = "Do you want to block OTAs?" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "HELLO SCREEN IDEVICE ĐÃ ĐƯỢC KÍCH HOẠT THÀNH CÔNG!EN" {
            input = "HELLO SCREEN IDEVICE SUCCESSFULLY ACTIVED!" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "THIẾT BỊ KHÔNG TRUY CẬP ĐƯỢC PHẦN VÙNG NGƯỜI DÙNG VUI LÒNG BOOT LẠI RAMDISKEN" {
            input = "DEVICE CANNOT ACCESS USER SECTION PLEASE REBOOT RAMDISK" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Không tìm thấy tệp kích hoạt trên máy chủ vui lòng thoát ramdisk và tạo lạiEN" {
            input = "Activation file not found on server please exit ramdisk and create again" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Bạn chọn chế độ off Baseband và không cần dùng sim với mã pinEN" {
            input = "You choose off Baseband mode and do not need to use sim with pin code" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "bạn chọn chế độ on Baseband và cần dùng sim có mã pin (đối với máy meid thì không cần dùng sim có mã pin)EN" {
            input = "You choose on Baseband mode and need to use a sim with a pin code (for meid devices, no need to use a sim with a pin code)" // Assign the new value to the outer 'input'
        }
        if "\(tgg)\(tg)" == "Tạo kích hoạt tuỳ chỉnh SN:" {
            input = "Create a custom trigger SN:" // Assign the new value to the outer 'input'
        }
        

        return input
    }
    
    func startGasterProcesses() {
         // Start the first process
         gasterProcess1 = startGasterProcess(with: "pwn")
         
         // Set up a timer to terminate all processes if the first process takes longer than 10 seconds
         timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: false)
     }
     
     @objc func timerExpired() {
         // Timer expired, terminate all processes
         print("Timer expired. Terminating all processes.")
         terminateProcesses()
     }
     
     func startGasterProcess(with argument: String) -> Process? {
         
     let partyPath1 = Bundle.main.url(forResource: "htools/exploits/gaster", withExtension: "")
     let gaster: String = partyPath1!.path
         
         let process = Process()
         process.launchPath = gaster
         process.arguments = [argument]
         
         process.terminationHandler = { [weak self] process in
             // A process terminated, invalidate the timer
             self?.timer?.invalidate()
             
             if process == self?.gasterProcess1 {
                 // Process 1 terminated, start the second process
                 print("Gaster process 1 terminated.")
                 self?.gasterProcess2 = self?.startGasterProcess(with: "reset")
             } else if process == self?.gasterProcess2 {
                 // Process 2 terminated, do any cleanup or additional actions
                 print("Gaster process 2 terminated.")
             }
         }
         
         do {
             try process.run()
             return process
         } catch {
             print("Error launching gaster process: \(error.localizedDescription)")
             return nil
         }
     }
     
     func terminateProcesses() {
         gasterProcess1?.terminate()
         gasterProcess2?.terminate()
     }
    func checkapimac(completion: @escaping (Bool) -> Void) {
        let serimac2 = getSerialNumber()!;
        makeHTTPRequest(urlString: "https://gsmunlockinfo.org/panel/api/apimac.php?ecid=\(serimac2)") { (responseString, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                    completion(false) // Indicate failure via completion handler
                } else if let responseString = responseString {
                    if responseString == "1" {
                        completion(true) // Indicate success via completion handler
                    } else {
                        completion(false) // Indicate failure via completion handler
                    }
                }
            }
        }
    }

    func showUSBConnectedNotification(deviceName: String) -> Void {
        if (!deviceName.contains("Hub") && !deviceName.contains("Internal") && !deviceName.contains("Host") && !deviceName.contains("Simulation")) {
            let notification = NSUserNotification()
            notification.title = "USB Device Connected"
            notification.soundName = NSUserNotificationDefaultSoundName
            notification.subtitle = deviceName
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    func getSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        guard platformExpert > 0 else {
            return nil
        }
        guard let serialNumber = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String else {
            return nil
        }
        IOObjectRelease(platformExpert)
        return serialNumber
    }
    func uploadFile(RRL:String,FILE:String) {
        // Đường dẫn đến tệp bạn muốn tải lên
        let filePath = "\(FILE)"

        // Đường dẫn URL của máy chủ
        guard let serverURL = URL(string: "\(RRL)") else {
            print("URL máy chủ không hợp lệ.")
            return
        }

        // Tạo yêu cầu POST
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"

        // Định dạng dữ liệu yêu cầu (multipart/form-data)
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Tạo nội dung yêu cầu
        var data = Data()

        // Thêm phần đầu yêu cầu
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(URL(fileURLWithPath: filePath).lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)

        // Đọc dữ liệu từ tệp và thêm vào yêu cầu
        if let fileData = FileManager.default.contents(atPath: filePath) {
            data.append(fileData)
        } else {
            print("Không thể đọc dữ liệu từ tệp.")
            return
        }

        // Thêm phần cuối yêu cầu
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        // Đặt dữ liệu yêu cầu
        request.httpBody = data

        // Tạo và khởi chạy task yêu cầu
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Lỗi tải lên: \(error)")
                return
            }

            // Xử lý dữ liệu phản hồi nếu cần
            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Phản hồi từ máy chủ: \(responseString ?? "")")
            }
        }

        task.resume()
    }
    
    
    
    
    func downloadFile(RRL: String, FILE: String, completion: @escaping () -> Void) {
        // URL của tệp bạn muốn tải về
        guard let fileURL = URL(string: RRL) else {
            print("URL không hợp lệ.")
            return
        }

        do {
            // Lấy đường dẫn tới thư mục desktop
            let documentsUrl = try FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = documentsUrl.appendingPathComponent(FILE)

            if FileManager.default.fileExists(atPath: destinationURL.path) {
                // Nếu tệp đã tồn tại, xóa nó trước khi di chuyển tệp mới vào
                try FileManager.default.removeItem(at: destinationURL)
            }

            let task = URLSession.shared.downloadTask(with: fileURL) { (tempURL, response, error) in
                if let error = error {
                    print("Lỗi tải về: \(error)")
                    completion() // Call the completion handler even if there is an error
                    return
                }

                guard let tempURL = tempURL else {
                    print("Không tìm thấy tệp tạm.")
                    completion() // Call the completion handler if tempURL is nil
                    return
                }

                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    print("Tệp đã được tải về và lưu tại: \(destinationURL.path)")
                    completion() // Call the completion handler after successful download and save
                } catch {
                    print("Lỗi di chuyển tệp: \(error)")
                    completion() // Call the completion handler if there is an error in moving the file
                }
            }

            task.resume()
        } catch {
            print("Lỗi lấy đường dẫn tới thư mục desktop: \(error)")
            completion() // Call the completion handler if there is an error in getting the desktop directory URL
        }
    }
    
    //bypass
    func isFileExist(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        
        // Kiểm tra xem tập tin có tồn tại hay không
        return fileManager.fileExists(atPath: path)
    }
    
    func checkbackup() {
       
      /*  let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationUrl = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)/")
        print("\(destinationUrl)/le.c")

        if isFileExist(atPath: "\(destinationUrl)/activation_record.plist") {
            DispatchQueue.main.async {
                self.check1.stringValue = "OK"
            }
        } else {
            DispatchQueue.main.async {
                self.check1.stringValue = "NG"
            }
        }
       let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         let destinationUrl = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)/")
         print("\(destinationUrl)/le.c")
       
        if isFileExist(atPath: "\(destinationUrl)/com.apple.commcenter.device_specific_nobackup.plist") {
            DispatchQueue.main.async {
                self.check2.stringValue = "OK"
            }
        } else {
            DispatchQueue.main.async {
                self.check2.stringValue = "NG"
            }
        }
        if isFileExist(atPath: "\(destinationUrl)/IC-Info.sisv") {
            DispatchQueue.main.async {
                self.check3.stringValue = "OK"
            }
        } else {
            DispatchQueue.main.async {
                self.check3.stringValue = "NG"
            }
        }*/
        
        
     
        if(shell("ls /Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)").contains("activation_record.plist")){
            
                self.check1.stringValue = "OK"
                print("OK")
            
        }
        else{
           
                self.check1.stringValue = "NG"
            
        }
        if(shell("ls /Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)").contains("com.apple.commcenter.device_specific_nobackup.plist")){
            
               
                    self.check2.stringValue = "OK"
                    print("OK")
            
                
              }
        else{
            
                self.check2.stringValue = "NG"
            
        }
        
        if(shell("ls /Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)").contains("IC-Info.sisv")){
            
                self.check3.stringValue = "OK"
                print("OK")
                
            
              }else{
           
                self.check3.stringValue = "NG"
            
        }
      
      
      
    }
    func checkaction() {
        if(sshpass12("ls /mnt2/containers/Data/System/*/Library/activation_records/").contains("activation_record.plist")){
                self.check1.stringValue = "OK"
        }
        else{
            
                self.check1.stringValue = "NG"
            
        }
        if(sshpass12("'ls /mnt2/wireless/Library/Preferences/'").contains("com.apple.commcenter.device_specific_nobackup.plist")){
            
                self.check2.stringValue = "OK"
            
        }else{
            
            
                self.check2.stringValue = "NG"
            
        }
        if(sshpass12("'ls /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/'").contains("IC-Info.sisv")){
            
                self.check3.stringValue = "OK"
            
        }else{
            
                self.check3.stringValue = "NG"
            
        }
    }
    func zipDirectory(at sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.zipItem(at: sourceURL, to: destinationURL)
            print("Thư mục đã được nén thành file zip tại: \(destinationURL.path)")
        } catch {
            print("Lỗi khi nén thư mục: \(error.localizedDescription)")
        }
    }
    func encodeBase64(string: String) -> String {
        let data = string.data(using: .utf8)
        return data?.base64EncodedString() ?? ""
    }
    
  
    
    func actifile() -> String {
        guard let partyPath1 = Bundle.main.url(forResource: "htools/libs/ideviceinfo", withExtension: "") else {
            return "Failed to find resource path"
        }
        let ideviceinfo = partyPath1.path
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/env") // Changed to executableURL
        task.arguments = [ideviceinfo, "-x"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run() // Changed to run() as launch() is deprecated
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            } else {
                return "Failed to decode output"
            }
        } catch {
            return "Failed to launch task: \(error.localizedDescription)"
        }
    }
    func backupPasscode(){
        autossh()
       
        if(sshpass12("'ls /mnt2/containers/Data/'").contains("System")){
            self.hienthi.stringValue = "BACKUP FILE"
            
        let ECIDD = ecid.stringValue
            
            _ = shell("mkdir /Users/$(whoami)/Desktop/PasscodeActivation; mkdir /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "");
            //download actvation record
          _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/internal/../ && cp -rp activation_records/activation_record.plist /mnt1/");
            _ = sshpass14("'/mnt1/activation_record.plist' /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/");
            //download again actvation record
        _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/internal/../ && cp -rp activation_records/activation_record.plist /mnt1/");
            _ = sshpass14("'/mnt1/activation_record.plist' /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/");
            //download com.apple.no.backup
            _ = sshpass12("cp -rp /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist /mnt1/");
            _ = sshpass14("'/mnt1/com.apple.commcenter.device_specific_nobackup.plist' /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/");
            //download again com.apple.no.backup
            _ = sshpass12("cp -rp /mnt2/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist /mnt1/");
            _ = sshpass14("'/mnt1/com.apple.commcenter.device_specific_nobackup.plist' /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/");
            //donwload ic-info.sisv
           // _ = sshpass12("cp -rp /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv /mnt1/");
                _ = sshpass14("'/mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv' /Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/");
            
            if(shell("ls /Users/$(whoami)/Desktop/PasscodeActivation/\(ECIDD)/").contains("IC-Info.sisv")){
                //
            }
            else {
                fixsisv(ECIDD: "\(ECIDD)/")
                
            }
            let username = NSUserName()
            if(shell("ls /Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)").contains("com.apple.commcenter.device_specific_nobackup.plist")){
                let documentsUrl1 = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let plistPath = "/Users/\(username)/Desktop/PasscodeActivation/\(self.ecid.stringValue)/com.apple.commcenter.device_specific_nobackup.plist"
                
                 if let data = FileManager.default.contents(atPath: plistPath) {
                     do {
                         // Parse plist data
                         if let plistDict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                             // Lấy giá trị ActivationTicket từ plist
                             if let ticketDict = plistDict["kPostponementTicket"] as? [String: String],
                                 let activationTicket = ticketDict["ActivationTicket"] {
                                 self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/panel/api/upbb.php?ecid=" + ECIDD + "&bb=\(activationTicket)") { (responseString, error) in
                                     
                                         if let error = error {
                                             print("Error: \(error)")
                                         } else  {
                                             
                                         }
                                     
                                 }
                                 
                                 
                        
                                 print("ActivationTicket: \(activationTicket)")
                             } else {
                                 print("ActivationTicket not found in the plist.")
                             }
                         } else {
                             print("Failed to parse the plist.")
                         }
                     } catch {
                         print("Error reading plist: \(error)")
                     }
                 } else {
                     print("Failed to read plist data.")
                 }
                 
                 
                 
                 
                 print("okkkkk")
                 
             }
            
            
            
            
            
            
            
            checkbackup();
                
            let tg2 = self.tg1(tgg:"Nếu một trong các thông báo NG vui lòng kiểm tra lại.");
            let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
            
                BoxShow("\(tg3) \n\nActivated \(check1.stringValue). \n\nNotification \(check2.stringValue). \n\nSignal \(check3.stringValue).", Buttontext: "OK");
            let check33 = "\(check1.stringValue)\(check2.stringValue)\(check2.stringValue)";
            if("\(check33)" == "OKOKOK"){
                makeHTTPRequest(urlString: "https://gsmunlockinfo.org/backup/check.php?ecid=\(ecid.stringValue)") { (responseString, error) in
                    DispatchQueue.main.async {
                            if let error = error {
                                print("Error: \(error)")
                            } else if let responseString = responseString {
                                if responseString == "1" {
                                    let tg2 = self.tg1(tgg:"Phát hiện xem bản sao lưu đã có trên hệ thống web mà bạn muốn ghi đè lên bản sao lưu chưa.?");
                                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
 
                                    let alert = NSAlert()
                                    alert.messageText = "\(tg3)"
                                    alert.addButton(withTitle: "YES")
                                    alert.addButton(withTitle: "NO")
                                    let response = alert.runModal()
                                    if response == .alertFirstButtonReturn {
                                        let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                        let sourceDirectoryURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)")
                                        let destinationZipURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue).zip")
                                        self.zipDirectory(at: sourceDirectoryURL, to: destinationZipURL)
                                      //  _ = self.shell("cd /Users/$(whoami)/Desktop/PasscodeActivation/;zip -r \(self.ecid.stringValue).zip \(self.ecid.stringValue) >/dev/null 2>&1;");
                                        self.uploadFile(RRL:"https://gsmunlockinfo.org/backup/up.php",FILE:"/Users/\(username)/Desktop/PasscodeActivation/\(self.ecid.stringValue).zip");
                                 
                                        _ = self.shell("/bin/rm -f /Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)-web.zip");
                                    
                                } else if response == .alertSecondButtonReturn {
                                    let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                    let sourceDirectoryURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)")
                                    let destinationZipURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue).zip")
                                    self.zipDirectory(at: sourceDirectoryURL, to: destinationZipURL)
                                }
                                } else {
                                    let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                    let sourceDirectoryURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)")
                                    let destinationZipURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue).zip")
                                    self.zipDirectory(at: sourceDirectoryURL, to: destinationZipURL)
                                    
                                   // _ = self.shell("cd /Users/$(whoami)/Desktop/PasscodeActivation/;zip -r \(self.ecid.stringValue).zip \(self.ecid.stringValue) >/dev/null 2>&1;");
                                    self.uploadFile(RRL:"https://gsmunlockinfo.org/backup/up.php",FILE:"/Users/\(username)/Desktop/PasscodeActivation/\(self.ecid.stringValue).zip");
                                   // self.dismiss(self);
                                }
                            }
                        }
                }
                
                DispatchQueue.main.async {
                    let tg2 = self.tg1(tgg:"Bạn có muốn xoá thiết bị của bạn về hello không?");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                let alert = NSAlert()
                alert.messageText = "\(tg3)"
                alert.addButton(withTitle: "ERASE")
                alert.addButton(withTitle: "EXIT")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    
                    _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=5 sync");
                    _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=5");
                    _ = self.sshpass12("/sbin/reboot");
                } else if response == .alertSecondButtonReturn {
                    self.ramdiskOpened()
                   
                  //  _ = sshpass12("/sbin/reboot");
                }
                }
            }
            else{
                DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Reboot iphone"
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    _ = self.sshpass12("/sbin/reboot");
                    self.exit1()
                } else if response == .alertSecondButtonReturn {
                    self.ramdiskOpened()
                   
    
                }
   
            }
            }
    }else {
        self.deviceDetectionHandler = true
        
        
        let tg2 = self.tg1(tgg:"THIẾT BỊ KHÔNG TRUY CẬP ĐƯỢC PHẦN VÙNG NGƯỜI DÙNG VUI LÒNG BOOT LẠI RAMDISK");
        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
        
        BoxShow("\(tg3)", Buttontext:"OK")
        exit1()
}
        }
    func activatePasscode() {
        
                  autossh()
        if(sshpass12("'ls /mnt2/containers/Data/'").contains("System")){
            self.hienthi.stringValue = "ACTIVATION...."
            let th1 = Bundle.main.url(forResource: "htools/libs/1", withExtension: "")
           let iy: String = th1!.path
            
            
            
        let ECIDD = ecid.stringValue
           
                if("\(web.stringValue)" == "web"){
                    self.hienthi.stringValue = "ACTIVATION BY WEB FILE"
                    _ = sshpass13("/Users/$(whoami)/Desktop/.WEB/" + ECIDD + "/activation_record.plist root@localhost:/mnt1/");
                    _ = sshpass13("/Users/$(whoami)/Desktop/.WEB/" + ECIDD + "/IC-Info.sisv root@localhost:/mnt1/");
                    _ = sshpass13("/Users/$(whoami)/Desktop/.WEB/" + ECIDD + "/com.apple.commcenter.device_specific_nobackup.plist root@localhost:/mnt2/mobile/Media/Downloads/com.apple.commcenter.device_specific_nobackup.plist");
                    _ = shell("rm -rf /Users/$(whoami)/Desktop/.WEB/");
                    
                    
                    
                }else{
                
            _ = sshpass13("/Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/activation_record.plist root@localhost:/mnt1/");
            _ = sshpass13("/Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/IC-Info.sisv root@localhost:/mnt1/");
            _ = sshpass13("/Users/$(whoami)/Desktop/PasscodeActivation/" + ECIDD + "/com.apple.commcenter.device_specific_nobackup.plist root@localhost:/mnt2/mobile/Media/Downloads/com.apple.commcenter.device_specific_nobackup.plist");
                    
                }
        //setting up activation data
        _ = sshpass12("/bin/mv -f /mnt1/activation_record.plist /mnt2/root/");
        _ = sshpass12("/bin/rm -rf /mnt2/mobile/Library/FairPlay");
        _ = sshpass12("/bin/mkdir -p -m 00755 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes");
        
        _ = sshpass12("/bin/mv -f /mnt1/IC-Info.sisv /mnt2/root/");
        _ = sshpass12("/bin/mv -f /mnt2/root/IC-Info.sisv /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/");
        _ = sshpass12("/bin/chmod 00664 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv");
        _ = sshpass12("/usr/sbin/chown -R mobile:mobile /mnt2/mobile/Library/FairPlay");
   
        _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/internal/../ && /bin/mkdir -p activation_records");
        //next
        _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records && /bin/mv -f /mnt2/root/activation_record.plist ./");
        _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records/.. && chmod 755 activation_records");
        _ = sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records/.. && chmod 0664 activation_records/activation_record.plist");
        _ = sshpass12("rm -rf /mnt2/mobile/Library/Logs/");
        
        _ = sshpass12("mv -f /mnt2/mobile/Media/Downloads/com.apple.commcenter.device_specific_nobackup.plist  /mnt2/wireless/Library/Preferences/");
                _ = sshpass13("" + iy + " root@localhost:/mnt1/com.apple.purplebuddy.plist");
               _ = sshpass12("rm -f /mnt2/mobile/Library/Preferences/com.apple.purplebuddy.plist");
             _ = sshpass12("mv -f /mnt1/com.apple.purplebuddy.plist /mnt2/mobile/Library/Preferences/com.apple.purplebuddy.plist && rm -rf /mnt2/mobile/Media/Downloads/com.apple.purplebuddy.plist");
            checkaction();
            checkaction();
            
            let tg2 = self.tg1(tgg:"Nếu một trong các thông báo NG vui lòng kiểm tra lại.");
            let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
            
                BoxShow("\(tg3) \n\nActivated \(check1.stringValue). \n\nNotification \(check2.stringValue). \n\nSignal \(check3.stringValue).", Buttontext: "OK");
                if("\(check1.stringValue)\(check2.stringValue)\(check2.stringValue)" == "OKOKOK"){
                    let tg2 = self.tg1(tgg:"Bạn có muốn chặn OTA không?");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                    
                    DispatchQueue.main.async {
                
                let alert = NSAlert()
                alert.messageText = "\(tg3)"
                alert.addButton(withTitle: "BLOCK")
                alert.addButton(withTitle: "EXIT")
                let response = alert.runModal()

                if response == .alertFirstButtonReturn {
                    self.ota()
                    
                    _ = self.sshpass12("/sbin/reboot");
                    self.exit1();
                } else if response == .alertSecondButtonReturn {
                    _ = self.sshpass12("/sbin/reboot");
                    self.exit1();
                }
                    }
                    }else {
                        _ = self.sshpass12("/sbin/reboot");
                        exit1();
                        
                }
                    // _ = shell("echo \(passssh.stringValue) &>/usr/local/bin/passssh");
                
            
           // performSegue(withIdentifier: "notificationaction", sender: self )
            
            self.deviceDetectionHandler = true
            exit1();
                
    }else {
            self.deviceDetectionHandler = true
        let tg2 = self.tg1(tgg:"THIẾT BỊ KHÔNG TRUY CẬP ĐƯỢC PHẦN VÙNG NGƯỜI VUI LÒNG BOOT LẠI RAMDISK");
        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
        
            BoxShow("\(tg3)", Buttontext:"OK")
        exit1();
    }
}
    
    
   
    
    
    
    func activateHello(){
        
        autossh()
        
       
        self.hienthi.textColor = NSColor.systemRed
            self.hienthi.stringValue = "ACTIVATION HELLO 10%"
        let ECIDD = ecid.stringValue

        makeHTTPRequest(urlString: "https://gsmunlockinfo.org/deviceservices/index.php?ecid=\(ecid.stringValue)") { (responseString, error) in
            let responseString = responseString
            
            print(responseString as Any)
            if responseString == "1" {
                let th1 = Bundle.main.url(forResource: "htools/libs/1", withExtension: "")
               let iy: String = th1!.path
                _ = self.shell("rm -rf /Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + "");
                _ = self.shell("mkdir /Users/$(whoami)/Desktop/HelloActivation/");

              
                
                self.downloadFile(RRL:"https://gsmunlockinfo.org/deviceservices/" + ECIDD + ".zip",FILE:"HelloActivation/" + ECIDD + ".zip"){

                _ = self.shell("unzip -o /Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + ".zip -d /Users/$(whoami)/Desktop/HelloActivation/; rm /Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + ".zip");
                    self.hienthi.textColor = NSColor.systemRed
                        self.hienthi.stringValue = "ACTIVATION HELLO 20%"
                             self.autossh();
                             if(self.sshpass12("'ls /mnt2/containers/Data/'").contains("System")){

                                 _ = self.sshpass13("/Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + "/activation_record.plist root@localhost:/mnt1/");
                                 _ = self.sshpass13("/Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + "/IC-Info.sisv root@localhost:/mnt1/");
                                 _ = self.sshpass13("/Users/$(whoami)/Desktop/HelloActivation/" + ECIDD + "/com.apple.commcenter.device_specific_nobackup.plist root@localhost:/mnt2/mobile/Media/Downloads/com.apple.commcenter.device_specific_nobackup.plist");
                                 _ = self.sshpass12("/bin/rm -f /mnt2/root/activation_record.plist");
                                 self.hienthi.textColor = NSColor.systemRed
                                     self.hienthi.stringValue = "ACTIVATION HELLO 30%"
                                 
                     //setting up activation data
                                 _ = self.sshpass12("/bin/mv -f /mnt1/activation_record.plist /mnt2/root/");
                                 _ = self.sshpass12("/bin/rm -rf /mnt2/mobile/Library/FairPlay");
                                 _ = self.sshpass12("/bin/rm -rf /mnt2/containers/Data/System/*/Library/activation_records");
                                 
                                 _ = self.sshpass12("/bin/mkdir -p -m 00755 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes");
                     
                                 _ = self.sshpass12("/bin/mv -f /mnt1/IC-Info.sisv /mnt2/root/");
                     
                                 _ = self.sshpass12("/bin/mv -f /mnt2/root/IC-Info.sisv /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/");
                                 _ = self.sshpass12("/bin/chmod 00664 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv");
                                 _ = self.sshpass12("/usr/sbin/chown -R mobile:mobile /mnt2/mobile/Library/FairPlay");
                                 _ = self.sshpass12("cd /mnt2/containers/Data/System/*/Library/internal/../ && /bin/mkdir -p activation_records");
                                 self.hienthi.textColor = NSColor.systemRed
                                     self.hienthi.stringValue = "ACTIVATION HELLO 40%"
                                 _ = self.sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records && /bin/mv -f /mnt2/root/activation_record.plist ./");
                                 _ = self.sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records/.. && chmod 755 activation_records");
                                 _ = self.sshpass12("cd /mnt2/containers/Data/System/*/Library/activation_records/.. && chmod 0664 activation_records/activation_record.plist");
                                 _ = self.sshpass12("rm -rf /mnt2/mobile/Library/Logs/");
                                 self.hienthi.textColor = NSColor.systemRed
                                     self.hienthi.stringValue = "ACTIVATION HELLO 60%"
                                 _ = self.sshpass12("mv -f /mnt2/mobile/Media/Downloads/com.apple.commcenter.device_specific_nobackup.plist  /mnt2/wireless/Library/Preferences/");
                                 _ = self.sshpass13("" + iy + " root@localhost:/mnt1/com.apple.purplebuddy.plist");
                                 _ = self.sshpass12("rm -f /mnt2/mobile/Library/Preferences/com.apple.purplebuddy.plist");
                                 _ = self.sshpass12("mv -f /mnt1/com.apple.purplebuddy.plist /mnt2/mobile/Library/Preferences/com.apple.purplebuddy.plist && rm -rf /mnt2/mobile/Media/Downloads/com.apple.purplebuddy.plist");
                                 _ = self.sshpass12("launchctl unload /mnt1/System/Library/LaunchDaemons/com.apple.CommCenter.plist");
                                 DispatchQueue.main.async {
                                     let alert = NSAlert()
                                     alert.messageText = "DELETE Baseband?"
                                     alert.addButton(withTitle: "DELETE")
                                     alert.addButton(withTitle: "NO")
                                     let response = alert.runModal()

                                     if response == .alertFirstButtonReturn {
                                         _ = self.sshpass12("/bin/mv -f /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband2");
                                     } else if response == .alertSecondButtonReturn {
                                        
                                     }
                                     
                                     
                                     
                                     
                                     
                                 
                                     
                                 }
                                 self.hienthi.textColor = NSColor.systemRed
                                     self.hienthi.stringValue = "ACTIVATION HELLO 70%"
                                 self.checkaction();
                                 self.checkaction();
                                 let tg2 = self.tg1(tgg:"Nếu một trong các thông báo NG vui lòng kiểm tra lại.");
                                 let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                                 self.BoxShow("\(tg3) \n\nActivated \(self.check1.stringValue). \n\nNotification \(self.check2.stringValue). \n\nSignal \(self.check3.stringValue).", Buttontext: "OK");
                                 if("\(self.check1.stringValue)\(self.check2.stringValue)\(self.check3.stringValue)" == "OKOKOK"){
                                     let tg2 = self.tg1(tgg:"Bạn có muốn chặn OTA không?");
                                     let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                                     
                                     
                                     DispatchQueue.main.async {
                                     
                                         self.hienthi.textColor = NSColor.systemRed
                                             self.hienthi.stringValue = "ACTIVATION HELLO 80%"
                                         
                                         
                                         
                                 let alert = NSAlert()
                                 alert.messageText = "\(tg3)"
                                 alert.addButton(withTitle: "BLOCK")
                                 alert.addButton(withTitle: "EXIT")
                                 let response = alert.runModal()

                                 if response == .alertFirstButtonReturn {
                                     self.ota()

                                     _ = self.sshpass12("/sbin/reboot");
                                     self.exit1()
                                 } else if response == .alertSecondButtonReturn {
                                     _ = self.sshpass12("/sbin/reboot");
                                     self.exit1()
                                 }
                                     }
                                 }else{
                                     _ = self.sshpass12("/sbin/reboot");
                                     self.exit1()
                                 
                                 }
                                 self.hienthi.textColor = NSColor.systemRed
                                     self.hienthi.stringValue = "ACTIVATION HELLO 100%"
                         self.deviceDetectionHandler = true
                         
                                 let tg7 = self.tg1(tgg:"HELLO SCREEN IDEVICE ĐÃ ĐƯỢC KÍCH HOẠT THÀNH CÔNG!");
                                 let tg4 = tg7!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                                 self.BoxShow("\(tg4)", Buttontext:"OK")
                                 self.exit1()
                             }else{
                                 
                                 
                                 
                                 
                                 
                                 let tg7 = self.tg1(tgg:"THIẾT BỊ KHÔNG TRUY CẬP ĐƯỢC PHẦN VÙNG NGƯỜI DÙNG VUI LÒNG BOOT LẠI RAMDISK");
                                 let tg4 = tg7!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                                
                                 
                                 self.BoxShow("\(tg4)", Buttontext:"OK")
                                 
                                 self.exit1()
                             
                             }
                             
                }
                         
                        } else{
                            let tg7 = self.tg1(tgg:"Không tìm thấy tệp kích hoạt trên máy chủ vui lòng thoát ramdisk và tạo lại");
                            let tg4 = tg7!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                            
                            
                            
                            self.BoxShow("\(tg4)", Buttontext:"OK")
                            
                            
                            
                            self.exit1()
                 
             }
        
        
}
    }
    
    func ota() {
        let th2 = Bundle.main.url(forResource: "htools/libs", withExtension: "")
       let iy1111: String = th2!.path
        _ = sshpass12("rm -rf /mnt2/root/Library/Preferences/com.apple.MobileAsset.plist");
                       
        
        _ = sshpass13("" + iy1111 + "/com.apple.MobileAsset.plist root@localhost:/mnt2/root/Library/Preferences/com.apple.MobileAsset.plist");
                        
                        _ = sshpass12("/bin/chmod 600 /mnt2/root/Library/Preferences/com.apple.MobileAsset.plist");
        _ = sshpass12("mkdir -pv /mnt1/Library/MobileSubstrate/DynamicLibraries");
        _ = sshpass13("" + iy1111 + "/DynamicLibraries root@localhost:/mnt1/Library/MobileSubstrate/DynamicLibraries");
        _ = sshpass12("chmod +x /mnt1/Library/MobileSubstrate/DynamicLibraries/OTADisabler.dylib");
       
        
                        _ = sshpass12("launchctl unload -w /mnt1/Library/MobileSubstrate/DynamicLibraries/com.apple.mobile.obliteration.plist");
                        _ = sshpass12("launchctl unload -w /mnt1/Library/MobileSubstrate/DynamicLibraries/com.apple.mobile.softwareupdated.plist");
                        
                        _ = sshpass12("launchctl unload -w /mnt1/Library/MobileSubstrate/DynamicLibraries/com.apple.OTATaskingAgent.plist");
                        
                       
                        _ = sshpass12("launchctl unload -w /mnt1/Library/MobileSubstrate/DynamicLibraries/com.apple.OTACrachCopier.plist");
                       // _ = sshpass12("launchctl unload /mnt1/System/Library/LaunchDaemons/com.apple.CommCenter.plist");
        _ = sshpass12("rm -rf /mnt1/Library/MobileSubstrate");
    }
    
    
    
    
    func fixsisv(ECIDD:String) {
        
        let documentsUrl1 = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let defaultFileURL = documentsUrl1.appendingPathComponent("PasscodeActivation/\(ECIDD)/activation_record.plist")
        
        do {
            let data = try Data(contentsOf: defaultFileURL)
            let decoder = PropertyListDecoder()
            let i = try decoder.decode(ar.self, from: data)
            
            guard let base64String = String(data: i.FairPlayKeyData, encoding: .utf8) else {
                print("Failed to get base64 string.")
                return
            }
            
            var b64str = base64String.dropLast(24)
            b64str = b64str.dropFirst(26)
            
            print(b64str)
            
            if let decodedData = Data(base64Encoded: String(b64str), options: .ignoreUnknownCharacters) {
                // use the data here
                if decodedData.count == 1140 {
                    print("Filesize check OK!")
  
                }
                let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let destinationUrl = documentsUrl.appendingPathComponent("PasscodeActivation/\(ECIDD)/")
                
                let fileURL = destinationUrl.appendingPathComponent("IC-Info.sisv")
                do {
                    try decodedData.write(to: fileURL)
                    print("File saved at: \(fileURL.path)")
                } catch {
                    print("Failed to save file: \(error)")
                }
            } else {
                print("Failed to decode the base64 string.")
            }
        } catch {
            print("Failed to open file: \(error)")
        }
        
    }
    
    
    struct ar: Codable {
        let FairPlayKeyData:Data
    }
    
    class OnlyNumericFormatter: NumberFormatter {
        override init() {
            super.init()
            self.allowsFloats = false // Disallow floating-point values
            self.minimum = 0 // Set the minimum allowed value to 0
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // chính
    @IBOutlet weak var ver: NSTextField!
    
    @IBOutlet weak var namethietbi: NSTextField!
    
    @IBOutlet weak var ecid: NSTextField!
    
    @IBOutlet weak var chedo: NSTextField!
    
    @IBOutlet weak var ios: NSTextField!
    
    
    @IBOutlet weak var SN: NSTextField!
    
    @IBOutlet weak var copy1: NSButton!
    
    @IBOutlet weak var boxngach: NSBox!
    
    @IBOutlet weak var hienthi: NSTextField!
    
    @IBOutlet weak var boxngach1: NSBox!
    
    @IBOutlet weak var MODEL: NSTextField!
    
    @IBOutlet weak var zalo: NSButton!
    
    @IBOutlet weak var web: NSButton!
    
    @IBOutlet weak var dangky: NSButton!
    
    @IBOutlet weak var ngonngu: NSPopUpButton!
    
    @IBOutlet weak var tickhello: NSButton!
    
    @IBOutlet weak var batdau: NSButton!
    
    @IBOutlet weak var chucnang: NSPopUpButton!
    
    @IBOutlet weak var checkboot: NSButton!
    
    @IBOutlet weak var menu1: NSPopUpButton!
    
    //dfu
    @IBOutlet weak var re: NSButton!
    
    @IBOutlet weak var prophantrawm: NSProgressIndicator!
    
    @IBOutlet weak var ttx: NSTextField!
    @IBOutlet weak var btnStartDFU: NSButton!
    @IBOutlet weak var lblDFUStatus: NSTextField!
    @IBOutlet weak var lblStep1: NSTextField!
        @IBOutlet weak var lblStep2: NSTextField!
        @IBOutlet weak var lblStep3: NSTextField!
        @IBOutlet weak var lblPowerBtn: NSTextField!
        @IBOutlet weak var lblHomeBtn: NSTextField!
    @IBOutlet weak var lblVolumeBtn: NSTextField!
    
    @IBOutlet weak var imgPhone: NSImageView!
    @IBOutlet weak var HIENTHI: NSTextField!
    
    @IBOutlet weak var cpid: NSTextField!
    
    @IBOutlet weak var phantram: NSProgressIndicator!
    
    @IBOutlet weak var exit: NSButton!
    
    @IBOutlet weak var heple: NSButton!
    
    @IBOutlet weak var MODEL1: NSTextField!
    
    @IBOutlet weak var board: NSTextField!
   
    @IBOutlet weak var ramfilel: NSTextField!
    
    @IBOutlet weak var check1: NSTextField!
    
    @IBOutlet weak var check2: NSTextField!
    
    @IBOutlet weak var check3: NSTextField!
    
    
    @IBOutlet weak var checkboot2: NSButton!
    
    
    
    @IBAction func dsd(_ sender: Any) {
        portisClosed()
       
    }
    func createDirectoryIfNotExists(atPath path: String) {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print("Thư mục đã được tạo: \(path)")
            } catch {
                print("Lỗi khi tạo thư mục: \(error.localizedDescription)")
            }
        } else {
            print("Thư mục đã tồn tại: \(path)")
        }
    }
    
    func autossh(){
 
        let mount = """
        #PREBOOT VOLUME DISK
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s3)" == "Preboot" ]]
        then
            /sbin/mount_apfs /dev/disk1s3 /mnt6
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s4)" == "Preboot" ]]
        then
            /sbin/mount_apfs /dev/disk1s4 /mnt6
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s5)" == "Preboot" ]]
        then
            /sbin/mount_apfs /dev/disk1s5 /mnt6
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s6)" == "Preboot" ]]
        then
            /sbin/mount_apfs /dev/disk1s6 /mnt6
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s7)" == "Preboot" ]]
        then
            /sbin/mount_apfs /dev/disk1s7 /mnt6
        fi
        #xART VOLUME DISK
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s3)" == "xART" ]]
        then
            /sbin/mount_apfs /dev/disk1s3 /mnt7
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s4)" == "xART" ]]
        then
            /sbin/mount_apfs /dev/disk1s4 /mnt7
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s5)" == "xART" ]]
        then
            /sbin/mount_apfs /dev/disk1s5 /mnt7
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s6)" == "xART" ]]
        then
            /sbin/mount_apfs /dev/disk1s6 /mnt7
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s7)" == "xART" ]]
        then
            /sbin/mount_apfs /dev/disk1s7 /mnt7
        fi
        #HARDWARE VOLUME DISK
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s3)" == "Hardware" ]]
        then
            /sbin/mount_apfs /dev/disk1s3 /mnt4
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s4)" == "Hardware" ]]
        then
            /sbin/mount_apfs /dev/disk1s4 /mnt4
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s5)" == "Hardware" ]]
        then
            /sbin/mount_apfs /dev/disk1s5 /mnt4
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s6)" == "Hardware" ]]
        then
            /sbin/mount_apfs /dev/disk1s6 /mnt4
        fi
        if [[ "$(/System/Library/Filesystems/apfs.fs/apfs.util -p /dev/disk1s7)" == "Hardware" ]]
        then
            /sbin/mount_apfs /dev/disk1s7 /mnt4
        fi
        /usr/libexec/seputil --gigalocker-init
        /usr/sbin/nvram oblit-inprogress=1 rev=2
        /usr/libexec/seputil --load $(find /mnt6 -iname sep-firmware.img4)
        /usr/sbin/nvram -d oblit-inprogress && /usr/sbin/nvram -d oblit-inprogres
        /sbin/mount_apfs /dev/disk1s2 /mnt2
"""
        let bootram = menu1.titleOfSelectedItem!
        if (bootram).contains("BOOT16.4.1<") || (bootram).contains("BOOT16.5>") || (bootram).contains("BOOT16.4.1<P") || (bootram).contains("BOOT16.5>P2") {
                    //_ = self.sshpass12("\(mount)");
                   // _ = self.sshpass12("\(mount)");
                    _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
                    _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
                    _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s6 /mnt6");
                    _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s3 /mnt7");
                    _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s5 /mnt4");
                    _ = self.sshpass12("/usr/libexec/seputil --gigalocker-init");
                    _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=1 rev=2");
            _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=1 rev=2");
            _ = self.sshpass12("/usr/libexec/seputil --load $(find /mnt6 -iname sep-firmware.img4)");
            _ = self.sshpass12("/usr/sbin/nvram -d oblit-inprogress && /usr/sbin/nvram -d oblit-inprogres");
            _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s2 /mnt2");
            
                
                if(self.sshpass12("'ls /mnt2/containers/Data/'").contains("System")){
                    let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG OK");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                    
                    
                    
                    self.hienthi.stringValue = "\(tg3)"
                   }
                else {
                    
                    _ = self.sshpass12("/sbin/reboot");
                   
                    let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG NG");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                    self.hienthi.stringValue = "\(tg3)"
                    self.BoxShow("\(tg3)", Buttontext: "OK")
                    self.deviceDetectionHandler = true
                    exit1()
                }
                
                
            }else{
                
                if "\(bootram)" == "BOOT12"{
   
                        _ = self.sshpass12("bash /usr/bin/mount_root");
                        _ = self.sshpass12("bash /usr/bin/mount_data");
                        _ = self.sshpass12("bash /usr/bin/mount_data2");
                  
                       
                    
                    if(self.sshpass12("'ls /mnt2/containers/Data/'").contains("System")){
                        let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG OK");
                        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                        
                        
                        
                        self.hienthi.stringValue = "\(tg3)"
                       }
                    else {
                        
                        _ = self.sshpass12("/sbin/reboot");
                       
                        let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG NG");
                        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                        self.hienthi.stringValue = "\(tg3)"
                        self.BoxShow("\(tg3)", Buttontext: "OK")
                        self.deviceDetectionHandler = true
                        exit1()
                    }
                    
                    
                }
                
                
                
                
                
                
        _ = self.sshpass12("mount_filesystems");
        _ = self.sshpass12("mount_filesystems");
                _ = self.sshpass12("mount_filesystems");
                
                
                
                
                
                if(self.sshpass12("'ls /mnt2/containers/Data/'").contains("System")){
                    let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG OK");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                    
                    
                    self.hienthi.stringValue = "\(tg3)"
                    
                    
                   }
                else {
                   
                    _ = self.sshpass12("/sbin/reboot");
                    let tg2 = self.tg1(tgg:"SSH MOUNT PHÂN VÙNG DỮ LIỆU NGƯỜI DÙNG NG");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                    
                    
                    self.hienthi.stringValue = "\(tg3)"
                    self.BoxShow("\(tg3)", Buttontext: "OK")
                    self.deviceDetectionHandler = true
                    exit1()
                }
            }
        
            
    }
    static func getCurrentAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return ""
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdateManager.checkForUpdates();
        let currentVersion = ViewController.getCurrentAppVersion()
        
        ver.stringValue = "Ver \(currentVersion)";
       portisClosed()
        deviceDetectionHandler = true
        deviceDetectiondfu = false
        devicedfu = false
        let username = NSUserName()
        
        let directoryPath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles"
        let directoryPath1 = "/Users/\(username)/Desktop/.BYPASSMDM"
        
        createDirectoryIfNotExists(atPath: directoryPath);
        createDirectoryIfNotExists(atPath: directoryPath1);
        grantWritePermissionToDirectory()
        grantWritePermissionToDirectory1()
        self.ngonngu.removeAllItems()
        self.ngonngu.addItems(withTitles: ["VN", "EN"]);
       
        usbWatcher1 = USBWatcher(delegate: self)
        
        
        
        
        // Drawing code here.
    }
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    /*override func viewDidAppear() {
        libmdutil().register()
    }*/
    @IBAction func hello(_ sender: Any) {
        if self.tickhello.state == .on {
            self.tickhello.title = "BYPASS HELLO"
            
        }
        if self.tickhello.state == .off {
            self.tickhello.title = "BYPASS PASSCODE"
            
        }
    }
    
    
    @IBAction func dangky(_ sender: Any) {
        let serimac2 = getSerialNumber()!;
        checkapimac { success in
            if success {
                self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/panel/login111.php?serialmac=\(serimac2)&ecid=\(self.ecid.stringValue)") { (responseString, error) in
                    
                    DispatchQueue.main.async {
                        self.BoxShow("\(String(describing: responseString))", Buttontext:"OK")
                        self.dangky.isHidden = true
                    }
                    
                }
            }
            
            else{
                let alert = NSAlert()
                alert.messageText = "Vui lòng chọn kênh thanh toán:"
                alert.addButton(withTitle: "Thanh toán online")
                alert.addButton(withTitle: "Đăng nhập để thanh toán")
                alert.addButton(withTitle: "Thoát")

                // Tạo NSTextField
                let label = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 160))
                label.stringValue = "Thanh toán online: Vui lòng sử dụng các dịch vụ ngân hàng để quét mã QR để thanh toán. Với giá 150.000 VND \n \nĐăng nhập để thanh toán: Vui lòng sử dụng tài khoản của web để đăng nhập và đăng ký."
                label.isEditable = false
                label.isBezeled = false
                label.backgroundColor = NSColor.clear

                // Thiết lập NSTextField là accessory view cho alert
                alert.accessoryView = label

                let response = alert.runModal()

                if response == .alertFirstButtonReturn {
                    let newWindowController = NewWindowController(urlString: "https://gsmunlockinfo.org/panel/VietQR.php?ecid=\(self.ecid.stringValue)")
                    newWindowController.showWindow(nil)
                } else if response == .alertSecondButtonReturn {
                    let newWindowController = NewWindowController(urlString: "https://gsmunlockinfo.org/panel/")
                    newWindowController.showWindow(nil)
                }
                
                
                
                
                 
                
               
                
                
                
            }
            
            
            
        }
        
    }
    func openURLInNewWindow(urlString: String) {
            let newWindowController = NewWindowController(urlString: urlString)
            newWindowController.showWindow(nil)
        }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Lỗi khi tải trang web: \(error.localizedDescription)")
        }

    
    
    
    @IBAction func copy(_ sender: Any) {
        let value = ecid.stringValue
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString("\(value)", forType: .string)
        let tg2 = tg1(tgg:"Đã copy thành công ECID:");
        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
        
        BoxShow("\(tg3)\(value)", Buttontext: "OK");
    }
    
    @IBAction func g(_ sender: Any) {
        
        
        let th1 = Bundle.main.url(forResource: "htools/libs/1", withExtension: "")
       let iy: String = th1!.path
        if let resourceURL = Bundle.main.url(forResource: "htools/libs/iproxy", withExtension: nil) {
            let iproxyPath = resourceURL.path
            
            
            
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = [iproxyPath, "2222", "44"]
            let pipe = Pipe()
            task.standardOutput = pipe
            
            task.launch()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                print("iproxy output: \(output)")
                
            }
            
            
            
        } else {
            print("Failed to locate iproxy resource file.")
        }
        
        
        
        _ = self.sshpass13("" + iy + " root@localhost:/private/var/mobile/Library/Preferences/com.apple.purplebuddy.plist");
        
        
        
        
        /*
        let linh = actifile() // Capture the output once
        print(linh)
        
        let ba = encodeBase64(string: linh) // Reuse the captured output
        print(ba)
        
        guard let url = URL(string: "https://gsmunlockinfo.org/deviceservices/deviceActivation3.php") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("true", forHTTPHeaderField: "Check") // Update if necessary
        let bodyParameters = "\(ba)"
        if let postData = bodyParameters.data(using: .utf8) {
            request.addValue(String(postData.count), forHTTPHeaderField: "Content-Length")
            request.httpBody = postData
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Error: \(error.localizedDescription)")
                    self.BoxShow("Error: \(error.localizedDescription)", Buttontext: "OK")
                }
            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("Response: \(responseString)")
                    self.BoxShow(responseString, Buttontext: "OK")
                }
            }
        }
        task.resume() // Start the network task
        */
    }
    
    @IBAction func batdau(_ sender: Any) {
        let tg = self.chucnang.titleOfSelectedItem!;
        let HIENTHI = self.HIENTHI.stringValue;
        let tichhell = self.tickhello.state
        self.checkapi { success in
            if success {
                
                
                if (tg).contains("BOOT RAMDISK"){
                    if tichhell == .on {
                        
                        
                        let tg1 = self.ngonngu.titleOfSelectedItem!
                        let ECIDD = self.ecid.stringValue
                        
                        self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/deviceservices/deviceActivation.php?sn=" + self.DeviceInfo("SerialNumber") + "&udid=" + self.DeviceInfo("UniqueDeviceID") + "&ucid=" + self.DeviceInfo("UniqueChipID") + "&pt=" + self.DeviceInfo("ProductType") + "&wf=\(self.DeviceInfo1("WiFiAddress"))&bl=\(self.DeviceInfo1("BluetoothAddress"))&ecid=" + ECIDD + "&tg=\(tg1)") { (responseString, error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Error: \(error)")
                                } else if let responseString = responseString {
                                    self.BoxShow("" + responseString + "", Buttontext: "OK");
                                    
                                }
                            }
                        }
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                    if(HIENTHI).contains("Normal"){
                        
                        
                        
                        
                        self.deviceDetectionHandler = false
                        self.deviceDetectiondfu = true
                        self.devicedfu = true
                        
                        self.portisClosed()
                        self.dfuhello()
                        DispatchQueue.main.async {
                            self.re.isHidden = false
                        }
                        self.lblStep1.stringValue = ""
                        self.lblStep2.stringValue = ""
                        self.lblStep3.stringValue = ""
                        self.lblPowerBtn.stringValue = ""
                        self.lblHomeBtn.stringValue = ""
                        self.lblVolumeBtn.stringValue = ""
                        self.lblDFUStatus.stringValue = "Please put your device into Recovery mode. Select 'go to Recovery' to enter Recovery."
                        self.re.title = "go to Recovery"
                        self.btnStartDFU.title = "EXIT"
                        
                    }
                    if(HIENTHI).contains("Recovery"){
                        
                        DispatchQueue.main.async {
                            self.deviceDetectionHandler = false
                            self.deviceDetectiondfu = true
                            self.portisClosed()
                            self.dfuOpened()
                            let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                            let irecovery: String = partyPath1!.path
                            
                            
                            self.cpid.stringValue = self.shell("" + irecovery + " -q | grep -w CPID | awk '{printf $NF}'");
                            
                            self.HIENTHI.stringValue = self.iRecoveryInfo("MODE");
                            self.recoOpened1()
                            
                            
                            self.btnStartDFU.isHidden = false
                            
                            self.recoOpened1()
                            self.btnStartDFU.title = "START"
                            self.checkid()
                        }
                    }
                }
                //ramdisk
                if(tg).contains("BLOCK OTA"){
                    self.deviceDetectionHandler = true
                    
                    self.hienthi.stringValue = "start blocking updates"
                    let partyPath1 = Bundle.main.url(forResource: "/htools/libs/idevicebackup", withExtension: "")
                    let directoryURL: String = partyPath1!.path
                    if let resourceURL = Bundle.main.url(forResource: "htools/libs/idevicebackup/idevicebackup", withExtension: nil) {
                        let idevicebackupPath: String = resourceURL.path
                        let task = Process()
                        
                        // Set the launch path to the idevicebackup binary
                        task.launchPath = idevicebackupPath
                        
                        // Set the arguments for the task
                        task.arguments = [
                            "--source",
                            "e80dd432a1170d6f76c2c9349f84739c68932dc5",
                            "restore",
                            "--system",
                            "--settings",
                            "--reboot",
                            "\(directoryURL)"
                        ]
                        
                        let pipe = Pipe()
                        task.standardOutput = pipe
                        task.standardError = pipe
                        
                        task.launch()
                        
                        let data = pipe.fileHandleForReading.readDataToEndOfFile()
                        if let output = String(data: data, encoding: .utf8) {
                            print("Output: \(output)")
                        }
                        
                        task.waitUntilExit()
                        print("Blocking successfully")
                        // If you want to update UI elements, make sure to do it on the main thread
                        DispatchQueue.main.async {
                            self.hienthi.stringValue = "Blocking successfully"
                            self.BoxShow("Blocking successfully", Buttontext: "OK")
                        }
                    } else {
                        print("File not found.")
                    }
                }
                if(tg).contains("CHECK LOCK"){
                    self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/AlbertSimlockCarrier/Check/Albert-Carrier-Check.php?imei=\(self.DeviceInfo1("InternationalMobileEquipmentIdentity"))&sn=\(self.DeviceInfo("SerialNumber"))&imei2=\(self.DeviceInfo1("InternationalMobileEquipmentIdentity2"))") { (responseString, error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error: \(error)")
                            } else if let responseString = responseString {
                                self.BoxShow(" \(responseString)", Buttontext: "OK")
                                
                                
                            }
                        }
                    }
                    
                }
                
                
                
                    
                    
                    
                    
                    
                    
                    if(tg).contains("TẠO TUỲ CHỈNH SN"){
                        
                
                        guard let url = URL(string: "https://gsmunlockinfo.org/deviceservices/deviceActivation3.php") else {
                            print("Invalid URL")
                            return
                        }
                        
                        var request = URLRequest(url: url)
                        request.httpMethod = "POST"
                        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.addValue("", forHTTPHeaderField: "Check") // Thêm header 'Check'
                        let bodyParameters = "data=\(self.encodeBase64(string: "\(self.actifile())"))"
                        request.httpBody = bodyParameters.data(using: .utf8)
                        
                        _ = URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                            } else if let data = data, let responseString = String(data: data, encoding: .utf8) {
                                print("Response: \(responseString)")
                                self.BoxShow("" + responseString + "", Buttontext: "OK");
                            }
                        }
                    }
                
                
            
                    
                    
                    
                    if(tg).contains("BACKUP PASSCODE"){
                        self.checkbackup();
                        self.checkbackup();
                        let check33 = "\(self.check1.stringValue)\(self.check2.stringValue)\(self.check2.stringValue)";
                        if("\(check33)" == "OKOKOK"){
                            let tg2 = self.tg1(tgg:"Phát hiện bản sao lưu đã có trên pc bạn muốn ghi đè lên bản sao lưu không.?");
                            let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");

                            let alert = NSAlert()
                            alert.messageText = "\(tg3)"
                            alert.addButton(withTitle: "YES")
                            alert.addButton(withTitle: "NO")
                            let response = alert.runModal()
                            if response == .alertFirstButtonReturn {
                                self.autossh()
                                self.backupPasscode()
                                
                        } else if response == .alertSecondButtonReturn {
                            _ = self.sshpass12("/sbin/reboot");
                            self.deviceDetectionHandler = true
                            
                        }
                            
                            
                        }else{
                                                  }
                    }
                    if(tg).contains("ACTIVATION PASSCODE"){
                        self.deviceDetectionHandler = false
                        self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/backup/check.php?ecid=\(self.ecid.stringValue)") { (responseString, error) in
                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Error: \(error)")
                                } else if let responseString = responseString {
                                    if responseString == "1" {
                                        let alert = NSAlert()
                                        alert.messageText = "Phát hiện bản sao lưu trên hệ thống web. Bạn muốn kích hoạt máy bằng bản sao lưu của WEB hoặc bản sao lưu được lưu trong PC:"
                                        alert.addButton(withTitle: "Web")
                                        alert.addButton(withTitle: "PC")
                                        let response = alert.runModal()
                                        
                                        if response == .alertFirstButtonReturn {
                                            _ = self.shell("mkdir /Users/$(whoami)/Desktop/.WEB/");
                                            self.hienthi.stringValue = "DOWNLOAD ACTIVATION"
                                            self.downloadFile(RRL:"https://gsmunlockinfo.org/backup/\(self.ecid.stringValue).zip",FILE:".WEB/\(self.ecid.stringValue).zip"){
                                                sleep(4);
                                                self.hienthi.stringValue = "UNZIP ACTIVATION"
                                                _ = self.shell("unzip -d /Users/$(whoami)/Desktop/.WEB/ /Users/$(whoami)/Desktop/.WEB/\(self.ecid.stringValue).zip; rm /Users/$(whoami)/Desktop/.WEB/\(self.ecid.stringValue).zip");
                                                self.web.stringValue = "web"
                                                self.autossh()
                                                self.activatePasscode()
                                                self.deviceDetectionHandler = true
                                                
                                            }
                                        } else if response == .alertSecondButtonReturn {
                                            self.autossh()
                                            self.activatePasscode()
                                            self.deviceDetectionHandler = true
                                        }
                                    } else {
                                        self.autossh()
                                        self.activatePasscode()
                                        self.deviceDetectionHandler = true
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                    
                    if(tg).contains("ReBoot"){
                        DispatchQueue.main.async {
                            self.hienthi.stringValue = "ReBooting...."
                        }
                        self.portisClosed()
                        _ = self.sshpass12("/sbin/reboot");
                        self.deviceDetectionHandler = true
                        self.BoxShow("ReBoot ok", Buttontext: "OK")
                        self.exit1()
                        
                    }
                    if(tg).contains("BYPASS CHECKRA1N"){
                        self.BoxShow("Hiện tại Bypass checkra1n chỉ hỗ trợ bypass có tín hiệu từ ios 12-14.5  ", Buttontext: "OK")
                        
                        
                        
                        self.CHECKRA1N()
                    }
                    if(tg).contains("GSM Signal"){
                        let partyPath1 = Bundle.main.url(forResource: "htools/libs/newUtils", withExtension: "tar")
                        let newUtils: String = partyPath1!.path
                        let partyPath2 = Bundle.main.url(forResource: "htools/libs/MobileSubstrate", withExtension: "lzma")
                        let MobileSubstrate: String = partyPath2!.path
                        let partyPath3 = Bundle.main.url(forResource: "htools/libs/ideviceactivation", withExtension: "")
                        let ideviceactivation: String = partyPath3!.path
                        self.IProxy();
                        if(self.sshpass12("'echo done'").contains("done")){
                            
                        _ = self.sshpass12("'mount -o rw,union,update /'");
                        
                        
                        _ = self.sshpass13("\(newUtils) root@localhost:/./");
                        _ = self.sshpass12("'tar -xvf /./newUtils.tar -C /./'");
                        _ = self.sshpass12("'rm /./newUtils.tar'");
                        _ = self.sshpass12("'chmod -R 755 /bin /usr/bin /sbin'");
                        
                        _ = self.sshpass12("'Clean'");
                        _ = self.sshpass13("\(MobileSubstrate) root@localhost:/./");
                        
                        _ = self.sshpass12("'InstallSubstrate'");
                        _ = self.sshpass12("'PrepareActivation'");
                   
                        
                        
                        self.PairDevice();
                       _ = self.shell("\(ideviceactivation) activate -d -s https://gsmunlockinfo.org/deviceservices/ActivateDevice.php");
                        self.makeHTTPRequest(urlString: "https://gsmunlockinfo.org/deviceservices/\(self.SN.stringValue)/Wildcard.der") { (responseString, error) in
                            DispatchQueue.main.async {
                                if let responseString = responseString {
                                    _ = self.sshpass12("echo \(responseString)&>/ticket");
                                    
                                }
                            }
                            
                        }
                        _ = self.sshpass12("'plutil -create /var/wireless/Library/Preferences/com.apple.commcenter.device_specific_nobackup.plist'");
                        _ = self.sshpass12("'FastEditCenter'");
                        _ = self.sshpass12("'activation_record'");
                        _ = self.sshpass12("rm /Library/MobileSubstrate/DynamicLibraries/*'");
                        
                        _ = self.sshpass12("'ldrestart'");
                        if(self.DeviceInfo("ActivationState") != "Unactivated")
                        {
                            self.BoxShow("Successfully Activate Device!", Buttontext: "DEVICE ACTIVATED")
                        }
                        else{
                            self.BoxShow("Upss! Sorry your device is unactivated, try again", Buttontext: "ACTIVATION FAILED")
                        }
                            
                           }
                        else {
                            
                            
                           
                            
                            self.BoxShow("Vui lòng JB bằng checkra1n trước khi bypass", Buttontext: "OK")
                            self.deviceDetectionHandler = true
                            self.exit2()
                        }
                            
                    //setting up activation dat
                        self.exit2()
                        
                    }
                    if(tg).contains("Bypass MEID (NS)"){
                        
                        
                        
                        
                        
                        
                        
                        self.exit2()
                    }
                   
                    if(tg).contains("BYPASS MDM"){
                        self.deviceDetectionHandler = true

                        // Lấy tên người dùng hiện tại
                      //  let UDID = self.DeviceInfo("UniqueDeviceID");
                        
                        self.hienthi.stringValue = "start blocking mdm";
                        self.MODEL1.stringValue = self.DeviceInfo("UniqueDeviceID");
                        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(self.DeviceInfo("UniqueDeviceID")).zip/");
                        
                        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/ffe2017db9c5071adfa1c23d3769970f7524a9d4");
                        
                        self.downloadFileFromURL(urlString: "https://gsmunlockinfo.org/MDM/index.php?ecid=\(self.ecid.stringValue)&pt=\(self.MODEL.stringValue)&serial=\(self.DeviceInfo("SerialNumber"))&uuid=\(self.DeviceInfo("UniqueDeviceID"))&ime=\(self.DeviceInfo("InternationalMobileEquipmentIdentity"))&ver=\(self.DeviceInfo("ProductVersion"))&build=\(self.DeviceInfo("BuildVersion"))&type=\(self.DeviceInfo("ProductType"))");
  
                        let partyPath1 = Bundle.main.url(forResource: "/htools/libs/idevicebackup", withExtension: "")
                        let directoryURL: String = partyPath1!.path
                        if let resourceURL = Bundle.main.url(forResource: "htools/libs/idevicebackup/idevicebackup", withExtension: nil) {
                            let idevicebackupPath: String = resourceURL.path
                            let task = Process()
                            
                            // Set the launch path to the idevicebackup binary
                            task.launchPath = idevicebackupPath
                            
                            // Set the arguments for the task
                            task.arguments = [
                                "--source",
                                "ffe2017db9c5071adfa1c23d3769970f7524a9d4",
                                "restore",
                                "--system",
                                "--settings",
                                "--reboot",
                                "\(directoryURL)"
                            ]
                            
                            let pipe = Pipe()
                            task.standardOutput = pipe
                            task.standardError = pipe
                            
                            task.launch()
                            
                            let data = pipe.fileHandleForReading.readDataToEndOfFile()
                            if let output = String(data: data, encoding: .utf8) {
                                print("Output: \(output)")
                            }
                            
                            task.waitUntilExit()
                            print("Blocking successfully")
                            // If you want to update UI elements, make sure to do it on the main thread
                            DispatchQueue.main.async {
                                self.hienthi.stringValue = "Blocking successfully"
                                self.BoxShow("Blocking successfully", Buttontext: "OK")
                            }
                        } else {
                            print("File not found.")
                        }
                        
                        
                        
                        
                        
                        
                        
                        
                    }
                    if(tg).contains("RAMDISK MDM"){
                        let th2 = Bundle.main.url(forResource: "htools/libs", withExtension: "")
                        let iy1111: String = th2!.path
                        
                        
                        DispatchQueue.main.async {
                            self.hienthi.stringValue = "MDM"
                        }
                        self.autossh()
                        DispatchQueue.main.async {
                            self.hienthi.stringValue = "MDM BYPASS...."                }
                        _ = self.sshpass13("" + iy1111 + "/iFix.plist root@localhost:/mnt2/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist");
                        
                        
                        
                        _ = self.sshpass12("/sbin/reboot");
                        self.exit1()
                        
                    }
                    
                    
                    
                    
                    
                    
                    if(tg).contains("FactoryReset"){
                        _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=5 sync");
                        _ = self.sshpass12("/usr/sbin/nvram oblit-inprogress=5");
                        self.BoxShow("FactoryReset ok", Buttontext: "OK")
                    }
                    if(tg).contains("Fix Notification"){
                        self.autossh()
                        
                        let documentsUrl1 = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        let defaultFileURL1 = documentsUrl1.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)/activation_record.plist")
                        
                        
                        
                        
                        do {
                            let data = try Data(contentsOf: defaultFileURL1)
                            let decoder = PropertyListDecoder()
                            let i = try decoder.decode(ar.self, from: data)
                            
                            guard let base64String = String(data: i.FairPlayKeyData, encoding: .utf8) else {
                                print("Failed to get base64 string.")
                                return
                            }
                            
                            var b64str = base64String.dropLast(24)
                            b64str = b64str.dropFirst(26)
                            
                            print(b64str)
                            
                            if let decodedData = Data(base64Encoded: String(b64str), options: .ignoreUnknownCharacters) {
                                // use the data here
                                if decodedData.count == 1140 {
                                    print("Filesize check OK!")
                                }
                                let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                let defaultFileURL = documentsUrl.appendingPathComponent("PasscodeActivation/\(self.ecid.stringValue)/")
                                let fileURL = defaultFileURL.appendingPathComponent("IC-Info.sisv")
                                do {
                                    try decodedData.write(to: fileURL)
                                    print("File saved at: \(fileURL.path)")
                                } catch {
                                    print("Failed to save file: \(error)")
                                }
                            } else {
                                print("Failed to decode the base64 string.")
                            }
                        } catch {
                            print("Failed to open file: \(error)")
                        }
                        _ = self.sshpass13("/Users/$(whoami)/Desktop/PasscodeActivation/\(self.ecid.stringValue)/IC-Info.sisv root@localhost:/mnt1/");
                        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/PasscodeActivation/FIX");
                        _ = self.sshpass12("/bin/rm -rf /mnt2/mobile/Library/FairPlay");
                        _ = self.sshpass12("/bin/mkdir -p -m 00755 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes");
                        _ = self.sshpass12("/bin/mv -f /mnt1/IC-Info.sisv /mnt2/root/");
                        
                        _ = self.sshpass12("/bin/mv -f /mnt2/root/IC-Info.sisv /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/");
                        _ = self.sshpass12("/bin/chmod 00664 /mnt2/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv");
                        _ = self.sshpass12("/usr/sbin/chown -R mobile:mobile /mnt2/mobile/Library/FairPlay");
                        
                        
                        self.BoxShow("Fix Notification", Buttontext: "OK")
                    }
                    if(tg).contains("ON Baseband"){
                        self.autossh()
                        _ = self.sshpass12("/bin/mv -f /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband2 /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband");
                        self.BoxShow("ON ok", Buttontext: "OK")
                    }
                    if(tg).contains("OFF Baseband"){
                        self.autossh()
                        
                        
                        
                        _ = self.sshpass12("/bin/mv -f /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband /mnt6/$(cat /mnt6/active)/usr/local/standalone/firmware/Baseband2");
                        self.BoxShow("OFF ok", Buttontext: "OK")
                    }
                    if(tg).contains("Check IOS"){
                        let bootram = self.menu1.titleOfSelectedItem!
                        
                        if (bootram).contains("BOOT16.4.1<") || (bootram).contains("BOOT16.5>") || (bootram).contains("BOOT16.4.1<P") || (bootram).contains("BOOT16.5>P2") {
                            _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
                            _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
                            
                        }else{
                            _ = self.sshpass12("/sbin/mount_apfs /dev/disk0s1s1 /mnt1");
                            _ = self.sshpass12("/sbin/mount_apfs /dev/disk0s1s1 /mnt1");
                            
                            
                        }
                        let sshData = self.sshpass12("cat /mnt1/System/Library/CoreServices/SystemVersion.plist");
                        
                        
                        let data = sshData.data(using: .utf8)
                        
                        if let data = data,
                           let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                           let productVersion = plist["ProductVersion"] as? String {
                            self.ios.stringValue = "\(productVersion)"
                            print(productVersion)
                            self.BoxShow("iOS: \(productVersion)", Buttontext: "OK")
                        }
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                    
                
                    
                    
                    
                    
                } else {
                    return
                }
            
        }
    }
    
    @IBAction func re(_ sender: Any) {
        self.re.isHidden = true
        self.re.title = ""
        
        let partyPath1 = Bundle.main.url(forResource: "htools/libs/ideviceenterrecovery", withExtension: "")
        let ideviceenterrecovery: String = partyPath1!.path
        let partyPath = Bundle.main.url(forResource: "htools/libs/ideviceinfo", withExtension: "")
        let ideviceinfo: String = partyPath!.path
        
        
        _ = self.shell("" + ideviceenterrecovery + " $(" + ideviceinfo + " -k UniqueDeviceID)");
        
        if (HIENTHI.stringValue == "Recovery"){
            
            recoOpened1()
            
            
        }
        
        
    }
    
  
    
    
    func checkramfile(url1:String){
            makeHTTPRequest(urlString: "\(url1)") { (responseString, error) in
                DispatchQueue.main.async {
                        if let error = error {
                            print("Error: \(error)")
                        } else if let responseString = responseString {
                            self.ramfilel.stringValue = responseString
                        }
                    }
        }
        
        }
    func checkramfile1(url1: String) {
        makeHTTPRequest(urlString: "\(url1)") { (responseString, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error)")
                } else if let responseString = responseString {
                    self.ramfilel.stringValue = responseString
                }
            }
        }
    }
    
    
    
    
   //kiểm tra ramdisk vầtir ramdisk về
    func checkrddownload() {
        deviceDetectionHandler = false
        
        DispatchQueue.main.async {
        
            self.portisClosed()
        
        let URL = "https://gsmunlockinfo.org/BOOT/index.php?ecid=\(self.ecid.stringValue)&boot=";
            if(self.iRecoveryInfo("MODE") != "DFU"){
            let tg2 = self.tg1(tgg:"Thiết bị chưa vào DFU");
            let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
            self.hienthi.stringValue = "\(tg3)"
            //self.BoxShow("\(tg3)", Buttontext: "OK")
                self.deviceDetectionHandler = true
      
            return
        }
            if(self.iRecoveryInfo("MODE") == "DFU"){
                let bootram = self.menu1.titleOfSelectedItem!

                self.portisClosed()
                sleep(10);
                self.board.stringValue = self.iRecoveryInfo("MODEL");
               
                
                if "\(bootram)" == "BOOT12" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)12"
                    self.download(urlS: "\(URL)IOS12")
                }
                if "\(bootram)" == "BOOT13" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)12"
                    self.download(urlS: "\(URL)IOS13")
                }
                if "\(bootram)" == "BOOT14" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)12"
                    self.download(urlS: "\(URL)IOS14")
                }

                if "\(bootram)" == "BOOT15" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)15"
                    self.download(urlS: "\(URL)IOS15")
                }
                if "\(bootram)" == "BOOT15P" {
                    self.MODEL1.stringValue = "\(self.board.stringValue)15P"
                    self.download(urlS: "\(URL)IOS15P")
                }
                
                if "\(bootram)" == "BOOT16.4.1<" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)16"
                    self.download(urlS: "\(URL)IOS16.4")
                }
                if "\(bootram)" == "BOOT16.5>" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)16S"
                    self.download(urlS: "\(URL)IOS16.5")
                }
                if "\(bootram)" == "BOOT17" {
                    self.startGasterProcesses();
                    self.MODEL1.stringValue = "\(self.board.stringValue)17S"
                    self.download(urlS: "\(URL)IOS17")
                }
                if "\(bootram)" == "BOOT16.4.1<P" {
                    self.MODEL1.stringValue = "\(self.board.stringValue)16P"
                    self.download(urlS: "\(URL)IOS16P")
                }
                if "\(bootram)" == "BOOT16.5>P2" {
                    self.MODEL1.stringValue = "\(self.board.stringValue)16P2"
                    self.download(urlS: "\(URL)IOS16P2")
                }
            }
            
        }
    }
    func downloadok(){
        let bootram = self.menu1.titleOfSelectedItem!
        let brd = ["BOOT12", "BOOT15P", "BOOT16.4.1<P", "BOOT16.5>P2"]
        portisClosed()
        let boardid =  self.board.stringValue
        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)");
        
        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/__MACOSX");
        
        
        let URL3 = "https://gsmunlockinfo.org/logo";
        let fileManager = FileManager.default
        let username = NSUserName() // Lấy tên người dùng hiện tại
        let model1Value = MODEL1.stringValue
        let filePath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(model1Value).zip"
        if fileManager.fileExists(atPath: filePath) {
            let username = NSUserName() // Lấy tên người dùng hiện tại
            
            let model1Value = MODEL1.stringValue
            
            let sourcePath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(model1Value).zip"
            let destinationPath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/" // Điểm đến thư mục giải nén
            
            
            if let sourceURL = URL(string: "file://\(sourcePath)"), let destinationURL = URL(string: "file://\(destinationPath)") {
                unzipFile(at: sourceURL, to: destinationURL)
            } else {
                exit1()
                
                print("Lỗi: Không thể tạo URL từ đường dẫn.")
            }
            if brd.contains(bootram) {
                    
                }
                else{
                    
                    self.downloadFile(RRL:"\(URL3)/\(self.cpid.stringValue).img4",FILE:".hrdeciddata/ramdiskFiles/\(self.board.stringValue)/logo.img4"){
                        
                        
                    }
                    
                    
                }
            sleep(5);
            self.boot();
        }
    }
    func unzipFile(at sourceURL: URL, to destinationURL: URL) {
        do {
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.unzipItem(at: sourceURL, to: destinationURL)
            print("Đã giải nén tập tin thành công.")
        } catch {
            
            print("Lỗi: \(error.localizedDescription)")
            exit1()
            
            
        }
    }
    func download(urlS:String){
        
        let brd = ["BOOT12", "BOOT15P", "BOOT16.4.1<P", "BOOT16.5>P2"]
        DispatchQueue.main.async {
            let bootram = self.menu1.titleOfSelectedItem!
            
            self.portisClosed()
            let URL3 = "https://gsmunlockinfo.org/logo";
            let boardid =  self.board.stringValue
           
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)");
            
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/__MACOSX");
            
            let fileManager = FileManager.default
            let username = NSUserName() // Lấy tên người dùng hiện tại
            let model1Value = self.MODEL1.stringValue
            let filePath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(model1Value).zip"
            if fileManager.fileExists(atPath: filePath) {
                let sourcePath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(model1Value).zip"
                let destinationPath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/" // Điểm đến thư mục giải nén
                
                if let sourceURL = URL(string: "file://\(sourcePath)"), let destinationURL = URL(string: "file://\(destinationPath)") {
                    self.unzipFile(at: sourceURL, to: destinationURL)
                } else {
                    
                    print("Lỗi: Không thể tạo URL từ đường dẫn.")
                    self.exit1()
                    
                    
                }
                
                if brd.contains(bootram) {
                        
                    }
                    else{
                        
                        self.downloadFile(RRL:"\(URL3)/\(self.cpid.stringValue).img4",FILE:".hrdeciddata/ramdiskFiles/\(self.board.stringValue)/logo.img4"){
                            
                            
                        }
                        
                        
                    }
                
                sleep(5);
                
                
                self.boot()
                
                
            }
            else{
                
                self.downloadFileFromURL(urlString: "\(urlS)");
                
            }
        }
    }
    func boot() {
        MODEL.stringValue = iRecoveryInfo("MODEL");
        deviceDetectionHandler = false
        
            if(self.iRecoveryInfo("MODE") != "DFU"){
                let tg2 = self.tg1(tgg:"Thiết bị chưa vào DFU");
                let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                DispatchQueue.main.async {
                    self.hienthi.stringValue = "\(tg3)"
                }
                self.BoxShow("\(tg3)", Buttontext: "OK")
                
                self.deviceDetectionHandler = true
            return
        }
            if(self.iRecoveryInfo("MODE") == "DFU"){
        DispatchQueue.main.async {
          let bootram = self.menu1.titleOfSelectedItem!
            self.hienthi.textColor = NSColor(calibratedRed: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
            
            self.hienthi.stringValue = "BOOTING...."
            
            
            
            if("\(bootram)" == "BOOT15P") || ("\(bootram)" == "BOOT16.4.1<P") || ("\(bootram)" == "BOOT16.5>P2"){
    let boardid =  self.MODEL.stringValue
                let userName = NSUserName()
                if let palera1nURL = Bundle.main.url(forResource: "htools/exploits/.palera1n", withExtension: nil) {
                    let palera1n: String? = palera1nURL.path
                    // Tiếp tục với các bước tiếp theo trong mã của bạn sử dụng biến 'palera1n'
                
                
    let arguments = ["-r", "/Users/\(userName)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ramdisk.dmg"]

    // Tạo một đối tượng Process
    let process = Process()

    // Thiết lập đường dẫn chương trình nhị phân cho tiến trình
                    process.executableURL = URL(fileURLWithPath: palera1n!)

    // Thiết lập tham số cho tiến trình
    process.arguments = arguments

    // Bắt đầu chạy tiến trình
    do {
        try process.run()

        // Đặt thời gian để dừng tiến trình sau 30 giây
        Timer.scheduledTimer(withTimeInterval: 60, repeats: false) { timer in
            // Dừng tiến trình
            process.terminate()
            print("Tiến trình đã dừng sau 30 giây.")
   
            
        }
             // Chờ tiến trình kết thúc (bị dừng hoặc kết thúc bình thường)
        process.waitUntilExit()

        print("Tiến trình đã kết thúc.")
        sleep(5);
        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/");
            
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/__MACOSX");
        
    } catch {
        print("Không thể chạy tiến trình: \(error)")
        self.exit1()
        
    }
                }
                
                
                
                
                
                
                
                
}
            else{
                if (self.self.iRecoveryInfo("PWND") != "checkm8") {
                    self.startGasterProcesses()
                }
                
                
                DispatchQueue.main.async {
                
                    let tg2 = self.tg1(tgg:"Kiểm tra thiết bị vào PWND");
                    let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
     
                    self.hienthi.stringValue = "\(tg3)"
   
                }
        if (self.self.iRecoveryInfo("PWND") != "checkm8") {
            let tg2 = self.tg1(tgg:"Thiết bị vào PWND lỗi vui lòng thử lại");
            let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
            
            
            self.hienthi.stringValue = "\(tg3)"
            
            
            
            self.BoxShow("\(tg3)", Buttontext: "OK")

            self.deviceDetectionHandler = true
            self.exit1()
            
            return
        }
        if (self.self.iRecoveryInfo("PWND") == "checkm8") {
            
            
            
            
            
            self.deviceDetectionHandler = false
            let boardid =  self.board.stringValue
            let fileManager = FileManager.default
            let username = NSUserName() // Lấy tên người dùng hiện tại
           
            let iBoot = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBoot.img4"
            let iBSS = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBSS.img4"
            let iBEC = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBEC.img4"
            
            
            let ibss = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibss.img4"
            let ibec = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibec.img4"
            let sepfirmware = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-firmware.img4"
            let sepfw = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-fw.img4.img4"
            
            if fileManager.fileExists(atPath: iBoot) {
                _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBoot.img4")
                _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBoot.img4");
            }
            if fileManager.fileExists(atPath: iBSS){
               
                _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBSS.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBSS.img4");
                sleep(3);
            }
           
            if fileManager.fileExists(atPath: iBEC){
           
                DispatchQueue.main.async {
                   
                    
                    
                    
            _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBEC.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/iBEC.img4");
                }
            }
            if fileManager.fileExists(atPath: ibss){
              
                        _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibss.img4")
                        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibss.img4");
                sleep(3);
            }
           
            if fileManager.fileExists(atPath: ibec){
              
                        _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibec.img4");
                        _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ibec.img4");
                
            }
            
            
            
            sleep(3);
            
            if(self.self.iRecoveryIF2("CPID") == "0x8010" )||(self.self.iRecoveryIF2("CPID") == "0x8015" )||(self.self.iRecoveryIF2("CPID") == "0x8011" )||(self.self.iRecoveryIF2("CPID") == "0x8012" ){
           
           _ = self.iRecoveryIF2("go")

        }
            if(self.self.iRecoveryInfo("MODE") != "Recovery"){
                
                
                
                let tg2 = self.tg1(tgg:"Boot ramdisk thất bại vui lòng thử lại");
                let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                
                
                self.hienthi.stringValue = "\(tg3)"
                
                
                
                self.BoxShow("\(tg3)", Buttontext: "OK")
                self.deviceDetectionHandler = true
                self.devicedfu = true
                self.deviceDetectionHandler = true;
                if (self.HIENTHI.stringValue == "Normal"){
                    self.deviceDetectionHandler = true;
                    self.deviceDetectiondfu = false;
                    self.portisClosed();
                    self.helloOpened();
                    
                }
                if (self.HIENTHI.stringValue == "Recovery"){
                    self.deviceDetectionHandler = true;
                    self.deviceDetectiondfu = false;
                    self.portisClosed();
                    self.recoOpened();
                    
                    
                }
                if (self.HIENTHI.stringValue == "DFU"){
                    self.deviceDetectionHandler = true;
                    self.deviceDetectiondfu = false;
                    self.portisClosed();
                    self.dfuOpened1();
                    
                    
                }
                
                
                
                
                
                
                
                
                return
            }
            sleep(4);
            DispatchQueue.main.async {
                self.hienthi.stringValue = "send LOGO"
            }
               _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/logo.img4")
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/logo.img4");
              _ = self.iRecoveryIF2("'setpicture 0x1'")
          
            _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ramdisk.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/ramdisk.img4");
            
            _ = self.iRecoveryIF2("ramdisk");
            if fileManager.fileExists(atPath: sepfirmware){
                _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-firmware.img4");
                _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-firmware.img4");
                
                
                _ = self.iRecoveryIF2("rsepfirmware");
                
            }
            if fileManager.fileExists(atPath: sepfw){
                _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-fw.img4");
                _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/sep-fw.img4");
                
                
                _ = self.iRecoveryIF2("rsepfirmware");
                
            }
            
            
            _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/devicetree.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/devicetree.img4");
            
            _ = self.iRecoveryIF2("devicetree");
            _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/trustcache.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/trustcache.img4");
            
            _ = self.iRecoveryIF2("firmware");

            _ = self.iRecoveryIF("/Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/kernelcache.img4");
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/kernelcache.img4");
            _ = self.iRecoveryIF2("bootx");
            
        

            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/\(boardid)/");
            
            _ = self.shell("rm -rf /Users/$(whoami)/Desktop/.hrdeciddata/ramdiskFiles/__MACOSX");
            sleep(20);

        }
                    
                }
                    _ = self.shell("sleep 2");
                sleep(5);
                
                    
                    _ = self.shell("rm -rf ~/.ssh/known_hosts" );
                
            self.IProxy();
            if(self.sshpass12("'ls /dev'").contains("disk1s1")) || (self.sshpass12("'ls /dev'").contains("disk0s1s1")){
                DispatchQueue.main.async {
                   
                            self.hienthi.stringValue = "BOOT SSH OK"
                }
                
                
                
                if(self.sshpass12("'ls /dev'").contains("disk1s1")){
                        _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
                        _ = self.sshpass12("/sbin/mount_apfs /dev/disk1s1 /mnt1/");
           
                    }else{
                _ = self.sshpass12("/sbin/mount_apfs /dev/disk0s1s1 /mnt1");
                _ = self.sshpass12("/sbin/mount_apfs /dev/disk0s1s1 /mnt1");
                    }
                    let sshData = self.sshpass12("cat /mnt1/System/Library/CoreServices/SystemVersion.plist");
                     let data = sshData.data(using: .utf8)
                     if let data = data,
                        let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
                        let productVersion = plist["ProductVersion"] as? String {
                         DispatchQueue.main.async {
                         self.ios.stringValue = "\(productVersion)"
                         }
                     }
                DispatchQueue.main.async {
                    self.chedo.stringValue = "RAMDISK SSH";
                
                }
                sleep(5);
                let tg2 = self.tg1(tgg:"RAMDISK KHỞI ĐỘNG THÀNH CÔNG");
                let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                
                if self.tickhello.state == .on {
                    self.activateHello()
                    return
                }
                if self.tickhello.state == .off {
                    self.ramdiskOpened()
                    self.BoxShow("\(tg3)", Buttontext: "OK")
                    
                }
                    }
                    else{
                        
                        self.deviceDetectionHandler = true
                        let tg2 = self.tg1(tgg:"Lỗi kết nối Ramdisk, vui lòng BOOT RAMDISK lại");
                        let tg3 = tg2!.replacingOccurrences(of: "Optional(\"", with: "").replacingOccurrences(of: "\")", with: "");
                        self.hienthi.stringValue = "\(tg3)"
                        self.BoxShow("\(tg3)", Buttontext: "OK")
                        self.devicedfu = true
                        self.deviceDetectionHandler = true;
                        if (self.HIENTHI.stringValue == "Normal"){
                            self.deviceDetectionHandler = true;
                            self.deviceDetectiondfu = false;
                            self.portisClosed();
                            self.helloOpened();
                            return
                            
                        }
                        if (self.HIENTHI.stringValue == "Recovery"){
                            self.deviceDetectionHandler = true;
                            self.deviceDetectiondfu = false;
                            self.portisClosed();
                            self.recoOpened();
                            return
                        }
                        if (self.HIENTHI.stringValue == "DFU"){
                            self.deviceDetectionHandler = true;
                            self.deviceDetectiondfu = false;
                            self.portisClosed();
                            self.dfuOpened1();
                            return
                        }
                        return
                        
                    }
                
            }
    }
    
    }
    
    func exit1(){
        self.devicedfu = true
        self.deviceDetectionHandler = true;
        if (self.HIENTHI.stringValue == "Normal"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.helloOpened();
            
        }
        if (self.HIENTHI.stringValue == "Recovery"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.recoOpened();
            
            
        }
        if (self.HIENTHI.stringValue == "DFU"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.dfuOpened1();
            
            
        }
        
        
        
        
        
    }
    func exit2(){
        self.devicedfu = true
        self.deviceDetectionHandler = true;
        if (self.HIENTHI.stringValue == "Normal"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.CHECKRA1N();
            
        }
        if (self.HIENTHI.stringValue == "Recovery"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.recoOpened();
            
            
        }
        if (self.HIENTHI.stringValue == "DFU"){
            self.deviceDetectionHandler = true;
            self.deviceDetectiondfu = false;
            self.portisClosed();
            self.dfuOpened1();
            
            
        }
        
        
        
        
        
    }
    
    
    
    
    
    @IBAction func zalo(_ sender: Any) {
        let imageName = NSImage.Name("zaloac")

        // Create an NSImage instance with the image from the asset
        if let qrImage = NSImage(named: imageName) {
            // Now you have the image, you can use it as needed
            // For example, you can use it in the NSImageView:

            let alert = NSAlert()
            alert.messageText = "Vui lòng quét mã QR để kết bạn ZALO!"
            
            // Tạo NSImageView để hiển thị mã QR trong thông báo
            let qrImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 150, height: 150))
            qrImageView.image = qrImage
            alert.accessoryView = qrImageView
            
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } else {
            // The image couldn't be loaded from the asset
            print("Error: Unable to load the image from the asset.")
        }
        
    }
    
    @IBAction func web(_ sender: Any) {
        self.performSegue(withIdentifier: "web", sender: self )
        
    }
    
    
    
    @IBAction func boot(_ sender: Any) {
    }
    
    @IBAction func menuhello(_ sender: Any) {
    }
    
    @IBAction func ngonngu(_ sender: Any) {
        
        
        
    }
  
    @IBAction func runCommand(_ sender: NSMenuItem) {
        // Thực hiện tập lệnh của bạn ở đây
        // Ví dụ:
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["your_command_here"]
        task.launch()
        task.waitUntilExit()
    }
    
    
    @IBAction func sata(_ sender: Any) {
        self.menu1.isHidden = true
        
        dfu()
    }
    
    @IBAction func exit(_ sender: Any) {
        devicedfu = true
        deviceDetectionHandler = true;
        if (HIENTHI.stringValue == "Normal"){
            deviceDetectionHandler = true;
            deviceDetectiondfu = false;
            portisClosed();
            helloOpened();
            
        }
        if (HIENTHI.stringValue == "Recovery"){
            deviceDetectionHandler = true;
            deviceDetectiondfu = false;
            portisClosed();
            recoOpened();
            
            
        }
        if (HIENTHI.stringValue == "DFU"){
            deviceDetectionHandler = true;
            deviceDetectiondfu = false;
            portisClosed();
            dfuOpened1();
            
            
        }
        
    }
    
    
   
}
extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Download completed
        print("Download completed")
        
        let documentsUrl = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationUrl = documentsUrl.appendingPathComponent(".hrdeciddata/ramdiskFiles/\(self.MODEL1.stringValue).zip")
        
        // Delete file if it already exists
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            try! FileManager.default.removeItem(at: destinationUrl)
        }
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            print("File moved to documents folder")
            
            DispatchQueue.main.async {
                
                self.hienthi.stringValue = "Download completed"
                
                if (self.MODEL1.stringValue == self.DeviceInfo("UniqueDeviceID")){
                   
                    let username = NSUserName()
                    let sourcePath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/\(self.DeviceInfo("UniqueDeviceID")).zip"
                    let destinationPath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles/ffe2017db9c5071adfa1c23d3769970f7524a9d4/" // Điểm đến thư mục giải nén
                    
                    if let sourceURL = URL(string: "file://\(sourcePath)"), let destinationURL = URL(string: "file://\(destinationPath)") {
                        self.unzipFile(at: sourceURL, to: destinationURL)

                       
                        if let resourceURL = Bundle.main.url(forResource: "htools/libs/idevicebackup/idevicebackup", withExtension: nil) {
                            let idevicebackupPath: String = resourceURL.path
                            let task = Process()
                            
                            // Set the launch path to the idevicebackup binary
                            task.launchPath = idevicebackupPath
                            
                            // Set the arguments for the task
                            task.arguments = [
                                "--source",
                                "ffe2017db9c5071adfa1c23d3769970f7524a9d4",
                                "restore",
                                "--system",
                                "--settings",
                                "--reboot",
                                "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles"
                            ]
                            
                            let pipe = Pipe()
                            task.standardOutput = pipe
                            task.standardError = pipe
                            
                            task.launch()
                            
                            let data = pipe.fileHandleForReading.readDataToEndOfFile()
                            if let output = String(data: data, encoding: .utf8) {
                                print("Output: \(output)")
                            }
                            
                            task.waitUntilExit()
                            print("Blocking successfully")
                            // If you want to update UI elements, make sure to do it on the main thread
                            DispatchQueue.main.async {
                                self.hienthi.stringValue = "Blocking successfully"
                                self.BoxShow("Blocking successfully", Buttontext: "OK")
                            }
                        } else {
                            print("File not found.")
                        }

                                            } else {

                                                print("Lỗi: Không thể tạo URL từ đường dẫn.")
                                                self.exit1()

                                            }
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                }
                else{
                    self.downloadok()
                }
            }
        } catch {
            print("Error while moving file to documents folder")
            exit1()
            
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let percent = Int(progress * 100)
        let downloadedSize = ByteCountFormatter.string(fromByteCount: totalBytesWritten, countStyle: .file)
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite, countStyle: .file)
        if "\(totalSize)" == "-1 byte"{
           
            
            
            
        DispatchQueue.main.async {
            
            
            self.hienthi.stringValue = "Download RAMDSISK \(downloadedSize) / \(self.ramfilel.stringValue)"
        
        }}else{
            DispatchQueue.main.async {
            self.hienthi.stringValue = "Download RAMDSISK \(percent)% (\(downloadedSize) / \(totalSize))"
            
        }
        }
        
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // Download failed
            print("Download failed with error: \(error.localizedDescription)")
            
            
            if let resumeData = (error as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                downloadTaskResumeData = resumeData
            }
        }
    }
}
class UpdateManager {
    
    static func getCurrentAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return ""
    }
    
    static func checkForUpdates() {
            // Get the current installed application version
            let currentVersion = getCurrentAppVersion()
            
            guard let updateURL = URL(string: "https://gsmunlockinfo.org/panel/api/checkup.php?action=check-update") else {
                return
            }
            
            URLSession.shared.dataTask(with: updateURL) { data, response, error in
                if error != nil {
                    DispatchQueue.main.async {
                        
                        
                        let alert = NSAlert()
                        alert.messageText = "New update available, but it's not ready to be installed yet."
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                        
                        exit(0)
                    }
                }
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return
                    
                    
                }
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let latestVersionString = json["version"] as? String,
                               let updateAvailable = json["update_available"] as? Bool {
                                let latestVersion = latestVersionString
                                print(" response: \(updateAvailable)")
                                if updateAvailable == true && latestVersion > currentVersion {
                                    DispatchQueue.main.async {
                                        
                                        let alert = NSAlert()
                                        alert.messageText = "New update \(latestVersion)"
                                        alert.addButton(withTitle: "Update")
                                        alert.addButton(withTitle: "Exit")
                                        let response = alert.runModal()
                                        if response == .alertFirstButtonReturn {
                                            DispatchQueue.main.async {
                                                downloadAndInstallUpdate()
                                            }
                                        } else if response == .alertSecondButtonReturn {
                                            exit(0)
                                        }
                                        print(" 1222: \(latestVersion)")
                                        
                                    }
                                } else if updateAvailable == false && latestVersion > currentVersion {
                                    DispatchQueue.main.async {
                                        let alert = NSAlert()
                                        alert.messageText = "New update available, but it's not ready to be installed yet."
                                        alert.addButton(withTitle: "OK")
                                        alert.runModal()
                                        
                                        exit(0)
                                    }
                                    // Update is available, but the latest version is not higher than the current version.
                                   
                                }else if latestVersion == currentVersion {
                                    //
                                }
                                else if latestVersion < currentVersion {
                                    DispatchQueue.main.async {
                                        let alert = NSAlert()
                                        alert.messageText = "You are using the beta version."
                                        alert.addButton(withTitle: "OK")
                                        alert.runModal()
                                        
                                        
                                    }
                                }
                                
                                
                                
                                
                                
                                else {
                                    DispatchQueue.main.async {
                                        
                                        let alert = NSAlert()
                                        alert.messageText = "New update available, but it's not ready to be installed yet."
                                        alert.addButton(withTitle: "OK")
                                        alert.runModal()
                                        
                                        exit(0)
                                    }
                                }
                            }
                        }
                    } catch {
                        print("Error parsing JSON response: \(error.localizedDescription)")
                        
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "New update available, but it's not ready to be installed yet."
                            alert.addButton(withTitle: "OK")
                            alert.runModal()
                            exit(0)
                            
                        }
                        
                    }
                }
            }.resume()
        }
    
    static func downloadAndInstallUpdate() {
        DispatchQueue.main.async {
            guard let updateURL = URL(string: "https://gsmunlockinfo.org/panel/api/updata/GSMUNLOCKINFO.zip") else {
                return
            }
            
            URLSession.shared.dataTask(with: updateURL) { data, response, error in
                if let error = error {
                    print("Error downloading update: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Error downloading update"
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                        exit(0)
                    }
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return
                }
                
                if let data = data {
                    let fileManager = FileManager.default
                    let tempURL = fileManager.temporaryDirectory.appendingPathComponent("update.zip")
                    
                    // Xoá file nếu tồn tại
                    if fileManager.fileExists(atPath: tempURL.path) {
                        do {
                            try fileManager.removeItem(at: tempURL)
                            print("File đã được xoá thành công.")
                        } catch {
                            print("Không thể xoá file: \(error.localizedDescription)")
                        }
                    }
                    
                    do {
                        try data.write(to: tempURL)
                        self.installUpdate(at: tempURL)
                    } catch {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "Error saving update"
                            alert.addButton(withTitle: "OK")
                            alert.runModal()
                            exit(0)
                        }
                    }
                }
            }.resume()
        }
    }
    
    
    static func installUpdate(at updateURL: URL) {
        let appDirectoryURL = Bundle.main.bundleURL.deletingLastPathComponent
        let appDirectoryPath = appDirectoryURL().path
        let destinationURL1 = "GSMUNLOCKINFO1"
        
        print("file: \(updateURL) \(appDirectoryPath)")
        

        if let sourceURL = URL(string: "\(updateURL)"), let destinationURL = URL(string: "file://\(appDirectoryPath)/") {
            do {
                try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                
                // Construct the destination file URL with the desired file name
                let destinationFileURL = destinationURL.appendingPathComponent(destinationURL1)

                if FileManager.default.fileExists(atPath: destinationFileURL.path) {
                    try FileManager.default.removeItem(at: destinationFileURL)
                }

                // Unzip the item from sourceURL to destinationFileURL
                try FileManager.default.unzipItem(at: sourceURL, to: destinationFileURL)
                print("Đã giải nén tập tin thành công.")
                let task = Process()
                task.launchPath = "/bin/bash"
                task.arguments = ["-c", "rm -rf \(appDirectoryPath)/GSMUNLOCKINFO.app ;sleep 5; mv \(appDirectoryPath)/GSMUNLOCKINFO1/GSMUNLOCKINFO.app \(appDirectoryPath)/GSMUNLOCKINFO.app ; rm -rf \(appDirectoryPath)/GSMUNLOCKINFO1 ;sleep 5 && open -a '\(appDirectoryPath)/GSMUNLOCKINFO.app'"]

                do {
                    try task.run()
                    exit(0)
                } catch {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "Check up"
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                        exit(0)
                    }
                }
            } catch {
                print("Lỗi: \(error.localizedDescription)")
            }
        } else{
            print("Lỗi: Không thể tạo URL từ đường dẫn.")
        }

        
    }

}
class NewWindowController: NSWindowController {
    var webView: WKWebView!

    convenience init(urlString: String) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 890),
                              styleMask: [.titled, .closable, .resizable],
                              backing: .buffered,
                              defer: false)
        self.init(window: window)
        
        let contentRect = window.contentRect(forFrameRect: window.frame)
        webView = WKWebView(frame: contentRect)
        window.contentView = webView
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

