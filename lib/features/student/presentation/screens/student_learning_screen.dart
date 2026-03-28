import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/constants/dimens.dart';
import 'package:study/features/student/presentation/widgets/learning/learning_widgets.dart';
import 'package:study/features/weather/weather.dart';

class StudentLearningScreen extends StatefulWidget {
  const StudentLearningScreen({super.key, this.initialSegment = 0});

  final int initialSegment;

  static const int segmentCourses = 0;
  static const int segmentSchedule = 1;
  static const int segmentAssignments = 2;

  @override
  State<StudentLearningScreen> createState() => StudentLearningScreenState();
}

class StudentLearningScreenState extends State<StudentLearningScreen> {
  late int _currentSegment;

  @override
  void initState() {
    super.initState();
    _currentSegment = widget.initialSegment;
  }

  void switchSegment(int index) {
    if (index >= 0 && index <= 2) {
      setState(() => _currentSegment = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppLayout.screenMargin,
                AppSpacing.lg,
                AppLayout.screenMargin,
                0,
              ),
              child: BlocBuilder<WeatherBackgroundCubit, WeatherBackgroundState>(
                builder: (context, state) {
                  return Text(
                    'Hoc tap',
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: context.weatherTextColorThemed,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LearningSegmentControl(
              currentIndex: _currentSegment,
              onChanged: (i) => setState(() => _currentSegment = i),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: IndexedStack(
                index: _currentSegment,
                children: const [
                  LearningCoursesTab(),
                  LearningScheduleTab(),
                  LearningAssignmentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
