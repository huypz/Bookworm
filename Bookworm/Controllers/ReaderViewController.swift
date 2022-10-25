import UIKit
import WebKit

class ReaderViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    @IBOutlet var webView: WKWebView!
    
    var document: Document!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        
        guard let fileExtension = document.url?.pathExtension else {
            print("Error retrieving file extension")
            return
        }
        
        switch fileExtension {
        case "pdf":
            webView.load(document.data!, mimeType: "application/pdf", characterEncodingName: "UTF-8", baseURL: .applicationDirectory)
        case "epub":
            let url = URL(string: "https://reader.ttsu.app")
            let request = URLRequest(url: url!)
            webView.load(request)
        default:
            print("WebView Unknown file extension: \(fileExtension)")
            return
        }
    }
    
    // MARK: - Actions
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showContents(sender: UIBarButtonItem) {
        return
    }
}
