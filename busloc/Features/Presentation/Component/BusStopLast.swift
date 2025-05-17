//
//  BusStopLast.swift
//  Bus-Loc
//
//  Created by Atilla Rizkyara on 07/04/25.
//

import SwiftUI

struct BusStopLast: View {
    let stopName: String

    var body: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.orange)
            }

            Text(stopName)
                .font(.body)
                .foregroundColor(.black)
                .padding(.leading, 10)
                .padding(.top, -4)
        }
        .padding(-5)
    }
}

#Preview {
    BusStopLast(stopName: "Stop 12")
}
