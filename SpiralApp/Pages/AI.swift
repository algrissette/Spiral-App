//
//  AI.swift
//  SpiralApp
//
//  Created by Alan Grissette on 11/24/25.
//

import Foundation
import SwiftUI
import WrappingHStack
//API KEYS IN SEPARATE CONFIG FILE

// -------------------------------
// MARK: - Collage Item Model
// -------------------------------
struct CollageItem: Identifiable {
    let id = UUID()
    let type: ItemType
    let task: String
    var content: String = ""
    var image: UIImage? = nil
    var isLoading: Bool = false
    let size: ItemSize
    
    enum ItemType {
        case imageOnly
        case textOnly
        case imageWithText
    }
    
    enum ItemSize {
        case small   // 1:1 square
        case medium  // 3:4 portrait
        case large   // 2:3 portrait
        case wide    // 16:9 landscape
        case tall    // 9:16 portrait
        
        var dimensions: CGSize {
            // Base unit: 80 points
            let unit: CGFloat = 80
            
            switch self {
            case .small:  return CGSize(width: unit * 1.5, height: unit * 1.5)      // 120x120 (1:1)
            case .medium: return CGSize(width: unit * 1.75, height: unit * 2.25)    // 140x180 (3:4)
            case .large:  return CGSize(width: unit * 2, height: unit * 3)          // 160x240 (2:3)
            case .wide:   return CGSize(width: unit * 2.5, height: unit * 1.4)      // 200x112 (16:9)
            case .tall:   return CGSize(width: unit * 1.25, height: unit * 2.75)    // 100x220 (9:16)
            }
        }
    }
}

// -------------------------------
// MARK: - Main View
// -------------------------------
struct Collage: View {
    // Pass in your tasks as strings
    let tasks: [String]
    
    @State private var collageItems: [CollageItem] = []
    @State private var loadedItemIDs: Set<UUID> = []
    @State private var debugLog: [String] = []
    
    init(tasks: [String] = [
        "Clean my room",
        "Exercise for 30 minutes",
        "Read a book",
        "Meditate",
        "Cook a healthy meal"
    ]) {
        self.tasks = tasks
    }
    
    // -------------------------------
    // MARK: - Generate Collage Items from Tasks
    // -------------------------------
    func generateCollageItems(from tasks: [String]) -> [CollageItem] {
        var items: [CollageItem] = []
        
        let types: [CollageItem.ItemType] = [.imageOnly, .textOnly, .imageWithText]
        let sizes: [CollageItem.ItemSize] = [.small, .medium, .large, .wide, .tall]
        
        for task in tasks {
            // Create one of each type for each task with varied sizes
            items.append(CollageItem(
                type: .imageOnly,
                task: task,
                size: sizes.randomElement() ?? .medium
            ))
            
            items.append(CollageItem(
                type: .textOnly,
                task: task,
                size: sizes.randomElement() ?? .small
            ))
            
            items.append(CollageItem(
                type: .imageWithText,
                task: task,
                size: sizes.randomElement() ?? .large
            ))
        }
        
        return items.shuffled() // Shuffle for a nice mixed layout
    }
    
    // -------------------------------
    // MARK: - API CALL 1 (Query)
    // -------------------------------
    func getQuery(task: String) async -> String {
        let TOKEN = APIKeys.HF_TOKEN
        let url = URL(string: "https://router.huggingface.co/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "meta-llama/Llama-3.1-8B-Instruct",
            "messages": [
                ["role": "system", "content": "You generate two-word image search queries --the first word being an adjective like aesthetic or pretty. Return only the text."],
                ["role": "user", "content": "Give me a very short aesthetic image search query for: \(task)"]
            ],
            "max_tokens": 50
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON Encoding Failed:", error)
            return ""
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return ""
            }
            
            guard (200..<300).contains(http.statusCode) else {
                print("❌ HF Server Error:", http.statusCode)
                print(String(data: data, encoding: .utf8) ?? "")
                return ""
            }
            
            let json = try JSONSerialization.jsonObject(with: data)
            
            guard let jsonDict = json as? [String: Any],
                  let choices = jsonDict["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ Could not parse response")
                return ""
            }

