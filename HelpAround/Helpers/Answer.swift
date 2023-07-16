import FirebaseFirestore

struct Answer: Codable {
    let id: String
    let questionId: String
    let text: String
    let location: GeoPoint
    let time: Date
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId
        case text
        case locationLatitude
        case locationLongitude
        case time
    }
    
    init(id: String, questionId: String, text: String, location: GeoPoint, time: Date) {
        self.id = id
        self.text = text
        self.location = location
        self.time = time
        self.questionId = questionId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        questionId = try container.decode(String.self, forKey: .questionId)
        text = try container.decode(String.self, forKey: .text)
        // Decode the latitude and longitude values and create a GeoPoint
        let latitude = try container.decode(Double.self, forKey: .locationLatitude)
        let longitude = try container.decode(Double.self, forKey: .locationLongitude)
        location = GeoPoint(latitude: latitude, longitude: longitude)
        
        // Decode the time value as a Date
        let timeValue = try container.decode(Date.self, forKey: .time)
        time = timeValue
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(questionId, forKey: .questionId)

        try container.encode(text, forKey: .text)
        
        // Encode the latitude and longitude values of the GeoPoint
        try container.encode(location.latitude, forKey: .locationLatitude)
        try container.encode(location.longitude, forKey: .locationLongitude)
        
        // Encode the time value as a Date
        try container.encode(time, forKey: .time)
    }
    
    func timeAgoString() -> String {
           let currentTime = Date()
           let timeDifference = Int(currentTime.timeIntervalSince(time))
           
           let seconds = timeDifference % 60
           let minutes = (timeDifference / 60) % 60
           let hours = (timeDifference / 3600) % 24
           let days = timeDifference / 86400
           
           var timeAgoString = ""
           if days > 0 {
               timeAgoString = "לפני \(days) ימים"
           } else if hours > 0 {
               timeAgoString = "לפני \(hours) שעות"
           } else if minutes > 0 {
               timeAgoString = "לפני \(minutes) דקות"
           } else {
               timeAgoString = "לפני \(seconds) שניות"
           }
           
           return timeAgoString
       }
}

