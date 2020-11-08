//
//  ViewController.swift
//  bitScoper
//
//  Created by Daisy Crego on 10/23/20.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI
import CocoaMQTT

class PanelValues : ObservableObject {
    
    @Published var dial1: Double = 0.0
    @Published var dial2: Double = 0.0
    
    @Published var channelA : [Double]?
    @Published var channelB : [Double]?
}

class RandomClass { }
let x = RandomClass()

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    var timer : Timer!
    var mqttClient: CocoaMQTT!
    var date : NSDate?
    var dateFormatter : DateFormatter?
    @ObservedObject var panelValues = PanelValues()
    @Published var dial1 : Double = 0.0
    @Published var dial2 : Double = 0.0
    @Published var scopeText : String = "bitScoper?"
    var currAnchor : ARImageAnchor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMQTT()
                
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        print("children: ")
        print(self.children)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
                
              configuration.trackingImages = imagesToTrack
                  
            // this tells ARKit how many images it is supposed to track simultaneously,
            //ARKit can do upto 100
              configuration.maximumNumberOfTrackedImages = 1
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        print("renderer()")
        let node = SCNNode()
            // Cast the found anchor as image anchor
            guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
            self.currAnchor = imageAnchor
            // get the name of the image from the anchor
            guard let imageName = imageAnchor.name else { return nil }
            
            // Check if the name of the detected image is the one you want
            if imageName == "thompson"  {
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                     height: imageAnchor.referenceImage.physicalSize.height)
                
                
                let planeNode = SCNNode(geometry: plane)
                // When a plane geometry is created, by default it is oriented vertically
                // so we have to rotate it on X-axis by -90 degrees to
                // make it flat to the image detected
                planeNode.eulerAngles.x = -.pi / 2
                
                createHostingController(for: planeNode)
                
                node.addChildNode(planeNode)
                return node
            } else {
                return nil
            }
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
    
    func createHostingController(for node: SCNNode) {
            // create a hosting controller with SwiftUI view
        
        let arVC = UIHostingController(rootView: SwiftUIARCardView(panelValues: self.panelValues))
            
            // Do this on the main thread
            DispatchQueue.main.async {
                arVC.willMove(toParent: self)
                // make the hosting VC a child to the main view controller
                self.addChild(arVC)
                
                // set the pixel size of the Card View
                arVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
                
                // add the ar card view as a subview to the main view
                self.view.addSubview(arVC.view)
                
                // render the view on the plane geometry as a material
                self.show(hostingVC: arVC, on: node)
            }
        }
        
        func show(hostingVC: UIHostingController<SwiftUIARCardView>, on node: SCNNode) {
            // create a new material
            let material = SCNMaterial()
            
            // this allows the card to render transparent parts the right way
            hostingVC.view.isOpaque = false
            
            // set the diffuse of the material to the view of the Hosting View Controller
            material.diffuse.contents = hostingVC.view
            
            // Set the material to the geometry of the node (plane geometry)
            node.geometry?.materials = [material]
            
            hostingVC.view.backgroundColor = UIColor.clear
        }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension ViewController : CocoaMQTTDelegate {
    
    func setupMQTT() {
        let clientID = "iOS Device"
        mqttClient = CocoaMQTT(clientID: clientID, host: "192.168.1.6", port: 1883)
        mqttClient.username = "test"
        mqttClient.password = "public"
        mqttClient.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqttClient.keepAlive = 60
        mqttClient.delegate = self
        mqttClient.connect()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(mqtt):\(ack)")
        mqttClient.subscribe("rpi/ios")
        mqttClient.subscribe("rpi/scope")
        //sliderState.text = "Subscribed"
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck \(mqtt):\(id)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("didSubscribeTopic \(mqtt):\(topics)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic \(mqtt):\(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidPing \(mqtt)")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong \(mqtt)")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("mqttDidDisconnect")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
       print("didConnect")
       
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        //print("didReceiveMessage")
        //sliderState.text = "didReceiveMessage"
        if message.topic == "rpi/scope" {
            if let msgString = message.string {
                let json = convertStringToDictionary(text: msgString)
                self.panelValues.channelA = json?["a"] as! [Double]
                self.panelValues.channelB = json?["a"] as! [Double]
                
                print(self.panelValues.channelA)
                //print(json!["a"]!)
                //print(json!["b"]!)
                //self.panelValues.channelA = json!["a"]! as! [Double]
                //self.panelValues.channelB = json!["a"]! as! [Double]
            }
        } else if message.topic == "rpi/ios" {
            if let msgString = message.string {
                //print(msgString)
                
                let msgObj = msgString.toJSON()
                
                if let msgDict = msgObj as? Dictionary<String, Double> {
                    //print(msgDict["dial1"]!)
                    //print(msgDict["dial2"]!)
                    panelValues.dial1 = msgDict["dial1"]!
                    panelValues.dial2 = msgDict["dial2"]!
                } else {
                    //print("not a dict")
                    //print(msgObj)
                }
                
                
                //let newDial1 : Double = msgObj["dial1"] as! Double
                //let newDial2 : Double = msgObj["dial2"] as! Double
                //panelValues.textToShow = "Reading encoders..."
                //panelValues.dial1 = newDial1
                //panelValues.dial2 = newDial2
                //renderer(sceneView, nodeFor: currAnchor)
                
                //print(self.sceneView.)
                
                //Every
                
                //self.view.subviews[0].removeFromSuperview()
                
                
                //self.view.subviews[0] = SwiftUIARCardView("bitScoped!")
                //sliderState.text = msgString
                //let str = "100"
                //if let n = NumberFormatter().number(from: str) {
                 //   dial.endPointValue = CGFloat(truncating: n)
                  //  //let f = CGFloat(n)
                //}
            }
        }
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
        if let msgString = message.string {
            print(msgString)
            print(self.view.subviews)
        }
    }
}

