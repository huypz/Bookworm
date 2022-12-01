import PDFKit
import UIKit
import WebKit

class ReaderViewController: UIViewController {
    
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var fontPlusButton: UIBarButtonItem!
    @IBOutlet var fontMinusButton: UIBarButtonItem!
    @IBOutlet var bookmarkButton: UIBarButtonItem!
    @IBOutlet var helpButtom: UIBarButtonItem!
    
    var fontSize: Int = 100
    
    var document: Document!
    
    var pdfView: ReaderPDFView?
    var editMenuInteraction: UIEditMenuInteraction?
    var page: PDFPage?
    var selection: PDFSelection?
    
    var webView: ReaderWebView?
    
    var selectedText: String?
    
    var deckStore: DeckStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let lookUp = UIMenuItem(title: "Look Up", action: #selector(lookUp))
        UIMenuController.shared.menuItems = [lookUp]
        
        switch document.url?.pathExtension {
        case "pdf":
            initPDF()
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
            fontSize = fontSize > 100 ? fontSize - 20 : fontSize
        case 1: // A +
            fontSize = fontSize < 300 ? fontSize + 20 : fontSize
        default:
            print("Unexpected font button tag")
            return
        }
        let js = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust = '\(fontSize)%'"
        webView?.evaluateJavaScript(js)
    }
    
    @objc func lookUp() {
        if pdfView != nil {
            if let result = pdfView?.currentSelection?.string {
                self.selectedText = result
                self.performSegue(withIdentifier: "lookUp", sender: self)
            }
        }
        else if webView != nil {
            webView!.evaluateJavaScript("window.getSelection().toString()") { (result, error) in
                if let result = result as? String {
                    self.selectedText = result
                    self.performSegue(withIdentifier: "lookUp", sender: self)
                }
            }
        }
    }
    
    @IBAction func showHelp(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Text selection", message: "EPUB: tap and hold\nPDF: tap", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true, completion: nil)
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
        
        bookmarkButton.isHidden = true
        
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

extension ReaderViewController: PDFViewDelegate, UIEditMenuInteractionDelegate {
        
    func initPDF() {
        guard
            let data = document.data,
            let pdfDocument = PDFDocument(data: data) else {
            print("Error loading PDF: missing data")
            return
        }
        
        bookmarkButton.isHidden = true
    
        pdfView = ReaderPDFView(frame: .zero)
        pdfView!.document = pdfDocument
        pdfView!.autoScales = true
        pdfView!.isUserInteractionEnabled = true
        pdfView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        pdfView!.addInteraction(editMenuInteraction!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tap.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        tap.numberOfTapsRequired = 1
        pdfView!.addGestureRecognizer(tap)
        
        view.addSubview(pdfView!)
        
        pdfView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pdfView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pdfView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        fontPlusButton.isHidden = true
        fontMinusButton.isHidden = true
    }
    
    @objc private func didTap(_ recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: pdfView!)
        
        page = pdfView!.page(for: location, nearest: false)
        guard page != nil else { return }
        
        let convertedLocation = pdfView!.convert(location, to: page!)
        if page!.annotation(at: convertedLocation) == nil {
            selection = page!.selectionForWord(at: convertedLocation)
            guard let word = selection?.string else { return }
            selectedText = word
            pdfView!.setCurrentSelection(selection, animate: false)
            if let interaction = editMenuInteraction {
                let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
                interaction.presentEditMenu(with: config)
            }
        }
    }
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: "Look Up") { _ in
                self.lookUp()
            }
        ])
        return menu
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

class ReaderPDFView: PDFView {
    
    private var isSwizzled = false
    
    override var document: PDFDocument? {
        didSet {
            if !isSwizzled {
                //swizzleDocumentView()
                isSwizzled = true
            }
        }
    }
    
    func swizzleDocumentView() {
        guard
            let documentView = documentView,
            let documentViewClass = object_getClass(documentView) else {
            return
        }
        
        let selector = #selector(swizzled_canPerformAction(_:withSender:))
        let method = class_getInstanceMethod(object_getClass(self), selector)!
        let implementation = method_getImplementation(method)
        
        let selectorOriginal = #selector(canPerformAction(_:withSender:))
        let methodOriginal = class_getInstanceMethod(documentViewClass, selectorOriginal)!
        
        method_setImplementation(methodOriginal, implementation)
    }
    
    @objc func swizzled_canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
