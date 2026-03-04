# School Management System (SMS) - App Flow Documentation

A complete, step-by-step flow document for the Flutter School Management System app. This guide is beginner-friendly and presentation-ready.

---

## Table of Contents

1. [App Launch / Entry Point](#1-app-launch--entry-point)
2. [Authentication Flow](#2-authentication-flow)
3. [Dashboard Flow](#3-dashboard-flow)
4. [Fee Data Flow](#4-fee-data-flow)
5. [Attendance Data Flow](#5-attendance-data-flow)
6. [Academic Progress Flow](#6-academic-progress-flow)
7. [Models Overview](#7-models-overview)
8. [Services Overview](#8-services-overview)
9. [ASCII Flow Diagrams](#9-ascii-flow-diagrams)
10. [Notes & Best Practices](#10-notes--best-practices)

---

## 1. App Launch / Entry Point

### Overview

The app starts from `main.dart` which sets up the GetX dependency injection system, theme configuration, and initializes controllers.

### Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        main.dart                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 1. WidgetsFlutterBinding.ensureInitialized()         │  │
│  │ 2. Get.put(ThemeController()) ← Eagerly loaded       │  │
│  │ 3. Get.lazyPut() for all data controllers            │  │
│  │ 4. runApp(const MyApp())                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                     MyApp Widget                       │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │ Obx(() => GetMaterialApp(                      │  │  │
│  │  │   home: SplashScreen()  ← Entry Point          │  │  │
│  │  │ ))                                              │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Controllers Registered in main.dart

| Controller | Registration Type | Purpose |
|------------|-------------------|---------|
| `ThemeController` | `Get.put()` | Theme management (light/dark) |
| `AdmitCardController` | `Get.lazyPut()` | Admit card data |
| `AttendanceController` | `Get.lazyPut()` | Attendance records |
| `CompositeMarksheetController` | `Get.lazyPut()` | Combined marksheets |
| `MarksheetController` | `Get.lazyPut()` | Single marksheet |
| `NoticesController` | `Get.lazyPut()` | Notices/announcements |
| `StudentFeeController` | `Get.lazyPut()` | Fee records |

### SplashScreen Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    SplashScreen                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ FutureBuilder<bool> _checkAuth()                     │  │
│  │   │                                                   │  │
│  │   ├── 2-second delay (simulated loading)             │  │
│  │   │                                                   │  │
│  │   ▼                                                   │  │
│  │ AuthService().isLoggedIn() ──────────────────────►   │  │
│  │   │                                                   │  │
│  │   ├── true  ──►  StudentDashboard()                  │  │
│  │   │                                                   │  │
│  │   └── false ──►  SigninScreen()                       │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Theme Setup

- **Theme Files**: `lib/theme/app_theme.dart`, `lib/theme/app_colors.dart`
- **Light Theme**: Uses `AppColors.lightBackground`, `AppColors.lightSurface`
- **Dark Theme**: Uses `AppColors.darkBackground`, `AppColors.darkSurface`
- **Font**: Google Fonts Inter via `GoogleFonts.interTextTheme()`

---

## 2. Authentication Flow

### Overview

The authentication system uses JWT tokens stored securely and student information stored in SharedPreferences.

### Flow Diagram

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────┐
│ SigninScreen │────►│  AuthService  │────►│   ApiService     │
│              │     │              │     │                  │
│ - userID     │     │ - login()    │     │ - POST /Auth/    │
│ - password   │     │ - logout()   │     │   Login          │
│ - rememberMe │     │ - getToken() │     │                  │
└──────────────┘     └──────────────┘     └──────────────────┘
                            │
                            ▼
              ┌────────────────────────────┐
              │    Storage Layers          │
              │  ┌──────────────────────┐  │
              │  │ FlutterSecureStorage │  │
              │  │ (JWT Token - Encrypted)│ │
              │  └──────────────────────┘  │
              │  ┌──────────────────────┐  │
              │  │   SharedPreferences  │  │
              │  │ - studentId          │  │
              │  │ - studentName        │  │
              │  │ - isLoggedIn         │  │
              │  └──────────────────────┘  │
              └────────────────────────────┘
```

### SignInScreen

| Field | Controller | Purpose |
|-------|------------|---------|
| `userID` | `TextEditingController` | Student username |
| `password` | `TextEditingController` | Student password |

**Login Process:**

```
1. User enters username & password
2. Tap "Login" button
3. _handleLogin() called
4. AuthService.login(username, password)
5. API POST /Auth/Login
6. On Success:
   - Store JWT in FlutterSecureStorage
   - Store student data in SharedPreferences
   - Navigate to StudentDashboard()
7. On Error:
   - Show SnackBar with error message
```

### Token & Storage

| Data | Storage | Key |
|------|---------|-----|
| JWT Token | FlutterSecureStorage | `jwt_token` |
| Student ID | SharedPreferences | `student_id` |
| Student Name | SharedPreferences | `student_name` |
| User Data | SharedPreferences | `user_data` |
| Login Status | SharedPreferences | `isLoggedIn` |

### Sign Out Flow

```
User taps "Sign out" → AuthService.logout()
  ├── Delete JWT from FlutterSecureStorage
  ├── Clear SharedPreferences
  └── Navigate to SigninScreen()
```

---

## 3. Dashboard Flow

### Overview

The main dashboard displays user information, notices, and three key cards showing academic progress, attendance, and fee status.

### Dashboard Structure

```
┌─────────────────────────────────────────────────────────────┐
│  StudentDashboard (Scaffold)                                │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ AppBar                                                │  │
│  │  ├── Menu Button (opens Drawer)                     │  │
│  │  ├── Title: "Student Dashboard"                     │  │
│  │  ├── Theme Toggle (light/dark)                      │  │
│  │  └── Sign Out Button                                │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  Drawer (Navigation Menu)                                   │
│  ├── Profile                                               │
│  ├── Attendance                                            │
│  ├── Marksheet                                             │
│  ├── Composite Marksheet                                    │
│  ├── Fee Details                                           │
│  ├── Notices                                               │
│  └── Admit Card                                            │
│                                                             │
│  Body (SingleChildScrollView)                               │
│  ├── UserIDSection()                                        │
│  │   └── Shows student name & ID                          │
│  │                                                         │
│  ├── NoticesSection()                                       │
│  │   └── Horizontal scrollable notice cards              │
│  │                                                         │
│  └── DashboardCardsRow()                                    │
│       ├── AcademicProgressCard                              │
│       ├── AttendancePieChartCard                            │
│       └── NextFeeDueCard                                    │
└─────────────────────────────────────────────────────────────┘
```

### Dashboard Cards

#### 1. AcademicProgressCard

| Property | Source |
|----------|--------|
| `percentage` | `AcademicProgressController.overallPercentage` |
| `completedExams` | `AcademicProgressController.completedExams` |
| `totalExpectedExams` | `AcademicProgressController.totalExpectedExams` |
| `isFinalResult` | `AcademicProgressController.isFinalResult` |
| `grade` | Calculated from percentage |

**Visual:**
- Circular progress indicator
- Grade display (A, B, C, Needs Improvement)
- Color-coded (Green ≥85%, LightGreen ≥70%, Orange ≥60%, Red <60%)

#### 2. AttendancePieChartCard

| Property | Source |
|----------|--------|
| `present` | `AttendanceController.dashboardSummary.present` |
| `absent` | `AttendanceController.dashboardSummary.absent` |
| `leave` | `AttendanceController.dashboardSummary.late` |
| `total` | `AttendanceController.dashboardSummary.total` |

**Visual:**
- Pie chart showing attendance breakdown
- Color-coded (Green=Present, Red=Absent, Orange=Late)

#### 3. NextFeeDueCard

| Property | Source |
|----------|--------|
| `dueDate` | `StudentFeeController.getCurrentMonthFee().feeDate` |
| `feeAmount` | `StudentFeeController.getCurrentMonthFee().fee` |

**Visual:**
- Calendar icon
- Current month fee amount in Rs.
- Due date display

### Card Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    DashboardCardsRow                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Get.put(AttendanceController())                       │  │
│  │ Get.put(StudentFeeController())                       │  │
│  │ Get.put(AcademicProgressController(studentId, classId))│  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│         ┌──────────────────┼──────────────────┐             │
│         ▼                  ▼                  ▼             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐       │
│  │ Academic    │   │ Attendance  │   │ Next Fee    │       │
│  │ Progress    │   │ Pie Chart   │   │ Due Card    │       │
│  │ Card        │   │ Card        │   │             │       │
│  └─────────────┘   └─────────────┘   └─────────────┘       │
│         │                  │                  │             │
│         ▼                  ▼                  ▼             │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐       │
│  │ Obx(()=>   │   │ Obx(()=>   │   │ Obx(()=>   │       │
│  │ controller │   │ controller  │   │ controller  │       │
│  │ .overall%  │   │ .dashboard  │   │ .getCurrent │       │
│  │ )          │   │ .Summary    │   │ MonthFee()  │       │
│  └─────────────┘   └─────────────┘   └─────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Drawer Navigation

| Menu Item | Screen | Controller |
|-----------|--------|------------|
| Profile | `ProfileScreen` | - |
| Attendance | `AttendanceScreen` | `AttendanceController` |
| Marksheet | `MarksheetScreen` | `MarksheetController` |
| Composite Marksheet | `CompositeMarksheetScreen` | `CompositeMarksheetController` |
| Fee Details | `StudentFeeScreen` | `StudentFeeController` |
| Notices | `NoticesScreen` | `NoticesController` |
| Admit Card | `AdmitCardScreen` | `AdmitCardController` |

---

## 4. Fee Data Flow

### Overview

The fee module fetches data from three APIs, calculates totals, and generates PDF reports.

### APIs Used

| Endpoint | Purpose |
|----------|---------|
| `GET /StudentFee/Get-StudentFees?Year=...` | Regular monthly fees |
| `GET /StudentFee/Get-StudentFeeAdditionals?Year=...` | Additional fees |
| `GET /PendingFee/Get-PendingFee-Tasks?StudentId=...&Year=...` | Pending fees |

### Controller: StudentFeeController

**State Variables:**

| Variable | Type | Purpose |
|----------|------|---------|
| `isLoading` | `RxBool` | Loading state |
| `regularFees` | `RxList<FeeRecord>` | Monthly fee records |
| `additionalFees` | `RxList<FeeRecord>` | Additional fee records |
| `pendingFeeMessage` | `RxString` | Pending fee status |
| `selectedYear` | `RxString` | Year filter |

**Computed Properties:**

```
dart
double get totalRegularFees   // Sum of all regular fees
double get totalAdditionalFees // Sum of all additional fees
double get grandTotal          // totalRegularFees + totalAdditionalFees
```

### Fee Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                StudentFeeController                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ onInit()                                              │  │
│  │   ├── _loadStudentInfo()                              │  │
│  │   └── fetchAllFeeData()                               │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ fetchAllFeeData()                                     │  │
│  │   ├── _fetchRegularFees()     ──► API: Get-StudentFees│  │
│  │   ├── _fetchAdditionalFees() ──► API: Get-StudentFee │  │
│  │   │                              Additionals          │  │
│  │   └── _fetchPendingFees()     ──► API: Get-PendingFee│  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ UI Updates (Reactive - Obx)                          │  │
│  │   ├── regularFees.value                              │  │
│  │   ├── additionalFees.value                           │  │
│  │   └── pendingFeeMessage.value                        │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Current Month Fee (Dashboard Card)

```
dart
FeeRecord? getCurrentMonthFee() {
  // Returns the fee record for current month (hardcoded for testing)
  // In production: uses DateFormat('MMMM').format(now).toLowerCase()
  final currentMonth = 'august';  // or DateTime.now().month
  final currentYear = '2026';     // or DateTime.now().year.toString()
  
  return regularFees.firstWhere(
    (fee) => fee.month.toLowerCase() == currentMonth && 
             fee.year == currentYear,
  );
}
```

### PDF Generation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   generatePdf()                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ 1. Check if fee records exist                         │  │
│  │ 2. Create pw.Document()                               │  │
│  │ 3. Add MultiPage with:                                │  │
│  │    ├── _pdfHeader() - School branding                 │  │
│  │    ├── _pdfStudentInfo() - Name, ID                  │  │
│  │    ├── _pdfFeeTable(regularFees)                      │  │
│  │    ├── _pdfFeeTable(additionalFees)                   │  │
│  │    ├── _pdfTotalRow() - Grand total                   │  │
│  │    └── _pdfFooter() - Powered by KI Software          │  │
│  │ 4. Return PDF bytes                                   │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Attendance Data Flow

### Overview

The attendance module fetches monthly attendance records, displays statistics, and generates PDF reports.

### API Used

```
POST /Attendance/GetAttendance
Body: {
  "studentId": "792",
  "month": "Jan",      // Short month name
  "year": "2026"
}
```

### Controller: AttendanceController

**State Variables:**

| Variable | Type | Purpose |
|----------|------|---------|
| `isLoading` | `RxBool` | Loading state |
| `selectedMonth` | `RxString` | Selected month |
| `selectedYear` | `RxString` | Selected year |
| `availableYears` | `RxList<String>` | Year dropdown options |
| `attendanceData` | `Rxn<AttendanceResponse>` | Full API response |
| `filteredRecords` | `RxList<AttendanceRecord>` | Daily records |
| `dashboardSummary` | `Rxn<AttendanceResponse>` | For dashboard card |
| `isDashboardLoading` | `RxBool` | Dashboard loading state |

**Computed Properties:**

```
dart
int get presentCount  // attendanceData.present
int get absentCount   // attendanceData.absent  
int get leaveCount    // attendanceData.late
```

### Attendance Flow

```
┌─────────────────────────────────────────────────────────────┐
│               AttendanceController                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ onInit()                                              │  │
│  │   ├── _initializeFilters()                            │  │
│  │   ├── _loadStudentInfo()                              │  │
│  │   ├── fetchAttendance()                               │  │
│  │   └── fetchDashboardSummary()  ← For Dashboard Card  │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ fetchAttendance() - Full Details Screen              │  │
│  │   API: POST /Attendance/GetAttendance                 │  │
│  │   └── Updates:                                        │  │
│  │       ├── attendanceData.value                        │  │
│  │       └── filteredRecords.value                       │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ fetchDashboardSummary() - Quick view for Dashboard   │  │
│  │   API: POST /Attendance/GetAttendance                │  │
│  │   (Uses current month/year automatically)            │  │
│  │   └── Updates: dashboardSummary.value                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Attendance Screen UI

```
┌─────────────────────────────────────────────────────────────┐
│                    AttendanceScreen                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ ActionButtons                                         │  │
│  │  ├── Filter Button → Expands month/year dropdown      │  │
│  │  └── Generate PDF → Creates attendance PDF           │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Statistics Cards (Row)                                │  │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐         │  │
│  │  │ Present   │ │ Absent    │ │ Late      │         │  │
│  │  │    20     │ │    2      │ │    1      │         │  │
│  │  │   (Green) │ │  (Red)    │ │ (Orange)  │         │  │
│  │  └───────────┘ └───────────┘ └───────────┘         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Daily Records List                                    │  │
│  │  ├── Date: 2026-01-01  ──► Status: Present ✓        │  │
│  │  ├── Date: 2026-01-02  ──► Status: Absent ✗         │  │
│  │  ├── Date: 2026-01-03  ──► Status: Late ⏰          │  │
│  │  └── ...                                              │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Obx Reactive Updates

```
dart
Obx(() {
  final summary = controller.dashboardSummary.value;
  return AttendancePieChartCard(
    present: summary?.present ?? 0,
    absent: summary?.absent ?? 0,
    leave: summary?.late ?? 0,
    total: summary?.total ?? 0,
  );
})
```

---

## 6. Academic Progress Flow

### Overview

The academic progress module fetches exam tasks and marksheets to calculate overall performance percentage.

### APIs Used

| Endpoint | Purpose |
|----------|---------|
| `GET /Marksheet/tasks` | Get list of exam tasks |
| `GET /Marksheet/Get-Marksheet-Single?studentId=...&taskId=...` | Get marks for specific exam |

### Controller: AcademicProgressController

**State Variables:**

| Variable | Type | Purpose |
|----------|------|---------|
| `isLoading` | `RxBool` | Loading state |
| `overallPercentage` | `RxDouble` | Weighted average of all exams |
| `completedExams` | `RxInt` | Number of exams with results |
| `totalExpectedExams` | `RxInt` | Total number of exams |
| `isFinalResult` | `RxBool` | True if all exams completed |

**Constructor Parameters:**
- `studentId` - Student ID (e.g., 792)
- `classId` - Class ID (e.g., 1)

### Academic Progress Flow

```
┌─────────────────────────────────────────────────────────────┐
│          AcademicProgressController                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ fetchAcademicProgress()                               │  │
│  │   │                                                    │  │
│  │   ├── 1. GET /Marksheet/tasks                         │  │
│  │   │     └─► Returns: [{taskId, taskName}, ...]       │  │
│  │   │                                                    │  │
│  │   ├── 2. For each task:                              │  │
│  │   │     GET /Marksheet/Get-Marksheet-Single          │  │
│  │   │       ?studentId=...&taskId=...                  │  │
│  │   │                                                    │  │
│  │   └── 3. Calculate overall percentage:               │  │
│  │         overallPercentage =                           │  │
│  │           sum(examPercentages) / completedExams       │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ UI: AcademicProgressCard                              │  │
│  │   ├── Circular Progress (percentage)                 │  │
│  │   ├── Grade (A, B, C, Needs Improvement)             │  │
│  │   ├── Subtitle: "Based on X of Y exams"               │  │
│  │   └── Color: Green ≥85%, LightGreen ≥70%,           │  │
│  │            Orange ≥60%, Red <60%                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Grade Calculation

```
dart
String _getGrade(int percentage) {
  if (percentage >= 85) return 'A';      // Green
  if (percentage >= 70) return 'B';      // LightGreen  
  if (percentage >= 60) return 'C';       // Orange
  return 'Needs Improvement';            // Red
}
```

### Marksheet Details Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   MarksheetController                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ loadMarksheet()                                       │  │
│  │   API: GET /Marksheet/Get-Marksheet-Single           │  │
│  │   ?studentId=...&taskId=...                           │  │
│  │   Returns: List of subject marks                      │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ _parseMarksheetResponse()                            │  │
│  │   ├── Calculate totalMarks (sum of all maxMarks)     │  │
│  │   ├── Calculate obtainedMarks (sum of all obtMarks) │  │
│  │   ├── Calculate percentage = (obtained/total)*100  │  │
│  │   └── Determine grade & result status               │  │
│  └───────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ PDF Generation                                        │  │
│  │   ├── School header & branding                       │  │
│  │   ├── Student info table                             │  │
│  │   ├── Subject marks table                            │  │
│  │   └── Signature lines                                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Models Overview

### FeeRecord (`lib/models/student_fee_models.dart`)

```
dart
class FeeRecord {
  final int studentId;
  final String year;
  final String month;
  final double fee;
  final String feeDate;
  final int slipNo;
  final String details;
}
```

**API Fields Mapping:**
- `month` ← API `months`
- `details` ← API `details` (default: "Monthly Fee")

---

### AttendanceResponse & AttendanceRecord (`lib/models/attendance_model.dart`)

```
dart
class AttendanceResponse {
  final String studentId;
  final String month;
  final int present;
  final int absent;
  final int late;
  final int total;
  final List<AttendanceRecord> records;
}

class AttendanceRecord {
  final String date;
  final String status;  // "P", "A", "L"
}
```

---

### MarksheetModel (`lib/models/singleMarksheetModel.dart`)

```
dart
class MarksheetModel {
  final StudentInfo studentInfo;
  final String session;
  final String taskName;
  final List<SubjectMark> subjects;
}

class StudentInfo {
  final String studentId;
  final String name;
  final String fatherName;
  final String rollNumber;
  final String grade;        // Class (e.g., "Class 5")
  final String result;       // "PASS" or "FAIL"
  final double totalMarks;
  final double obtainedMarks;
  final String percentage;
  final String remarks;
}

class SubjectMark {
  final String subjectName;
  final double maximumMarks;
  final double passingMarks;
  final double obtainedMarks;
  final String? grade;
  final bool isPassed;
}
```

---

### NoticeModel (`lib/models/noticesModel.dart`)

```
dart
class NoticeModel {
  final int noticeId;
  final String title;        // API field: "note"
  final String description;  // API field: "notice"
  final DateTime date;
  final bool isSelected;
  bool isNew;                // Calculated locally (top 5 are "new")
}
```

---

## 8. Services Overview

### ApiService (`lib/services/api_service.dart`)

**Base URL:** `http://209.126.84.176:2099`

**Methods:**

```
dart
// GET request
Future<dynamic> get(
  String endpoint, {
  Map<String, String>? queryParams,
  bool requiresAuth = true,
})

// POST request
Future<dynamic> post(
  String endpoint, {
  Map<String, dynamic>? body,
  bool requiresAuth = true,
})
```

**Features:**
- Automatic JWT token injection in headers
- JSON response parsing
- Error handling with `ApiException`

**Headers Structure:**
```
dart
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer <jwt_token>',  // If requiresAuth=true
}
```

---

### AuthService (`lib/services/auth_service.dart`)

**Methods:**

```
dart
// Login
Future<Map<String, dynamic>> login(String userName, String password)

// Register
Future<dynamic> register(Map<String, dynamic> registerData)

// Update Password
Future<dynamic> updatePassword(String studentId, String newPassword)

// Token Management
Future<String?> getToken()
Future<void> setToken(String token)
Future<bool> isTokenExpired()

// Session Data
Future<String?> getStudentId()
Future<String?> getStudentName()
Future<Map<String, dynamic>?> getUserData()
Future<bool> isLoggedIn()

// Logout
Future<void> logout()
```

**Storage Security:**
- JWT Token → `FlutterSecureStorage` (encrypted)
- Student Data → `SharedPreferences` (non-sensitive)

---

## 9. ASCII Flow Diagrams

### Complete App Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            SMS APP FLOW                                     │
└─────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────┐
                                    │    main.dart    │
                                    │  (Entry Point)  │
                                    └────────┬────────┘
                                             │
                                             ▼
                              ┌────────────────────────┐
                              │    SplashScreen        │
                              │  (2 second delay)     │
                              └────────────┬───────────┘
                                           │
                           ┌───────────────┼───────────────┐
                           │               │               │
                           ▼               ▼               ▼
                    ┌────────────┐  ┌────────────┐  ┌────────────┐
                    │ Signin     │  │ Student    │  │ (Error)    │
                    │ Screen     │  │ Dashboard  │  │            │
                    └─────┬──────┘  └─────┬──────┘  └────────────┘
                          │                │
                          │                ▼
                          │      ┌─────────────────────┐
                          │      │   Drawer Menu       │
                          │      │  ┌───────────────┐  │
                          │      │  │ Profile       │──┼──► ProfileScreen
                          │      │  │ Attendance    │──┼──► AttendanceScreen
                          │      │  │ Marksheet     │──┼──► MarksheetScreen
                          │      │  │ Composite     │──┼──► CompositeScreen
                          │      │  │ Fee Details   │──┼──► StudentFeeScreen
                          │      │  │ Notices       │──┼──► NoticesScreen
                          │      │  │ Admit Card    │──┼──► AdmitCardScreen
                          │      │  └───────────────┘  │
                          │      └─────────────────────┘
                          │                │
                          │                ▼
                          │      ┌─────────────────────┐
                          │      │  Dashboard Body     │
                          │      │  ┌───────────────┐   │
                          │      │  │ UserIDSection │   │
                          │      │  └───────────────┘   │
                          │      │  ┌───────────────┐   │
                          │      │  │ NoticesSection│   │
                          │      │  └───────────────┘   │
                          │      │  ┌───────────────┐   │
                          │      │  │DashboardCards │   │
                          │      │  │  - Academic   │   │
                          │      │  │  - Attendance │   │
                          │      │  │  - Fee Due    │   │
                          │      │  └───────────────┘   │
                          │      └─────────────────────┘
                          │
                          ▼
                    ┌────────────┐
                    │  AuthService│
                    │  .logout()  │
                    └─────┬──────┘
                          │
                          ▼
                    ┌────────────┐
                    │  Signin    │
                    │  Screen    │
                    └────────────┘
```

### API → Controller → Card → UI Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     DATA FLOW: API to UI                                     │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌──────────────────────────────────────────────────────────────────────┐
    │                         ATTENDANCE FLOW                               │
    └──────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐       ┌────────────────┐       ┌────────────────────┐
    │   API       │       │  Controller    │       │      UI Card       │
    │  Service    │       │   (GetX)       │       │                    │
    └──────┬──────┘       └───────┬────────┘       └────────┬───────────┘
           │                      │                         │
           │   POST /Attendance/  │                         │
           │   GetAttendance      │                         │
           │────────────────────►│                         │
           │                      │                         │
           │   {present:20,      │                         │
           │    absent:2,        │   Obx(() =>            │
           │    late:1,          │     controller.       │
           │    records:[...]}   │     dashboardSummary  │
           │                      │     .value)           │
           │                      │                      │
           │                      │──────────────────────►│
           │                      │                         │
           │                      │              ┌────────┴────────┐
           │                      │              │ AttendancePie   │
           │                      │              │ ChartCard       │
           │                      │              │ - present: 20  │
           │                      │              │ - absent: 2     │
           │                      │              │ - leave: 1      │
           │                      │              └─────────────────┘
           │                      │                         │
           │   TAP ON CARD        │                         │
           │◄─────────────────────│                         │
           │                      │                         │
           │   Navigate to        │                         │
           │   AttendanceScreen  │                         │
           │                      │                         │
           ▼                      ▼                         ▼


    ┌──────────────────────────────────────────────────────────────────────┐
    │                         FEE FLOW                                      │
    └──────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐       ┌────────────────┐       ┌────────────────────┐
    │   API       │       │  Controller    │       │      UI Card       │
    │  Service    │       │   (GetX)       │       │                    │
    └──────┬──────┘       └───────┬────────┘       └────────┬───────────┘
           │                      │                         │
           │   GET /StudentFee/  │                         │
           │   Get-StudentFees  │                         │
           │────────────────────►│                         │
           │                      │                         │
           │   [FeeRecord,...]   │   Obx(() =>           │
           │                      │     controller.       │
           │                      │     getCurrentMonth   │
           │                      │     Fee())            │
           │                      │                      │
           │                      │──────────────────────►│
           │                      │                         │
           │                      │              ┌────────┴────────┐
           │                      │              │ NextFeeDueCard │
           │                      │              │ - dueDate       │
           │                      │              │ - feeAmount     │
           │                      │              └─────────────────┘
           │                      │                         │
           │   TAP ON CARD        │                         │
           │◄─────────────────────│                         │
           │                      │                         │
           │   Navigate to        │                         │
           │   StudentFeeScreen   │                         │
           │                      │                         │
           ▼                      ▼                         ▼
```

### Marksheet Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MARKSHEET FLOW                                         │
└─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────┐       ┌────────────────┐       ┌────────────────────┐
    │   API       │       │  Controller    │       │      UI Screen     │
    │  Service    │       │   (GetX)       │       │                    │
    └──────┬──────┘       └───────┬────────┘       └────────┬───────────┘
           │                      │                         │
           │   GET /Marksheet/   │                         │
           │   tasks             │                         │
           │────────────────────►│                         │
           │                      │                         │
           │   [{taskId,         │   Task Dropdown         │
           │    taskName},...]   │   Populated            │
           │                      │                      │
           │                      │   Select Task         │
           │                      │◄─────────────────────│
           │                      │                         │
           │   GET /Marksheet/   │                         │
           │   Get-Marksheet-   │                         │
           │   Single?studentId │                         │
           │   =...&taskId=...  │                         │
           │────────────────────►│                         │
           │                      │                         │
           │   [{subjectName,    │   Marks Loaded         │
           │    totalMarks,      │   Obx(() =>           │
           │    obtMarks,...}]   │     controller.       │
           │                      │     marksheet)        │
           │                      │                      │
           │                      │──────────────────────►│
           │                      │                         │
           │                      │              ┌──────────┴─────────┐
           │                      │              │ MarksheetScreen  │
           │                      │              │ - Student Info   │
           │                      │              │ - Subject Table  │
           │                      │              │ - Total/Grade    │
           │                      │              │ - Generate PDF  │
           │                      │              └──────────────────┘
           │                      │                         │
           │   TAP "Generate PDF"│                         │
           │◄─────────────────────│                         │
           │                      │                         │
           │   PDF Generated     │                         │
           │                      │                         │
           ▼                      ▼                         ▼
```

---

## 10. Notes & Best Practices

### GetX Reactive Updates

The app uses GetX's `Obx()` widget for reactive UI updates:

```
dart
// In controller
final RxBool isLoading = false.obs;
final RxList<FeeRecord> regularFees = <FeeRecord>[].obs;

// In UI
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  return Text('${controller.regularFees.length} records');
})
```

### Dependency Injection

| Type | Method | When to Use |
|------|--------|-------------|
| Eager | `Get.put(controller)` | Theme controller (needed immediately) |
| Lazy | `Get.lazyPut(controller)` | Data controllers (loaded on demand) |

### Error Handling

All API calls use try-catch blocks:

```
dart
try {
  final response = await _api.get(endpoint);
  // Handle response
} on ApiException catch (e) {
  errorMessage.value = e.message;
} catch (e) {
  errorMessage.value = 'Unexpected error: $e';
}
```

### PDF Generation

- Uses `pdf` package for PDF creation
- Uses `printing` package for sharing/saving
- Responsive layout with `MultiPage` for long content

### Theme Support

- Light and Dark themes via `ThemeController`
- Uses Material 3 (`useMaterial3: true`)
- Google Fonts Inter for consistent typography

### Security

- JWT tokens stored in `FlutterSecureStorage` (encrypted)
- Non-sensitive data in `SharedPreferences`
- Token expiry checking on app launch

---

## Quick Reference

### File Structure Summary

```
lib/
├── main.dart                          # App entry point
├── splashscreen.dart                  # Initial loading screen
├── controllers/
│   ├── attendance_controller.dart     # Attendance data
│   ├── student_fee_controller.dart    # Fee records & PDF
│   ├── academicCardController.dart    # Academic progress
│   ├── singleMarksheetController.dart # Marksheet data
│   ├── noticeController.dart          # Notices
│   └── theme_controller.dart          # Theme switching
├── dashboard/
│   ├── student_dashboard.dart        # Main dashboard
│   ├── sections/
│   │   ├── dashboard_cards_row/      # Cards (Academic, Fee, Attendance)
│   │   └── noticesSection.dart        # Notices display
│   └── Drawer_Screens/               # All detail screens
├── models/
│   ├── student_fee_models.dart       # FeeRecord
│   ├── attendance_model.dart         # AttendanceResponse
│   ├── singleMarksheetModel.dart     # MarksheetModel
│   └── noticesModel.dart             # NoticeModel
├── services/
│   ├── api_service.dart              # HTTP client
│   └── auth_service.dart             # Authentication
├── theme/
│   ├── app_theme.dart                # Theme configuration
│   └── app_colors.dart                # Color constants
└── authentication_screens/
    ├── signin.dart                    # Login screen
    └── signup_screen.dart             # Registration
```

### API Endpoints Summary

| Feature | Endpoint | Method |
|---------|----------|--------|
| Login | `/Auth/Login` | POST |
| Register | `/Auth/Register` | POST |
| Update Password | `/Auth/Update-Password` | POST |
| Fees | `/StudentFee/Get-StudentFees` | GET |
| Additional Fees | `/StudentFee/Get-StudentFeeAdditionals` | GET |
| Pending Fees | `/PendingFee/Get-PendingFee-Tasks` | GET |
| Attendance | `/Attendance/GetAttendance` | POST |
| Marksheet Tasks | `/Marksheet/tasks` | GET |
| Single Marksheet | `/Marksheet/Get-Marksheet-Single` | GET |
| Notices | `/Notice/Get-Notices` | GET |

---

*Document generated for Flutter School Management System App*
*Beginner-friendly, presentation-ready flow documentation*
