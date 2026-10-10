import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const CampusFlowApp());
}

class Student {
  Student({
    required this.id,
    required this.name,
    required this.roll,
    required this.gender,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.year,
    required this.branch,
    required this.section,
    required this.semester,
    required this.admissionYear,
    required this.cgpa,
    required this.present,
    required this.totalClasses,
    required this.feesTotal,
    required this.feesPaid,
    required this.marks,
    required this.feeHistory,
  });

  String id;
  String name;
  String roll;
  String gender;
  String dob;
  String email;
  String phone;
  String address;
  int year;
  String branch;
  String section;
  int semester;
  int admissionYear;
  double cgpa;
  int present;
  int totalClasses;
  double feesTotal;
  double feesPaid;
  Map<String, int> marks;
  List<String> feeHistory;

  double get attendance => totalClasses == 0 ? 0 : present * 100 / totalClasses;
  double get feesPending => (feesTotal - feesPaid).clamp(0, double.infinity).toDouble();
  String get feeStatus => feesPending <= 0 ? 'Paid' : feesPaid > 0 ? 'Partial' : 'Pending';
}

class CampusController extends ChangeNotifier {
  CampusController() {
    students = _seedStudents();
  }

  late List<Student> students;
  bool notificationsEnabled = true;
  bool compactMode = false;
  bool showLowAttendanceAlerts = true;
  bool darkMode = true;
  int _notificationCounter = 4;

  static const List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  static const List<String> branches = ['CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AIML', 'DS'];
  static const List<String> sections = ['A', 'B'];

  List<String> subjectsFor(String branch, int semester) {
    final Map<String, List<String>> base = {
      'CSE': ['Data Structures', 'DBMS', 'Operating Systems', 'Computer Networks', 'Artificial Intelligence'],
      'ECE': ['Digital Electronics', 'Signals & Systems', 'Communication Systems', 'Microprocessors', 'VLSI Design'],
      'EEE': ['Circuit Theory', 'Power Systems', 'Electrical Machines', 'Control Systems', 'Power Electronics'],
      'MECH': ['Thermodynamics', 'Fluid Mechanics', 'Machine Design', 'Manufacturing', 'Heat Transfer'],
      'CIVIL': ['Surveying', 'Structural Analysis', 'Geotechnical Engineering', 'Concrete Technology', 'Transportation'],
      'IT': ['Web Technologies', 'Cloud Computing', 'DBMS', 'Software Engineering', 'Cyber Security'],
      'AIML': ['Machine Learning', 'Deep Learning', 'NLP', 'Data Mining', 'Computer Vision'],
      'DS': ['Statistics', 'Data Analytics', 'Machine Learning', 'Big Data', 'Data Visualization'],
    };
    final list = List<String>.from(base[branch] ?? base['CSE']!);
    if (semester.isEven) list[0] = '${list[0]} II';
    return list;
  }

  List<Student> _seedStudents() {
    final result = <Student>[];
    final firstNames = ['Sai Charan', 'Lahari', 'Pavan Kumar', 'Sravani', 'Karthik', 'Keerthana', 'Vamsi Krishna', 'Mounika', 'Nikhil', 'Bhavya', 'Sandeep', 'Haritha', 'Harsha', 'Navya', 'Teja', 'Sirisha'];
    final lastNames = ['Reddy', 'Naidu', 'Kumar', 'Rao', 'Chowdary', 'Varma', 'Goud', 'Prasad'];
    var index = 0;
    for (var year = 1; year <= 4; year++) {
      for (var branchIndex = 0; branchIndex < branches.length; branchIndex++) {
        for (var copy = 0; copy < 2; copy++) {
          index++;
          final branch = branches[branchIndex];
          final semester = (year - 1) * 2 + (copy % 2) + 1;
          final subjectNames = subjectsFor(branch, semester);
          final marks = <String, int>{};
          for (var m = 0; m < subjectNames.length; m++) {
            marks[subjectNames[m]] = 62 + ((index * 7 + m * 5) % 31);
          }
          final present = 62 + ((index * 3) % 30);
          final total = 75 + ((index * 2) % 18);
          final totalFee = 65000 + ((branchIndex % 3) * 5000);
          final paid = index % 5 == 0 ? totalFee * .55 : index % 7 == 0 ? totalFee * .78 : totalFee;
          result.add(Student(
            id: 'CF${1000 + index}',
            name: '${firstNames[(index - 1) % firstNames.length]} ${lastNames[(index + branchIndex) % lastNames.length]}',
            roll: '22${branchIndex.toString().padLeft(2, '0')}${index.toString().padLeft(3, '0')}',
            gender: index.isEven ? 'Female' : 'Male',
            dob: '200${4 - (year % 2)}-${(index % 9) + 1}'.padLeft(10, '0'),
            email: 'student$index@campusflow.edu',
            phone: '98${(60000000 + index * 137).toString().padLeft(8, '0')}',
            address: 'Campus Residence, Main Road, University City',
            year: year,
            branch: branch,
            section: sections[(index - 1) % sections.length],
            semester: semester,
            admissionYear: 2026 - year + 1,
            cgpa: 6.8 + ((index * 11) % 29) / 10,
            present: present,
            totalClasses: total,
            feesTotal: totalFee.toDouble(),
            feesPaid: paid.toDouble(),
            marks: marks,
            feeHistory: paid >= totalFee
                ? ['Tuition fee paid • ₹${totalFee.toStringAsFixed(0)} • Aug 2026']
                : ['Partial payment • ₹${paid.toStringAsFixed(0)} • Sep 2026'],
          ));
        }
      }
    }
    return result;
  }

