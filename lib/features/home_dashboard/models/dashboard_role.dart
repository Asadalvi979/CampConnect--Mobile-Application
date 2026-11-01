enum DashboardRole {
  student,
  senior,
  alumni;

  String get label => switch (this) {
    DashboardRole.student => 'Student',
    DashboardRole.senior => 'Senior',
    DashboardRole.alumni => 'Alumni',
  };
}
