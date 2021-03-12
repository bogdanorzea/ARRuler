//
//  ViewController.swift
//  ARRuler
//
//  Created by Bogdan Orzea on 2021-03-12.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.debugOptions = .showFeaturePoints
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Set plane detection
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (dotNodes.count >= 2) {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }

            dotNodes = []
        }

        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneInfinite, alignment: .any) else {
                return
            }

            let hitResults = sceneView.session.raycast(query)
            if let hitResult = hitResults.first {
                addDot(at: hitResult)
            }
        }
    }

    func addDot(at location: ARRaycastResult) {
        let sphere = SCNSphere(radius: 0.01)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        sphere.materials = [material]

        let dotNode = SCNNode(geometry: sphere)
        dotNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y,
            z: location.worldTransform.columns.3.z
        )

        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)

        if (dotNodes.count >= 2) {
            calculateDistance()
        }
    }

    func calculateDistance() {
        let start = dotNodes[0].position
        let end = dotNodes[1].position

        let distance = abs(sqrt(pow(end.x - start.x, 2) + pow(end.y - start.y, 2) + pow(end.z - end.z, 2)))

        updateText(text: "\(distance)", at: end)
    }

    func updateText(text: String, at position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red

        textNode.removeFromParentNode()
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)

        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