  Student? byId(String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  void addStudent(Student student) {
    students.insert(0, student);
    notifyListeners();
  }

  void updateStudent(Student student) {
    final index = students.indexWhere((s) => s.id == student.id);
    if (index >= 0) students[index] = student;
    notifyListeners();
  }

  void deleteStudent(String id) {
    students.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void markAttendance(String id, bool present) {
    final student = byId(id);
    if (student == null) return;
    student.totalClasses += 1;
    if (present) student.present += 1;
    notifyListeners();
  }

  void updateMark(String id, String subject, int mark) {
    final student = byId(id);
    if (student == null) return;
    student.marks[subject] = mark.clamp(0, 100).toInt();
    notifyListeners();
  }

  void addFeePayment(String id, double amount) {
    final student = byId(id);
    if (student == null || amount <= 0) return;
    final remaining = student.feesTotal - student.feesPaid;
    final actual = amount > remaining ? remaining : amount;
    student.feesPaid += actual;
    student.feeHistory.insert(0, 'Payment received • ₹${actual.toStringAsFixed(0)} • Oct 2026');
    notifyListeners();
  }

  int get totalStudents => students.length;
  double get averageAttendance => students.isEmpty ? 0 : students.map((s) => s.attendance).reduce((a, b) => a + b) / students.length;
  double get averageCgpa => students.isEmpty ? 0 : students.map((s) => s.cgpa).reduce((a, b) => a + b) / students.length;
  double get pendingFees => students.fold(0, (sum, s) => sum + s.feesPending);

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void toggleCompact(bool value) {
    compactMode = value;
    notifyListeners();
  }

  void toggleLowAttendance(bool value) {
    showLowAttendanceAlerts = value;
    notifyListeners();
  }

  int nextNotificationId() => ++_notificationCounter;
}

final campus = CampusController();

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: campus,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CampusFlow',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFAF5EC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9F1838),
              brightness: Brightness.light,
              surface: const Color(0xFFFFFFFF),
            ).copyWith(
              primary: const Color(0xFF9F1838),
              onPrimary: Colors.white,
              secondary: const Color(0xFFD77B91),
              onSurface: const Color(0xFF211B19),
              outline: const Color(0xFFE0D0BA),
            ),
            fontFamily: 'Georgia',
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF211B19)),
              bodyMedium: TextStyle(color: Color(0xFF211B19)),
              titleMedium: TextStyle(color: Color(0xFF211B19)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFAF5EC),
              foregroundColor: Color(0xFF211B19),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFFF5EBDD),
              labelStyle: const TextStyle(color: Color(0xFF4B403A)),
              prefixIconColor: const Color(0xFF9F1838),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0D0BA))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE0D0BA))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF9F1838), width: 1.8)),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFFFFFFFF),
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE7D9C5), width: 1.2)),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8D1732),
                side: const BorderSide(color: Color(0xFFD7B99A), width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9F1838),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: const Duration(milliseconds: 320), pageBuilder: (_, animation, secondaryAnimation) => const LoginScreen(), transitionsBuilder: (_, animation, secondaryAnimation, child) => FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic), child: ScaleTransition(scale: Tween<double>(begin: .98, end: 1).animate(animation), child: child))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 84, height: 84, decoration: BoxDecoration(color: const Color(0xFF9F1838), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.school_rounded, size: 48, color: Colors.white)),
          const SizedBox(height: 22),
          const Text('CampusFlow', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Smart campus management', style: TextStyle(color: const Color(0xFF27211F), fontSize: 15)),
          const SizedBox(height: 30),
          const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2)),
        ]),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'admin@campusflow.edu');
  final password = TextEditingController(text: 'admin123');
  bool obscure = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void login() {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email and password.')));
      return;
    }
    Navigator.pushReplacement(context, PageRouteBuilder(transitionDuration: const Duration(milliseconds: 320), pageBuilder: (_, animation, secondaryAnimation) => const DashboardScreen(), transitionsBuilder: (_, animation, secondaryAnimation, child) => FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic), child: ScaleTransition(scale: Tween<double>(begin: .98, end: 1).animate(animation), child: child))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF5EC), Color(0xFFF0E3CF), Color(0xFFFDFBFF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF211B19),
                  borderRadius: BorderRadius.circular(42),
                  boxShadow: [BoxShadow(color: const Color(0xFF9F1838).withValues(alpha: .20), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Container(
                    color: const Color(0xFFFFFFFF),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(width: 92, height: 20, decoration: BoxDecoration(color: const Color(0xFF211B19), borderRadius: BorderRadius.circular(20))),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 20, 22, 26),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(25),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 64, height: 64, decoration: BoxDecoration(color: const Color(0xFF9F1838), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.school_rounded, size: 34)),
                  const SizedBox(height: 18),
                  const Text('Welcome back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text('Sign in to CampusFlow', style: TextStyle(color: const Color(0xFF27211F))),
                  const SizedBox(height: 26),
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline))),
                  const SizedBox(height: 14),
                  TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility_off : Icons.visibility)))),
                  const SizedBox(height: 22),
                  SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: login, icon: const Icon(Icons.login), label: const Text('Sign in'))),
                  const SizedBox(height: 16),
                  Text('Demo: admin@campusflow.edu  •  admin123', style: TextStyle(color: const Color(0xFF514640), fontSize: 12), textAlign: TextAlign.center),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void openPage(BuildContext context, Widget page) {
  Navigator.push(context, PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, animation, secondaryAnimation) => page,
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .975, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  ));
}

class _CampusFloatingBackground extends StatefulWidget {
  const _CampusFloatingBackground();
  @override
  State<_CampusFloatingBackground> createState() => _CampusFloatingBackgroundState();
}

