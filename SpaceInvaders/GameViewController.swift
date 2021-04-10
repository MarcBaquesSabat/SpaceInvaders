import GameplayKit
import SpriteKit
import UIKit

class GameViewController: UIViewController {
    @IBOutlet var launchImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let view = self.view as? SKView else { return }

        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "GameScene") {
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFit

            // Present the scene
            view.presentScene(scene)
        }

        view.ignoresSiblingOrder = true

        view.showsFPS = true
        view.showsNodeCount = true
    }

    override func viewDidAppear(_: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.launchImage.isHidden = true
        }
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
