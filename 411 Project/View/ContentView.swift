import SwiftUI
import UIKit

// This SwiftUI view will act as the bridge to your UIKit components.
struct ContentView: View {
    var body: some View {
        MapViewControllerRepresentable() // Allows the map to extend to the screen edges
    }
}

// This struct makes your UIKit MapViewController usable within SwiftUI.
struct MapViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        // We embed the MapViewController inside a UINavigationController.
        // This is crucial because your MapViewController sets a title and bar button items,
        // which only appear if it's part of a navigation stack.
        let mapVC = MapViewController()
        let navController = UINavigationController(rootViewController: mapVC)
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // This app doesn't need to pass data from SwiftUI back to the view controller,
        // so we can leave this empty.
    }
}

// A preview provider for Xcode Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().ignoresSafeArea()//maybe this will do something good for us with the title idk
    }
}
