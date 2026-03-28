import 'package:flutter/material.dart';

class BadgeItem {
  const BadgeItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.unlocked = false,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool unlocked;
}

const mockBadges = [
  BadgeItem(
    icon: Icons.bolt_rounded,
    title: 'Fast Learner',
    description: 'Hoan thanh bai hoc\nduoi 5 phut',
    color: Color(0xff2563eb),
    unlocked: true,
  ),
  BadgeItem(
    icon: Icons.local_fire_department_rounded,
    title: '7-day Streak',
    description: 'Hoc tap lien tuc\ntrong 1 tuan',
    color: Color(0xfff97316),
    unlocked: true,
  ),
  BadgeItem(
    icon: Icons.quiz_rounded,
    title: 'Top Quizzer',
    description: 'Dat diem tuyet doi\n10 bai quiz',
    color: Color(0xff8b5cf6),
    unlocked: false,
  ),
  BadgeItem(
    icon: Icons.menu_book_rounded,
    title: 'Book Worm',
    description: 'Doc het 50 tai lieu\nbo tro',
    color: Color(0xff10b981),
    unlocked: false,
  ),
  BadgeItem(
    icon: Icons.rocket_launch_rounded,
    title: 'Pioneer',
    description: 'Dang ky khoa hoc\ndau tien',
    color: Color(0xffef4444),
    unlocked: true,
  ),
  BadgeItem(
    icon: Icons.groups_rounded,
    title: 'Team Player',
    description: 'Tham gia 5 thao luan\ntrong lop',
    color: Color(0xff06b6d4),
    unlocked: true,
  ),
];

class CertItem {
  const CertItem({
    required this.title,
    required this.issuer,
    required this.date,
    required this.credential,
    this.verified = true,
  });
  final String title;
  final String issuer;
  final String date;
  final String credential;
  final bool verified;
}

const mockCerts = [
  CertItem(
    title: 'Flutter Development Professional',
    issuer: '40Study Academy',
    date: '15/02/2024',
    credential: 'CERT-FL-2024-0891',
  ),
  CertItem(
    title: 'UI/UX Design Fundamentals',
    issuer: '40Study Academy',
    date: '28/01/2024',
    credential: 'CERT-UX-2024-0456',
  ),
  CertItem(
    title: 'Data Science with Python',
    issuer: '40Study Academy',
    date: '10/12/2023',
    credential: 'CERT-DS-2023-1203',
  ),
  CertItem(
    title: 'Web Fullstack Development',
    issuer: '40Study Academy',
    date: '05/11/2023',
    credential: 'CERT-WF-2023-0987',
  ),
  CertItem(
    title: 'React Native Mobile Apps',
    issuer: '40Study Academy',
    date: '20/09/2023',
    credential: 'CERT-RN-2023-0654',
    verified: false,
  ),
];

class StickerItem {
  const StickerItem({
    required this.emoji,
    required this.title,
    this.unlocked = false,
  });
  final String emoji;
  final String title;
  final bool unlocked;
}

class StickerCollection {
  const StickerCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.coverEmoji,
    required this.stickers,
    this.color = const Color(0xff6366f1),
  });
  final String id;
  final String name;
  final String description;
  final String coverEmoji;
  final List<StickerItem> stickers;
  final Color color;

  int get unlockedCount => stickers.where((s) => s.unlocked).length;
  bool get isCompleted => unlockedCount == stickers.length;
}

const mockStickerCollections = [
  StickerCollection(
    id: 'code_king',
    name: 'Vua Code',
    description: '征服moi thử thach lap trinh',
    coverEmoji: '👑',
    color: Color(0xfff59e0b),
    stickers: [
      StickerItem(emoji: '💻', title: 'First Code', unlocked: true),
      StickerItem(emoji: '🐛', title: 'Bug Hunter', unlocked: true),
      StickerItem(emoji: '⚡', title: 'Speed Coder', unlocked: true),
      StickerItem(emoji: '🧩', title: 'Problem Solver', unlocked: false),
      StickerItem(emoji: '👑', title: 'Code King', unlocked: false),
    ],
  ),
  StickerCollection(
    id: 'fire_streak',
    name: 'Ngon Lua',
    description: 'Duy tri streak hoc tap',
    coverEmoji: '🔥',
    color: Color(0xffef4444),
    stickers: [
      StickerItem(emoji: '🕯️', title: '3 ngay', unlocked: true),
      StickerItem(emoji: '🔥', title: '7 ngay', unlocked: true),
      StickerItem(emoji: '🌋', title: '30 ngay', unlocked: false),
      StickerItem(emoji: '☄️', title: '100 ngay', unlocked: false),
    ],
  ),
  StickerCollection(
    id: 'brain_power',
    name: 'Sieu Nao',
    description: '征服cac bai quiz kho',
    coverEmoji: '🧠',
    color: Color(0xff8b5cf6),
    stickers: [
      StickerItem(emoji: '💡', title: 'First Quiz', unlocked: true),
      StickerItem(emoji: '🎯', title: 'Perfect 10', unlocked: true),
      StickerItem(emoji: '🧠', title: 'Big Brain', unlocked: false),
      StickerItem(emoji: '🔮', title: 'Genius', unlocked: false),
      StickerItem(emoji: '🌌', title: 'Galaxy Brain', unlocked: false),
    ],
  ),
  StickerCollection(
    id: 'social_star',
    name: 'Ngoi Sao XH',
    description: 'Ket noi voi cong dong',
    coverEmoji: '⭐',
    color: Color(0xff10b981),
    stickers: [
      StickerItem(emoji: '👋', title: 'Say Hi', unlocked: true),
      StickerItem(emoji: '💬', title: 'Chatterbox', unlocked: true),
      StickerItem(emoji: '🤝', title: 'Helper', unlocked: true),
      StickerItem(emoji: '👨‍🏫', title: 'Mentor', unlocked: false),
      StickerItem(emoji: '⭐', title: 'Superstar', unlocked: false),
    ],
  ),
  StickerCollection(
    id: 'explorer',
    name: 'Nha Tham Hiem',
    description: 'Kham pha cac khoa hoc',
    coverEmoji: '🗺️',
    color: Color(0xff0ea5e9),
    stickers: [
      StickerItem(emoji: '🚀', title: 'First Course', unlocked: true),
      StickerItem(emoji: '📚', title: '5 Courses', unlocked: false),
      StickerItem(emoji: '🗺️', title: '10 Courses', unlocked: false),
      StickerItem(emoji: '🌍', title: 'World Explorer', unlocked: false),
    ],
  ),
  StickerCollection(
    id: 'legend',
    name: 'Huyen Thoai',
    description: 'Nhung thanh tuu dac biet',
    coverEmoji: '🏆',
    color: Color(0xfff97316),
    stickers: [
      StickerItem(emoji: '🥉', title: 'Bronze', unlocked: true),
      StickerItem(emoji: '🥈', title: 'Silver', unlocked: false),
      StickerItem(emoji: '🥇', title: 'Gold', unlocked: false),
      StickerItem(emoji: '💎', title: 'Diamond', unlocked: false),
      StickerItem(emoji: '🏆', title: 'Legend', unlocked: false),
    ],
  ),
];

// Flatten all stickers for counting
List<StickerItem> get mockStickers =>
    mockStickerCollections.expand((c) => c.stickers).toList();
