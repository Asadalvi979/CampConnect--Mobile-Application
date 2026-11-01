import '../models/community.dart';
import '../models/community_membership.dart';
import '../models/post.dart';

abstract final class CommunityMockData {
  static const currentUserId = 'current-user';

  static final communities = <Community>[
    const Community(
      id: 'software-engineering',
      name: 'Software Engineering Community',
      category: 'Technology',
      description: 'Official student and alumni hub for software engineering, FYP partnerships, hackathons, and technical discussions at Riphah International University Sahiwal.',
      memberCount: 428,
      onlineCount: 12,
    ),
    const Community(
      id: 'artificial-intelligence',
      name: 'Artificial Intelligence & Machine Learning',
      category: 'Technology',
      description: 'Deep learning, NLP, computer vision study group and paper reviews with senior mentors.',
      memberCount: 315,
      onlineCount: 8,
    ),
    const Community(
      id: 'web-development',
      name: 'Web Development',
      category: 'Technology',
      description: 'Full-stack development, modern frontend frameworks, REST APIs, and UI/UX design discussions.',
      memberCount: 260,
      onlineCount: 22,
    ),
    const Community(
      id: 'career-guidance',
      name: 'Career & Internship Guidance',
      category: 'Career',
      description: 'Alumni mentorship, resume reviews, interview preparation, and tech job referrals.',
      memberCount: 540,
      onlineCount: 31,
    ),
    const Community(
      id: 'competitive-programming',
      name: 'Competitive Programming',
      category: 'Academic',
      description: 'LeetCode problem solving, algorithmic challenges, and ICPC contest preparation.',
      memberCount: 195,
      onlineCount: 9,
    ),
    const Community(
      id: 'fyp-collaboration',
      name: 'Final Year Project Discussion',
      category: 'Projects',
      description: 'Find teammates and discuss ideas, research, and final year projects.',
      memberCount: 180,
      onlineCount: 6,
    ),
  ];

  static final memberships = <CommunityMembership>[
    const CommunityMembership(
      communityId: 'software-engineering',
      userId: currentUserId,
    ),
    const CommunityMembership(
      communityId: 'artificial-intelligence',
      userId: currentUserId,
    ),
    const CommunityMembership(
      communityId: 'fyp-collaboration',
      userId: currentUserId,
    ),
  ];

  static List<CommunityPost> get posts {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: 'post-workshop',
        communityId: 'software-engineering',
        authorId: 'zainab',
        content: 'We are organizing a hands-on Flutter & Clean Architecture workshop this Friday at Lab 3. RSVP below!',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CommunityPost(
        id: 'post-campus-iot',
        communityId: 'software-engineering',
        authorId: currentUserId,
        content: "Excited to share our team's upcoming open-source campus initiative: Smart Campus Parking IoT & Mobile App! We are actively looking for contributors with experience in Flutter and Python MQTT.",
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      CommunityPost(
        id: 'post-internships',
        communityId: 'software-engineering',
        authorId: 'bilal',
        content: 'Tips for junior students preparing for summer software engineering internships: build a production project, practice problem solving, and keep your coursework strong.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CommunityPost(
        id: 'post-ai-study',
        communityId: 'artificial-intelligence',
        authorId: 'hamza',
        content: 'We are starting a weekly computer vision study group. Share the topics you would like to explore together.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static const memberPreviews = <({String name, String role, String detail})>[
    (
      name: 'Zainab Fatima',
      role: 'Senior',
      detail: 'BS Software Engineering • 7th Semester',
    ),
    (
      name: 'Bilal Ahmed',
      role: 'Alumni',
      detail: 'Software Engineer • Batch 2022',
    ),
    (
      name: 'Asadullah Sadiq',
      role: 'Student',
      detail: 'BS Software Engineering • 5th Semester',
    ),
    (
      name: 'Hamza Tariq',
      role: 'Senior',
      detail: 'BS Computer Science • 6th Semester',
    ),
    (
      name: 'Ayesha Malik',
      role: 'Alumni',
      detail: 'UI/UX Designer • Batch 2021',
    ),
    (
      name: 'Usman Ali',
      role: 'Student',
      detail: 'BS Software Engineering • 3rd Semester',
    ),
  ];

  static String userName(String userId) => switch (userId) {
    currentUserId => 'Asadullah Sadiq',
    'zainab' => 'Zainab Fatima',
    'bilal' => 'Bilal Ahmed',
    'hamza' => 'Hamza Tariq',
    _ => 'Community Member',
  };

  static String userRole(String userId) => switch (userId) {
    currentUserId => 'Student',
    'zainab' || 'hamza' => 'Senior',
    'bilal' => 'Alumni',
    _ => 'Student',
  };
}
