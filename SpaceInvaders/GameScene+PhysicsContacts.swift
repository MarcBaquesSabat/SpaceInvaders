import GameplayKit
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        guard let nameA = nodeA.name, let nameB = nodeB.name else { return }

        let oneNodeIsEnemy = nameA.hasPrefix("Enemy") || nameB.hasPrefix("Enemy")
        let oneNodeIsShoot = nameA == "shoot" || nameB == "shoot"
        let oneNodeIsBomb = nameA == "bomb" || nameB == "bomb"
        let oneNodeIsHouse = nameA.hasPrefix("house") || nameB.hasPrefix("house")

        if oneNodeIsEnemy, oneNodeIsShoot {
            nodeA.removeFromParent()
            nodeB.removeFromParent()

            self.currentScore += 1
            self.scoreLabel.text = "SCORE: \(self.currentScore)"

            run(self.boomSound)

            return
        }

        if oneNodeIsHouse, oneNodeIsBomb {
            run(self.bombSound)
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            return
        }

        if oneNodeIsShoot, oneNodeIsBomb {
            nodeA.removeFromParent()
            nodeB.removeFromParent()
            return
        }

        if oneNodeIsEnemy, oneNodeIsHouse {
            print("End Game")
            return
        }

        if oneNodeIsShoot {
            nodeA.name == "shoot" ? nodeA.removeFromParent() : nodeB.removeFromParent()
        }
    }
}
