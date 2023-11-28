//
//  AppDelegate.swift
//  H-Ramdisk
//
//  Created by Hyterax on 22/12/2022.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func iRecoveryInfo(_ Info:String)->String{
                let partyPath1 = Bundle.main.url(forResource: "htools/libs/irecovery", withExtension: "")
                let irecovery: String = partyPath1!.path
                
                let Ret:String = shell("" + irecovery + " -q | grep -w " + Info + " | awk '{printf $NF}'");
                return Ret;
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
  
    
    
    @IBAction func date(_ sender: Any) {
        let fileManager = FileManager.default
        let username = NSUserName()
        let model1Value = iRecoveryInfo("MODEL")
        let directoryPath = "/Users/\(username)/Desktop/.hrdeciddata/ramdiskFiles"
       
        
       
        // Kiểm tra xem thư mục tồn tại hay không
        if fileManager.fileExists(atPath: directoryPath) {
            do {
                let fileURLs = try fileManager.contentsOfDirectory(atPath: directoryPath)

                for fileURL in fileURLs {
                    if fileURL.hasPrefix(model1Value) {
                        let filePath = "\(directoryPath)/\(fileURL)"
                        try fileManager.removeItem(atPath: filePath)
                    }
                }
                
                let alert = NSAlert()
                alert.messageText = "Deleting \(model1Value) files successfully "
                alert.addButton(withTitle: "OK")
                alert.runModal()
            } catch {
                print("Lỗi khi xóa các tệp: \(error.localizedDescription)")
            }
        } else {
            print("Thư mục không tồn tại.")
        }
    }
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    internal func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
     return true
    }
}