class _CampusFloatingBackgroundState extends State<_CampusFloatingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this, duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() { _motion.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, double, double, double)>[
      (Icons.school_rounded, .08, .16, 52),
      (Icons.menu_book_rounded, .82, .13, 43),
      (Icons.auto_stories_rounded, .91, .60, 56),
      (Icons.backpack_rounded, .12, .77, 46),
      (Icons.calculate_rounded, .70, .88, 40),
      (Icons.emoji_events_rounded, .43, .06, 38),
    ];
    return IgnorePointer(child: AnimatedBuilder(
      animation: _motion,
      builder: (context, _) => LayoutBuilder(builder: (context, box) => Stack(children: [
        for (var i = 0; i < items.length; i++)
          Positioned(
            left: box.maxWidth * items[i].$2 + (i.isEven ? 1 : -1) * 18 * _motion.value,
            top: box.maxHeight * items[i].$3 + (i.isOdd ? 1 : -1) * 22 * _motion.value,
            child: Transform.rotate(
              angle: (i.isEven ? 1 : -1) * .10 * _motion.value,
              child: Container(
                width: items[i].$4, height: items[i].$4,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E3CF).withValues(alpha: .58),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFFD7B99A).withValues(alpha: .42)),
                ),
                child: Icon(items[i].$1, size: items[i].$4 * .52,
                  color: const Color(0xFF9F1838).withValues(alpha: .26)),
              ),
            ),
          ),
      ])),
    ));
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.title, required this.child, this.actions = const []});
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFFAF5EC),
        surfaceTintColor: Colors.transparent,
        actions: [
          ...actions,
          IconButton(tooltip: 'Notifications', onPressed: () => openPage(context, const NotificationsScreen()), icon: const Icon(Icons.notifications_none_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(child: _SidebarContent(current: title)),
      body: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1050;
        return Stack(children: [
          const Positioned.fill(child: _CampusFloatingBackground()),
          Row(children: [
            if (desktop) SizedBox(width: 245, child: _SidebarContent(current: title)),
            Expanded(child: child),
          ]),
        ]);
      }),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({required this.current});
  final String current;

  void nav(BuildContext context, Widget page) {
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
    openPage(context, page);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4EBDD),
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(14, 18, 14, 20), children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF9F1838), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.school_rounded)),
            const SizedBox(width: 12),
            const Expanded(child: Text('CampusFlow', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
          ])),
          const SizedBox(height: 22),
          _nav(context, 'Dashboard', Icons.dashboard_rounded, const DashboardScreen()),
          _nav(context, 'Students', Icons.people_alt_rounded, const StudentsScreen()),
          _nav(context, 'Attendance', Icons.fact_check_rounded, const AttendanceScreen()),
          _nav(context, 'Marks', Icons.bar_chart_rounded, const MarksScreen()),
          _nav(context, 'Subjects', Icons.menu_book_rounded, const SubjectsScreen()),
          _nav(context, 'Departments', Icons.account_tree_rounded, const DepartmentsScreen()),
          _nav(context, 'Fees', Icons.payments_rounded, const FeesScreen()),
          _nav(context, 'Notifications', Icons.notifications_rounded, const NotificationsScreen()),
          const Divider(height: 28),
          _nav(context, 'Profile', Icons.person_rounded, const ProfileScreen()),
          _nav(context, 'Settings', Icons.settings_rounded, const SettingsScreen()),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Administrator', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text('admin@campusflow.edu', style: TextStyle(fontSize: 12, color: const Color(0xFF27211F))),
          ]))),
        ]),
      ),
    );
  }

  Widget _nav(BuildContext context, String label, IconData icon, Widget page) {
    final selected = current == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: selected ? const Color(0xFFD7B99A) : Colors.transparent, width: 1.1)),
        selected: selected,
        selectedTileColor: const Color(0xFFF0E3CF),
        leading: Icon(icon, size: 20, color: selected ? const Color(0xFF9F1838) : const Color(0xFF39302C)),
        title: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? const Color(0xFF76142B) : const Color(0xFF39302C))),
        onTap: () => nav(context, page),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final byYear = List<int>.generate(4, (i) => campus.students.where((s) => s.year == i + 1).length);
    return AppShell(title: 'Dashboard', child: ListView(padding: const EdgeInsets.all(22), children: [
      const _PageHeader(title: 'Good morning, Administrator', subtitle: 'Here is your campus overview for today.'),
      Container(
        height: 285,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF76142B),
          boxShadow: [BoxShadow(color: const Color(0xFF76142B).withValues(alpha: .18), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1600&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF651126), Color(0xFFB52A49)]),
                ),
                child: const Center(child: Icon(Icons.account_balance_rounded, size: 100, color: Color(0x55FFFFFF))),
              ),
            ),
            Container(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
                colors: [const Color(0xFF4B0C1D).withValues(alpha: .96), const Color(0xFF6D1228).withValues(alpha: .82), const Color(0xFF6D1228).withValues(alpha: .12)]),
            )),
            Positioned(right: -22, bottom: -42, child: Icon(Icons.account_balance_rounded, size: 230, color: Colors.white.withValues(alpha: .10))),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 470),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .13), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: .28))),
                      child: const Text('WELCOME TO CAMPUSFLOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 14),
                    const Text('Make every campus day count.', style: TextStyle(color: Colors.white, fontSize: 27, height: 1.12, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Text('Your students, academics, attendance and fees — all in one connected place.', style: TextStyle(color: Colors.white.withValues(alpha: .91), height: 1.5, fontSize: 13)),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF8D1732), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13)),
                      onPressed: () => openPage(context, const StudentsScreen()),
                      icon: const Icon(Icons.school_rounded, size: 18),
                      label: const Text('Explore students'),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      Wrap(spacing: 14, runSpacing: 14, children: [
        _StatCard(label: 'Total Students', value: '${campus.totalStudents}', icon: Icons.people_alt_rounded, color: const Color(0xFF9F1838)),
        _StatCard(label: 'Avg Attendance', value: '${campus.averageAttendance.toStringAsFixed(1)}%', icon: Icons.fact_check_rounded, color: const Color(0xFF22C55E)),
        _StatCard(label: 'Avg CGPA', value: campus.averageCgpa.toStringAsFixed(2), icon: Icons.school_rounded, color: const Color(0xFF38BDF8)),
        _StatCard(label: 'Pending Fees', value: '₹${campus.pendingFees.toStringAsFixed(0)}', icon: Icons.payments_rounded, color: const Color(0xFFF59E0B)),
      ]),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Campus at a glance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Your essential academic spaces, ready when you need them.', style: TextStyle(color: Color(0xFF4B403A), fontSize: 12)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 650 ? 4 : 2;
              final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
              final items = [
                (Icons.groups_rounded, 'Student records', 'Profiles & enrolment', const StudentsScreen()),
                (Icons.fact_check_rounded, 'Attendance', 'Daily class tracking', const AttendanceScreen()),
                (Icons.auto_graph_rounded, 'Marks & grades', 'Academic performance', const MarksScreen()),
                (Icons.account_balance_wallet_rounded, 'Fee centre', 'Payments & dues', const FeesScreen()),
              ];
              return Wrap(spacing: 12, runSpacing: 12, children: items.map((item) => SizedBox(
                width: width,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => openPage(context, item.$4),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFF6EDE0), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE0D0BA))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF9F1838).withValues(alpha: .10), borderRadius: BorderRadius.circular(12)), child: Icon(item.$1, color: const Color(0xFF9F1838))),
                      const SizedBox(height: 12),
                      Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(item.$3, style: const TextStyle(color: Color(0xFF4B403A), fontSize: 10)),
                    ]),
                  ),
                ),
              )).toList());
            }),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 850;
        if (wide) {
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _YearChart(counts: byYear)),
            const SizedBox(width: 16),
            const Expanded(child: _QuickActions()),
          ]);
        }
        return Column(children: [
          _YearChart(counts: byYear),
          const SizedBox(height: 16),
          const _QuickActions(),
        ]);
      }),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Recent students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...campus.students.take(5).map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: _Avatar(name: s.name), title: Text(s.name), subtitle: Text('${s.id} • ${s.branch} • ${CampusController.years[s.year - 1]}'), trailing: Text(s.cgpa.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w700)), onTap: () => openPage(context, StudentDetailsScreen(studentId: s.id)))),
      ]))),
    ]));
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(subtitle, style: TextStyle(color: const Color(0xFF27211F)))]);
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 235,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF27211F))),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YearChart extends StatelessWidget {
  const _YearChart({required this.counts});
  final List<int> counts;
  @override
  Widget build(BuildContext context) {
    final max = counts.reduce((a, b) => a > b ? a : b).toDouble();
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Students by year', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 22),
      ...List.generate(4, (i) => Padding(padding: const EdgeInsets.only(bottom: 15), child: Row(children: [SizedBox(width: 72, child: Text('${i + 1}${i == 0 ? 'st' : i == 1 ? 'nd' : i == 2 ? 'rd' : 'th'} Year', style: const TextStyle(fontSize: 12))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: max == 0 ? 0 : counts[i] / max, minHeight: 10, backgroundColor: const Color(0xFFE7D9C5), color: const Color(0xFF9F1838)))), const SizedBox(width: 10), Text('${counts[i]}', style: const TextStyle(fontWeight: FontWeight.w700))]))),
    ])));
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quick actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: MediaQuery.sizeOf(context).width < 560 ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: MediaQuery.sizeOf(context).width < 560 ? 2.05 : 1.42,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _QuickActionTile(label: 'Add student', icon: Icons.person_add_alt_1_rounded, onTap: () => openPage(context, const StudentFormScreen())),
                _QuickActionTile(label: 'Attendance', icon: Icons.fact_check_rounded, onTap: () => openPage(context, const AttendanceScreen())),
                _QuickActionTile(label: 'Marks & grades', icon: Icons.auto_graph_rounded, onTap: () => openPage(context, const MarksScreen())),
                _QuickActionTile(label: 'Fee centre', icon: Icons.account_balance_wallet_rounded, onTap: () => openPage(context, const FeesScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  String get _description => switch (label) {
    'Add student' => 'Register a new student profile',
    'Attendance' => 'Record and review daily presence',
    'Marks & grades' => 'Update scores and academic results',
    'Fee centre' => 'Track payments and pending balances',
    _ => 'Open this campus tool',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFFBF6ED)]),
            border: Border.all(color: const Color(0xFFD7B99A), width: 1.35),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFFF0E3CF), borderRadius: BorderRadius.circular(14)),
                  child: Icon(icon, color: const Color(0xFF8D1732), size: 23)),
                const Spacer(),
                const Icon(Icons.arrow_outward_rounded, size: 18, color: Color(0xFF9F1838)),
              ]),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF211B19))),
              Text(_description, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, height: 1.35, color: Color(0xFF4B403A))),
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF9F1838), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Open tool', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9F1838))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String search = '';
  int? year;
  String branch = 'All';
  String section = 'All';
  String attendance = 'All';
  String fee = 'All';
  String sort = 'Name';

  List<Student> get filtered {
    final list = campus.students.where((s) {
      final q = search.toLowerCase();
      final matchesSearch = q.isEmpty || s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q) || s.roll.toLowerCase().contains(q);
      final matchesYear = year == null || s.year == year;
      final matchesBranch = branch == 'All' || s.branch == branch;
      final matchesSection = section == 'All' || s.section == section;
      final matchesAttendance = attendance == 'All' || (attendance == 'Low' ? s.attendance < 75 : s.attendance >= 75);
      final matchesFee = fee == 'All' || s.feeStatus == fee;
      return matchesSearch && matchesYear && matchesBranch && matchesSection && matchesAttendance && matchesFee;
    }).toList();
    list.sort((a, b) {
      switch (sort) {
        case 'ID': return a.id.compareTo(b.id);
        case 'CGPA': return b.cgpa.compareTo(a.cgpa);
        case 'Attendance': return b.attendance.compareTo(a.attendance);
        case 'Year': return a.year.compareTo(b.year);
        default: return a.name.compareTo(b.name);
      }
    });
    return list;
  }

  void reset() => setState(() { search = ''; year = null; branch = 'All'; section = 'All'; attendance = 'All'; fee = 'All'; sort = 'Name'; });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: campus, builder: (context, _) => AppShell(title: 'Students', actions: [IconButton(tooltip: 'Refresh', onPressed: () => setState(() {}), icon: const Icon(Icons.refresh))], child: ListView(padding: const EdgeInsets.all(22), children: [
      Row(children: [const Expanded(child: _PageHeader(title: 'Student directory', subtitle: 'Search, filter, sort and manage students.')), FilledButton.icon(onPressed: () => openPage(context, const StudentFormScreen()), icon: const Icon(Icons.add), label: const Text('Add student'))]),
      const SizedBox(height: 18),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(width: 280, child: TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search name, ID or roll'))),
        _drop<int?>('Year', year, [null, 1, 2, 3, 4], (v) => setState(() => year = v), (v) => v == null ? 'All' : CampusController.years[v - 1]),
        _drop<String>('Branch', branch, ['All', ...CampusController.branches], (v) => setState(() => branch = v)),
        _drop<String>('Section', section, ['All', ...CampusController.sections], (v) => setState(() => section = v)),
        _drop<String>('Attendance', attendance, ['All', 'Low', '75%+'], (v) => setState(() => attendance = v)),
        _drop<String>('Fee', fee, ['All', 'Paid', 'Partial', 'Pending'], (v) => setState(() => fee = v)),
        _drop<String>('Sort', sort, ['Name', 'ID', 'CGPA', 'Attendance', 'Year'], (v) => setState(() => sort = v)),
        TextButton.icon(onPressed: reset, icon: const Icon(Icons.clear), label: const Text('Reset')),
      ]))),
      const SizedBox(height: 14),
      Text('${filtered.length} students', style: TextStyle(color: const Color(0xFF27211F))),
      const SizedBox(height: 8),
      Card(child: Column(children: [
        if (filtered.isEmpty) const Padding(padding: EdgeInsets.all(50), child: Column(children: [Icon(Icons.search_off, size: 46), SizedBox(height: 10), Text('No students match your filters.')])),
        ...filtered.map((s) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
          leading: _Avatar(name: s.name),
          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${s.id} • ${s.roll} • ${s.branch} • ${CampusController.years[s.year - 1]} • Sec ${s.section}'),
          trailing: Wrap(spacing: 5, children: [
            _Pill(text: '${s.attendance.toStringAsFixed(0)}%', color: s.attendance < 75 ? const Color(0xFFEF4444) : const Color(0xFF22C55E)),
            _Pill(text: s.feeStatus, color: s.feesPending > 0 ? const Color(0xFFF59E0B) : const Color(0xFF22C55E)),
            PopupMenuButton<String>(onSelected: (v) { if (v == 'view') openPage(context, StudentDetailsScreen(studentId: s.id)); if (v == 'edit') openPage(context, StudentFormScreen(studentId: s.id)); if (v == 'delete') _delete(context, s); }, itemBuilder: (_) => const [PopupMenuItem(value: 'view', child: Text('View details')), PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
          ]),
          onTap: () => openPage(context, StudentDetailsScreen(studentId: s.id)),
        )),
      ])),
    ])));
  }

  Widget _drop<T>(String label, T value, List<T> values, ValueChanged<T> onChanged, [String Function(T)? labeler]) {
    return SizedBox(width: 145, child: DropdownButtonFormField<T>(initialValue: value, decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)), items: values.map((v) => DropdownMenuItem<T>(value: v, child: Text(labeler?.call(v) ?? v.toString()))).toList(), onChanged: (v) { if (v != null || value == null) onChanged(v as T); }));
  }

  Future<void> _delete(BuildContext context, Student s) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete student?'), content: Text('Delete ${s.name} (${s.id})? This action cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))]));
    if (yes == true) campus.deleteStudent(s.id);
  }
}

