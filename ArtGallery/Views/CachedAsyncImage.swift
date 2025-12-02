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
        
        // Download image
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                
                guard error == nil,
                      let data = data,
                      let downloadedImage = UIImage(data: data) else {
                    return
                }
                
                ImageCache.shared.set(downloadedImage, forKey: urlString)
                self.image = downloadedImage
            }
        }.resume()
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
