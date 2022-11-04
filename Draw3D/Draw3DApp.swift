//
//  Draw3DApp.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

import os
import SwiftUI

let logger = Logger(subsystem: "Draw3D", category: "bla")

@main
struct Draw3DApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(originalTexture: UIImage(named: "KanaKanaTexture")!)
        }
    }
}
