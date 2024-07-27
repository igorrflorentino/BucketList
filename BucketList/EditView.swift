//
//  EditView.swift
//  BucketList
//
//  Created by Igor Florentino on 11/06/24.
//

import SwiftUI

struct EditView: View {	
	@State private var viewModel: ViewModel
	
	@Environment(\.dismiss) var dismiss
	var onSave: (Location) -> Void
		
    var body: some View {
		NavigationStack{
			Form {
				Section{
					TextField("Place name", text: $viewModel.name)
					TextField("Description", text: $viewModel.description)
				}
				Section("Nearby…") {
					switch viewModel.loadingState {
					case .loaded:
						ForEach(viewModel.pages, id: \.pageid) { page in
							Text(page.title)
								.font(.headline)
							+ Text(": ") +
							Text(page.description)
								.italic()
						}
					case .loading:
						Text("Loading…")
					case .failed:
						Text("Please try again later.")
					}
				}
			}.navigationTitle("Place details")
			.toolbar{
				Button("Save"){
					let newLocation = viewModel.createNewLocation()
					onSave(newLocation)
					dismiss()
				}
			}
			.task {
				await viewModel.fetchNearbyPlaces()
			}
		}
    }
	
	init(location: Location, onSave: @escaping (Location) -> Void){
		_viewModel = State(initialValue: ViewModel(location: location))
		self.onSave = onSave
	}

}


#Preview {
	EditView(location: .example) { _ in }
}
