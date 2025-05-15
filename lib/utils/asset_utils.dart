class AssetUtils {
  // Stock bus images from Unsplash
  static const List<String> busImages = [
    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1000',
    'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?q=80&w=1000',
    'https://images.unsplash.com/photo-1570125909517-53cb21c89ff2?q=80&w=1000',
    'https://images.unsplash.com/photo-1464219789935-c2d9d9aba644?q=80&w=1000',
    'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=1000',
    'https://images.unsplash.com/photo-1691504075270-67e95e9e6677?q=80&w=1000',
  ];

  // Specific bus type images
  static const Map<String, String> busTypeImages = {
    'Express Bus':
        'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?q=80&w=1000',
    'Local Bus':
        'https://images.unsplash.com/photo-1464219789935-c2d9d9aba644?q=80&w=1000',
    'Luxury Bus':
        'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=1000',
    'Night Bus':
        'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1000',
  };

  // Get random bus image
  static String getRandomBusImage() {
    return busImages[DateTime.now().microsecond % busImages.length];
  }

  // Get bus image by index
  static String getBusImage(int index) {
    return busImages[index % busImages.length];
  }

  // Get bus image by bus type
  static String getBusImageByType(String busType) {
    return busTypeImages[busType] ?? getRandomBusImage();
  }

  // Banner images for home screen
  static const List<String> bannerImages = [
    'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?q=80&w=1000',
    'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?q=80&w=1000',
    'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?q=80&w=1000',
  ];
}
