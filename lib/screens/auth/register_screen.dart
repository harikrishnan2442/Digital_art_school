import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/student.dart';
import '../../services/api_client.dart';
import '../../services/location_service.dart';
import '../../state/app_state.dart';
import '../shell/main_shell.dart';

const Map<String, List<String>> _disciplinesByCategory = {
  'Classical Dance': ['Kathakali', 'Mohiniyattam', 'Bharatanatyam'],
  'Vocal Music': ['Carnatic Vocal', 'Hindustani Classical', 'Light Music'],
  'Visual Arts': ['Mural Painting', 'Traditional Art', 'Sketching & Painting'],
  'Instrumental Music': ['Veena', 'Mridangam', 'Violin'],
  'Theatre': ['Kathakali Acting', 'Modern Theatre', 'Storytelling'],
};

/// Slot vocabulary shared with `Teacher.availableSlots` in
/// `mock_data.dart` — storing the *key* (not free text) is what lets
/// `TeacherMatchingService` compare a student's preference against a
/// teacher's declared availability.
const Map<String, String> _scheduleSlots = {
  'weekday_morning': 'Weekday Mornings',
  'weekday_evening': 'Weekday Evenings',
  'weekday_all_day': 'Weekday, Flexible',
  'weekend_morning': 'Weekend Mornings',
  'weekend_evening': 'Weekend Evenings',
  'weekend_all_day': 'Weekend, Flexible',
};

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _step = 0;
  final int _totalSteps = 4;

  final _stepKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Step 1
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Step 2
  String? _artCategory;
  String? _artDiscipline;
  final _secondaryInterestCtrl = TextEditingController();

  // Step 3
  SkillLevel _skillLevel = SkillLevel.completeBeginner;
  final _yearsCtrl = TextEditingController();
  final _previousTrainingCtrl = TextEditingController();

  // Step 4
  LearningPurpose _learningPurpose = LearningPurpose.hobby;
  final _timeCommitmentCtrl = TextEditingController();
  String? _preferredScheduleSlot;
  final _specificGoalsCtrl = TextEditingController();
  final _physicalConstraintsCtrl = TextEditingController();
  final _accommodationsCtrl = TextEditingController();

  bool _submitting = false;
  bool _locating = false;

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in [
      _fullNameCtrl,
      _emailCtrl,
      _passwordCtrl,
      _confirmCtrl,
      _ageCtrl,
      _locationCtrl,
      _secondaryInterestCtrl,
      _yearsCtrl,
      _previousTrainingCtrl,
      _timeCommitmentCtrl,
      _specificGoalsCtrl,
      _physicalConstraintsCtrl,
      _accommodationsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final result = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() {
        _locationCtrl.text = result.label ??
            '${result.latitude.toStringAsFixed(3)}, ${result.longitude.toStringAsFixed(3)}';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _goNext() {
    final currentFormState = _stepKeys[_step].currentState;
    if (currentFormState != null && !currentFormState.validate()) return;
    if (_step == _totalSteps - 1) {
      _submit();
      return;
    }
    setState(() => _step++);
    _pageController.animateToPage(_step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  void _goBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step--);
    _pageController.animateToPage(_step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final student = Student(
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      age: int.tryParse(_ageCtrl.text.trim()),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      artCategory: _artCategory,
      artDiscipline: _artDiscipline,
      secondaryInterest: _secondaryInterestCtrl.text.trim().isEmpty
          ? null
          : _secondaryInterestCtrl.text.trim(),
      skillLevel: _skillLevel,
      yearsOfExperience: double.tryParse(_yearsCtrl.text.trim()),
      previousTraining: _previousTrainingCtrl.text.trim().isEmpty
          ? null
          : _previousTrainingCtrl.text.trim(),
      learningPurpose: _learningPurpose,
      timeCommitment: _timeCommitmentCtrl.text.trim().isEmpty
          ? null
          : _timeCommitmentCtrl.text.trim(),
      preferredSchedule: _preferredScheduleSlot,
      specificGoals: _specificGoalsCtrl.text.trim().isEmpty
          ? null
          : _specificGoalsCtrl.text.trim(),
      physicalConstraints: _physicalConstraintsCtrl.text.trim().isEmpty
          ? null
          : _physicalConstraintsCtrl.text.trim(),
      learningAccommodations: _accommodationsCtrl.text.trim().isEmpty
          ? null
          : _accommodationsCtrl.text.trim(),
    );

    try {
      await context.read<AppState>().registerStudent(student);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  static const _stepLabels = [
    'Basic Info',
    'Art & Interests',
    'Experience',
    'Goals & Schedule',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: const Text('Create your account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(current: _step, labels: _stepLabels),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
            _buildNavRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.blue.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back',
                    style: TextStyle(
                        color: AppColors.blue, fontWeight: FontWeight.w700)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: _step == _totalSteps - 1 ? 'Create Account' : 'Continue',
              icon: _step == _totalSteps - 1 ? null : Icons.arrow_forward_rounded,
              loading: _submitting,
              onPressed: _submitting ? null : _goNext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepScaffold({
    required int stepIndex,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Form(
        key: _stepKeys[stepIndex],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.deep)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 13, color: AppColors.slate.withOpacity(0.85))),
            const SizedBox(height: 22),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
      );

  Widget _buildStep1() {
    return _stepScaffold(
      stepIndex: 0,
      title: 'Basic Information',
      subtitle: "Let's set up your account — these details are used to log in.",
      children: [
        _label('Full Name'),
        TextFormField(
          controller: _fullNameCtrl,
          decoration: const InputDecoration(hintText: "your name"),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
        ),
        const SizedBox(height: 16),
        _label('Email Address'),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'your.email@example.com'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Password'),
        TextFormField(
          controller: _passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Minimum 8 characters'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 8) return 'Minimum 8 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Confirm Password'),
        TextFormField(
          controller: _confirmCtrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Re-enter your password'),
          validator: (v) =>
              (v != _passwordCtrl.text) ? 'Passwords do not match' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Age'),
                  TextFormField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'your age'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Location'),
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      hintText: 'City, State',
                      suffixIcon: _locating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Use my current location',
                              icon: const Icon(AppIcons.locateFixed, size: 19, color: AppColors.blue),
                              onPressed: _useCurrentLocation,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final disciplines =
        _artCategory != null ? _disciplinesByCategory[_artCategory] ?? [] : <String>[];
    return _stepScaffold(
      stepIndex: 1,
      title: 'Art & Interests',
      subtitle: 'Tell us what draws you to the arts — this helps match you with the right teacher.',
      children: [
        _label('Art Category'),
        DropdownButtonFormField<String>(
          value: _artCategory,
          items: _disciplinesByCategory.keys
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() {
            _artCategory = v;
            _artDiscipline = null;
          }),
          decoration: const InputDecoration(hintText: 'Choose a category'),
          validator: (v) => v == null ? 'Please choose an art category' : null,
        ),
        const SizedBox(height: 16),
        _label('Art Discipline'),
        DropdownButtonFormField<String>(
          value: _artDiscipline,
          items: disciplines
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: disciplines.isEmpty
              ? null
              : (v) => setState(() => _artDiscipline = v),
          decoration: InputDecoration(
            hintText: disciplines.isEmpty ? 'Pick a category first' : 'Choose a discipline',
          ),
          validator: (v) => v == null ? 'Please choose a discipline' : null,
        ),
        const SizedBox(height: 16),
        _label('Secondary Interests (optional)'),
        TextFormField(
          controller: _secondaryInterestCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
              hintText: 'Any other art forms you\'re curious about?'),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return _stepScaffold(
      stepIndex: 2,
      title: 'Experience & Background',
      subtitle: 'Help your instructor tailor lessons to your level.',
      children: [
        _label('Skill Level'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SkillLevel.values.map((level) {
            final selected = _skillLevel == level;
            return ChoiceChip(
              label: Text(level.label),
              selected: selected,
              selectedColor: AppColors.blue,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.deep,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5),
              backgroundColor: AppColors.coconut,
              onSelected: (_) => setState(() => _skillLevel = level),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _label('Years of Experience'),
        TextFormField(
          controller: _yearsCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(hintText: 'e.g. 1.5'),
        ),
        const SizedBox(height: 16),
        _label('Previous Training (optional)'),
        TextFormField(
          controller: _previousTrainingCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Any classes, workshops, or self-taught experience'),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return _stepScaffold(
      stepIndex: 3,
      title: 'Learning Goals & Schedule',
      subtitle: "Almost there — tell us how you'd like to learn.",
      children: [
        _label('Learning Purpose'),
        DropdownButtonFormField<LearningPurpose>(
          value: _learningPurpose,
          items: LearningPurpose.values
              .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
              .toList(),
          onChanged: (v) => setState(() => _learningPurpose = v ?? _learningPurpose),
          decoration: const InputDecoration(hintText: 'Why are you learning?'),
        ),
        const SizedBox(height: 16),
        _label('Time Commitment'),
        TextFormField(
          controller: _timeCommitmentCtrl,
          decoration: const InputDecoration(hintText: 'e.g. 4-6 hrs / week'),
        ),
        const SizedBox(height: 16),
        _label('Preferred Schedule'),
        Text(
          'This is matched directly against each teacher\'s declared '
          'availability when we rank your teacher suggestions.',
          style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.7)),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _scheduleSlots.entries.map((entry) {
            final selected = _preferredScheduleSlot == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              selectedColor: AppColors.blue,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.deep,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
              backgroundColor: AppColors.coconut,
              onSelected: (_) => setState(() => _preferredScheduleSlot = entry.key),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _label('Specific Goals (optional)'),
        TextFormField(
          controller: _specificGoalsCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'What would you like to achieve in your first year?'),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.teal.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.accessibility_new_rounded,
                  color: AppColors.teal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Health & Accessibility — optional, and only shared with your '
                  'teacher to help them tailor sessions for you.',
                  style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.9)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _label('Physical Constraints (optional)'),
        TextFormField(
          controller: _physicalConstraintsCtrl,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _label('Learning Accommodations (optional)'),
        TextFormField(
          controller: _accommodationsCtrl,
          maxLines: 2,
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> labels;

  const _StepIndicator({required this.current, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final done = i < current;
          final active = i == current;
          final circleColor = done || active ? AppColors.blue : AppColors.coconut;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i != 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: done ? AppColors.blue : AppColors.blue.withOpacity(0.15),
                        ),
                      ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: Border.all(
                            color: active ? AppColors.blue : Colors.transparent, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: done
                          ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                          : Text('${i + 1}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: active ? Colors.white : AppColors.slate)),
                    ),
                    if (i != labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: done ? AppColors.blue : AppColors.blue.withOpacity(0.15),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.deep : AppColors.slate.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
