//
//  web.swift
//  AU-RAM
//
//  Created by linh on 22/07/2023.
//

import Cocoa
import WebKit

class web: NSViewController {


    @IBOutlet weak var web: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Load a webpage when the view loads
        let urlString = "https://gsmunlockinfo.com/"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            web.load(request)
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(true)
        
    }
    
    
    
    
}
