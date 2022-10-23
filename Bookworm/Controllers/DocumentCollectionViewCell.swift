import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var documentImageView: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            documentImageView.alpha = isEditing ? (isSelected ? 1.0 : 0.5) : 1.0
        }
    }
    
    var isEditing: Bool = false
}
