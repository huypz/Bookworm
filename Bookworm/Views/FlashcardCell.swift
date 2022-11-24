import UIKit

class FlashcardCell: UITableViewCell {

    @IBOutlet var termLabel: UILabel!
    
    var flashcard: Flashcard! {
        didSet {
            frontTermLabel.text = flashcard.term
            if flashcard.definition?.isEmpty ?? true {
                backDefinitionLabel.font = UIFont.italicSystemFont(ofSize: 18.0)
                backDefinitionLabel.alpha = 0.5
                backDefinitionLabel.text = "empty"
            }
            else {
                backDefinitionLabel.font = UIFont.systemFont(ofSize: 18.0)
                backDefinitionLabel.alpha = 1.0
                backDefinitionLabel.text = flashcard.definition
            }
        }
    }
    
    var frontView: UIView?
    var frontAudioButton: UIButton = {
        let frontAudioButton = UIButton()
        frontAudioButton.titleLabel?.text = ""
        frontAudioButton.setImage(UIImage(systemName: "speaker.wave.3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        frontAudioButton.translatesAutoresizingMaskIntoConstraints = false
        return frontAudioButton
    }()
    var frontTermLabel: UILabel = {
        let frontTermLabel = UILabel()
        frontTermLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        frontTermLabel.numberOfLines = 0
        frontTermLabel.textAlignment = .center
        frontTermLabel.translatesAutoresizingMaskIntoConstraints = false
        return frontTermLabel
    }()
    var frontEditButton: UIButton = {
        let frontEditButton = UIButton()
        frontEditButton.titleLabel?.text = ""
        frontEditButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        frontEditButton.translatesAutoresizingMaskIntoConstraints = false
        return frontEditButton
    }()
    
    var backView: UIView?
    var backAudioButton: UIButton = {
        let backAudioButton = UIButton()
        backAudioButton.setImage(UIImage(systemName: "speaker.wave.3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        backAudioButton.translatesAutoresizingMaskIntoConstraints = false
        return backAudioButton
    }()
    var backDefinitionLabel: UILabel = {
        let backDefinitionLabel = UILabel()
        backDefinitionLabel.font = UIFont.systemFont(ofSize: 18.0)
        backDefinitionLabel.numberOfLines = 0
        backDefinitionLabel.textAlignment = .center
        backDefinitionLabel.translatesAutoresizingMaskIntoConstraints = false
        return backDefinitionLabel
    }()
    var backEditButton: UIButton = {
        let backEditButton = UIButton()
        backEditButton.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        backEditButton.translatesAutoresizingMaskIntoConstraints = false
        return backEditButton
    }()
    
    var isFlipped: Bool = false
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tap.numberOfTapsRequired = 1
        
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true
        
        initFrontView()
    }
    
    override func prepareForReuse() {
        if isFlipped {
            initFrontView()
            UIView.transition(from: backView!, to: frontView!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft)
            isFlipped = false
            backView!.removeFromSuperview()
        }
    }
    
    @objc func tapped() {
        if isFlipped {
            initFrontView()
            UIView.transition(from: backView!, to: frontView!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft)
            isFlipped = false
            backView!.removeFromSuperview()
            
        }
        else {
            initBackView()
            UIView.transition(from: frontView!, to: backView!, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromRight)
            isFlipped = true
            frontView!.removeFromSuperview()
        }
    }
    
    func initFrontView() {
        frontView = UIView(frame: self.frame)
        frontView!.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(frontView!)
        NSLayoutConstraint.activate([
            frontView!.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            frontView!.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            frontView!.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            frontView!.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
        
        frontView!.addSubview(frontAudioButton)
        frontView!.addSubview(frontTermLabel)
        frontView!.addSubview(frontEditButton)
        
        NSLayoutConstraint.activate([
            frontAudioButton.widthAnchor.constraint(equalToConstant: 32.0),
            frontAudioButton.heightAnchor.constraint(equalToConstant: 32.0),
            frontAudioButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            frontAudioButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            frontTermLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0.0),
            frontTermLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0.0),
            frontTermLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            frontEditButton.widthAnchor.constraint(equalToConstant: 32.0),
            frontEditButton.heightAnchor.constraint(equalToConstant: 32.0),
            frontEditButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            frontEditButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    func initBackView() {
        backView = UIView(frame: self.frame)
        backView!.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backView!)
        NSLayoutConstraint.activate([
            backView!.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            backView!.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            backView!.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            backView!.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
        ])
        
        backView!.addSubview(backAudioButton)
        backView!.addSubview(backDefinitionLabel)
        backView!.addSubview(backEditButton)
        
        NSLayoutConstraint.activate([
            backAudioButton.widthAnchor.constraint(equalToConstant: 32.0),
            backAudioButton.heightAnchor.constraint(equalToConstant: 32.0),
            backAudioButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            backAudioButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            backDefinitionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0.0),
            backDefinitionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0.0),
            backDefinitionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            backEditButton.widthAnchor.constraint(equalToConstant: 32.0),
            backEditButton.heightAnchor.constraint(equalToConstant: 32.0),
            backEditButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            backEditButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            //backDefinitionLabel.topAnchor.constraint(greaterThanOrEqualTo: backAudioButton.bottomAnchor, constant: 64.0),
            //frontTermLabel.bottomAnchor.constraint(greaterThanOrEqualTo: frontEditButton.topAnchor, constant: 16.0)
        ])
    }
}
