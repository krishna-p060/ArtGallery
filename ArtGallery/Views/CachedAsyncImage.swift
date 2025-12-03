//
//  CachedAsyncImage.swift
//  ArtGallery
//
//  Created by Krishna Patidar on 02/12/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let urlString: String?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        urlString: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear { loadImage() }
            }
        }
    }
    
    private func loadImage() {
        guard let urlString = urlString, !isLoading else { return }
        isLoading = true
        
        // Handle base64 images (from API thumbnails)
        if urlString.starts(with: "data:image") {
            loadBase64Image(urlString)
            return
        }
        
        // Handle regular URL images
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        // Check cache first
        if let cached = ImageCache.shared.get(forKey: urlString) {
            self.image = cached
            isLoading = false
            return
        }
        
        // Download image with proper headers
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("https://www.artic.edu", forHTTPHeaderField: "Referer")
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                
                guard let downloadedImage = UIImage(data: data) else {
                    await MainActor.run {
                        isLoading = false
                    }
                    return
                }
                
                // Cache the image
                ImageCache.shared.set(downloadedImage, forKey: urlString)
                
                // Update UI on main thread
                await MainActor.run {
                    self.image = downloadedImage
                    self.isLoading = false
                }
            } catch {
                print("Failed to load image from \(url): \(error.localizedDescription)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func loadBase64Image(_ dataString: String) {
        guard let commaIndex = dataString.firstIndex(of: ",") else {
            isLoading = false
            return
        }
        
        let base64String = String(dataString[dataString.index(after: commaIndex)...])
        
        guard let data = Data(base64Encoded: base64String),
              let decodedImage = UIImage(data: data) else {
            isLoading = false
            return
        }
        
        self.image = decodedImage
        isLoading = false
    }
}

// MARK: - Image Cache
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
