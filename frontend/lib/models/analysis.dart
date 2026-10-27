class Analysis {
  final int score;
  final double matchPercentage;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final List<String> extraSkills;
  final double experienceYears;
  final List<String> education;
  final List<String> suggestions;
  final int atsScore;
  final int wordCount;
  final Map<String, dynamic> contactInfo;

  Analysis({
    required this.score,
    required this.matchPercentage,
    required this.matchedSkills,
    required this.missingSkills,
    required this.extraSkills,
    required this.experienceYears,
    required this.education,
    required this.suggestions,
    required this.atsScore,
    required this.wordCount,
    required this.contactInfo,
  });

  factory Analysis.fromJson(Map<String, dynamic> j) {
    return Analysis(
      score: j['score'] ?? 0,
      matchPercentage: (j['match_percentage'] ?? 0).toDouble(),
      matchedSkills: List<String>.from(j['matched_skills'] ?? []),
      missingSkills: List<String>.from(j['missing_skills'] ?? []),
      extraSkills: List<String>.from(j['extra_skills'] ?? []),
      experienceYears: (j['experience_years'] ?? 0).toDouble(),
      education: List<String>.from(j['education'] ?? []),
      suggestions: List<String>.from(j['suggestions'] ?? []),
      atsScore: j['ats_score'] ?? 0,
      wordCount: j['word_count'] ?? 0,
      contactInfo: Map<String, dynamic>.from(j['contact_info'] ?? {}),
    );
  }
}