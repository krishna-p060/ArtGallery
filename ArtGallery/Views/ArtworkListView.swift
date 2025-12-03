//
//  ArtworkListView.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import SwiftUI

struct ArtworkListView: View {
    @StateObject private var viewModel = ArtworkListViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main Content
                if viewModel.filteredArtworks.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    artworkListContent
                }
                
                // Loading Overlay
                if viewModel.isLoading && viewModel.artworks.isEmpty {
                    ProgressView("Loading artworks...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Art Gallery")
            .searchable(text: $viewModel.searchText, prompt: "Search artworks...")
            .task {
                // Load initial artworks when view appears
                if viewModel.artworks.isEmpty {
                    await viewModel.fetchArtworks()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    // MARK: - Artwork List Content
    private var artworkListContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredArtworks) { artwork in
                    NavigationLink(value: artwork) {
                        ArtworkRowView(artwork: artwork)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .task {
                        // Load more when reaching near the end
                        await viewModel.loadMoreIfNeeded(currentItem: artwork)
                    }
                }
                
                // Loading indicator at bottom when loading more
                if viewModel.isLoading && !viewModel.artworks.isEmpty {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .navigationDestination(for: Artwork.self) { artwork in
            ArtworkDetailView(artworkId: artwork.id, artWorkTitle: artwork.title)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Artworks Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ArtworkListView()
}
