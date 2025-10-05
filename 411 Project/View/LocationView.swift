//
//  LocationView.swift
//  411 Project
//
//  Created by csuftitan on 10/4/25.
//

import SwiftUI

struct LocationView: View {
    var placeholder_location_title = "Denny's"
    var placeholder_bathroom_code = 12345
    var body: some View {
        VStack(spacing: 8){
            //This is for the name of the location
            Text(placeholder_location_title)
                .font(.custom("Noteworthy-Light", size: 32, relativeTo: .largeTitle))
                .padding(.top, 16)
                //.background(Color.green)
                .padding(.bottom, -13)
            
            //This is for the bathroom code of associaated location
            Text("\(placeholder_bathroom_code)")
                .font(.custom("Noteworthy-Light", size: 32, relativeTo: .largeTitle))
                .padding(.top, 16)
                //.background(Color.green)
                .padding(.bottom, -13)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        
        //Need to figure out how to get image of location??
        
        //End of Body
    }
}

#Preview {
    LocationView()
}
