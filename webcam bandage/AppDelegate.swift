//
//  AppDelegate.swift
//  webcam bandage
//
//  Created by Luis on 4/1/17.
//  Copyright © 2017 Luis Toledo. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

    @IBOutlet weak var processMenu: NSMenu!
    @IBOutlet weak var processMenuItem: NSMenuItem!

    
    var pmtarget : AnyObject?

    
    weak var updateTimer : Timer!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        updateTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(AppDelegate.updateSuspicious), userInfo: nil, repeats: true)
        
        updateTimer.fire()
 
        pmtarget = releaseMenuItem.target
    }

    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        updateTimer.invalidate()
    }
    
    
    
    @IBAction func releaseClicked(_ sender: NSMenuItem) {
        killSuspiciousProcess()
    }
    
    
    @IBOutlet weak var releaseMenuItem: NSMenuItem!
    
    
    func updateSuspicious() {
        let processes = findSuspiciousProcess().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let processesArray = processes.components(separatedBy: "\n")

//        releaseMenuItem.isEnabled = false
//        releaseMenuItem.action = nil
//        releaseMenuItem.target = nil
        
//        processMenu.removeAllItems()
        
        disableItems()
        
        if (processes != "") {

//            releaseMenuItem.isEnabled = true
            for process in processesArray {
                
                let item = process.components(separatedBy: ",")
                processMenu.addItem(withTitle: item[0], action: nil, keyEquivalent: "")
            }
            
            enableItems()
        }
        
        print(processes)
    }

    
    
    func findSuspiciousProcess() -> String {
        return runScript("FindSuspicious")
    }
    
    
    func killSuspiciousProcess() {
        print("releasing")
        print( runScript("KillSuspicious") )
        updateSuspicious()
    }
    
    
    func disableItems() {
        releaseMenuItem.action = nil
        processMenu.removeAllItems()
        processMenuItem.target = nil
    }
    
    func enableItems() {
        releaseMenuItem.action = #selector(AppDelegate.releaseClicked)
        releaseMenuItem.target = pmtarget
//        processMenuItem.action = #selector()
    }
    
    
    
    func runScript(_ scriptName: String) -> String {
        guard let path = Bundle.main.path(forResource: scriptName,ofType:"command") else {
            print("Unable to locate Script")
            return ""
        }
        let task = Process()
        task.launchPath = path
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        task.launch()
        task.waitUntilExit()
        
        let dataOut = outpipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: dataOut, encoding: String.Encoding.utf8.rawValue)
        
        return output! as String
    }
    
}

