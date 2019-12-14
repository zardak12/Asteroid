//
//  GameScene.swift
//  Asteroids
//
//  Created by марк  on 11.12.2019.
//  Copyright © 2019 марк . All rights reserved.
//
import CoreMotion
import SpriteKit
import GameplayKit

class GameScene: SKScene ,SKPhysicsContactDelegate {
    
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode! // надпись на экране
    var lifeLabel : SKLabelNode!
    var check :Int = 0
    var life:Int = 4 {
        didSet{
            lifeLabel.text = "Жизнь:\(life)"
        }
    }
    var score:Int = 0 {//создаем вспомогательную пременную
        didSet{// автоматически обновление (конструктор) надпись на экране
            scoreLabel.text = "Счет:\(score)"//само отображение
        }
    }
    var gameTimer:Timer!
    var aliens = ["alien","alien2","alien3"] // создание массива для врагов( три разные картинки)
    let alienCategory:UInt32 = 0x1 << 1 // созднаие уни интифигатора
    let bulletCategory:UInt32 = 0x1 << 0 //создание уникального интифигатора
    let playerCategory:UInt32 = 0x1 << 2
    let motionManager = CMMotionManager() //
    var xAccelerate:CGFloat = 0 // данные акселератора по х(насколько вращаем будет записываться в эту переменную)
    