            print("Query Result is : \(content)")
            return content
            
        } catch {
            print(" Network error:", error)
            return ""
        }
    }
    
    // -------------------------------
    // MARK: - API CALL 2 (Inspiration)
    // -------------------------------
    func generateInspiration(task: String) async -> String {
        let TOKEN = APIKeys.HF_TOKEN
        let url = URL(string: "https://router.huggingface.co/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(TOKEN)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "meta-llama/Llama-3.1-8B-Instruct",
            "messages": [
                ["role": "system", "content": "You generate very short motivational lines. Return only the text."],
                ["role": "user", "content": "Give me one short inspirational line for: \(task)"]
            ],
            "max_tokens": 50
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("❌ JSON Encoding Failed:", error)
            return ""
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ Invalid response")
                return ""
            }
            
            guard (200..<300).contains(http.statusCode) else {
                print("❌ HF Server Error:", http.statusCode)
                print(String(data: data, encoding: .utf8) ?? "")
                return ""
            }
            
            let json = try JSONSerialization.jsonObject(with: data)
            
            guard let jsonDict = json as? [String: Any],
                  let choices = jsonDict["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ Could not parse response")
                return ""
            }
            
            return content
            
        } catch {
            print(" Network error:", error)
            return ""
        }
    }
    
    // -------------------------------
    // MARK: - API CALL 3 (Unsplash)
    // -------------------------------
    func getUnsplashImage(query: String) async -> UIImage? {
        let accessKey = APIKeys.UNSPLASH_KEY
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode query")
            return nil
        }
        
        let urlString = "https://api.unsplash.com/photos/random?query=\(encodedQuery)&orientation=portrait&content_filter=high"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                print(" Invalid HTTP response")
                return nil
            }
            
            guard (200..<300).contains(http.statusCode) else {
                print("Unsplash Error \(http.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
                return nil
            }
            
            struct UnsplashResponse: Codable {
                let urls: URLs
                struct URLs: Codable {
                    let small: String
                    let regular: String
                }
            }
            
            let decoded = try JSONDecoder().decode(UnsplashResponse.self, from: data)
            guard let imageURL = URL(string: decoded.urls.small) else {
                print("❌ Invalid image URL")
                return nil
            }
            
            print(" Downloading image from: \(imageURL)")
            let (imageData, checking) = try await URLSession.shared.data(from: imageURL)
            
            guard let http2 = checking as? HTTPURLResponse else {
                print ("Connection Failed")
                return nil
            }
            
            guard (200..<300).contains(http2.statusCode) else {
                print("Unsplash Error \(http2.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
                return nil
            }
            
            if let image = UIImage(data: imageData) {
                print("✅ Successfully loaded image")
                return image
            } else {
                print("❌ Failed to create UIImage from data")
                return nil
            }
            
        } catch {
            print("❌ Unsplash error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // -------------------------------
    // MARK: - API CALL 4 (Pixabay)
    // -------------------------------
    func getPixelBayImage(query: String) async -> UIImage? {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode query")
            return nil
        }
        
        let apiKey = APIKeys.PIXABAY_KEY
        
        guard let url = URL(string: "https://pixabay.com/api/?key=\(apiKey)&q=\(encodedQuery)&image_type=photo&safesearch=true") else {
            print("❌ Invalid URL for Pixabay")
            return nil
        }
        
        struct PixabayResponse: Codable {
            let hits: [PixabayHit]
        }
        
        struct PixabayHit: Codable {
            let webformatURL: String
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ No response from Pixabay")
                return nil
            }
            
            print("📡 Pixabay status code:", http.statusCode)
            
            guard (200..<300).contains(http.statusCode) else {
                print("❌ Pixabay status error: \(http.statusCode)")
                return nil
            }
            
            let json = try JSONDecoder().decode(PixabayResponse.self, from: data)
            
            guard let imageURLString = json.hits.first?.webformatURL,
                  let imageURL = URL(string: imageURLString) else {
                print("❌ Could not extract image URL from Pixabay response")
                return nil
            }
            
            let (imgData, _) = try await URLSession.shared.data(from: imageURL)
            
            if let image = UIImage(data: imgData) {
                print("✅ Pixabay image loaded")
                return image
            } else {
                print("❌ Failed to convert data to UIImage")
                return nil
            }
            
        } catch {
            print("❌ Pixabay API error: \(error)")
            return nil
        }
    }

    // -------------------------------
    // MARK: - API CALL 5 (Giphy)
    // -------------------------------
    func getGiphyImage(query: String) async -> UIImage? {
        let apiKey = APIKeys.GIPHY_KEY
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode query")
            return nil
        }
        
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(encodedQuery)&limit=10&rating=g&lang=en"
        guard let url = URL(string: urlString) else {
            print("❌ Invalid Giphy URL")
            return nil
        }
        
        print("🔍 Searching Giphy for: '\(query)'")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let http = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP response")
                return nil
            }
            
            print("📡 Giphy status: \(http.statusCode)")
            
            guard (200..<300).contains(http.statusCode) else {
                print("❌ Giphy HTTP Error: \(http.statusCode)")
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
                return nil
            }
            
            struct GiphyResponse: Codable {
                struct DataItem: Codable {
                    struct Images: Codable {
                        struct FixedHeight: Codable {
                            let url: String
                        }
                        let fixed_height: FixedHeight
                    }
                    let images: Images
                }
                let data: [DataItem]
            }
            
            let decoded = try JSONDecoder().decode(GiphyResponse.self, from: data)
            print("📊 Found \(decoded.data.count) GIFs")
            
            guard let gifItem = decoded.data.randomElement(),
                  let gifURL = URL(string: gifItem.images.fixed_height.url) else {
                print("⚠️ No GIFs in response")
                return nil
            }
            
            print("⬇️ Downloading GIF from: \(gifURL)")
            let (imageData, _) = try await URLSession.shared.data(from: gifURL)
            
            if let image = UIImage(data: imageData) {
                print("✅ Successfully loaded GIF (will show as static)")
                return image
            } else {
                print("❌ Failed to create UIImage from GIF data")
                return nil
            }
            
        } catch {
            print("❌ Giphy error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // -------------------------------
    // MARK: - Combined Image Fetcher
    // -------------------------------
    func getImage(query: String) async -> UIImage? {
        print("\n🎨 Fetching image for: '\(query)'")
        
        // Try Unsplash first (more reliable)
        if let image = await getUnsplashImage(query: query) {
            print("✅ Got image from Unsplash")
            return image
        }
        
        print("⚠️ Unsplash failed, trying Giphy...")
        
        // Try Giphy
        if let image = await getGiphyImage(query: query) {
            print("✅ Got image from Giphy")
            return image
        }
        
        print("⚠️ Giphy failed, trying Pixabay...")
        if let image = await getPixelBayImage(query: query) {
            print("✅ Got image from Pixabay")
            return image
        }
        
        // Try with simpler query on both services
        let simpleQuery = query.components(separatedBy: " ").prefix(2).joined(separator: " ")
        
        if let image = await getUnsplashImage(query: simpleQuery) {
            print("✅ Got image from Unsplash (simple query)")
            return image
        }
        
        if let image = await getGiphyImage(query: simpleQuery) {
            print("✅ Got image from Giphy (simple query)")
            return image
        }
        
        if let image = await getPixelBayImage(query: simpleQuery) {
            print("✅ Got image from Pixabay (simple query)")
            return image
        }
        
        // Last resort: try just the task name
        let taskWord = query.components(separatedBy: " ").first ?? query
        
        if let image = await getUnsplashImage(query: taskWord) {
            print("✅ Got image from Unsplash (single word)")
            return image
        }
        
        if let image = await getPixelBayImage(query: taskWord) {
            print("✅ Got image from Pixabay (single word)")
            return image
        }
        
        print("❌ All image attempts failed for '\(query)'")
        return nil
    }
    
    // -------------------------------
    // MARK: - Load Item Data
    // -------------------------------
    func loadItemData(for index: Int) async {
        let item = collageItems[index]
        
        switch item.type {
        case .imageOnly:
            let query = await getQuery(task: item.task)
            let searchQuery = query.isEmpty ? item.task : query
            let image = await getImage(query: searchQuery)
            
            await MainActor.run {
                collageItems[index].image = image
                collageItems[index].isLoading = false
            }
            
        case .textOnly:
            let inspiration = await generateInspiration(task: item.task)
            
            await MainActor.run {
                collageItems[index].content = inspiration
                collageItems[index].isLoading = false
            }
            
        case .imageWithText:
            let inspiration = await generateInspiration(task: item.task)
            
            await MainActor.run {
                collageItems[index].content = inspiration
            }
            
            let searchQuery = inspiration.isEmpty ? item.task : inspiration
            let image = await getImage(query: searchQuery)
            
            await MainActor.run {
                collageItems[index].image = image
                collageItems[index].isLoading = false
            }
        }
    }
    
    // -------------------------------
    // MARK: - UI
    // -------------------------------
    var body: some View {
        ScrollView {
            WrappingHStack(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(collageItems) { item in
                    CollageItemView(item: item)
                }
            }
            .padding(12)
            .background(Color.secondary)
        }
        .ignoresSafeArea()
        .background(Color.secondary)
        .onAppear {
            // Generate collage items from tasks only if not already generated
            if collageItems.isEmpty {
                collageItems = generateCollageItems(from: tasks)
            }
        }
        .task {
            if !collageItems.isEmpty {
                // Only load items that haven't been loaded yet
                let itemsToLoad = collageItems.enumerated().filter { index, item in
                    !loadedItemIDs.contains(item.id)
                }
                
                // Mark items as loading
                for (index, _) in itemsToLoad {
                    collageItems[index].isLoading = true
                }
                
                await withTaskGroup(of: Void.self) { group in
                    for (index, item) in itemsToLoad {
                        group.addTask {
                            await loadItemData(for: index)
                            // Mark this item as loaded
                            await MainActor.run {
                                loadedItemIDs.insert(item.id)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: tasks) { newTasks in
            // Regenerate collage when tasks change
            collageItems = generateCollageItems(from: newTasks)
            loadedItemIDs.removeAll()
        }
    }
}

// -------------------------------
// MARK: - Collage Item View
// -------------------------------
struct CollageItemView: View {
    let item: CollageItem
    
    var body: some View {
        let size = item.size.dimensions
        
        ZStack {
            switch item.type {
            case .imageOnly:
                imageOnlyView
                    .frame(width: size.width, height: size.height)
                
            case .textOnly:
                textOnlyView
                    .frame(width: size.width, height: size.height)
                
            case .imageWithText:
                imageWithTextView
                    .frame(width: size.width, height: size.height)
            }
        }
    }
    
    var imageOnlyView: some View {
        Group {
            if item.isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                    ProgressView()
                }
            } else if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: item.size.dimensions.width, height: item.size.dimensions.height)
                    .clipped()
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
            }
        }
    }
    
    var textOnlyView: some View {
        Group {
            if item.isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.3), Color.orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    ProgressView()
                }
            } else if !item.content.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: randomGradientColors(),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text(item.content)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(16)
                }
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
            }
        }
    }
    
    var imageWithTextView: some View {
        Group {
            if item.isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                    ProgressView()
                }
            } else if let image = item.image {
                ZStack(alignment: .bottom) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: item.size.dimensions.width, height: item.size.dimensions.height)
                        .clipped()
                    
                    if !item.content.isEmpty {
                        VStack {
                            Spacer()
                            Text(item.content)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Rectangle()
                                        .fill(Color.black.opacity(0.6))
                                        .blur(radius: 10)
                                )
                        }
                    }
                }
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
            }
        }
    }
    
    func randomGradientColors() -> [Color] {
        let gradients: [[Color]] = [
            [Color.pink, Color.purple],
            [Color.blue, Color.cyan],
            [Color.orange, Color.red],
            [Color.green, Color.mint],
            [Color.purple, Color.pink],
            [Color.indigo, Color.blue]
        ]
        return gradients.randomElement() ?? [Color.purple, Color.blue]
    }
}

// -------------------------------
// MARK: - PREVIEW
// -------------------------------
struct Collage_Previews: PreviewProvider {
    static var previews: some View {
        Collage(tasks: [
            "Clean my room",
            "Exercise for 30 minutes",
            "Read a book",
            "Meditate",
            "Cook a healthy meal"
        ])
    }
}
