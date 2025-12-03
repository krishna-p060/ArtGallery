//
//  ArtworkRowView.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 02/12/25.
//

import SwiftUI

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
