import GameplayKit
import SpriteKit

class GameScene: SKScene {
    var spaceShip: SKSpriteNode!
    private let laserShootSound = SKAction.playSoundFileNamed("lasershoot.wav", waitForCompletion: false)
    let bombSound = SKAction.playSoundFileNamed("bomb.wav", waitForCompletion: false)
    let boomSound = SKAction.playSoundFileNamed("boom.wav", waitForCompletion: false)
    private var spaceshipTouch: UITouch?
    var scoreLabel: SKLabelNode!
    var bombTimer: Timer?
    var enemiesMoveTimer: Timer?

    var currentScore: Int = 0
    let enemiesVerticaSpacing: CGFloat = 50.0
    private(set) lazy var enemiesHorizontalSpacing: CGFloat = { CGFloat(self.size.width / 16) }()
    var houseImpacts = [0, 0, 0, 0]

    enum Direction {
        case left, right
    }

    var enemiesMovementDirection = Direction.right

    override func didMove(to _: SKView) {
        let spaceshipYPositon = -(self.size.height / 2) + 100

        self.backgroundColor = .black
        self.spaceShip = SKSpriteNode(imageNamed: "SpaceShip")
        self.spaceShip.name = "spaceship"
        self.spaceShip.size = CGSize(width: 50, height: 25)
        self.spaceShip.position = CGPoint(x: 0, y: spaceshipYPositon)
        self.addChild(self.spaceShip)

        self.addHouses(spaceshipYPositon)

        self.addEnemies(at: 100)

        self.physicsWorld.contactDelegate = self

        self.scoreLabel = SKLabelNode(text: "SCORE: 0")
        self.scoreLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - 50)
        self.addChild(self.scoreLabel)

        self.bombTimer = Timer.scheduledTimer(timeInterval: 1.5,
                                              target: self,
                                              selector: #selector(dropBomb),
                                              userInfo: nil,
                                              repeats: true)
        self.enemiesMoveTimer = Timer.scheduledTimer(timeInterval: 1,
                                                     target: self,
                                                     selector: #selector(moveEnemies),
                                                     userInfo: nil,
                                                     repeats: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard self.spaceshipTouch == nil
        else {
            self.createShoot()
            run(self.laserShootSound)
            return
        }

        if let touch = touches.first {
            self.spaceshipTouch = touch
            let newPosition = touch.location(in: self)
            let action = SKAction.moveTo(x: newPosition.x, duration: 0.5)
            action.timingMode = .easeInEaseOut
            self.spaceShip.run(action)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard let touchIndex = touches.firstIndex(of: spaceshipTouch) else { return }

        let touch = touches[touchIndex]

        let newPosition = touch.location(in: self)
        let action = SKAction.moveTo(x: newPosition.x, duration: 0.05)
        action.timingMode = .easeInEaseOut
        self.spaceShip.run(action)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }

        self.spaceshipTouch = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let spaceshipTouch = self.spaceshipTouch else { return }
        guard touches.firstIndex(of: spaceshipTouch) != nil else { return }

        self.spaceshipTouch = nil
    }

    override func update(_: TimeInterval) {
        self.cleanPastShoots()
    }
}

extension GameScene {
    private func cleanPastShoots() {
        for node in children {
            guard node.name == "shoot" || node.name == "bomb" else { continue }
            if node.position.y > 700 || node.position.y < -700 {
                node.removeFromParent()
            }
        }
    }

    @objc
    private func dropBomb() {
        let bottomEnemies = self.children.filter { node in
            guard let isEnemy = node.name?.hasPrefix("Enemy"), isEnemy == true else { return false }
            let bottomPosition = CGPoint(x: node.position.x, y: node.position.y - self.enemiesVerticaSpacing)
            let enemies = self.nodes(at: bottomPosition)

            return !enemies.contains { $0.name!.hasPrefix("Enemy") }
        }

        guard bottomEnemies.count > 0 else { return }

        let shooterEnemyIndex = Int.random(in: 0 ..< bottomEnemies.count)
        let shooterEnemy = bottomEnemies[shooterEnemyIndex]
        let bombPosition = CGPoint(x: shooterEnemy.position.x,
                                   y: shooterEnemy.position.y - self.enemiesVerticaSpacing / 2)
        self.createBomb(at: bombPosition)
    }

    @objc
    private func moveEnemies() {
        let allEnemies = self.children.filter { ($0.name?.hasPrefix("Enemy")) ?? false }
        var allMoveActions = [SKAction]()
        var movementX: CGFloat = 0
        var movementY: CGFloat = 0

        switch self.enemiesMovementDirection {
        case .left:
            let minX = allEnemies.reduce(CGFloat(Int.max)) { min($0, $1.position.x) }
            let nextPosition = minX - self.enemiesHorizontalSpacing
            if nextPosition <= -(self.size.width / 2) {
                movementX = 0
                movementY = -self.enemiesVerticaSpacing
                self.enemiesMovementDirection = .right
            } else {
                movementX = -self.enemiesHorizontalSpacing
                movementY = 0
            }
        case .right:
            let maxX = allEnemies.reduce(CGFloat(Int.min)) { max($0, $1.position.x) }
            let nextPosition = maxX + self.enemiesHorizontalSpacing
            if nextPosition >= (self.size.width / 2) {
                movementX = 0
                movementY = -self.enemiesVerticaSpacing
                self.enemiesMovementDirection = .left
            } else {
                movementX = self.enemiesHorizontalSpacing
                movementY = 0
            }
        }

        for enemy in allEnemies {
            let enemyAction = SKAction.run {
                enemy.run(SKAction.moveBy(x: movementX, y: movementY, duration: 0))
            }
            allMoveActions.append(enemyAction)
        }

        self.run(SKAction.group(allMoveActions))
    }
}
