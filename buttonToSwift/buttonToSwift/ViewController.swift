//
//  ViewController.swift
//  buttonToSwift
//
//  Created by Daisy on 9/24/20.
//  Copyright © 2020 Daisy. All rights reserved.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController, CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(mqtt):\(ack)")
        mqttClient.subscribe("rpi/gpio")
        buttonState.text = "Subscribed"
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
        print("mqttDidDisconnect \(mqtt):\(err)")
    }
    

    @IBOutlet weak var light: UISwitch!
    @IBOutlet weak var buttonState: UILabel!
    
    var mqttClient: CocoaMQTT!
    
    func setUpMQTT() {
        let clientID = "iOS Device"
        mqttClient = CocoaMQTT(clientID: clientID, host: "192.168.1.6", port: 1883)
        mqttClient.username = "test"
        mqttClient.password = "public"
        mqttClient.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqttClient.keepAlive = 60
        mqttClient.delegate = self
        mqttClient.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMQTT()
    }
    
    @IBAction func connectButton(_ sender: UIButton) {
        mqttClient.connect()
        buttonState.text = "Connected"
    }
    
    @IBAction func disconnectButton(_ sender: UIButton) {
        mqttClient.disconnect()
        buttonState.text = "Disconnected"
    }
    
     func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect")
     }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
      
      buttonState.text = "didReceiveMessage"
      if let msgString = message.string {
        if light.isOn {
            buttonState.text = "on"
        } else {
            buttonState.text = "off"
        }
        if msgString == "buttonPressed" {
            
            if light.isOn {
                mqttClient.publish("rpi/gpio", withString: "on")
                light.setOn(false, animated: true)
                buttonState.text = "on"
            } else {
                mqttClient.publish("rpi/gpio", withString:"off")
                light.setOn(true, animated: true)
                buttonState.text = "off"
            }
        }
      }
      
     }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
        if let msgString = message.string {
            print(msgString)
        }
    }
    
    
}

