//
//  ContentView.swift
//  411 Project
//
//  Created by csuftitan on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var nearest_restroom = ""
    var body: some View {
        //This is for the title
        VStack(spacing: 4){
            Text("Restroom Runner")
                .font(.custom("Noteworthy-Light", size: 32, relativeTo: .largeTitle))
                .padding(.top, 16)
                //.background(Color.green)
                .padding(.bottom, -13)
        }
        
        //This is for the searchbar
        NavigationStack {
 
        }
        .navigationTitle("Restroom Runner")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $nearest_restroom,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Nearest Restroom")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        
        
        
        
        //End of body
    }
}

#Preview {
    ContentView()
}