class StudentDetailsScreen extends StatelessWidget {
  const StudentDetailsScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: campus, builder: (context, _) {
      final s = campus.byId(studentId);
      if (s == null) return const AppShell(title: 'Student Details', child: Center(child: Text('Student not found')));
      final subjects = campus.subjectsFor(s.branch, s.semester);
      return AppShell(title: 'Student Details', actions: [IconButton(tooltip: 'Edit', onPressed: () => openPage(context, StudentFormScreen(studentId: s.id)), icon: const Icon(Icons.edit_rounded))], child: ListView(padding: const EdgeInsets.all(22), children: [
        Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), const SizedBox(width: 4), const Text('Student profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 16),
        Card(child: Padding(padding: const EdgeInsets.all(22), child: Row(children: [
          _Avatar(name: s.name, size: 74), const SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('${s.id} • ${s.roll} • ${s.branch} • ${CampusController.years[s.year - 1]}'), const SizedBox(height: 8), Row(children: [_Pill(text: 'CGPA ${s.cgpa.toStringAsFixed(2)}', color: const Color(0xFF9F1838)), const SizedBox(width: 8), _Pill(text: '${s.attendance.toStringAsFixed(1)}% attendance', color: s.attendance < 75 ? const Color(0xFFEF4444) : const Color(0xFF22C55E))])]))
        ]))),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          _InfoCard(label: 'Year', value: CampusController.years[s.year - 1]),
          _InfoCard(label: 'Branch / Section', value: '${s.branch} / ${s.section}'),
          _InfoCard(label: 'Semester', value: '${s.semester}'),
          _InfoCard(label: 'Admission', value: '${s.admissionYear}'),
          _InfoCard(label: 'Gender', value: s.gender),
          _InfoCard(label: 'DOB', value: s.dob),
          _InfoCard(label: 'Email', value: s.email),
          _InfoCard(label: 'Phone', value: s.phone),
          _InfoCard(label: 'Address', value: s.address),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 12, runSpacing: 12, children: [
          FilledButton.icon(onPressed: () => openPage(context, AttendanceDetailsScreen(studentId: s.id)), icon: const Icon(Icons.fact_check), label: const Text('Attendance')),
          FilledButton.icon(onPressed: () => openPage(context, MarksDetailsScreen(studentId: s.id)), icon: const Icon(Icons.bar_chart), label: const Text('Marks')),
          FilledButton.icon(onPressed: () => openPage(context, FeeDetailsScreen(studentId: s.id)), icon: const Icon(Icons.payments), label: const Text('Fees')),
          OutlinedButton.icon(onPressed: () => openPage(context, StudentFormScreen(studentId: s.id)), icon: const Icon(Icons.edit), label: const Text('Edit student')),
        ]),
        const SizedBox(height: 16),
        _SectionCard(title: 'Subject performance', child: Column(children: subjects.map((subject) { final mark = s.marks[subject] ?? 0; return ListTile(contentPadding: EdgeInsets.zero, title: Text(subject), trailing: Text('$mark / 100', style: TextStyle(fontWeight: FontWeight.w800, color: mark < 40 ? const Color(0xFFEF4444) : const Color(0xFF9F1838)))); }).toList())),
        const SizedBox(height: 16),
        _SectionCard(title: 'Fee summary', child: Column(children: [
          _summaryRow('Total', '₹${s.feesTotal.toStringAsFixed(0)}'), _summaryRow('Paid', '₹${s.feesPaid.toStringAsFixed(0)}'), _summaryRow('Pending', '₹${s.feesPending.toStringAsFixed(0)}'), _summaryRow('Status', s.feeStatus),
        ])),
      ]));
    });
  }

  Widget _summaryRow(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Row(children: [Expanded(child: Text(a, style: TextStyle(color: const Color(0xFF27211F))),), Text(b, style: const TextStyle(fontWeight: FontWeight.w700))]));
}

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key, this.studentId});
  final String? studentId;
  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController name, roll, email, phone, dob, address, cgpa;
  String gender = 'Male';
  int year = 1;
  String branch = 'CSE';
  String section = 'A';
  int semester = 1;
  bool get editing => widget.studentId != null;

  @override
  void initState() {
    super.initState();
    final s = editing ? campus.byId(widget.studentId!) : null;
    name = TextEditingController(text: s?.name ?? ''); roll = TextEditingController(text: s?.roll ?? ''); email = TextEditingController(text: s?.email ?? ''); phone = TextEditingController(text: s?.phone ?? ''); dob = TextEditingController(text: s?.dob ?? '2005-01-01'); address = TextEditingController(text: s?.address ?? ''); cgpa = TextEditingController(text: s?.cgpa.toString() ?? '7.50');
    if (s != null) { gender = s.gender; year = s.year; branch = s.branch; section = s.section; semester = s.semester; }
  }

  @override
  void dispose() { name.dispose(); roll.dispose(); email.dispose(); phone.dispose(); dob.dispose(); address.dispose(); cgpa.dispose(); super.dispose(); }

  void save() {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final old = editing ? campus.byId(widget.studentId!) : null;
    final student = Student(id: old?.id ?? 'CF${1000 + campus.students.length + 1}', name: name.text.trim(), roll: roll.text.trim(), gender: gender, dob: dob.text.trim(), email: email.text.trim(), phone: phone.text.trim(), address: address.text.trim(), year: year, branch: branch, section: section, semester: semester, admissionYear: old?.admissionYear ?? 2026, cgpa: double.tryParse(cgpa.text) ?? 7.5, present: old?.present ?? 70, totalClasses: old?.totalClasses ?? 80, feesTotal: old?.feesTotal ?? 70000, feesPaid: old?.feesPaid ?? 0, marks: old?.marks ?? {for (final x in campus.subjectsFor(branch, semester)) x: 75}, feeHistory: old?.feeHistory ?? []);
    if (editing) campus.updateStudent(student); else campus.addStudent(student);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(editing ? 'Student updated successfully.' : 'Student added successfully.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: editing ? 'Edit Student' : 'Add Student',
      child: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 4),
                Expanded(child: _PageHeader(title: editing ? 'Edit student' : 'Add a new student', subtitle: editing ? 'Update profile and academic information.' : 'Create a complete student record.')),
              ],
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _fieldsRow([_field('Full name', name), _field('Roll number', roll)]),
                    _fieldsRow([_field('Email', email, type: TextInputType.emailAddress), _field('Phone', phone, type: TextInputType.phone)]),
                    _fieldsRow([
                      _field('Date of birth', dob),
                      DropdownButtonFormField<String>(initialValue: gender, decoration: const InputDecoration(labelText: 'Gender'), items: ['Male', 'Female', 'Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => gender = v ?? gender)),
                    ]),
                    _fieldsRow([
                      DropdownButtonFormField<int>(initialValue: year, decoration: const InputDecoration(labelText: 'Year'), items: List.generate(4, (i) => DropdownMenuItem(value: i + 1, child: Text(CampusController.years[i]))), onChanged: (v) => setState(() { year = v ?? year; semester = (year - 1) * 2 + 1; })),
                      DropdownButtonFormField<String>(initialValue: branch, decoration: const InputDecoration(labelText: 'Branch'), items: CampusController.branches.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => branch = v ?? branch)),
                    ]),
                    _fieldsRow([
                      DropdownButtonFormField<String>(initialValue: section, decoration: const InputDecoration(labelText: 'Section'), items: CampusController.sections.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => section = v ?? section)),
                      DropdownButtonFormField<int>(initialValue: semester, decoration: const InputDecoration(labelText: 'Semester'), items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))), onChanged: (v) => setState(() => semester = v ?? semester)),
                    ]),
                    _fieldsRow([_field('CGPA', cgpa, type: const TextInputType.numberWithOptions(decimal: true)), _field('Address', address)]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 10),
                        FilledButton.icon(onPressed: save, icon: const Icon(Icons.save), label: Text(editing ? 'Save changes' : 'Create student')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {TextInputType? type}) => TextFormField(controller: c, keyboardType: type, validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null, decoration: InputDecoration(labelText: label));
  Widget _fieldsRow(List<Widget> widgets) => Padding(padding: const EdgeInsets.only(bottom: 14), child: LayoutBuilder(builder: (context, c) => c.maxWidth > 650 ? Row(children: [Expanded(child: widgets[0]), const SizedBox(width: 14), Expanded(child: widgets[1])]) : Column(children: [widgets[0], const SizedBox(height: 14), widgets[1]])));
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) => AppShell(title: 'Attendance', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Attendance management', subtitle: 'Review attendance and open individual attendance records.'), const SizedBox(height: 18),
    Card(child: Column(children: campus.students.take(30).map((s) => ListTile(leading: _Avatar(name: s.name), title: Text(s.name), subtitle: Text('${s.id} • ${s.branch} • ${CampusController.years[s.year - 1]}'), trailing: Wrap(spacing: 8, children: [_Pill(text: '${s.attendance.toStringAsFixed(1)}%', color: s.attendance < 75 ? const Color(0xFFEF4444) : const Color(0xFF22C55E)), TextButton(onPressed: () => openPage(context, AttendanceDetailsScreen(studentId: s.id)), child: const Text('Open'))]), onTap: () => openPage(context, AttendanceDetailsScreen(studentId: s.id)))).toList())),
  ])));
}

