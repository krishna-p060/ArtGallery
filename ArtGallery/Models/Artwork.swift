//
//  Artwork.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import Foundation

// MARK: - Artwork Model
struct Artwork: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let artistDisplay: String?
    let dateDisplay: String?
    let imageId: String?
    let thumbnail: Thumbnail?
    
    // Additional fields for detail view
    let mediumDisplay: String?
    let dimensions: String?
    let creditLine: String?
    let publicationHistory: String?
    let exhibitionHistory: String?
    let provenanceText: String?
    let artistId: Int?
    let artistTitle: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artistDisplay = "artist_display"
        case dateDisplay = "date_display"
        case imageId = "image_id"
        case thumbnail
        case mediumDisplay = "medium_display"
        case dimensions
        case creditLine = "credit_line"
        case publicationHistory = "publication_history"
        case exhibitionHistory = "exhibition_history"
        case provenanceText = "provenance_text"
        case artistId = "artist_id"
        case artistTitle = "artist_title"
    }
    
    // Initialize with all optional fields for flexibility
    init(id: Int,
         title: String,
         artistDisplay: String? = nil,
         dateDisplay: String? = nil,
         imageId: String? = nil,
         thumbnail: Thumbnail? = nil,
         mediumDisplay: String? = nil,
         dimensions: String? = nil,
         creditLine: String? = nil,
         publicationHistory: String? = nil,
         exhibitionHistory: String? = nil,
         provenanceText: String? = nil,
         artistId: Int? = nil,
         artistTitle: String? = nil) {
        self.id = id
        self.title = title
        self.artistDisplay = artistDisplay
        self.dateDisplay = dateDisplay
        self.imageId = imageId
        self.thumbnail = thumbnail
        self.mediumDisplay = mediumDisplay
        self.dimensions = dimensions
        self.creditLine = creditLine
        self.publicationHistory = publicationHistory
        self.exhibitionHistory = exhibitionHistory
        self.provenanceText = provenanceText
        self.artistId = artistId
        self.artistTitle = artistTitle
    }
    
    // Computed property to get full image URL
    var imageURL: String? {
        // First try to get the thumbnail LQIP (Low Quality Image Placeholder)
        // These are base64 encoded and work without Cloudflare issues
        if let lqip = thumbnail?.lqip, lqip.starts(with: "data:image") {
            return lqip
        }
        
        // Fallback to IIIF URL
        guard let imageId = imageId else { return nil }
        return NetworkService.shared.buildImageURL(imageId: imageId)
    }
    
    // Get artist name (clean format)
    var artistName: String {
        artistDisplay?.components(separatedBy: "\n").first ?? "Unknown Artist"
    }
    
    // Get display year from date_display
    var displayYear: String {
        dateDisplay ?? "Unknown Date"
    }
    
    // MARK: - Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Artwork, rhs: Artwork) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Thumbnail Model
struct Thumbnail: Codable, Hashable {
    let lqip: String?
    let width: Int?
    let height: Int?
    let altText: String?
    
    enum CodingKeys: String, CodingKey {
        case lqip
        case width
        case height
        case altText = "alt_text"
    }
}

// MARK: - Pagination Model
struct Pagination: Codable {
    let total: Int
    let limit: Int
    let offset: Int
    let totalPages: Int
    let currentPage: Int
    let nextUrl: String?
    let prevUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case total
        case limit
        case offset
        case totalPages = "total_pages"
        case currentPage = "current_page"
        case nextUrl = "next_url"
        case prevUrl = "prev_url"
    }
}

// MARK: - Config Model
struct Config: Codable {
    let iiifUrl: String
    let websiteUrl: String
    
    enum CodingKeys: String, CodingKey {
        case iiifUrl = "iiif_url"
        case websiteUrl = "website_url"
    }
}

// MARK: - Artwork Response (for list/search endpoints)
struct ArtworkResponse: Codable {
    let pagination: Pagination
    let data: [Artwork]
    let config: Config
}

// MARK: - Artwork Detail Response (for single artwork endpoint)
struct ArtworkDetailResponse: Codable {
    let data: Artwork
    let config: Config
}
