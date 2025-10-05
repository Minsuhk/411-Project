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
        //We want to edit this part later on so that a valid location from google maps is selectable
        //Upon selecting, we send the name of the location to the LocationView while also changing screen to LocationView
        //LocationView will display info from database about name, address, picture of location(?), and passcode for it
        NavigationStack {
            //This is for the google map stuff??
//            VStack(spacing: 12) {
//                GoogleMapView(center: .init(lattitude: 33.8830,
//                                            longitude: -117.8850)
//                )
//                .frame(height: 320)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .shadow(radius: 3)
//                Spacer()
//            }
//            .padding(.horizontal)
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
