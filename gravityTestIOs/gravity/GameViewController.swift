//
//  GameViewController.swift
//  gravity
//
//  Created by Andrey Pervushin on 26.07.17.
//  Copyright © 2017 Andrey Pervushin. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GravityObject: NSObject {
    
    var vector = SCNVector4Make(Float(arc4random_uniform(50)) - 25,
                                Float(arc4random_uniform(50)) - 25,
                                0,
                                1000 + 1000 * Float(arc4random_uniform(50)))
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
                
                let distance: Float = 1 + pow(xDiff, 2.0) + pow(yDiff, 2.0)
                
                velocity.x += obj.vector.w * (xDiff / distance) / 1000000.0
                velocity.y += obj.vector.w * (yDiff / distance) / 1000000.0
            }
        }
    }
    
}

class GameViewController: UIViewController {
    
    var objects = [GravityObject]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        let scnView = self.view as! SCNView
        scnView.preferredFramesPerSecond = 60
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.orange
        
        if let plane = scene.rootNode.childNode(withName: "plane", recursively: true) {
            
            plane.geometry?.shaderModifiers = [SCNShaderModifierEntryPoint.fragment: shader(objCount: 10)]
            
            for i in 0..<10 {
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
