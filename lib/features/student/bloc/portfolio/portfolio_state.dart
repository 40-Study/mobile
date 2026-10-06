import 'package:equatable/equatable.dart';

class PortfolioState extends Equatable {
  const PortfolioState({
    this.isEditMode = true,
    this.visibility = 'public',
    this.sections = const [],
    this.profile,
  });

  final bool isEditMode;
  final String visibility;
  final List<PortfolioSection> sections;
  final PortfolioProfile? profile;

  PortfolioState copyWith({
    bool? isEditMode,
    String? visibility,
    List<PortfolioSection>? sections,
    PortfolioProfile? profile,
  }) {
    return PortfolioState(
      isEditMode: isEditMode ?? this.isEditMode,
      visibility: visibility ?? this.visibility,
      sections: sections ?? this.sections,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [isEditMode, visibility, sections, profile];
}

class PortfolioProfile extends Equatable {
  const PortfolioProfile({
    required this.name,
    required this.title,
    required this.location,
    required this.website,
    required this.bio,
    this.socialLinks = const [],
  });

  final String name;
  final String title;
  final String location;
  final String website;
  final String bio;
  final List<SocialLink> socialLinks;

  PortfolioProfile copyWith({
    String? name,
    String? title,
    String? location,
    String? website,
    String? bio,
    List<SocialLink>? socialLinks,
  }) {
    return PortfolioProfile(
      name: name ?? this.name,
      title: title ?? this.title,
      location: location ?? this.location,
      website: website ?? this.website,
      bio: bio ?? this.bio,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  @override
  List<Object?> get props => [name, title, location, website, bio, socialLinks];
}

class SocialLink extends Equatable {
  const SocialLink({required this.type, required this.url});

  final String type;
  final String url;

  @override
  List<Object?> get props => [type, url];
}

class PortfolioSection extends Equatable {
  const PortfolioSection({
    required this.id,
    required this.title,
    this.visible = true,
  });

  final String id;
  final String title;
  final bool visible;

  PortfolioSection copyWith({bool? visible}) {
    return PortfolioSection(id: id, title: title, visible: visible ?? this.visible);
  }

  @override
  List<Object?> get props => [id, title, visible];
}

class PortfolioStats extends Equatable {
  const PortfolioStats({
    required this.yearsExperience,
    required this.projectsCompleted,
    required this.certificates,
    required this.followers,
  });

  final String yearsExperience;
  final int projectsCompleted;
  final int certificates;
  final int followers;

  @override
  List<Object?> get props => [yearsExperience, projectsCompleted, certificates, followers];
}

class Project extends Equatable {
  const Project({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.category,
    required this.tool,
    required this.year,
  });

  final String title;
  final String subtitle;
  final String description;
  final String category;
  final String tool;
  final String year;

  @override
  List<Object?> get props => [title, subtitle, description, category, tool, year];
}

class Skill extends Equatable {
  const Skill({required this.name, required this.level});

  final String name;
  final int level;

  @override
  List<Object?> get props => [name, level];
}

class Experience extends Equatable {
  const Experience({
    required this.position,
    required this.company,
    required this.startDate,
    this.endDate,
    required this.description,
  });

  final String position;
  final String company;
  final String startDate;
  final String? endDate;
  final String description;

  @override
  List<Object?> get props => [position, company, startDate, endDate, description];
}
