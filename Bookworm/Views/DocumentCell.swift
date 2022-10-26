import UIKit

class DocumentCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var isEditing: Bool = false
    
    func update() {
        if isEditing {
            imageView.alpha = isSelected ? 1.0 : 0.5
        }
        else {
            imageView.alpha = 1.0
        }
    }
    
    func update(displaying image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        }
        else {
            spinner.startAnimating()
            imageView.image = nil
        }
        update()
    }
}
