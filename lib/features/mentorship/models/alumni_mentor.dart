class AlumniMentor {
  const AlumniMentor({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.company,
    required this.industry,
    required this.graduationYear,
    required this.yearsExperience,
    required this.location,
    required this.department,
    required this.degree,
    required this.bio,
    required this.skills,
    required this.focusAreas,
    required this.experience,
    required this.menteesGuided,
    required this.rating,
    required this.reviewCount,
    required this.acceptsRequests,
    required this.openSpots,
  });

  final String id;
  final String name;
  final String jobTitle;
  final String company;
  final String industry;
  final int graduationYear;
  final int yearsExperience;
  final String location;
  final String department;
  final String degree;
  final String bio;
  final List<String> skills;
  final List<String> focusAreas;
  final List<AlumniExperience> experience;
  final int menteesGuided;
  final double rating;
  final int reviewCount;
  final bool acceptsRequests;
  final int openSpots;

  String get headline => '$jobTitle @ $company';
}

class AlumniExperience {
  const AlumniExperience({
    required this.title,
    required this.company,
    required this.period,
    required this.description,
  });

  final String title;
  final String company;
  final String period;
  final String description;
}
