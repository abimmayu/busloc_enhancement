import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.black]
    }

    var body: some View {
        NavigationStack{
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
