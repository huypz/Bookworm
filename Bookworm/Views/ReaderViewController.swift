import UIKit
import WebKit

class ReaderViewController: UIViewController {
    
    var document: Document! {
        didSet {
            documentExtension = document.url?.pathExtension
        }
    }
    
    var documentExtension: String?
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}

extension ReaderViewController: WKUIDelegate, WKNavigationDelegate {
    
    private func initEPUB() {
        let parser = EPUBParser()
        guard
            let book = parser.parse(at: document.url!),
            let pages = book.pages
        else {
            print("Error parsing epub at \(document.url!)")
            return
        }
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
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
