class ApiConstants {
  // ⚠️ GANTI IP INI sesuai network kamu (10.0.2.2 untuk emulator, atau IP LAN untuk HP fisik)
  static const String baseUrl = "https://piket-nekat-be.vercel.app";

  // --- Auth ---
  static const String authLogin = "/auth/login";
  static const String authLogout = "/auth/logout";
  static const String authMe = "/auth/me";

  // --- Student Permits (Izin Siswa) ---
  static const String permits = "/student-permits";
  static const String permitsPendingMapel = "/student-permits/mapel/pending";
  static const String permitsPendingPiket =
      "/student-permits/piket/ready-to-approve";

  static String permitDetail(int id) => "/student-permits/$id";
  static String permitProcessMapel(int id) =>
      "/student-permits/$id/process/mapel";
  static String permitProcessPiket(int id) =>
      "/student-permits/$id/process/piket";

  // --- Master Data ---
  static const String students = "/students";
  static const String subjects = "/subjects";
  static const String users = "/users";
  static const String userMapel = "/users/mapel"; // Endpoint khusus guru mapel
  static const String roles = "/roles";
  static const String userRoles = "/user-roles";

  // --- [BARU] Piket Schedules ---
  static const String piketSchedules = "/piket-schedules";
  static String piketScheduleDetail(int id) => "/piket-schedules/$id";

  // --- [BARU] Teacher Assignments ---
  static const String teacherAssignments = "/teacher-assignments";
  static String teacherAssignmentDetail(int id) => "/teacher-assignments/$id";
}
