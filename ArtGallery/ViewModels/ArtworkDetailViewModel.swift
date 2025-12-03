//
//  ArtworkDetailViewModel.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 02/12/25.
//

import Foundation
import Combine

@MainActor
class ArtworkDetailViewModel: ObservableObject {
    @Published var artwork: Artwork?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService.shared
    
    func fetchArtworkDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedArtwork = try await networkService.fetchArtworkDetail(id: id)
            artwork = fetchedArtwork
            isLoading = false
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = "An unexpected error occurred"
            isLoading = false
        }
    }
}
