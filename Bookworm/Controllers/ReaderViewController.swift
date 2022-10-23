import UIKit
import PDFKit

class ReaderViewController: UIViewController {
    
    @IBOutlet weak var pdfView: PDFView?
    
    @IBOutlet var backButton: UIBarButtonItem!
    
    var document: Document!
    var documentPDF: PDFDocument!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView?.document = documentPDF
        pdfView?.autoScales = true
    }
    
    // MARK: - Actions
    @IBAction func back(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showContents(sender: UIBarButtonItem) {
        return
    }
}