    override func didMove(to view : SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")//показ звездного поля
        starfield.position = CGPoint(x:0,y:1472) // координаты под звездное поле
        starfield.advanceSimulationTime(10)//пропускаем десять секунд анимации для заполнения всего поля
        self.addChild(starfield)//добавление обькта на экрана
        
        starfield.zPosition = -1 // делаем бэкграунд для того чтобы он не перекрывал игрока чтобы он был всегда снизу
        
        player = SKSpriteNode(imageNamed: "shuttle") //добавление игрока
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2,y: 40)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = alienCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx:0,dy:0) // убираем гравитацию через метод физики
        self.physicsWorld.contactDelegate = self//позволяет отслеживать наши соприкосновения в нашей игре
        
        scoreLabel = SKLabelNode(text:"Счет:0")//отображение
        scoreLabel.fontName = "AmericanTypewriter-Bold"//установка шрифта надписи
        scoreLabel.fontSize = 23 //установка размера
        scoreLabel.fontColor =  UIColor.red
        scoreLabel.position = CGPoint(x:60,y: UIScreen.main.bounds.height - 60)
        score = 0
        
        self.addChild(scoreLabel)
        
        lifeLabel = SKLabelNode(text:"Жизнь:4")//отображение
        lifeLabel.fontName = "AmericanTypewriter-Bold"//установка шрифта надписи
        lifeLabel.fontSize = 30 //установка размера
        lifeLabel.fontColor =  UIColor.red
        lifeLabel.position = CGPoint(x:280,y: UIScreen.main.bounds.height -
            60)
        life = 4
        self.addChild(lifeLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector:#selector(addAlien) , userInfo:nil , repeats: true) //функция показывает интервал времени , цель (на какой обьект ?) , селектор ( та функкция которую будем вызывать) , юзеринфо информация для пользователя, повторение
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data:CMAccelerometerData!,error :Error?) in //добавление в акселератор
            if let accelerometrData = data {
                let accelaration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(accelaration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {// функция позволяет прозводить операции и симуляции
        player.position.x += xAccelerate * 50
        //проверка чтобы не выходил за рамки
        if (player.position.x < 0) {
            player.position = CGPoint(x:UIScreen.main.bounds.width - player.size.width, y:player.position.y)
        }else if (player.position.x > UIScreen.main.bounds.width){
            player.position = CGPoint(x:20 , y:player.position.y)
        }
    }
    
 func collisionElements(bulletNode:SKSpriteNode,alienNode:SKSpriteNode){ // добавление элементов столкновения
    let explosion = SKEmitterNode(fileNamed: "Vzriv")
    explosion?.position = alienNode.position
    self.addChild(explosion!)
    
    self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
    bulletNode.removeFromParent()
    alienNode.removeFromParent()
    
    self.run(SKAction.wait(forDuration: 2)){
        explosion?.removeFromParent()
    }// удаление с помощью таймера
    
    score += 50
    if (score - check == 10000)
    {
        check = score
        life += 1
    }
    }
    
    func testMylifeElements(alienNode:SKSpriteNode){ // проверка на жизнь
    if (life > 0)
    {
        let explosion2 = SKEmitterNode(fileNamed: "Vzriv")
        explosion2?.position = alienNode.position
        self.addChild(explosion2!)
         self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        alienNode.removeFromParent()
        life -= 1
        
    }else {
        exit(0)
    }
    }
    
     func didBegin(_ contact: SKPhysicsContact) {// функция сталкнивания друг с другим
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask { //функция сравнивает и понимаеь кто патрон а кто враг
            secondBody = contact.bodyA //
            firstBody = contact.bodyB //
        } else { // иначе меняем значение(другой вариаент)
            secondBody = contact.bodyB
            firstBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask == alienCategory)  && (secondBody.categoryBitMask == bulletCategory )
        {
            collisionElements(bulletNode:secondBody.node as! SKSpriteNode,alienNode:firstBody.node as! SKSpriteNode)
        }//проверка если два тела столкнулись , то мы ничего не делаем
        
        if firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == alienCategory {
          testMylifeElements(alienNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    @objc func addAlien (){//функция добавления игрока
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]//делает рандомные три элементы
        let alien = SKSpriteNode(imageNamed: aliens[0])//устанволение картинки врага
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width + 20)) //  выбираем диаопзон нашего местопложения
        let pos = CGFloat(randomPos.nextInt())//6 minute(20
        alien.position = CGPoint(x:pos,y:UIScreen.main.bounds.height - alien.size.height)//установка позиция
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)//установка размера
        alien.physicsBody?.isDynamic = true //устанвока дианмики
        alien.physicsBody?.categoryBitMask = alienCategory // присваиваем уникальное значение нашему врагу
        alien.physicsBody?.contactTestBitMask = bulletCategory // обьект с кем будем отслеживать
        alien.physicsBody?.collisionBitMask = 0 // значения по умолчанию врагу
        
        self.addChild(alien)
        
        let animDuration :TimeInterval = 6 // скорость с которой наша анимация будет передвигаться
        var actions = [SKAction]()
        //массив будем записывать действия для того чтобы двигать к определенной точки а также удалять и чистить
        actions.append(SKAction.move(to:CGPoint(x:pos,y:-alien.size.height),duration : animDuration))
            // показываем куда будем двигать и скакой чатсотой
        actions.append(SKAction.removeFromParent())// удаление после выхождения за рамки
        alien.run(SKAction.sequence(actions))
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet () {// функция при выпускания огня и выстрела
        self.run(SKAction.playSoundFileNamed("bullet.mp3",waitForCompletion:false)) // установка звука при выстрела
        let bullet = SKSpriteNode(imageNamed: "torpedo")//устанволение картинки выстрела
        bullet.position = player.position//установка позиция
        bullet.position.y += 5
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)//установка размера
        bullet.physicsBody?.isDynamic = true //устанвока дианмики
        bullet.physicsBody?.categoryBitMask = bulletCategory // принадлежание к буллет
        bullet.physicsBody?.contactTestBitMask = alienCategory // обьект отслеживания прикосновения
        bullet.physicsBody?.collisionBitMask = 0 // значения по умолчанию
        bullet.physicsBody?.usesPreciseCollisionDetection = true // возможность соприкосновения с обьектом
        self.addChild(bullet)
        
        let animDuration :TimeInterval = 0.3 // скорость с которой наша анимация будет передвигаться
        var actions = [SKAction]()
        //массив будем записывать действия для того чтобы двигать к определенной точки а также удалять и чистить
        actions.append(SKAction.move(to:CGPoint(x:player.position.x,y:UIScreen.main.bounds.size.height + bullet.size.height),duration : animDuration))
            // показываем куда будем двигать и скакой чатсотой
        actions.append(SKAction.removeFromParent())// удаление после выхождения за рамки
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
