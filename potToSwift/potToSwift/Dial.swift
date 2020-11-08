//
//  Dial.swift
//  potToSwift
//
//  Created by Daisy on 9/28/20.
//  Copyright © 2020 Daisy. All rights reserved.
//

import UIKit

import SwiftUI
import Sliders

struct Dial: View {
    @State var value: Double = 0.5
    var body: some View {
        ZStack {
            Color(white: 0.2)
            RSlider($value).frame(width: 200, height: 200)
        }.navigationBarTitle("Default RSlider Style")
    }
}

struct Dial_Previews: PreviewProvider {
    static var previews: some View {
        Dial()
    }
}
