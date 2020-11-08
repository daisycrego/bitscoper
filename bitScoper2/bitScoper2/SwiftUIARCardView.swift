//
//  SwiftUIARCardView.swift
//  bitScoper
//
//  Created by Daisy Crego on 10/23/20.
//

import SwiftUI
import ARKit
import Charts
import SwiftUICharts

struct SwiftUIARCardView: View {
    @ObservedObject var panelValues : PanelValues
    
    //weak var chartView: ScopeLineChartView!
    
    @State var data1: [Double] = (0..<16).map { _ in .random(in: 9.0...100.0) }
    @State var data2: [Double] = (0..<16).map { _ in .random(in: 9.0...100.0) }
    
    var textToShow : String = "Bitscoper"
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 0)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]),
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                //LineChartView(data: panelValues.channelA ?? data1, title: "A" )
                //LineChartView(data: panelValues.channelB ?? data2, title: "B" )
                
                var channelA = panelValues.channelA != nil ? panelValues.channelA! : data1
                var channelB = panelValues.channelB != nil ? panelValues.channelB! : data1
                //MultiLineChartView(data: [(channelA, GradientColors.green), (channelB, GradientColors.purple)], title: "A and B")
                
                Path { path in
                    path.move(to: CGPoint(x: 100, y: 100))
                    path.addLine(to: CGPoint(x: 100, y: 300))
                    path.addLine(to: CGPoint(x: 300, y: 300))
                    }.fill(Color.green)
                }
                /*
                Text(textToShow)
                    .foregroundColor(.white)
                    .bold().font(.title)
                 */
                
                HStack {
                    //Image("thompson").resizable().aspectRatio(contentMode: .fit).position(x: 130, y: 180)
                    
                    /*VStack {
                        HStack {
                            Text("1: ")
                                .foregroundColor(.yellow)
                                .bold().font(.system(size:80))
                            Text(String(format: "%.1f", panelValues.dial1))
                                .foregroundColor(.white)
                                .font(.system(size:60))
                        }
                        
                        HStack {
                            Text("2: ")
                                .foregroundColor(.yellow)
                                .bold().font(.system(size:80))
                            Text(String(format: "%.1f", panelValues.dial2))
                                .foregroundColor(.white)
                                .font(.system(size:60))
                        }
                    }.position(x: 120, y: 170)
 */
                    
                }
                /*
                Button(action: {
                    panelValues.dial1 += 1
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                        Text("hi")
                    }
                }
 */
            }
        }
    }
