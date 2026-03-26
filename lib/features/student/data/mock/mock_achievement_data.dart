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
    required this.description,
    this.unlocked = false,
    this.rarity = 'Common',
  });
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;
  final String rarity;
}

const mockStickers = [
  StickerItem(
    emoji: '🔥',
    title: 'On Fire!',
    description: 'Streak 7 ngay',
    unlocked: true,
    rarity: 'Common',
  ),
  StickerItem(
    emoji: '🚀',
    title: 'Rocket Start',
    description: 'Hoan thanh 5 bai\ntrong 1 ngay',
    unlocked: true,
    rarity: 'Rare',
  ),
  StickerItem(
    emoji: '🎯',
    title: 'Bullseye',
    description: 'Diem tuyet doi\nbai quiz',
    unlocked: true,
    rarity: 'Epic',
  ),
  StickerItem(
    emoji: '💎',
    title: 'Diamond',
    description: 'Top 1% hoc vien',
    unlocked: false,
    rarity: 'Legendary',
  ),
  StickerItem(
    emoji: '🌟',
    title: 'Rising Star',
    description: 'Dat cap 10',
    unlocked: true,
    rarity: 'Rare',
  ),
  StickerItem(
    emoji: '🏆',
    title: 'Champion',
    description: 'Thang cuoc thi\ndau tien',
    unlocked: false,
    rarity: 'Epic',
  ),
  StickerItem(
    emoji: '🎨',
    title: 'Creative Mind',
    description: 'Hoan thanh khoa\nUI/UX Design',
    unlocked: true,
    rarity: 'Common',
  ),
  StickerItem(
    emoji: '⚡',
    title: 'Speed Demon',
    description: 'Hoan thanh khoa hoc\ntrong 1 tuan',
    unlocked: false,
    rarity: 'Legendary',
  ),
  StickerItem(
    emoji: '🧠',
    title: 'Big Brain',
    description: 'Tra loi dung 100\ncau hoi',
    unlocked: true,
    rarity: 'Rare',
  ),
  StickerItem(
    emoji: '🤝',
    title: 'Helper',
    description: 'Giup 10 ban hoc\ntrong forum',
    unlocked: true,
    rarity: 'Common',
  ),
  StickerItem(
    emoji: '📚',
    title: 'Scholar',
    description: 'Doc het 100 tai lieu',
    unlocked: false,
    rarity: 'Epic',
  ),
  StickerItem(
    emoji: '🎓',
    title: 'Graduate',
    description: 'Hoan thanh 10\nkhoa hoc',
    unlocked: false,
    rarity: 'Legendary',
  ),
];
