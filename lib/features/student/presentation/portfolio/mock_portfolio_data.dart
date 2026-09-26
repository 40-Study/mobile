import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';

// TODO(MOCK-01): Mock data cho portfolio demo. Xóa file này khi có API.
// API endpoint cần: GET /api/student/portfolio

const kMockProfile = PortfolioProfile(
  name: 'Linh Nguyen',
  title: 'UI/UX Designer',
  location: 'Hà Nội, Việt Nam',
  website: 'linhnguyen.design',
  bio: 'Mình là UI/UX Designer với niềm đam mê tạo ra những trải nghiệm số đẹp mắt, hữu ích và dễ sử dụng.',
  socialLinks: [
    SocialLink(type: 'dribbble', url: ''),
    SocialLink(type: 'behance', url: ''),
    SocialLink(type: 'linkedin', url: ''),
    SocialLink(type: 'github', url: ''),
  ],
);

const kMockStats = PortfolioStats(
  yearsExperience: '3+',
  projectsCompleted: 18,
  certificates: 12,
  followers: 120,
);

const kMockProjects = [
  Project(
    title: 'EduFlow',
    subtitle: 'Hệ thống quản lý học tập',
    description: 'Thiết kế hệ thống dashboard và trải nghiệm học tập toàn diện.',
    category: 'UI/UX DESIGN',
    tool: 'Figma',
    year: '2024',
  ),
  Project(
    title: 'Mindora',
    subtitle: 'Ứng dụng thiền và thư giãn',
    description: 'Thiết kế ứng dụng giúp người dùng thiền định và theo dõi thói quen.',
    category: 'MOBILE APP',
    tool: 'Figma',
    year: '2023',
  ),
  Project(
    title: 'GreenSpace',
    subtitle: 'Website thương hiệu',
    description: 'Thiết kế website giới thiệu sản phẩm và thương hiệu thân thiện.',
    category: 'WEBSITE',
    tool: 'Figma',
    year: '2023',
  ),
];

const kMockSkills = [
  Skill(name: 'UI Design', level: 5),
  Skill(name: 'UX Research', level: 3),
  Skill(name: 'Prototyping', level: 4),
  Skill(name: 'Interaction Design', level: 4),
  Skill(name: 'Figma', level: 5),
  Skill(name: 'Design System', level: 4),
  Skill(name: 'Wireframing', level: 4),
  Skill(name: 'Usability Testing', level: 3),
];

const kMockExperiences = [
  Experience(
    position: 'Senior UI/UX Designer',
    company: 'Vela Creative Studio',
    startDate: '03/2022',
    endDate: null,
    description: 'Thiết kế sản phẩm số cho khách hàng trong lĩnh vực edtech, fintech và healthtech. Dẫn dắt team 4 designer trong các dự án lớn.',
  ),
];
