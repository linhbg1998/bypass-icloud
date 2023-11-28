//
//  qr.swift
//  AU-RAM
//
//  Created by linh on 23/07/2023.
//
import Cocoa

class QRViewController: NSViewController {
    
    @IBOutlet weak var qrCodeImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gọi hàm để tạo mã QR và hiển thị nó trên imageView
        generateQRCode()
    }
    
    func makeHTTPRequest11(urlString: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completionHandler(nil, error)
                } else {
                    completionHandler(data, nil)
                }
            }
            task.resume()
        } else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completionHandler(nil, error)
        }
    }
    
    func generateQRCode() {
        // Thông tin bạn muốn mã hóa thành mã QR
        let urlString = "https://gsmunlockinfo.com/tt.php"
        makeHTTPRequest11(urlString: urlString) { (data, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let imageData = data, let qrImage = NSImage(data: imageData) else {
                print("Error converting data to NSImage.")
                return
            }
            
            DispatchQueue.main.async {
                self.qrCodeImageView.image = qrImage
            }
        }
    }
}
