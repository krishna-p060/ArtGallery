//
//  ArtworkDetailView.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import SwiftUI

struct ArtworkDetailView: View {
    let artworkId: Int
    let artWorkTitle: String
    
    @StateObject private var viewModel = ArtworkDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image
                if viewModel.isLoading {
                    LoadingView()
                } else if let artwork = viewModel.artwork {
                    // Large Image
                    CachedAsyncImage(
                        urlString: artwork.imageURL
                    ) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.2)
                            ProgressView()
                        }
                        .frame(height: 400)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    
                    // Content Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & Artist
                        VStack(alignment: .leading, spacing: 8) {
                            Text(artwork.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(artwork.artistName)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text(artwork.displayYear)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Details Grid
                        if artwork.mediumDisplay != nil || artwork.dimensions != nil || artwork.creditLine != nil {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details")
                                    .font(.headline)
                                
                                if let medium = artwork.mediumDisplay {
                                    DetailRow(title: "Medium", value: medium)
                                }
                                
                                if let dimensions = artwork.dimensions {
                                    DetailRow(title: "Dimensions", value: dimensions)
                                }
                                
                                if let credit = artwork.creditLine {
                                    DetailRow(title: "Credit", value: credit)
                                }
                            }
                            
                            Divider()
                        }
                        
                        // Additional Information
                        if artwork.publicationHistory != nil || artwork.exhibitionHistory != nil || artwork.provenanceText != nil {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Additional Information")
                                    .font(.headline)
                                
                                if let publication = artwork.publicationHistory {
                                    ExpandableSection(title: "Publication History", content: publication)
                                }
                                
                                if let exhibition = artwork.exhibitionHistory {
                                    ExpandableSection(title: "Exhibition History", content: exhibition)
                                }
                                
                                if let provenance = artwork.provenanceText {
                                    ExpandableSection(title: "Provenance", content: provenance)
                                }
                            }
                        }
                    }
                    .padding()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error, retryAction: {
                        Task {
                            await viewModel.fetchArtworkDetail(id: artworkId)
                        }
                    })
                }
            }
        }
        .navigationTitle("Artwork Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchArtworkDetail(id: artworkId)
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - Expandable Section
struct ExpandableSection: View {
    let title: String
    let content: String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading artwork details...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 400)
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        ArtworkDetailView(artworkId: 129884, artWorkTitle: "The Bedroom")
    }
}
