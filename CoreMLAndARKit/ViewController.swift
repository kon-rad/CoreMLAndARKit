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
import Vision

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var resnetModel = Resnet50()
    
    private var hitTestResult :ARHitTestResult!
    
    private var visionRequests = [VNRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
//        let text = SCNText(string: "Hello ARKit", extrusionDepth: 0)
//
//        text.font = UIFont(name: "Futura", size: 0.15)
//        text.firstMaterial?.diffuse.contents = UIColor.orange
//        text.firstMaterial?.specular.contents = UIColor.white
//
//        let textNode = SCNNode(geometry: text)
//        textNode.position = SCNVector3(0, 0, -0.5)
//        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
//
//        scene.rootNode.addChildNode(textNode)
//
        // example demo, creating a simple 3D box
        
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
        
        registerGestureRecognizers()
    }
    
    private func registerGestureRecognizers() {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        print("registerGestureRecognizers")
    }
    
    @objc func tapped(recognizer :UIGestureRecognizer) {
        print("tapped")
        
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = self.sceneView.center
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
        
        if hitTestResults.isEmpty {
            return
        }
        
        guard let hitTestResult = hitTestResults.first else {
            return
        }
        
        self.hitTestResult = hitTestResult
        let pixelBuffer = currentFrame.capturedImage
        
        performVisionRequest(pixelBuffer: pixelBuffer)
    }
    
    private func displayPredicitons(text :String) {
        
        let node = createText(text: text)
        
        node.position = SCNVector3(self.hitTestResult.worldTransform.columns.3.x,
                                       self.hitTestResult.worldTransform.columns.3.y,
                                       self.hitTestResult.worldTransform.columns.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(node)
        
        
    }
    
    private func createText(text :String) -> SCNNode {
        
        let parentNode = SCNNode()
        
        // create sphere
        let sphere = SCNSphere(radius: 0.01)
        
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor.orange
        sphere.firstMaterial = sphereMaterial
        let sphereNode = SCNNode(geometry: sphere)
        
        // create text
        let textGeometry = SCNText(string: text, extrusionDepth: 0)
        
        textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
        textGeometry.firstMaterial?.diffuse.contents = UIColor.orange
        textGeometry.firstMaterial?.specular.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true
        
        let font = UIFont(name: "Futura", size: 0.15)
        textGeometry.font = font
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3Make(0.2, 0.2, 0.2)
        
        parentNode.addChildNode(sphereNode)
        parentNode.addChildNode(textNode)
        return parentNode
        
    }
    
    private func performVisionRequest(pixelBuffer :CVPixelBuffer) {
        
        let visionModel = try! VNCoreMLModel(for: self.resnetModel.model)
        
        let request = VNCoreMLRequest(model: visionModel) { request, error in
            
            if error != nil {
                return
            }
            
            guard let observations = request.results else {
                return
            }
            
            let observation = observations.first as! VNClassificationObservation
            
            print("Name \(observation.identifier) and confidence is \(observation.confidence)")
            
            DispatchQueue.main.async {
                self.displayPredicitons(text: observation.identifier)
            }
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        self.visionRequests = [request]
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored, options: [:])
        
        DispatchQueue.global().async {
            try! imageRequestHandler.perform(self.visionRequests)
        }
        
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
