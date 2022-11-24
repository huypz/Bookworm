import UIKit
import AVKit

class EntryCell: UITableViewCell {
    
    @IBOutlet var partOfSpeechLabel: UILabel!
    @IBOutlet var termLabel: UILabel!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var definitionLabel: UILabel!
    
    var player: AVPlayer?
    var audio: URL?
    
    var delegate: EntriesViewController!
    
    @IBAction func add(_ sender: UIButton) {
        delegate.selectedDefinition = definitionLabel.text
        delegate.performSegue(withIdentifier: "addEntry", sender: delegate)
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        if let url = audio {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player!.volume = 1.0
            player!.play()
        }
    }
}