class AttendanceDetailsScreen extends StatelessWidget {
  const AttendanceDetailsScreen({super.key, required this.studentId});
  final String studentId;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) {
    final s = campus.byId(studentId);
    if (s == null) return const AppShell(title: 'Attendance Details', child: Center(child: Text('Student not found')));
    return AppShell(title: 'Attendance Details', child: ListView(padding: const EdgeInsets.all(22), children: [
      _DetailHeader(student: s, title: 'Attendance record'), const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Text('${s.attendance.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF9F1838))),
        Text('${s.present} present out of ${s.totalClasses} classes', style: TextStyle(color: const Color(0xFF27211F))), const SizedBox(height: 20),
        LinearProgressIndicator(value: s.attendance / 100, minHeight: 12, borderRadius: BorderRadius.circular(10)), const SizedBox(height: 22),
        Wrap(spacing: 10, children: [FilledButton.icon(onPressed: () => campus.markAttendance(s.id, true), icon: const Icon(Icons.check), label: const Text('Mark Present')), OutlinedButton.icon(onPressed: () => campus.markAttendance(s.id, false), icon: const Icon(Icons.close), label: const Text('Mark Absent'))]),
      ]))), const SizedBox(height: 16),
      _SectionCard(title: 'Attendance policy', child: Text(s.attendance < 75 ? 'This student is below the 75% attendance alert threshold.' : 'Attendance is currently above the 75% alert threshold.')),
    ]));
  });
}

