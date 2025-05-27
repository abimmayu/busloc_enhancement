//
//  RouteResultCard.swift
//  busloc
//
//  Created by Abim on 16/05/25.
//

import SwiftUI

struct RouteResultCard: View {
    var isSelected: Bool = false
    var time: String?
    var routeName: String?
    var route: String?
    var stopcount: Int?
    
    var body: some View {
        HStack {
            VStack {
                Text("ETA")
                    .font(.caption)
                    .foregroundColor(Color("PrimaryDark"))
                Text(time ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryDark"))
                Text("min")
                    .font(.body)
                    .foregroundColor(Color("PrimaryDark"))
            }
            .frame(maxWidth: 100)
            Divider()
                .frame(width: 1)
            VStack(alignment: .leading) {
                HStack {
                    Text(routeName ?? "")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color("PrimaryDark"))
                    Spacer()
                    Image("RouteIcon")
                }
                Spacer()
                HStack {
                    Text(route ?? "")
                        .font(.footnote)
                        .foregroundColor(Color("PrimaryDark"))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Text("\(stopcount ?? 0) stops")
                        .font(.footnote)
                        .foregroundColor(Color("PrimaryDark"))
                        
                }
            }
            .padding(4)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(isSelected ? Color("PrimaryLighter") : .white)
        .cornerRadius(8)
        
    }
}

#Preview {
    RouteResultCard(
        routeName: "Rute 1",
        route: "SML Plaza - Halte Sektor 1.3 Halte Sektor 1.3"
    )
}
