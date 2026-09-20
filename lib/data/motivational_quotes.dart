class MotivationalQuote {
  const MotivationalQuote(this.quote);

  final String quote;

  static const _quotes = [
    MotivationalQuote('Không có ngày nào tồi tệ khi bạn vẫn còn cố gắng.'),
    MotivationalQuote('Học hỏi là hành trình, không phải đích đến.'),
    MotivationalQuote('Mỗi bước nhỏ đều đưa bạn đến gần mục tiêu hơn.'),
    MotivationalQuote('Kiến thức là sức mạnh, học tập là con đường.'),
    MotivationalQuote('Thành công đến từ sự kiên trì mỗi ngày.'),
    MotivationalQuote('Hôm nay bạn học gì mới?'),
    MotivationalQuote('Đừng sợ thất bại, hãy sợ không cố gắng.'),
    MotivationalQuote('Nghỉ ngơi cũng là một phần của học tập.'),
    MotivationalQuote('Mỗi ngày là một cơ hội mới để phát triển.'),
    MotivationalQuote('Học không bao giờ là muộn.'),
  ];

  static MotivationalQuote scheduleForDate(DateTime date) {
    final index = (date.year * 366 + date.month * 31 + date.day) % _quotes.length;
    return _quotes[index];
  }
}
