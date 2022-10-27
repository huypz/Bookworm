import UIKit
import PDFKit
import WebKit

class ReaderViewController: UIViewController {
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    var document: Document! {
        didSet {
            documentExtension = document.url?.pathExtension
        }
    }
    var documentExtension: String?
    
    var pdfView: PDFView?
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch documentExtension {
        case "pdf":
            initPDF()
        case "epub":
            initEPUB()
        default:
            fatalError("Unexpected document file extension")
        }
    }
}

extension ReaderViewController: PDFViewDelegate {
    
    private func initPDF() {
        pdfView = PDFView()
        
        view.addSubview(pdfView!)
        
        pdfView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pdfView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pdfView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pdfView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        if let document = PDFDocument(data: document.data!) {
            pdfView!.document = document
            pdfView!.autoScales = true
        }
    }
    
    private func initMenuInteraction() {
        
    }
}

extension ReaderViewController: WKUIDelegate {
    
    private func initEPUB() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView!.uiDelegate = self
        
        view.addSubview(webView!)
        
        webView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView!.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView!.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let url = URL(string: "https://reader.ttsu.app")
        let request = URLRequest(url: url!)
        webView!.load(request)
    }
}
