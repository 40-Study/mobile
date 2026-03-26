import 'package:flutter/material.dart';

class MockArticle {
  const MockArticle({
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.gradient,
    required this.icon,
  });
  final String title;
  final String tag;
  final Color tagColor;
  final List<Color> gradient;
  final IconData icon;
}

const mockArticles = [
  MockArticle(
    title: 'Tuong lai cua AI\ntrong giao duc\nhien dai',
    tag: 'CONG NGHE',
    tagColor: Color(0xff10b981),
    gradient: [Color(0xff0f172a), Color(0xff1e3a5f)],
    icon: Icons.auto_awesome_rounded,
  ),
  MockArticle(
    title: 'Phuong phap\nhoc tap 40Study\nhieu qua',
    tag: 'KY NANG',
    tagColor: Color(0xff8b5cf6),
    gradient: [Color(0xff4c1d95), Color(0xff6d28d9)],
    icon: Icons.psychology_rounded,
  ),
  MockArticle(
    title: 'Top 10 ngon ngu\nlap trinh\nnam 2024',
    tag: 'LAP TRINH',
    tagColor: Color(0xff2563eb),
    gradient: [Color(0xff1e3a5f), Color(0xff2563eb)],
    icon: Icons.code_rounded,
  ),
];

class MockContest {
  const MockContest({
    required this.title,
    required this.participants,
    required this.deadline,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
  final String title;
  final String participants;
  final String deadline;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

const mockContests = [
  MockContest(
    title: 'Hackathon 2024:\nGreen Tech',
    participants: '1.240 tham gia',
    deadline: 'Con 2 ngay',
    icon: Icons.code_rounded,
    iconBg: Color(0xffdbeafe),
    iconColor: Color(0xff2563eb),
  ),
  MockContest(
    title: 'Data Science\nChallenge',
    participants: '350 tham gia',
    deadline: 'Con 5 gio',
    icon: Icons.shield_rounded,
    iconBg: Color(0xfffef3c7),
    iconColor: Color(0xfff59e0b),
  ),
];

class MockTrendingCourse {
  const MockTrendingCourse({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.gradient,
    required this.icon,
    required this.instructorName,
  });
  final String id;
  final String title;
  final String price;
  final double rating;
  final List<Color> gradient;
  final IconData icon;
  final String instructorName;
}

const mockTrendingCourses = [
  MockTrendingCourse(
    id: 'trend1',
    title: 'Lap trinh Python tu\nco ban den nang cao',
    price: '599k',
    rating: 4.9,
    gradient: [Color(0xff0f172a), Color(0xff1e40af)],
    icon: Icons.terminal_rounded,
    instructorName: 'Thay Tran Quoc Bao',
  ),
  MockTrendingCourse(
    id: 'trend2',
    title: 'Thiet ke UI/UX cho\nnguoi moi bat dau',
    price: '450k',
    rating: 4.8,
    gradient: [Color(0xff4c1d95), Color(0xff7c3aed)],
    icon: Icons.palette_rounded,
    instructorName: 'Co Nguyen Lan Phuong',
  ),
  MockTrendingCourse(
    id: 'trend3',
    title: 'React Native:\nMobile App Development',
    price: '699k',
    rating: 4.7,
    gradient: [Color(0xff064e3b), Color(0xff10b981)],
    icon: Icons.phone_android_rounded,
    instructorName: 'Thay Le Minh Duc',
  ),
];
