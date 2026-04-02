class Podcast {
  final int id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final List<PodcastEpisode> episodes;

  Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.imageUrl,
    required this.episodes,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      episodes: (json['episodes'] as List? ?? [])
          .map((e) => PodcastEpisode.fromJson(e))
          .toList(),
    );
  }
}

class PodcastEpisode {
  final int id;
  final String title;
  final String audioUrl;
  final String duration;
  final String date;

  PodcastEpisode({
    required this.id,
    required this.title,
    required this.audioUrl,
    required this.duration,
    required this.date,
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id'],
      title: json['title'],
      audioUrl: json['audio_url'],
      duration: json['duration'] ?? '0:00',
      date: json['date'] ?? '',
    );
  }
}

class Fatwa {
  final int id;
  final String question;
  final String answer;
  final String category;
  final String scholar;
  final String date;

  Fatwa({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.scholar,
    required this.date,
  });

  factory Fatwa.fromJson(Map<String, dynamic> json) {
    return Fatwa(
      id: json['id'],
      question: json['question'],
      answer: json['answer'] ?? '',
      category: json['category'] ?? 'General',
      scholar: json['scholar'] ?? 'Unknown Scholar',
      date: json['date'] ?? '',
    );
  }
}

class Article {
  final int id;
  final String title;
  final String content;
  final String author;
  final String imageUrl;
  final String date;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.imageUrl,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      author: json['author'] ?? 'Admin',
      imageUrl: json['image_url'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
class Mosque {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double distance;
  final Map<String, String> prayerTimes;

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    this.distance = 0.0,
    required this.prayerTimes,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      prayerTimes: Map<String, String>.from(json['prayer_times'] ?? {}),
    );
  }
}

class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['fajr'] ?? '--:--',
      dhuhr: json['dhuhr'] ?? '--:--',
      asr: json['asr'] ?? '--:--',
      maghrib: json['maghrib'] ?? '--:--',
      isha: json['isha'] ?? '--:--',
      date: json['date'] ?? '',
    );
  }
}

class Hadith {
  final int id;
  final String text;
  final String reference;
  final String narrator;
  final String category;

  Hadith({
    required this.id,
    required this.text,
    required this.reference,
    required this.narrator,
    required this.category,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      text: json['text'],
      reference: json['reference'] ?? '',
      narrator: json['narrator'] ?? 'Prophet Muhammad (PBUH)',
      category: json['category'] ?? 'General',
    );
  }
}

class HadithCollection {
  final int id;
  final String name;
  final String count;
  final String description;

  HadithCollection({
    required this.id,
    required this.name,
    required this.count,
    required this.description,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'],
      name: json['name'],
      count: json['count'] ?? '0',
      description: json['description'] ?? '',
    );
  }
}

class Book {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final String description;
  final String category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.description,
    required this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'] ?? 'Unknown Author',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
    );
  }
}

class Video {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final String rating;
  final String duration;
  final String category;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.videoUrl,
    required this.rating,
    required this.duration,
    required this.category,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      rating: json['rating'] ?? '5.0',
      duration: json['duration'] ?? '0:00',
      category: json['category'] ?? 'General',
    );
  }
}

class VideoSeries {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String lessonCount;

  VideoSeries({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.lessonCount,
  });

  factory VideoSeries.fromJson(Map<String, dynamic> json) {
    return VideoSeries(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      lessonCount: json['lesson_count'] ?? '0',
    );
  }
}

class Clip {
  final int id;
  final String username;
  final String userImageUrl;
  final String description;
  final String videoUrl;
  final String likes;
  final String comments;
  final List<String> hashtags;
  final String audioTitle;

  Clip({
    required this.id,
    required this.username,
    required this.userImageUrl,
    required this.description,
    required this.videoUrl,
    required this.likes,
    required this.comments,
    required this.hashtags,
    required this.audioTitle,
  });

  factory Clip.fromJson(Map<String, dynamic> json) {
    return Clip(
      id: json['id'],
      username: json['username'] ?? 'qalaam_user',
      userImageUrl: json['user_image_url'] ?? '',
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      likes: json['likes'] ?? '0',
      comments: json['comments'] ?? '0',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      audioTitle: json['audio_title'] ?? 'Original Audio',
    );
  }
}

class DailyAyah {
  final String text;
  final String translation;
  final String reference;

  DailyAyah({
    required this.text,
    required this.translation,
    required this.reference,
  });

  factory DailyAyah.fromJson(Map<String, dynamic> json) {
    return DailyAyah(
      text: json['text'],
      translation: json['translation'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}

class Dhikr {
  final int id;
  final String name;
  final String arabic;
  final String translation;
  final int defaultTarget;

  Dhikr({
    required this.id,
    required this.name,
    required this.arabic,
    required this.translation,
    this.defaultTarget = 33,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'],
      name: json['name'],
      arabic: json['arabic'] ?? '',
      translation: json['translation'] ?? '',
      defaultTarget: json['default_target'] ?? 33,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profile_image_url'],
    );
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}
