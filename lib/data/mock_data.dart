import '../models/course_module.dart';
import '../models/schedule_event.dart';

/// Static seed data standing in for parts of the original PHP project
/// that don't need a live database (orientation content, badges…).
///
/// Teacher data is NOT here — see `TeacherRepository`, which loads the
/// real 26-teacher dataset bundled at `assets/data/teachers.json`.
class MockData {
  MockData._();

  static const List<CourseModule> orientationModules = [
    CourseModule(
      number: 1,
      title: 'Welcome to Digital Art School',
      description:
          'Platform overview, how sessions work, and what to expect from '
          'your learning journey.',
      type: ModuleType.video,
      durationMinutes: 12,
      status: ModuleStatus.done,
    ),
    CourseModule(
      number: 2,
      title: 'History & Traditions of Your Art Form',
      description:
          'A curated overview of the origins, major schools, and key '
          'artists who shaped this discipline.',
      type: ModuleType.theory,
      durationMinutes: 25,
      status: ModuleStatus.done,
    ),
    CourseModule(
      number: 3,
      title: 'Core Vocabulary & Terminology',
      description:
          'Essential terms, concepts, and notation your teacher will use '
          'from day one.',
      type: ModuleType.theory,
      durationMinutes: 18,
      status: ModuleStatus.done,
    ),
    CourseModule(
      number: 4,
      title: 'Warm-Up Exercises for Beginners',
      description:
          'Guided daily warm-up routines designed for your discipline — '
          'practice these before your first live class.',
      type: ModuleType.practice,
      durationMinutes: 20,
      status: ModuleStatus.active,
    ),
    CourseModule(
      number: 5,
      title: 'Setting Up Your Practice Space',
      description:
          'What you need at home to get the most out of live and '
          'self-paced sessions.',
      type: ModuleType.video,
      durationMinutes: 9,
      status: ModuleStatus.locked,
    ),
  ];

  static const List<Resource> resources = [
    Resource(
        title: 'Beginner\'s Glossary (PDF)',
        subtitle: 'Printable reference sheet',
        type: ModuleType.theory),
    Resource(
        title: 'Daily Warm-Up Playlist',
        subtitle: '18-minute guided audio',
        type: ModuleType.video),
    Resource(
        title: 'Practice Log Template',
        subtitle: 'Track minutes & notes',
        type: ModuleType.practice),
  ];

  static const List<JourneyStep> journeySteps = [
    JourneyStep(
      title: 'Account Created & Profile Set Up',
      description:
          'You registered, chose your art form and discipline, and '
          'described your learning goals. That\'s the hardest part — '
          'you already did it.',
      detail: 'Unlocked: Free orientation track · AI learning assistant · '
          'Resource library',
      status: JourneyStepStatus.done,
    ),
    JourneyStep(
      title: 'Request a Teacher',
      description:
          'Browse the teacher list on your dashboard and send a '
          'personalised request. Include your background, goals, and '
          'availability — a thoughtful intro gets faster responses.',
      detail: 'Tip: teachers typically respond within 24–48 hours. You '
          'can message up to 3 teachers at the same time.',
      status: JourneyStepStatus.active,
      actionLabel: 'Browse Teachers',
    ),
    JourneyStep(
      title: 'Teacher Accepts Your Request',
      description:
          'Once a teacher accepts, you\'ll get a notification and your '
          'schedule opens up for booking your first session.',
      detail: 'Unlocks: personal schedule · assignment submissions · '
          'session recordings · direct messaging',
      status: JourneyStepStatus.pending,
    ),
    JourneyStep(
      title: 'Attend Your First Class',
      description:
          'Join your virtual studio session, meet your teacher, and '
          'start your first formal lesson.',
      status: JourneyStepStatus.locked,
    ),
    JourneyStep(
      title: 'Submit Your First Assignment',
      description:
          'Upload your first practice video or written exercise and '
          'receive detailed feedback from your teacher.',
      detail: 'Unlocks: certificate track · masterclasses · progress '
          'analytics · peer community',
      status: JourneyStepStatus.locked,
    ),
  ];

  static const List<EarnedBadge> badges = [
    EarnedBadge(name: 'First Step', earned: true),
    EarnedBadge(name: 'Orientation Halfway', earned: true),
    EarnedBadge(name: 'Teacher Matched', earned: false),
    EarnedBadge(name: 'First Class', earned: false),
    EarnedBadge(name: 'Consistent Learner', earned: false),
    EarnedBadge(name: 'Certified', earned: false),
  ];
}
