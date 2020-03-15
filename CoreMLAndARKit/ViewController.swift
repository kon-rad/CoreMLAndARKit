//
//  ViewController.swift
//  CoreMLAndARKit
//
//  Created by Konrad Gnat on 3/14/20.
//  Copyright © 2020 Konrad Gnat. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        let text = SCNText(string: "Hello ARKit", extrusionDepth: 0)
        
        text.font = UIFont(name: "Futura", size: 0.15)
        text.firstMaterial?.diffuse.contents = UIColor.orange
        text.firstMaterial?.specular.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(0, 0, -0.5)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        scene.rootNode.addChildNode(textNode)
        
//        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIColor.red
//
//        box.materials = [material]
//
//        let node = SCNNode(geometry: box)
//
//        node.position = SCNVector3(0, 0, -0.5)
//
//        scene.rootNode.addChildNode(node)
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
