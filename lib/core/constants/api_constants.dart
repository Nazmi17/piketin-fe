class ApiConstants {
  static const String baseUrl = "https://piket-nekat-be.vercel.app";

 // ===========================================================================
  // MODULE: AUTH
  // ===========================================================================
  static const String authLogin = "/auth/login";
  static const String authLogout = "/auth/logout";
  static const String authMe = "/auth/me";

  // ===========================================================================
  // MODULE: USERS
  // ===========================================================================
  /// GET (List) & POST (Create)
  static const String users = "/users";

  /// GET (List User khusus Guru Mapel)
  static const String usersMapel = "/users/mapel";

  /// GET (Detail), PUT (Update), DELETE (Delete)
  static String userDetail(int id) => "/users/$id";

  // ===========================================================================
  // MODULE: USER ROLES
  // ===========================================================================
  /// GET (List Roles by User) & POST (Add Role to User)
  static String userRoles(int userId) => "/user-roles/$userId";

  /// DELETE (Remove Role from User)
  static String deleteUserRole(int userId, int roleId) =>
      "/user-roles/$userId/$roleId";

  // ===========================================================================
  // MODULE: ROLES
  // ===========================================================================
  /// GET (List All Roles)
  static const String roles = "/roles";

  // ===========================================================================
  // MODULE: STUDENTS
  // ===========================================================================
  /// GET (List All Students)
  static const String students = "/students";

  // ===========================================================================
  // MODULE: SUBJECTS (Mata Pelajaran)
  // ===========================================================================
  /// GET (List) & POST (Create)
  static const String subjects = "/subjects";

  /// GET (Detail), PUT (Update), DELETE (Delete)
  static String subjectDetail(int id) => "/subjects/$id";

  // ===========================================================================
  // MODULE: STUDENT PERMITS (Izin Siswa)
  // ===========================================================================
  /// GET (List with filters) & POST (Create)
  static const String permits = "/student-permits";

  /// GET (List Pending Mapel - Khusus Guru Mapel)
  static const String permitsPendingMapel = "/student-permits/mapel/pending";

  /// GET (List Pending Piket - Khusus Guru Piket)
  static const String permitsPendingPiket =
      "/student-permits/piket/ready-to-approve";

  /// GET (Detail), PUT (Update), DELETE (Cancel/Delete)
  static String permitDetail(int id) => "/student-permits/$id";

  /// PATCH (Approval Guru Mapel)
  static String permitProcessMapel(int id) =>
      "/student-permits/$id/process/mapel";

  /// PATCH (Approval Guru Piket)
  static String permitProcessPiket(int id) =>
      "/student-permits/$id/process/piket";

  // ===========================================================================
  // MODULE: PIKET SCHEDULES (Jadwal Piket)
  // ===========================================================================
  /// GET (List with day filter) & POST (Create)
  static const String piketSchedules = "/piket-schedules";

  /// GET (Detail), PUT (Update), DELETE (Delete)
  static String piketScheduleDetail(int id) => "/piket-schedules/$id";

  // ===========================================================================
  // MODULE: TEACHER ASSIGNMENTS (Tugas Guru)
  // ===========================================================================
  /// GET (List with filters) & POST (Create)
  static const String teacherAssignments = "/teacher-assignments";

  /// GET (Detail), PUT (Update), DELETE (Delete)
  static String teacherAssignmentDetail(int id) => "/teacher-assignments/$id";
}
