import UIKit
import PDFKit

class ReaderViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView?
    
    var document: Document!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let documentPDF = PDFDocument(url: document.url) {
            pdfView?.document = documentPDF
            pdfView?.autoScales = true
        }
    }
}
