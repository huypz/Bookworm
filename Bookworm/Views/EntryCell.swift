import UIKit
import AVKit

class EntryCell: UITableViewCell {
    
    @IBOutlet var partOfSpeechLabel: UILabel!
    @IBOutlet var termLabel: UILabel!
    @IBOutlet var audioButton: UIButton!
    @IBOutlet var definitionLabel: UILabel!
    
    var player: AVPlayer?
    var audio: URL?
    
    @IBAction func playAudio(_ sender: UIButton) {
        if let url = audio {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            player!.volume = 1.0
            player!.play()
        }
    }
}
