//
//  GameViewController.swift
//  com.rian.gravityTest
//
//  Created by Andrey Pervushin on 29.07.17.
//  Copyright (c) 2017 Andrey Pervushin. All rights reserved.
//

import SceneKit
import QuartzCore

class GravityObject: NSObject {
    
    var vector = SCNVector4Make(CGFloat(arc4random_uniform(100)) - 50,
                                CGFloat(arc4random_uniform(100)) - 50,
                                0,
                                1000 + CGFloat(arc4random_uniform(100000)))
    var velocity = SCNVector3Make(0, 0, 0)
    
    func move() {
        vector.x += velocity.x
        vector.y += velocity.y
    }
    
    func updateVelocity(list: [GravityObject]) {
        for obj in list {
            if obj != self {
                let xDiff = obj.vector.x - self.vector.x
                let yDiff = obj.vector.y - self.vector.y
                
                let distance: CGFloat = 1 + pow(xDiff, 2.0) + pow(yDiff, 2.0)
                
                velocity.x += obj.vector.w * (xDiff / distance) / 10000000.0
                velocity.y += obj.vector.w * (yDiff / distance) / 10000000.0
            }
        }
    }
    
}

class GameViewController: NSViewController {
    
    var objects = [GravityObject]()
    var timer: Timer?
    
    @IBOutlet weak var gameView: GameView!
    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        self.gameView!.scene = scene
        self.gameView!.allowsCameraControl = true
        self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.black
        
        if let plane = scene.rootNode.childNode(withName: "plane", recursively: true) {
            
            plane.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.fragment: shader(objCount: 10)]
            
            for _ in 0..<40 {
                objects.append(GravityObject())
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true, block: { (t) in
                for obj in self.objects {
                    obj.updateVelocity(list: self.objects)
                }
                
                for obj in self.objects {
                    obj.move()
                }
                
                for i in 0..<self.objects.count {
                    plane.geometry?.setValue(self.objects[i].vector, forKey: "obj\(i)")
                }
            })
            
        }
    }
    
    func shader(objCount: Int) -> String {
        
        var shaderString = ""
        do {
            let url = Bundle.main.url(forResource: "Gravity", withExtension: "fsh")!
            
            shaderString = try String(contentsOf: url)
            
            var variables = [String]()
            var math = [String]()
            
            for i in 0..<objCount {
                variables.append("uniform vec4 obj\(i);")
                
                let distance = "distance(vec3(obj\(i).x, obj\(i).y, obj\(i).z), pos)"
                
                math.append(" obj\(i).w / ( \(distance) * \(distance))")
            }
            
            shaderString = shaderString.replacingOccurrences(of: "{uniforms}", with: variables.joined(separator: ""))
            
            shaderString = shaderString.replacingOccurrences(of: "{math}", with: math.joined(separator: "+"))
            
            
            return shaderString
            
        } catch {
        }
        
        return shaderString
        
    }

}
