import UIKit
import WebKit

class ReaderViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    var webView: WKWebView!
    
    var document: Document!
    
    // MARK: - View lifecycle
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WebView loading...")
        webView.load(document.data!, mimeType: "application/pdf", characterEncodingName: "UTF-8", baseURL: .applicationDirectory)
    }
    
    // MARK: - Actions
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showContents(sender: UIBarButtonItem) {
        return
    }
}
