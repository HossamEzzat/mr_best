import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import '../../features/navigation/main_navigation_wrapper.dart';
import '../../features/groups/presentation/groups_screen.dart';
import '../../features/groups/presentation/group_details_screen.dart';
import '../../features/students/presentation/student_profile_screen.dart';
import '../../features/students/presentation/add_student_screen.dart';
import '../../features/attendance/presentation/take_attendance_screen.dart';
import '../../features/grades/presentation/enter_grades_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/pdf/presentation/pdf_preview_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationWrapper(),
    ),
    GoRoute(
      path: '/groups',
      builder: (context, state) => const GroupsScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return GroupDetailsScreen(groupId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/students/add',
      builder: (context, state) {
        final groupIdStr = state.uri.queryParameters['groupId'];
        final groupId = groupIdStr != null ? int.tryParse(groupIdStr) : null;
        return AddStudentScreen(groupId: groupId);
      },
    ),
    GoRoute(
      path: '/students/edit/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddStudentScreen(studentId: id);
      },
    ),
    GoRoute(
      path: '/students/profile/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return StudentProfileScreen(studentId: id);
      },
    ),
    GoRoute(
      path: '/attendance/take/:groupId/:sessionId',
      builder: (context, state) {
        final groupId = int.parse(state.pathParameters['groupId']!);
        final sessionId = int.parse(state.pathParameters['sessionId']!);
        return TakeAttendanceScreen(groupId: groupId, sessionId: sessionId);
      },
    ),
    GoRoute(
      path: '/grades/take/:groupId/:taskId',
      builder: (context, state) {
        final groupId = int.parse(state.pathParameters['groupId']!);
        final taskId = int.parse(state.pathParameters['taskId']!);
        return EnterGradesScreen(groupId: groupId, taskId: taskId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/pdf/preview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final title = extra['title'] as String;
        final pdfFileName = extra['fileName'] as String;
        final buildPdf = extra['buildPdf'] as Future<Uint8List> Function(PdfPageFormat format);
        return PdfPreviewScreen(
          title: title,
          pdfFileName: pdfFileName,
          buildPdf: buildPdf,
        );
      },
    ),
  ],
);
