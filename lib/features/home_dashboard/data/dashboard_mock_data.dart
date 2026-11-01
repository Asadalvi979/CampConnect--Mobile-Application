class DashboardMentor {
  const DashboardMentor({
    required this.name,
    required this.title,
    required this.skills,
    required this.initials,
  });

  final String name;
  final String title;
  final String skills;
  final String initials;
}

class DashboardProject {
  const DashboardProject({
    required this.title,
    required this.description,
    required this.tags,
    required this.meta,
  });

  final String title;
  final String description;
  final String tags;
  final String meta;
}

class DashboardPost {
  const DashboardPost({
    required this.title,
    required this.community,
    required this.author,
    required this.replies,
  });

  final String title;
  final String community;
  final String author;
  final String replies;
}

class DashboardResource {
  const DashboardResource({
    required this.title,
    required this.description,
    required this.meta,
  });

  final String title;
  final String description;
  final String meta;
}

class DashboardRequest {
  const DashboardRequest({
    required this.name,
    required this.study,
    required this.message,
    required this.when,
  });

  final String name;
  final String study;
  final String message;
  final String when;
}

abstract final class DashboardMockData {
  static const studentName = 'Usman';
  static const studentProgram = 'BS Software Engineering • 3rd Sem';
  static const campus = 'Riphah International University • Sahiwal';
  static const semester = 'Fall Semester 2024';
  static const semesterWeek = 'Week 8 of 16';
  static const studentAnnouncementTitle =
      'Fall 2024 Capstone Project & FYP Proposals Open';
  static const studentAnnouncement =
      'Department of Computing invites project synopsis submissions. Submit supervisor approval letters via the departmental academic portal before the deadline.';

  static const mentors = [
    DashboardMentor(
      name: 'Ayesha Malik',
      title: 'Lead Product Designer @ DevStudio',
      skills: 'UI/UX  •  Flutter',
      initials: 'AM',
    ),
    DashboardMentor(
      name: 'Bilal Ahmed',
      title: 'Senior Software Engineer',
      skills: 'Cloud Architecture',
      initials: 'BA',
    ),
  ];

  static const studentProjects = [
    DashboardProject(
      title: 'AI-Based Student Assistant',
      description: 'Project Lead: Asadullah Sadiq',
      tags: 'Flutter  •  Python  •  NLP',
      meta: '4 Collaborators Needed',
    ),
    DashboardProject(
      title: 'Smart Campus Parking System',
      description: 'Project Lead: Bilal Ahmed',
      tags: 'IoT  •  Embedded C++  •  Raspberry Pi',
      meta: '2 Embedded Devs Needed',
    ),
  ];

  static const studentPost = DashboardPost(
    title: 'Tips for clearing CS-304 Database Systems Midterms?',
    community: 'CS & SE Society',
    author: 'Hamza Tariq',
    replies: '14 replies',
  );

  static const studentResource = DashboardResource(
    title: 'Database Systems Midterm Solved Past Papers (2021–2024)',
    description: 'Uploaded by Asadullah Sadiq • Department of Computing',
    meta: '184 campus downloads',
  );

  static const studentReminder =
      'Midterm examination schedules will be released on portal by Friday.';

  static const seniorName = 'Zainab';
  static const seniorProgram = 'Senior Student • 7th Sem BSSE • Dean’s Honor';
  static const seniorActions = 'Impact: 18 Guided';
  static const seniorRequests = [
    DashboardRequest(
      name: 'Usman Ali',
      study: '3rd Sem BSSE',
      message: 'Seeking guidance on Data Structures & State Management (Riverpod vs Bloc) in Flutter.',
      when: '3rd Sem BSSE',
    ),
    DashboardRequest(
      name: 'Danish Rehman',
      study: '4th Sem BSSE',
      message: 'Interested in collaborating on mobile UI/UX engineering and capstone research setup.',
      when: '4th Sem BSSE',
    ),
  ];
  static const seniorProjects = [
    DashboardProject(
      title: 'Smart Campus Parking System',
      description: 'Need Senior Lead for MQTT integration.',
      tags: 'IoT + Flutter',
      meta: 'Capstone',
    ),
    DashboardProject(
      title: 'CampConnect Mobile App Architecture',
      description: 'Peer collaboration with Computer Science students.',
      tags: 'Architecture Review',
      meta: 'Project opportunity',
    ),
  ];
  static const seniorDiscussion = DashboardPost(
    title: 'How to choose between Bloc and Riverpod for FYP?',
    community: 'Mobile Dev Club',
    author: 'Usman Ali',
    replies: '3 replies already',
  );
  static const seniorNotice = DashboardResource(
    title: 'Midterm Examination Schedule',
    description: 'Finalized seating plan and examination schedule.',
    meta: 'Registrar Office',
  );

  static const alumniName = 'Bilal';
  static const alumniTitle = 'Alumni Mentor • Senior SE @ Systems Ltd';
  static const alumniMentorshipRequests = [
    DashboardRequest(
      name: 'Asadullah Sadiq',
      study: '5th Sem • BS Software Engineering',
      message: 'Requesting career and system design guidance for Spring 2025. Aiming for cloud microservices track.',
      when: '2d ago',
    ),
    DashboardRequest(
      name: 'Hira Naveed',
      study: '8th Sem • BS Computer Science',
      message: 'Seeking an AI capstone architecture review before midterm evaluations next month.',
      when: 'Yesterday',
    ),
  ];
  static const alumniProjects = [
    DashboardProject(
      title: 'AI-Based Student Assistant',
      description: 'Department of Computer Science • Final Year Project',
      tags: 'Advisory Request',
      meta: 'Review Project',
    ),
  ];
  static const alumniPost = DashboardPost(
    title: 'Transitioning from University to Software Industry in Pakistan',
    community: 'Alumni Career Forum',
    author: 'Bilal Ahmed',
    replies: '28 replies',
  );
  static const alumniResource = DashboardResource(
    title: 'Share Learning Materials',
    description: 'Upload interview prep, slides, or guides.',
    meta: 'Contribution Hub',
  );
  static const alumniNotice = DashboardResource(
    title: 'Campus Mentorship Program – Fall Drive',
    description: 'Inviting distinguished alumni to expand mentorship capacity for final-year capstone panels and peer review.',
    meta: '71% Enrolled (142 / 200)',
  );
}
