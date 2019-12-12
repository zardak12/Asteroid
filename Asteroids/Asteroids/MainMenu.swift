import SpriteKit

class MainMenu: SKScene {
    var starfield :SKEmitterNode!
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labellevelBtnNode:SKLabelNode!
    
    override func didMove(to view: SKView) {
        // присвоение и установка новых картинок на наши кнопки
        starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        starfield.advanceSimulationTime(10)//установка для анимации времени
        newGameBtnNode = self.childNode(withName: "newGameBtn") as! SKSpriteNode
         newGameBtnNode.texture = SKTexture(imageNamed: "swift_newGameBtn")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    { //срабатывает когда мы нажимаем на экран
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location) //сохранение обьектов на которые нажал пользователь
            if nodesArray.first?.name == "newGameBtn" { // переход
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size:UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene,transition: transition)
            }
        }
    }

}
