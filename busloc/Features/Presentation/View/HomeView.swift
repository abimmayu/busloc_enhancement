//
//  home view.swift
//  busloc
//
//  Created by Aqua on 27/03/25.
//
import SwiftUI
import UIKit

let busData: [Bus] = BusData.getData()

struct HomeView: View {
    @State private var selectedBus: Bus = busData[0]
    @State private var isNavigating = false
    @State private var selectedTab: Int = 0
    @State private var showMapView = false
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .fill(Color.orange)
                    .frame(height: 50)
                ZStack {
                    HalfCircle()
                        .fill(Color.orange)
                        .frame(height: 180)
                        .overlay(
                            Text("Start your journey!")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        )
                    Circle()
                        .stroke(Color.orange, lineWidth: 8)
                        .background(Circle().fill(Color.white))
                        .frame(width: 200, height: 130)
                        .overlay(
                            Image("Kucing")
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .padding(10)
                        )
                        .offset(y: 90)
                }
                .padding(.bottom, 100)
                
                Divider()
                    .padding(.bottom, 20)
                Text("All Buses:")
                    .font(.headline)
                    .padding(.leading, -145)
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)
                    
                ScrollView {
                    VStack {
                        ForEach(Array(busData.enumerated()), id: \.element) { index, bus in
                            TicketMask(bus: bus, onClick: {
                                selectedBus = bus
                                isNavigating = true
                            })
                        }
                        Spacer()
                    }
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.top)
            .background(
                NavigationLink(destination: BusStopList(bus: selectedBus), isActive: $isNavigating) { EmptyView() }.hidden()
            )
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            MapViewControllerWrapper()
                    .background(Color.white)
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(2)
        }
        .background(Color.white)
        .navigationBarTitle(
            selectedTab == 0 ? Text("") :
                selectedTab == 1 ? Text("Search The Route") :
                Text("Search Nearest Bus-Stop"), displayMode: .inline
        )
    }
}

struct MapViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct HalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                    radius: rect.width / 2,
                    startAngle: .degrees(0),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

#Preview {
    ContentView()
}
