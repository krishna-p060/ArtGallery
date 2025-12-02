//
//  ArtworkListViewModel.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import Foundation
import Combine

@MainActor
class ArtworkListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedYear: String = "" // For year filter
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageLimit = 20
    private var canLoadMore = true
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    // MARK: - Initialization
    init() {
        setupSearchDebounce()
    }
    
    // MARK: - Setup Search Debounce
    /// Sets up debouncing for search to avoid excessive API calls
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                Task {
                    await self?.performSearch(query: searchText)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Artworks
    /// Fetches initial artworks or loads more based on pagination
    func fetchArtworks() async {
        guard !isLoading, canLoadMore else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkService.fetchArtworks(
                page: currentPage,
                limit: pageLimit
            )
            
            print("✅ Fetched \(response.data.count) artworks")
            print("First artwork: \(response.data.first?.title ?? "none")")
            print("First artwork imageId: \(response.data.first?.imageId ?? "none")")
            print("First artwork imageURL: \(response.data.first?.imageURL ?? "none")")
            
            // Append new artworks to existing ones
            artworks.append(contentsOf: response.data)
            
            // Update pagination state
            currentPage += 1
            canLoadMore = currentPage <= response.pagination.totalPages
            
            isLoading = false
        } catch let error as NetworkError {
            print("❌ Network Error: \(error.errorDescription)")
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            print("❌ Unexpected Error: \(error)")
            errorMessage = "An unexpected error occurred"
            isLoading = false
        }
    }
    
    // MARK: - Perform Search
    /// Performs search based on user query
    private func performSearch(query: String) async {
        // Reset pagination for new search
        currentPage = 1
        artworks = []
        canLoadMore = true
        
        // If search is empty, fetch regular artworks
        guard !query.isEmpty else {
            await fetchArtworks()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await networkService.searchArtworks(
                query: query,
                page: currentPage,
                limit: pageLimit
            )
            
            artworks = response.data
            currentPage += 1
            canLoadMore = currentPage <= response.pagination.totalPages
            
            isLoading = false
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            isLoading = false
        } catch {
            errorMessage = "An unexpected error occurred"
            isLoading = false
        }
    }
    
    // MARK: - Filter by Year
    /// Filters artworks by selected year
    /// Note: This performs client-side filtering on loaded artworks
    var filteredArtworks: [Artwork] {
        guard !selectedYear.isEmpty else {
            return artworks
        }
        
        return artworks.filter { artwork in
            guard let dateDisplay = artwork.dateDisplay else { return false }
            return dateDisplay.contains(selectedYear)
        }
    }
    
    // MARK: - Refresh
    /// Refreshes the artwork list (pull to refresh)
    func refresh() async {
        currentPage = 1
        artworks = []
        canLoadMore = true
        searchText = ""
        selectedYear = ""
        await fetchArtworks()
    }
    
    // MARK: - Load More
    /// Loads more artworks when scrolling near the bottom
    func loadMoreIfNeeded(currentItem: Artwork) async {
        // Check if we're near the end of the list
        guard let lastItem = artworks.last,
              lastItem.id == currentItem.id else {
            return
        }
        
        // If searching, load more search results
        if !searchText.isEmpty {
            await loadMoreSearchResults()
        } else {
            await fetchArtworks()
        }
    }
    
    // MARK: - Load More Search Results
    private func loadMoreSearchResults() async {
        guard !isLoading, canLoadMore, !searchText.isEmpty else { return }
        
        isLoading = true
        
        do {
            let response = try await networkService.searchArtworks(
                query: searchText,
                page: currentPage,
                limit: pageLimit
            )
            
            artworks.append(contentsOf: response.data)
            currentPage += 1
            canLoadMore = currentPage <= response.pagination.totalPages
            
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
