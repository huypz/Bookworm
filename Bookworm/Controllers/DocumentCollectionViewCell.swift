import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            imageView.alpha = isEditing ? (isSelected ? 1.0 : 0.5) : 1.0
        }
    }
    var isEditing: Bool = false
    
    func update(displaying image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        }
        else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
}
