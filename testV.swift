//
//  testV.swift
//  Draw3D
//
//  Created by Johannes Brands on 28/02/2023.
//

import SwiftUI

struct testV: View {
    var body: some View {
        ZStack {
            Color.red
                .frame(width: 200,height: 200, alignment: .bottom)
            Color.green
                .frame(width: 100,height: 100)
                .offset(CGSize(width: 50, height: 50))
        }
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct testV_Previews: PreviewProvider {
    static var previews: some View {
        testV()
    }
}
