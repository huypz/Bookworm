import AVKit
import UIKit

class FlashcardCell: UITableViewCell {
    
    var player: AVPlayer?
    
    var flashcard: Flashcard! {
        didSet {
            frontPartOfSpeechLabel.text = flashcard.partOfSpeech
            
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
            
            if flashcard.audio?.isEmpty ?? true {
                frontAudioButton.isEnabled = false
                backAudioButton.isEnabled = false
            }
        }
    }
    
    var frontView: UIView?
    var frontPartOfSpeechLabel: UILabel = {
        let frontPartOfSpeechLabel = UILabel()
        frontPartOfSpeechLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        frontPartOfSpeechLabel.textColor = .secondaryLabel
        frontPartOfSpeechLabel.numberOfLines = 0
        frontPartOfSpeechLabel.adjustsFontSizeToFitWidth = true
        frontPartOfSpeechLabel.translatesAutoresizingMaskIntoConstraints = false
        return frontPartOfSpeechLabel
    }()
    
    var frontAudioButton: UIButton = {
        let frontAudioButton = UIButton()
        frontAudioButton.titleLabel?.text = ""
        frontAudioButton.setImage(UIImage(systemName: "speaker.wave.3.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .medium)), for: .normal)
        frontAudioButton.translatesAutoresizingMaskIntoConstraints = false
        
        frontAudioButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        
        return frontAudioButton
    }()
    var frontTermLabel: UILabel = {
        let frontTermLabel = UILabel()
        frontTermLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        frontTermLabel.numberOfLines = 0
        frontTermLabel.textAlignment = .center
        frontTermLabel.adjustsFontSizeToFitWidth = true
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
        
        backAudioButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        
        return backAudioButton
    }()
    var backDefinitionLabel: UILabel = {
        let backDefinitionLabel = UILabel()
        backDefinitionLabel.font = UIFont.systemFont(ofSize: 18.0)
        backDefinitionLabel.numberOfLines = 0
        backDefinitionLabel.textAlignment = .center
        backDefinitionLabel.adjustsFontSizeToFitWidth = true
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
    
    @objc func playAudio() {
        if let url = URL(string: flashcard.audio!) {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player!.volume = 1.0
            player!.play()
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
        
        frontView!.addSubview(frontPartOfSpeechLabel)
        frontView!.addSubview(frontAudioButton)
        frontView!.addSubview(frontTermLabel)
        frontView!.addSubview(frontEditButton)
        
        NSLayoutConstraint.activate([
            frontPartOfSpeechLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            frontPartOfSpeechLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            frontPartOfSpeechLabel.trailingAnchor.constraint(equalTo: frontAudioButton.leadingAnchor, constant: 0.0),
            
            frontAudioButton.widthAnchor.constraint(equalToConstant: 32.0),
            frontAudioButton.heightAnchor.constraint(equalToConstant: 32.0),
            frontAudioButton.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            frontAudioButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            frontTermLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 0.0),
            frontTermLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: 0.0),
            frontTermLabel.topAnchor.constraint(equalTo: frontAudioButton.bottomAnchor, constant: 0.0),
            frontTermLabel.bottomAnchor.constraint(equalTo: frontEditButton.topAnchor, constant: 0.0),
            
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
            backDefinitionLabel.topAnchor.constraint(equalTo: backAudioButton.bottomAnchor, constant: 0.0),
            backDefinitionLabel.bottomAnchor.constraint(equalTo: backEditButton.topAnchor, constant: 0.0),
            
            backEditButton.widthAnchor.constraint(equalToConstant: 32.0),
            backEditButton.heightAnchor.constraint(equalToConstant: 32.0),
            backEditButton.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            backEditButton.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
}
