//
//  ViewController.swift
//  MQTTDemo
//
//  Created by Daisy on 9/23/20.
//  Copyright © 2020 Daisy. All rights reserved.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {
    //let mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.1.6", port: 1883)
    var mqttClient: CocoaMQTT!
    
    func setUpMQTT() {
        let clientID = "iOS Device"
        mqttClient = CocoaMQTT(clientID: clientID, host: "192.168.1.6", port: 1883)
        mqttClient.username = "test"
        mqttClient.password = "public"
        mqttClient.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqttClient.keepAlive = 60
        mqttClient.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMQTT()
        // Do any additional setup after loading the view.
    }

    // Executed when switch changes states (ON or OFF)
    @IBAction func gpio40sw(_ sender: UISwitch) {
        if sender.isOn {
            mqttClient.publish("rpi/gpio", withString: "off")
        }
        else {
            mqttClient.publish("rpi/gpio", withString: "on")
        }
    }
    
    // Executed when Connect button pressed
    @IBAction func connectButton(_ sender: UIButton) {
        mqttClient.connect()
        //mqttClient.publish("rpi/gpio", withString: "on")
    }
    
    // Executed when Disconnect button pressed
    @IBAction func disconnectButton(_ sender: UIButton) {
        mqttClient.disconnect()

    }
}

