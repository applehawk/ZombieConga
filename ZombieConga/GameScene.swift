import SpriteKit

class GameScene: SKScene {
  var zombie : SKSpriteNode = SKSpriteNode(imageNamed: "zombie1")
  var lastUpdateTime : NSTimeInterval = 0
  var dt: NSTimeInterval = 0
  
  let playableRect: CGRect
  let zombieMovePointsPerSec: CGFloat = 450.0
  let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
  var velocity = CGPoint.zero
  
  override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0 // 3
    playableRect = CGRect(x: 0, y: playableMargin,
      width: size.width,
      height: playableHeight) // 4
    super.init(size: size) // 5
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented") // 6
  }
  
  override func didMoveToView(view: SKView) {
    backgroundColor = SKColor.blackColor()

    let background = SKSpriteNode(imageNamed: "background1")
    background.zPosition = -1
    background.position = CGPoint(x: size.width/2, y: size.height/2)

    zombie.position = CGPoint(x: 400, y: 400);
    zombie.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    zombie.setScale(2)
    addChild(background)
    addChild(zombie)
    spawnEnemy()

    debugDrawPlayableArea()
  }
  
  func debugDrawPlayableArea() {
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil, playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 4.0
    addChild(shape)
  }
  
  override func update(currentTime: NSTimeInterval) {
    if lastUpdateTime > 0 {
      dt = currentTime - lastUpdateTime
    } else {
      dt = 0
    }
    lastUpdateTime = currentTime

    moveSprite(zombie, velocity: velocity)
    rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
    boundsCheckZombie()

    print("\(dt*1000) milliseconds since last update");
  }
}

//Playground touches

extension GameScene /*touches actions*/ {
  func sceneTouched( touchLocation: CGPoint) {
    moveZombieToward(touchLocation)
  }
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.locationInNode(self)
    sceneTouched(touchLocation)
  }
}

extension GameScene /*enemy functionality*/ {
  func spawnEnemy() {
    let enemy = SKSpriteNode(imageNamed: "enemy")
    enemy.position = CGPoint(
				x: size.width + enemy.size.width/2,
				y: size.height/2)
    let actionMove = SKAction.moveTo(CGPoint(
          x: -enemy.size.width/2, y: enemy.position.y),
          duration: 2.0)
    enemy.runAction(actionMove)
    addChild(enemy)
  }
}


extension GameScene /*zombie movements*/ {
  func boundsCheckZombie() {
    let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
    let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
    if zombie.position.x <= bottomLeft.x {
      zombie.position.x = bottomLeft.x
      velocity.x = -velocity.x
    }
    if zombie.position.x >= topRight.x {
      zombie.position.x = topRight.x
      velocity.x = -velocity.x
    }
    if zombie.position.y <= bottomLeft.y {
      zombie.position.y = bottomLeft.y
      velocity.y = -velocity.y
    }
    if zombie.position.y >= topRight.y {
      zombie.position.y = topRight.y
      velocity.y = -velocity.y
    }
  }
    
  func moveZombieToward(location: CGPoint) {
    let direction = (location - zombie.position).normalized()
    velocity = direction * zombieMovePointsPerSec
  }

  func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
    let amountToMove = velocity * CGFloat(dt)
    sprite.position += amountToMove
  }

  func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat)
  {
    let shortest = shortestAngleBetween(sprite.zRotation, angle2: velocity.angle)
    var amountToRotate = min( abs(shortest), rotateRadiansPerSec * CGFloat(dt))
    sprite.zRotation += amountToRotate * shortest.sign()
  }
}