class MarksScreen extends StatelessWidget {
  const MarksScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) => AppShell(title: 'Marks', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Marks & performance', subtitle: 'Open a student record to view or edit subject marks.'), const SizedBox(height: 18),
    Card(child: Column(children: campus.students.take(30).map((s) => ListTile(leading: _Avatar(name: s.name), title: Text(s.name), subtitle: Text('${s.id} • ${s.branch} • Semester ${s.semester}'), trailing: TextButton(onPressed: () => openPage(context, MarksDetailsScreen(studentId: s.id)), child: const Text('Open')), onTap: () => openPage(context, MarksDetailsScreen(studentId: s.id)))).toList())),
  ])));
}

class MarksDetailsScreen extends StatefulWidget {
  const MarksDetailsScreen({super.key, required this.studentId});
  final String studentId;
  @override
  State<MarksDetailsScreen> createState() => _MarksDetailsScreenState();
}

class _MarksDetailsScreenState extends State<MarksDetailsScreen> {
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) {
    final s = campus.byId(widget.studentId);
    if (s == null) return const AppShell(title: 'Marks Details', child: Center(child: Text('Student not found')));
    final subjects = campus.subjectsFor(s.branch, s.semester);
    return AppShell(title: 'Marks Details', child: ListView(padding: const EdgeInsets.all(22), children: [
      _DetailHeader(student: s, title: 'Marks record'), const SizedBox(height: 16),
      Card(child: Column(children: subjects.map((subject) => ListTile(title: Text(subject), subtitle: Text('Subject mark'), trailing: SizedBox(width: 100, child: TextFormField(initialValue: '${s.marks[subject] ?? 0}', keyboardType: TextInputType.number, textAlign: TextAlign.center, onFieldSubmitted: (v) => campus.updateMark(s.id, subject, int.tryParse(v) ?? 0), decoration: const InputDecoration(isDense: true)) ))).toList())),
      const SizedBox(height: 14),
      _SectionCard(title: 'Performance summary', child: Text('Average mark: ${s.marks.values.isEmpty ? '0' : (s.marks.values.reduce((a, b) => a + b) / s.marks.length).toStringAsFixed(1)} / 100')),
    ]));
  });
}

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});
  @override
  Widget build(BuildContext context) => AppShell(title: 'Subjects', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Subjects', subtitle: 'Branch-specific subjects across all semesters.'), const SizedBox(height: 18),
    ...CampusController.branches.map((branch) => Card(child: ExpansionTile(leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF9F1838)), title: Text(branch, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Semester curriculum'), children: List.generate(8, (i) => ListTile(title: Text('Semester ${i + 1}'), subtitle: Text(campus.subjectsFor(branch, i + 1).join(' • ')), trailing: const Icon(Icons.chevron_right), onTap: () => openPage(context, SubjectDetailsScreen(branch: branch, semester: i + 1))))))),
  ]));
}

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key, required this.branch, required this.semester});
  final String branch; final int semester;
  @override
  Widget build(BuildContext context) { final subjects = campus.subjectsFor(branch, semester); return AppShell(title: 'Subject Details', child: ListView(padding: const EdgeInsets.all(22), children: [
    _PageHeader(title: '$branch • Semester $semester', subtitle: 'Subject details and enrolled student count.'), const SizedBox(height: 18),
    ...subjects.asMap().entries.map((e) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFF0E3CF), child: Text('${e.key + 1}')), title: Text(e.value), subtitle: Text('${campus.students.where((s) => s.branch == branch && s.semester == semester).length} enrolled students'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)))),
  ])); }
}

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => AppShell(title: 'Departments', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Departments', subtitle: 'Academic branches and their student distribution.'), const SizedBox(height: 18),
    ...CampusController.branches.map((branch) { final count = campus.students.where((s) => s.branch == branch).length; return Card(child: ListTile(leading: const Icon(Icons.account_tree_rounded, color: Color(0xFF9F1838)), title: Text('$branch Department'), subtitle: Text('$count students • 4 academic years'), trailing: const Icon(Icons.chevron_right), onTap: () => openPage(context, DepartmentDetailsScreen(branch: branch)))); }),
  ]));
}

