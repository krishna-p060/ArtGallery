//
//  NetworkService.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 25/11/25.
//

import Foundation

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// MARK: - Network Service
class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.artic.edu/api/v1"
    private let imageBaseURL = "https://www.artic.edu/iiif/2"
    
    private init() {}
    
    // MARK: - Fetch Artworks
    /// Fetches artworks from the API with pagination
    /// - Parameters:
    ///   - page: Page number (default: 1)
    ///   - limit: Number of items per page (default: 20)
    /// - Returns: ArtworkResponse containing artworks and pagination info
    func fetchArtworks(page: Int = 1, limit: Int = 20) async throws -> ArtworkResponse {
        let urlString = "\(baseURL)/artworks?page=\(page)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id,thumbnail"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let artworkResponse = try JSONDecoder().decode(ArtworkResponse.self, from: data)
            return artworkResponse
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Search Artworks
    /// Searches for artworks based on query
    /// - Parameters:
    ///   - query: Search term
    ///   - page: Page number
    ///   - limit: Number of items per page
    /// - Returns: ArtworkResponse containing search results
    func searchArtworks(query: String, page: Int = 1, limit: Int = 20) async throws -> ArtworkResponse {
        let urlString = "\(baseURL)/artworks/search?q=\(query)&page=\(page)&limit=\(limit)&fields=id,title,artist_display,date_display,image_id,thumbnail"
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let artworkResponse = try JSONDecoder().decode(ArtworkResponse.self, from: data)
            return artworkResponse
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Fetch Artwork Detail
    /// Fetches detailed information for a specific artwork
    /// - Parameter id: Artwork ID
    /// - Returns: Detailed Artwork object
    func fetchArtworkDetail(id: Int) async throws -> Artwork {
        let urlString = "\(baseURL)/artworks/\(id)?fields=id,title,artist_display,date_display,image_id,thumbnail,medium_display,dimensions,credit_line,publication_history,exhibition_history,provenance_text,artist_id,artist_title"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Invalid response")
        }
        
        do {
            let detailResponse = try JSONDecoder().decode(ArtworkDetailResponse.self, from: data)
            return detailResponse.data
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
    
    // MARK: - Build Image URL
    /// Constructs the IIIF image URL
    /// - Parameters:
    ///   - imageId: Image identifier
    ///   - size: Image size (default: 843 which is recommended by API)
    /// - Returns: Complete image URL string
    func buildImageURL(imageId: String, size: Int = 843) -> String {
        // Try the direct IIIF URL first
        return "\(imageBaseURL)/\(imageId)/full/\(size),/0/default.jpg"
    }
}
