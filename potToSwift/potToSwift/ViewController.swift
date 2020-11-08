//
//  ViewController.swift
//  potToSwift
//
//  Created by Daisy on 9/27/20.
//  Copyright © 2020 Daisy. All rights reserved.
//

import UIKit
import CocoaMQTT
import HGCircularSlider

class ViewController: UIViewController {

    
    @IBOutlet weak var sliderState: UILabel!
    //@IBOutlet weak var slider: UISlider!
    
    var mqttClient: CocoaMQTT!
    @IBOutlet var dial: CircularSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMQTT()
        dial = CircularSlider()
        dial.minimumValue = 0
        dial.maximumValue = 100
        dial.endPointValue = 0.2
    }

    @IBAction func connectButton(_ sender: UIButton) {
        mqttClient.connect()
        sliderState.text = "Connected"
    }
    
    @IBAction func disconnectButton(_ sender: UIButton) {
        mqttClient.disconnect()
        sliderState.text = "Disconnected"
    }
    
    @IBAction func pollValue(_ sender: UIButton) {
        mqttClient.publish("rpi/gpio", withString: "poll")
        sliderState.text = "Polling value"
    }
}

extension ViewController : CocoaMQTTDelegate {
    
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
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck \(mqtt):\(ack)")
        mqttClient.subscribe("rpi/ios")
        sliderState.text = "Subscribed"
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
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceiveMessage")
        //sliderState.text = "didReceiveMessage"
        if let msgString = message.string {
            print(msgString)
            sliderState.text = msgString
            let str = "32.4"
            if let n = NumberFormatter().number(from: str) {
                dial.endPointValue = CGFloat(truncating: n)
                //let f = CGFloat(n)
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


