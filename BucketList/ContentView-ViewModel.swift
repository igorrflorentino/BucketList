//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Igor Florentino on 25/07/24.
//

import Foundation
import MapKit
import LocalAuthentication

extension ContentView {
	@Observable
	class ViewModel {
		var selectedPlace: Location?
		private(set) var locations: [Location]
		let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
		var isUnlocked = false
		var authenticationError: String = ""
		var isShowingAuthenticationError = true
		
		init() {
			do {
				let data = try Data(contentsOf: savePath)
				locations = try JSONDecoder().decode([Location].self, from: data)
			} catch {
				locations = []
			}
		}
		
		func addLocation(at point: CLLocationCoordinate2D) {
			let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
			locations.append(newLocation)
		}
		
		func update(location: Location) {
			guard let selectedPlace else { return }
			
			if let index = locations.firstIndex(of: selectedPlace) {
				locations[index] = location
			}
		}
		
		func save() {
			do {
				let data = try JSONEncoder().encode(locations)
				try data.write(to: savePath, options: [.atomic, .completeFileProtection])
			} catch {
				print("Unable to save data.")
			}
		}
		
		func authenticate() {
			let context = LAContext()
			var error: NSError?
			
			if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
				let reason = "Please authenticate yourself to unlock your places."
				
				context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in

					if success {
						self.isUnlocked = true
					} else {
						self.authenticationError = authenticationError?.localizedDescription ?? ""
						self.isShowingAuthenticationError = true
					}
				}
			} else {
				self.authenticationError = error?.localizedDescription ?? ""
				self.isShowingAuthenticationError = true
			}
		}
		
	}
}
