//
//  ViewController.swift
//  Finding Surfaces
//
//  Created by Aleksandr Avdukich on 17.09.2018.
//  Copyright © 2018 Sanel Avdukich. All rights reserved.
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
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints] //распознавание плоскости
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        //чтобы разрешить распознавание поверхности
        configuration.planeDetection = [.horizontal] //распознает пов-ти с помощью точек; пов-ть горизонтальная
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    //создает некую пов-ть
    func createCube(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.y)
        
        let geometry = SCNPlane(width: width, height: height)
        
        let cubeNode = SCNNode()
        cubeNode.position = SCNVector3(0, 0, 0.05)
        let cube = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        cube.firstMaterial?.diffuse.contents = UIColor.blue
        cubeNode.geometry = cube
        
        let planeNode = SCNNode()
        planeNode.geometry = geometry
        planeNode.opacity = 0.25
        planeNode.eulerAngles.x = -Float.pi / 2
        
        planeNode.addChildNode(cubeNode)
        
        return planeNode
    }
    
    //func createCube(plane)

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //мы проверяем что за тип объекта(может быть любой и картинкой и тд)
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        //после того как определилась пов-ть вызываем ф-ию
        let cube = createCube(planeAnchor: planeAnchor)
        node.addChildNode(cube)
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let floor = node.childNodes.first, let geometry = floor.geometry as? SCNPlane else { return }
        
        geometry.width = CGFloat(planeAnchor.extent.x)
        geometry.height = CGFloat(planeAnchor.extent.z)
        
        floor.position = SCNVector3(planeAnchor.center.x,0, planeAnchor.center.z)
    }
    
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
