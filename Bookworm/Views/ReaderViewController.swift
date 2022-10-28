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
    
    var editMenuInteraction: UIEditMenuInteraction?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "lookup":
            let entriesViewController = segue.destination as! EntriesViewController
            entriesViewController.term = pdfView?.currentSelection?.string?.lowercased()
            if entriesViewController.store == nil {
                entriesViewController.store = EntryStore()
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "lookup":
            return isValidSelection(selection: pdfView?.currentSelection?.string ?? "")
        default:
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch documentExtension {
        case "pdf":
            initPDF()
            initPDFMenuInteraction()
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
            pdfView!.isFindInteractionEnabled = true
        }
    }
    
    private func initPDFMenuInteraction() {
        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        pdfView!.addInteraction(editMenuInteraction!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        tap.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        pdfView!.addGestureRecognizer(tap)
    }
    
    @objc private func didTap(_ recognizer: UIGestureRecognizer) {
        let location = recognizer.location(in: pdfView!)
        
        let page = pdfView!.page(for: location, nearest: false)
        guard page != nil else { return }
        
        let convertedLocation = pdfView!.convert(location, to: page!)
        if page!.annotation(at: convertedLocation) == nil {
            let selection = page!.selectionForWord(at: convertedLocation)
            pdfView!.setCurrentSelection(selection, animate: false)
            
            guard isValidSelection(selection: selection?.string ?? "") else { return }
            
            if let interaction = editMenuInteraction {
                let config = UIEditMenuConfiguration(identifier: nil, sourcePoint: location)
                interaction.presentEditMenu(with: config)
            }
        }
    }
    
    func isValidSelection(selection: String) -> Bool {
        guard !selection.isEmpty else { return false }
        for ch in selection.lowercased() {
            if !(ch >= "a" && ch <= "z") {
                return false
            }
        }
        return true
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

extension ReaderViewController: UIEditMenuInteractionDelegate {
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let menu = UIMenu(options: .displayInline, children: [
            UIAction(title: "Look Up") { _ in
                self.performSegue(withIdentifier: "lookup", sender: self)
            }
        ])
        return menu
    }
}
