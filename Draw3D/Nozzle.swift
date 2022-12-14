//
//  Nozzle.swift
//  Draw3D
//
//  Created by Johannes Brands on 08/11/2022.
//

import SceneKit

var nozzle: SCNNode {
    let node = SCNNode()
    
    let nozzleRadius = 0.01
    let plasmaHeight = 0.01
    let waterHeight = 0.1
    
    // TODO: make nozzle a subclass of SCNNode with a settable properties like color and speed
    let plasmaColor = UIColor.orange
    
    let plasma = SCNCylinder(radius: nozzleRadius, height: plasmaHeight)
    plasma.firstMaterial?.diffuse.contents = plasmaColor
    plasma.firstMaterial?.emission.contents = plasmaColor
    let plasmaNode = SCNNode(geometry: plasma)
    plasmaNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    plasmaNode.position = SCNVector3(x: 0, y: Float(plasmaHeight/2), z: 0)
    node.addChildNode(plasmaNode)
    
    let water = SCNCylinder(radius: nozzleRadius, height: waterHeight)
    water.firstMaterial?.diffuse.contents = UIColor.blue
    let waterNode = SCNNode(geometry: water)
    waterNode.opacity = 0.8
    waterNode.eulerAngles = SCNVector3(x: 0, y: 0, z: 0)
    waterNode.position = SCNVector3(x: 0, y: Float(plasmaHeight+waterHeight/2), z: 0)
    node.addChildNode(waterNode)
    
    node.name = "nozzle"

    return node
}

struct Waypoint {
//    let position: SCNVector3
//    let orientation: SCNVector3
    let position: SIMD3<Float>
    let orientation: SIMD3<Float>
}

func move(node: SCNNode, along path: [Waypoint]) {
    var actionSequence: [SCNAction] = []
    
    for point in path {
        
        let reposition = SCNAction.run { node in
//            let originalOrientation = SIMD3(Float(0.0), Float(1.0), Float(0.0))
            let originalOrientation = SIMD3<Float>(0.0, 1.0, 0.0)
//            let desiredOrientation = SIMD3(x: point.orientation.x, y: point.orientation.y, z: point.orientation.z)
            let desiredOrientation = point.orientation
            let rotation = simd_quatf(from: originalOrientation, to: desiredOrientation)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2
//            node.position = point.position
            node.simdPosition = point.position
            node.simdOrientation = rotation
            SCNTransaction.commit()
        }
        // this 'run' action returns immediately, so we need to apply a group delay to sync.
        let delay = SCNAction.wait(duration: 2)
        let sync = SCNAction.group([reposition, delay])
        actionSequence.append(sync)
    }
    
    let moveSequence = SCNAction.sequence(actionSequence)
    let moveLoop = SCNAction.repeatForever(moveSequence)

    node.runAction(moveLoop)
}

// simple greedy cheapest neighbour
func optimized2(_ path: [Waypoint]) -> [Waypoint] {
//    let start = Waypoint(position: SCNVector3(0, 0, 0), orientation: SCNVector3(0, 0, 0))
    let start = Waypoint(position: SIMD3(0, 0, 0), orientation: SIMD3(0, 0, 0))

    var chaotic = path
    var ordered = [start]
    
    var current = start
    
    while !chaotic.isEmpty {
        // calculate the costs from the current point to all points in chaotic
        let costs = chaotic.map { point in cost(A: current, B: point) }
        // find the index of the cheapest next point
        let cheap = costs.enumerated().reduce(0) { i, p in costs[i] < p.element ? i : p.offset }
        // make the cheapest point current and move it from chaotic to ordered
        current = chaotic[cheap]
        ordered.append(current)
        chaotic.remove(at: cheap)
    }
    
    return ordered
}

// cheapest insertion into partial path
func optimized(_ path: [Waypoint]) -> [Waypoint] {
//    let start = Waypoint(position: SCNVector3(0, 0, 0), orientation: SCNVector3(0, 0, 0))
    let start = Waypoint(position: SIMD3(0, 0, 0), orientation: SIMD3(0, 0, 0))

    var chaotic = path
    var ordered = [start]
        
    while !chaotic.isEmpty {
        // get the next chaotic point
        let point = chaotic.removeFirst()
        // find the cheapest place to insert this point
        var costs: [Float] = []
        for i in ordered.indices {
            // create test paths by inserting the point at successive locations in the partial ordered path
            var testPath = ordered
            testPath.insert(point, at: i+1)
            // calculate and store the total cost for this test path
            var total: Float = 0.0
            if testPath.count > 1 {
                var a = testPath[0]
                for i in 1 ..< testPath.count {
                    let b = testPath[i]
                    total += cost(A: a, B: b)
                    a = b
                }
            }
//            let cost = ordered.enumerated().reduce(0.0) { i, p in 0.0 }
            costs.append(total)
        }
        // find the index of the cheapest insertion
        let cheap = costs.enumerated().reduce(0) { i, p in costs[i] < p.element ? i : p.offset }
        // insert the point in ordered at the cheapest location
        ordered.insert(point, at: cheap+1)
    }
    
    return ordered
}

func cost(A: Waypoint, B: Waypoint) -> Float {
    // TODO: review cost parameters
    let costPerMeter: Float = 1.0   // Fanuc CRX-10iA travels ~ 1 m/s
    let costPerRadian: Float = 0.1  // Fanuc CRX-10iA rotates ~ 360/s < 0.1 rad/s
    
    let positionCost = length(A.position - B.position) * costPerMeter
    let orientationCost = acos(dot(normalize(A.orientation), normalize(B.orientation))) * costPerRadian
    
    return positionCost + orientationCost
}
