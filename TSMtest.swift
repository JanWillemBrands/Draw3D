//
//  TSMtest.swift
//  Draw3D
//
//  Created by Johannes Brands on 26/03/2023.
//

import Foundation

struct Point {
    let x: Double
    let y: Double
}

func distance(from point1: CGPoint, to point2: Point) -> Double {
    return sqrt(pow(point1.x - point2.x, 2) + pow(point1.y - point2.y, 2))
}

func minimumSpanningTree(points: [Point]) -> [(Point, Point)] {
    var mst: [(Point, Point)] = []
    var visitedPoints: Set<Point> = []
    var remainingPoints = points
    
    func nearestNeighbor(to point: Point) -> Point {
        var minDistance = Double.infinity
        var nearestPoint: Point!
        
        for p in remainingPoints where p != point {
            let d = distance(from: point, to: p)
            if d < minDistance {
                minDistance = d
                nearestPoint = p
            }
        }
        
        return nearestPoint
    }
    
    let firstPoint = remainingPoints.removeFirst()
    visitedPoints.insert(firstPoint)
    
    while !remainingPoints.isEmpty {
        var minDistance = Double.infinity
        var nextEdge: (Point, Point)!
        
        for p in visitedPoints {
            let nearestPoint = nearestNeighbor(to: p)
            let d = distance(from: p, to: nearestPoint)
            if d < minDistance {
                minDistance = d
                nextEdge = (p, nearestPoint)
            }
        }
        
        mst.append(nextEdge)
        visitedPoints.insert(nextEdge.1)
        remainingPoints = remainingPoints.filter { $0 != nextEdge.1 }
    }
    
    return mst
}

func minimumWeightPerfectMatching(points: [Point]) -> [(Point, Point)] {
    var matching: [(Point, Point)] = []
    
    while !points.isEmpty {
        var minDistance = Double.infinity
        var pair: (Point, Point)!
        
        for i in 0..<points.count-1 {
            for j in i+1..<points.count {
                let d = distance(from: points[i], to: points[j])
                if d < minDistance {
                    minDistance = d
                    pair = (points[i], points[j])
                }
            }
        }
        
        matching.append(pair)
        points = points.filter { $0 != pair.0 && $0 != pair.1 }
    }
    
    return matching
}

func eulerianCircuit(multigraph: [Point: Set<Point>]) -> [Point] {
    var circuit: [Point] = []
    var stack: [Point] = []
    
    func dfs(at point: Point) {
        while !multigraph[point]!.isEmpty {
            let nextPoint = multigraph[point]!.removeFirst()
            multigraph[nextPoint]!.remove(point)
            dfs(at: nextPoint)
        }
        
        circuit.append(point)
    }
    
    dfs(at: multigraph.keys.first!)
    
    return circuit.reversed()
}

func christofides(points: [Point]) -> [Point] {
    let mst = minimumSpanningTree(points: points)
    
    var oddDegreeVertices: Set<Point> = []
    
    for edge in mst {
        if oddDegreeVertices.contains(edge.0) {
            oddDegreeVertices.remove(edge.0)
        } else {
            oddDegreeVertices.insert(edge.0)
        }
        
        if oddDegreeVertices.contains(edge.1) {
            oddDegreeVertices.remove(edge.1)
        } else {
            oddDegreeVertices.insert(edge.1)
        }
    }
    
    let mwpm = minimumWeightPerfectMatching(points: Array(oddDegreeVertices))
    
    var multigraph: [Point: Set<Point>] = [:]
    
    for edge in mst + mwpm {
        if multigraph[edge.0] == nil { multigraph[edge.0] = [] }
        if multigraph[edge.1] == nil { multigraph[edge.1] = [] }
        
        multigraph[edge.0]!.insert(edge.1)
        multigraph[edge.1]!.insert(edge.0)
    }
    
    let circuit = eulerianCircuit(multigraph: multigraph)
    
    var visitedPoints: Set<Point> = []
    
    return circuit.filter { visitedPoints.insert($0).inserted }
}
