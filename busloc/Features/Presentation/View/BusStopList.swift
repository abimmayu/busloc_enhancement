//
//  BusStopList.swift
//  Bus-Loc
//
//  Created by Atilla Rizkyara on 07/04/25.
//
import SwiftUI

struct BusStopList: View {
    let bus: Bus
    
//    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    ForEach(bus.route.indices, id: \.self) { index in
                        let stop = bus.route[index]
                        
                        if index == bus.route.count - 1 {
                            BusStopLast(stopName: stop)
                        } else {
                            BusStopDefault(stopName: stop)
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.leading, 50)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .navigationTitle("Rute \(bus.name)")
        .navigationBarTitleDisplayMode(.inline)
            }
        }


#Preview {
    BusStopList(bus: BusData.getData().first!)
}
