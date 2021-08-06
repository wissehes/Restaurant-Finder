//
//  RestaurantView.swift
//  Restaurant Finder
//
//  Created by Wisse Hes on 02/08/2021.
//

import SwiftUI
import MapKit

struct RestaurantView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var restaurant: YelpBusiness?
    
    @State var mapSheetShown = false
    @State var directionSheetShown = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    if restaurant?.imageURL != nil && restaurant?.imageURL.count != 0 {
                        HStack {
                            Spacer()
                            AsyncImage(url: URL(string: restaurant!.imageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                //                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(16)
                                //                                    .frame(maxWidth: 250.0, maxHeight: 250.0)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 250.0, height: 250.0)
                            }
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Text("Open")
                        Spacer()
                        Text(restaurant!.isClosed ? "No" : "Yes")
                    }
                    
                    HStack {
                        Text(restaurant!.categories.count == 1 ? "Category" : "Categories")
                        Spacer()
                        Text(restaurant!.categories.map { $0.title }.joined(separator: ", "))
                    }
                    
//                    Button("Show map") {
//                        mapSheetShown.toggle()
//                    }
                    
                    Button("Get directions", action: directionsActionSheet)
                    
                    HStack {
                        Link("Open on Yelp", destination: URL(string: restaurant!.url)!)
                    }
                    
                }.navigationTitle(Text(restaurant?.name ?? "Unknown")).navigationBarItems(leading: closeButton())
                    .sheet(isPresented: $mapSheetShown) {
                        MapView(latitude: restaurant!.coordinates.latitude, longitude: restaurant!.coordinates.longitude, name: restaurant!.name)
                    }
                    .actionSheet(isPresented: $directionSheetShown) {
                        let lat = restaurant!.coordinates.latitude
                        let lon = restaurant!.coordinates.longitude
                        let add = restaurant!.location.address1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                        let addString = String(describing: add!)
                        
                        return ActionSheet(title: Text("Directions"), message: Text("Which app would you like to use for directions?"), buttons: [
                            .default(Text("Google Maps"), action: {
                            let url = URL(string: "comgooglemaps://?q=\(addString)&center=\(lat),\(lon)")!

                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }),
                            .default(Text("Apple Maps"), action: openInAppleMaps),
                            .cancel()
                        ])
                    }
            }
        }
    }
    
    func closeButton() -> some View {
        Button("Close") {
            dismiss()
        }
    }
    
    func directionsActionSheet() {
        let googleMapsAvailable = UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")! as URL)
        
        if googleMapsAvailable {
            directionSheetShown.toggle()

        } else {
            openInAppleMaps()
        }
        
    }
    
    func openInAppleMaps() {
        let coordinate = CLLocationCoordinate2DMake(restaurant!.coordinates.latitude, restaurant!.coordinates.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        mapItem.name = restaurant!.name
//      mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
        mapItem.openInMaps()
    }
}

//struct RestaurantView_Previews: PreviewProvider {
//    static var previews: some View {
//        RestaurantView()
//    }
//}