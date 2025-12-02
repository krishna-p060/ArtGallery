//
//  ArtworkDetailView.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import SwiftUI

struct ArtworkDetailView: View {
    let artworkId: Int
    
    var body: some View {
        VStack {
            Text("Artwork Detail View")
                .font(.title)
            Text("ID: \(artworkId)")
                .font(.caption)
            Text("(To be implemented in Stage 2)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .navigationTitle("Artwork Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ArtworkDetailView(artworkId: 123)
    }
}
