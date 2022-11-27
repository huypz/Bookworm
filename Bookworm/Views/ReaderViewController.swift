import UIKit
import WebKit

class ReaderViewController: UIViewController {
    
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var fontPlusButton: UIBarButtonItem!
    @IBOutlet var fontMinusButton: UIBarButtonItem!
    @IBOutlet var bookmarkButton: UIBarButtonItem!
    
    var fontSize: Int = 100
    
    var document: Document! {
        didSet {
            documentExtension = document.url?.pathExtension
        }
    }
    
    var documentExtension: String?
    
    var webView: ReaderWebView?
    var selectedText: String?
    
    var deckStore: DeckStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lookUp = UIMenuItem(title: "Look Up", action: #selector(lookUp))
        UIMenuController.shared.menuItems = [lookUp]
        
        switch documentExtension {
        case "pdf":
            print("Error loading pdf: the document type is currently not supported")
            return
        case "epub":
            initEPUB()
        default:
            fatalError("Unexpected document file extension")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "lookUp":
            let navigationController = segue.destination as! UINavigationController
            let entriesViewController = navigationController.topViewController as! EntriesViewController
            entriesViewController.deckStore = deckStore
            entriesViewController.term = selectedText?.lowercased()
            if entriesViewController.store == nil {
                entriesViewController.store = EntryStore()
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    @IBAction func showFontView(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0: // A -
            fontSize = fontSize > 100 ? fontSize - 10 : fontSize
        case 1: // A +
            fontSize = fontSize < 300 ? fontSize + 10 : fontSize
        default:
            print("Unexpected font button tag")
            return
        }
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '\(fontSize)%'"
        webView?.evaluateJavaScript(js)
    }
    
    @objc func lookUp() {
        webView!.evaluateJavaScript("window.getSelection().toString()") { (result, error) in
            if let result = result as? String {
                self.selectedText = result
                self.performSegue(withIdentifier: "lookUp", sender: self)
            }
        }
    }
}

extension ReaderViewController: WKUIDelegate, WKNavigationDelegate {
    
    func initEPUB() {
        
        let parser = EPUBParser()
        guard
            let book = parser.parse(at: document.url!),
            let pages = book.pages
        else {
            print("Error parsing epub at \(document.url!)")
            return
        }
        
        // Init WebView
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.preferredContentMode = .mobile
        
        webView = ReaderWebView(frame: .zero, configuration: config)
        webView!.uiDelegate = self
        webView!.navigationDelegate = self
        
        webView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(webView!)
        
        webView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        var bookHtmlString = ""
        
        let cssFilePath = Bundle.main.path(forResource: "stylesheet", ofType: "css")
        let cssTag = "<link rel='stylesheet' type='text/css' href='\(cssFilePath!)'>"
        let htmlInject = "\n\(cssTag)\n</head>"
        
        pages.forEach { (url) in
            if var pageHtmlString = try? String(contentsOf: url) {
                pageHtmlString = pageHtmlString.replacingOccurrences(of: "</head>", with: htmlInject)
                bookHtmlString.append(pageHtmlString)
            }
        }
        
        webView!.loadHTMLString(bookHtmlString, baseURL: book.baseURL)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let url = navigationAction.request.url {
                UIApplication.shared.canOpenURL(url)
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            }
            else {
                decisionHandler(.allow)
            }
        }
        else {
            decisionHandler(.allow)
        }
    }
     
}

class ReaderWebView: WKWebView {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if NSStringFromSelector(action) == "lookUp:" {
            return super.canPerformAction(action, withSender: sender)
        }
        
        return false
    }
}
