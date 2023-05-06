//
//  Draw3DApp.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/10/2022.
//

// https://developer.apple.com/documentation/quicklookthumbnailing/creating_quick_look_thumbnails_to_preview_files_in_your_app
// https://stackoverflow.com/questions/48190891/what-3d-model-formats-are-supported-by-arkit
// https://developer.apple.com/documentation/modelio
// https://developer.apple.com/documentation/modelio/mdlasset/asset_file_types
// https://stackoverflow.com/questions/50846627/how-to-create-usdz-file-using-xcode-converter/50867018#50867018

import os
import SwiftUI

let logger = Logger(subsystem: "Draw3D", category: "bla")

@main
struct Draw3DApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
