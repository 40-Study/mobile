class UpdateProgressDto {
  const UpdateProgressDto({
    this.status,
    this.progressPercentage,
    this.videoWatchedSeconds,
  });

  final String? status;
  final double? progressPercentage;
  final int? videoWatchedSeconds;

  Map<String, dynamic> toJson() {
    return {
      if (status != null) 'status': status,
      if (progressPercentage != null) 'progress_percentage': progressPercentage,
      if (videoWatchedSeconds != null)
        'video_watched_seconds': videoWatchedSeconds,
    };
  }
}
