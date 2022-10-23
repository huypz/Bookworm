import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var documentImageView: UIImageView!
    
    var isEditing: Bool = false {
        didSet {
            if isEditing {
                documentImageView.alpha = 0.5
            }
            else {
                documentImageView.alpha = 1
            }
        }
    }
}
