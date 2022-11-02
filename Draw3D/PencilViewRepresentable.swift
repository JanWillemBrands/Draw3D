//
//  PencilViewContainer.swift
//  Draw3D
//
//  Created by Johannes Brands on 27/10/2022.
//

import SwiftUI
import PencilKit

struct PencilViewRepresentable: UIViewRepresentable {
    let canvasView: PKCanvasView
    let picker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
//        let adjustedStrokes = uiView.drawing.strokes.map { stroke -> PKStroke in
//            var stroke = stroke
//            // Adjust the stroke ink to be black.
//            stroke.ink = PKInk(.pen, color: .black)
//            
//            // Adjust the stroke widths to be more uniform.
//            let newPoints = stroke.path.indices.compactMap { index -> PKStrokePoint? in
//                let point = stroke.path[index]
//                let adjustedPoint = PKStrokePoint(
//                    location: point.location,
//                    timeOffset: point.timeOffset,
//                    size: CGSize(width: point.size.width * 0.8, height: point.size.height * 0.8),
//                    opacity: point.opacity,
//                    force: point.force,
//                    azimuth: point.azimuth,
//                    altitude: point.altitude)
//                return adjustedPoint
//            }
//            stroke.path = PKStrokePath(controlPoints: newPoints, creationDate: stroke.path.creationDate)
//            
//            return stroke
//        }
//
//        uiView.drawing.strokes.append(contentsOf: adjustedStrokes)
        
        picker.addObserver(canvasView)
        picker.setVisible(true, forFirstResponder: uiView)
        canvasView.tool = PKInkingTool(.pen, color: .tintColor, width: .infinity)
        DispatchQueue.main.async {
            uiView.becomeFirstResponder()
        }
    }
}