class DepartmentDetailsScreen extends StatelessWidget {
  const DepartmentDetailsScreen({super.key, required this.branch});
  final String branch;
  @override
  Widget build(BuildContext context) { final students = campus.students.where((s) => s.branch == branch).toList(); return AppShell(title: 'Department Details', child: ListView(padding: const EdgeInsets.all(22), children: [
    _PageHeader(title: '$branch Department', subtitle: 'Department overview and student distribution.'), const SizedBox(height: 18),
    Wrap(spacing: 12, runSpacing: 12, children: [for (var y = 1; y <= 4; y++) _InfoCard(label: CampusController.years[y - 1], value: '${students.where((s) => s.year == y).length} students')]), const SizedBox(height: 18),
    _SectionCard(title: 'Students', child: Column(children: students.map((s) => ListTile(contentPadding: EdgeInsets.zero, leading: _Avatar(name: s.name), title: Text(s.name), subtitle: Text('${s.id} • ${s.section} • Semester ${s.semester}'), onTap: () => openPage(context, StudentDetailsScreen(studentId: s.id)))).toList())),
  ])); }
}

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) => AppShell(title: 'Fees', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Fee management', subtitle: 'Track paid, partial and pending student fees.'), const SizedBox(height: 18),
    Wrap(spacing: 12, runSpacing: 12, children: [_InfoCard(label: 'Total billed', value: '₹${campus.students.fold<double>(0, (a, s) => a + s.feesTotal).toStringAsFixed(0)}'), _InfoCard(label: 'Collected', value: '₹${campus.students.fold<double>(0, (a, s) => a + s.feesPaid).toStringAsFixed(0)}'), _InfoCard(label: 'Pending', value: '₹${campus.pendingFees.toStringAsFixed(0)}')]), const SizedBox(height: 18),
    Card(child: Column(children: campus.students.take(30).map((s) => ListTile(leading: _Avatar(name: s.name), title: Text(s.name), subtitle: Text('${s.id} • ${s.branch} • ${s.feeStatus}'), trailing: Wrap(spacing: 10, children: [Text('₹${s.feesPending.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)), TextButton(onPressed: () => openPage(context, FeeDetailsScreen(studentId: s.id)), child: const Text('Open'))]), onTap: () => openPage(context, FeeDetailsScreen(studentId: s.id)))).toList())),
  ])));
}

class FeeDetailsScreen extends StatefulWidget {
  const FeeDetailsScreen({super.key, required this.studentId});
  final String studentId;

  @override
  State<FeeDetailsScreen> createState() => _FeeDetailsScreenState();
}

class _FeeDetailsScreenState extends State<FeeDetailsScreen> {
  final amount = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: campus,
      builder: (context, _) {
        final s = campus.byId(widget.studentId);
        if (s == null) {
          return const AppShell(title: 'Fee Details', child: Center(child: Text('Student not found')));
        }
        return AppShell(
          title: 'Fee Details',
          child: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              _DetailHeader(student: s, title: 'Fee account'),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Payment summary',
                child: Column(
                  children: [
                    _summary('Total fee', '₹${s.feesTotal.toStringAsFixed(0)}'),
                    _summary('Paid', '₹${s.feesPaid.toStringAsFixed(0)}'),
                    _summary('Pending', '₹${s.feesPending.toStringAsFixed(0)}'),
                    _summary('Status', s.feeStatus),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Record payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount'))),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () {
                              final value = double.tryParse(amount.text) ?? 0;
                              if (value <= 0) return;
                              campus.addFeePayment(s.id, value);
                              amount.clear();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded.')));
                            },
                            child: const Text('Record'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Payment history',
                child: Column(children: s.feeHistory.map((h) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.receipt_long), title: Text(h))).toList()),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summary(String a, String b) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [Expanded(child: Text(a, style: TextStyle(color: const Color(0xFF27211F)))), Text(b, style: const TextStyle(fontWeight: FontWeight.w700))]),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => AppShell(title: 'Notifications', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Notifications', subtitle: 'Campus updates, alerts and administrative messages.'), const SizedBox(height: 18),
    ...[
      ['Attendance alert', '12 students are below 75% attendance.', Icons.warning_amber_rounded],
      ['Fee reminder', 'Pending fee accounts need review.', Icons.payments_outlined],
      ['Semester update', 'Marks review window is open.', Icons.assignment_outlined],
      ['System', 'CampusFlow data is synchronized locally.', Icons.sync_rounded],
    ].asMap().entries.map((e) => Card(child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFF0E3CF), child: Icon(e.value[2] as IconData, color: const Color(0xFF9F1838))), title: Text(e.value[0] as String, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(e.value[1] as String), trailing: const Icon(Icons.chevron_right), onTap: () => openPage(context, NotificationDetailsScreen(title: e.value[0] as String, message: e.value[1] as String))))),
  ]));
}

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({super.key, required this.title, required this.message});
  final String title, message;
  @override Widget build(BuildContext context) => AppShell(title: 'Notification Details', child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 700), child: Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.notifications_active, size: 50, color: Color(0xFF9F1838)), const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: TextStyle(color: const Color(0xFF27211F), fontSize: 16)), const SizedBox(height: 22), FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))]))))));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) => AppShell(title: 'Profile', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Administrator profile', subtitle: 'Manage your CampusFlow account details.'), const SizedBox(height: 18),
    Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [Container(width: 96, height: 108, decoration: BoxDecoration(color: const Color(0xFFF0E3CF), borderRadius: BorderRadius.circular(26), border: Border.all(color: const Color(0xFFD7B99A), width: 1.5)), child: const Icon(Icons.person_rounded, size: 72, color: Color(0xFF8D1732))), const SizedBox(height: 15), const Text('CampusFlow Administrator', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('admin@campusflow.edu', style: TextStyle(color: const Color(0xFF27211F))), const SizedBox(height: 22), const Divider(), const SizedBox(height: 10), const ListTile(leading: Icon(Icons.badge_outlined), title: Text('Role'), subtitle: Text('Administrator')), const ListTile(leading: Icon(Icons.security_outlined), title: Text('Access'), subtitle: Text('Students • Academics • Fees • Reports'))]))),
  ]));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context) => AnimatedBuilder(animation: campus, builder: (context, _) => AppShell(title: 'Settings', child: ListView(padding: const EdgeInsets.all(22), children: [
    const _PageHeader(title: 'Settings', subtitle: 'Preferences apply immediately across the application.'), const SizedBox(height: 18),
    Card(child: Column(children: [
      SwitchListTile(value: campus.notificationsEnabled, onChanged: campus.toggleNotifications, title: const Text('Notifications'), subtitle: const Text('Show campus alerts in the application')), const Divider(height: 1),
      SwitchListTile(value: campus.showLowAttendanceAlerts, onChanged: campus.toggleLowAttendance, title: const Text('Low attendance alerts'), subtitle: const Text('Flag students below 75% attendance')), const Divider(height: 1),
      SwitchListTile(value: campus.compactMode, onChanged: campus.toggleCompact, title: const Text('Compact lists'), subtitle: const Text('Use a denser list presentation where supported')),
    ])), const SizedBox(height: 18),
    Card(child: ListTile(leading: const Icon(Icons.palette_outlined), title: const Text('Theme'), subtitle: const Text('CampusFlow uses the premium light lavender theme for this build.'), trailing: const Chip(label: Text('Light Lavender')))),
  ])));
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.size = 46});
  final String name; final double size;
  @override Widget build(BuildContext context) { final initials = name.trim().split(' ').where((x) => x.isNotEmpty).take(2).map((x) => x[0]).join().toUpperCase(); return Container(width: size, height: size, decoration: BoxDecoration(color: const Color(0xFFF0E3CF), borderRadius: BorderRadius.circular(size * .28), border: Border.all(color: const Color(0xFFDCC8A9))), alignment: Alignment.center, child: Text(initials, style: TextStyle(color: const Color(0xFF8D1732), fontWeight: FontWeight.w800, fontSize: size * .28))); }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text; final Color color;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)));
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});
  final String label, value;
  @override Widget build(BuildContext context) => SizedBox(width: 210, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: const Color(0xFF27211F), fontSize: 12)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]))));
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title; final Widget child;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 12), child])));
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.student, required this.title});
  final Student student; final String title;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [_Avatar(name: student.name), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text('${student.name} • ${student.id} • ${student.branch}')]))])));
}
