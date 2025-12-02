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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(selectedYear: $viewModel.selectedYear)
            }
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
            ArtworkDetailView(artworkId: artwork.id)
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

// MARK: - Artwork Row View

struct ArtworkRowView: View {
    let artwork: Artwork
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Artwork Image using CachedAsyncImage with string URL
            CachedAsyncImage(
                urlString: artwork.imageURL
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Color.gray.opacity(0.2)
                    ProgressView()
                }
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .clipped()
            
            // Artwork Details
            VStack(alignment: .leading, spacing: 6) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                Text(artwork.artistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(artwork.displayYear)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Filter View
struct FilterView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedYear: String
    @State private var inputYear: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter year (e.g., 1900)", text: $inputYear)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Filter by Year")
                } footer: {
                    Text("Enter a specific year to filter artworks")
                }
                
                if !selectedYear.isEmpty {
                    Section {
                        Button("Clear Filter") {
                            selectedYear = ""
                            inputYear = ""
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedYear = inputYear
                        dismiss()
                    }
                    .disabled(inputYear.isEmpty)
                }
            }
            .onAppear {
                inputYear = selectedYear
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ArtworkListView()
}
