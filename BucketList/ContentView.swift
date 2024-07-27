//
//  ContentView.swift
//  BucketList
//
//  Created by Igor Florentino on 10/06/24.
//

import SwiftUI
import MapKit


struct ContentView: View {
	@State private var viewModel = ViewModel()
	
	@AppStorage("mapStyleIndex") private var mapStyleKey: String = "standart"
	let mapStyles: [String:MapStyle] = ["standart": .standard,"hybrid": .hybrid, "imagery": .imagery]
	
	let startPosition = MapCameraPosition.region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 56, longitude: -3),
			span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
		)
	)
	
	var body: some View {
		if viewModel.isUnlocked {
			VStack{
				MapReader {proxy in
					Map(initialPosition: startPosition){
						ForEach(viewModel.locations) { location in
							Annotation(location.name, coordinate: location.coordinate){
								Image(systemName: "star.circle")
									.resizable()
									.foregroundStyle(.red)
									.frame(width: 44, height: 44)
									.background(.white)
									.clipShape(.circle)
									.onLongPressGesture(perform: {
										viewModel.selectedPlace = location
									})
							}
						}
					}
					.mapStyle(mapStyles[mapStyleKey] ?? .standard)
					.onTapGesture { position in
						if let coordinate = proxy.convert(position, from: .local){
							viewModel.addLocation(at: coordinate)
							viewModel.save()
						}
					}
					.sheet(item: $viewModel.selectedPlace) { place in
						EditView(location: place) { newLocation in
							viewModel.update(location: newLocation)
							viewModel.save()
						}
					}
				}
				Picker("Map mode", selection: $mapStyleKey) {
					Text("Standard")
						.tag("standart")
					
					Text("Hybrid")
						.tag("hybrid")
					
					Text("Imagery")
						.tag("imagery")
				}
				.pickerStyle(.segmented)
				.padding(.horizontal)

			}
		} else {
			Button("Unlock Places", action: viewModel.authenticate)
				.padding()
				.background(.blue)
				.foregroundStyle(.white)
				.clipShape(.capsule)
				.alert(isPresented: $viewModel.isShowingAuthenticationError) {
					Alert(title: Text("Error"), message: Text(viewModel.authenticationError), dismissButton: .default(Text("OK")))
				}
		}
	}
}

#Preview {
    ContentView()
}
