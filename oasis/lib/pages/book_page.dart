import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/spa_menu_data.dart';
import '../data/spa_theme.dart';
import '../services/supabase_service.dart';

class BookPageBody extends StatefulWidget {
  const BookPageBody({super.key});

  @override
  State<BookPageBody> createState() => _BookPageBodyState();
}

class _BookPageBodyState extends State<BookPageBody> {
  // ─── State ──────────────────────────────────────────────────
  int _currentStep = 0;

  List<SpaTreatment> _treatments = [];
  SpaTreatment? _selectedTreatment;

  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    final treatments = await SupabaseService.fetchTreatments();
    if (mounted) setState(() => _treatments = treatments);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ─── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: SpaColors.sand,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel:
            _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        controlsBuilder: _buildControls,
        type: StepperType.vertical,
        steps: [
          _buildTreatmentStep(),
          _buildDateTimeStep(),
          _buildDetailsStep(),
        ],
      ),
    );
  }

  // ─── Step 1: Choose Treatment ───────────────────────────────
  Step _buildTreatmentStep() {
    return Step(
      title: Text('Choose Treatment',
          style: TextStyle(
              color: SpaColors.terracotta, fontWeight: FontWeight.bold)),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: _treatments.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          : Column(
              children: _treatments.map((t) {
                final isSelected = _selectedTreatment?.title == t.title;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: isSelected ? SpaColors.warmBeige : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _selectedTreatment = t),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? SpaColors.terracotta
                                : SpaColors.terracotta
                                    .withValues(alpha: 0.25),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.spa,
                                color: SpaColors.terracotta, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: SpaColors.deepBrown,
                                        fontSize: 15,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(t.durationAndPrice,
                                      style: TextStyle(
                                        color: SpaColors.terracotta,
                                        fontSize: 13,
                                      )),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: SpaColors.terracotta),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ─── Step 2: Pick Date & Time ───────────────────────────────
  Step _buildDateTimeStep() {
    return Step(
      title: Text('Pick Date & Time',
          style: TextStyle(
              color: SpaColors.terracotta, fontWeight: FontWeight.bold)),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker button
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: Icon(Icons.calendar_today, color: SpaColors.terracotta),
            label: Text(
              _selectedDate == null
                  ? 'Select a date'
                  : DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
              style: TextStyle(color: SpaColors.deepBrown),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: SpaColors.terracotta),
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),

          // Time slots
          if (_loadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (_selectedDate != null && _availableSlots.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpaColors.warmBeige,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No available slots on this date. Please choose another day.',
                style: TextStyle(color: SpaColors.deepBrown),
              ),
            )
          else if (_availableSlots.isNotEmpty) ...[
            Text('Available times:',
                style: TextStyle(
                    color: SpaColors.deepBrown, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) {
                final display = _formatTime(slot);
                final isSelected = _selectedTime == slot;
                return ChoiceChip(
                  label: Text(display),
                  selected: isSelected,
                  selectedColor: SpaColors.terracotta,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : SpaColors.deepBrown,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: SpaColors.terracotta.withValues(alpha: 0.4),
                  ),
                  onSelected: (_) => setState(() => _selectedTime = slot),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Step 3: Customer Details ───────────────────────────────
  Step _buildDetailsStep() {
    return Step(
      title: Text('Your Details',
          style: TextStyle(
              color: SpaColors.terracotta, fontWeight: FontWeight.bold)),
      isActive: _currentStep >= 2,
      state: StepState.indexed,
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon:
                    Icon(Icons.person_outline, color: SpaColors.terracotta),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SpaColors.terracotta, width: 2),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon:
                    Icon(Icons.email_outlined, color: SpaColors.terracotta),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: SpaColors.terracotta, width: 2),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter your email';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Booking summary card
            if (_selectedTreatment != null &&
                _selectedDate != null &&
                _selectedTime != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SpaColors.warmBeige,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: SpaColors.terracotta.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: SpaColors.terracotta,
                          fontSize: 16,
                        )),
                    const Divider(),
                    _summaryRow(
                        'Treatment', _selectedTreatment!.title),
                    _summaryRow('Duration',
                        '${_selectedTreatment!.durationMinutes} min'),
                    _summaryRow('Price',
                        '€${_selectedTreatment!.priceEuros.toStringAsFixed(0)}'),
                    _summaryRow('Date',
                        DateFormat('d MMM yyyy').format(_selectedDate!)),
                    _summaryRow('Time', _formatTime(_selectedTime!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Controls ───────────────────────────────────────────────
  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _submitting ? null : details.onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: SpaColors.terracotta,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(isLastStep ? 'Confirm Booking' : 'Continue'),
          ),
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: details.onStepCancel,
              child: Text('Back',
                  style: TextStyle(color: SpaColors.terracotta)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Logic ──────────────────────────────────────────────────
  Future<void> _onStepContinue() async {
    switch (_currentStep) {
      case 0:
        if (_selectedTreatment == null) {
          _showSnackBar('Please select a treatment');
          return;
        }
        setState(() => _currentStep = 1);
        break;
      case 1:
        if (_selectedDate == null || _selectedTime == null) {
          _showSnackBar('Please pick a date and time');
          return;
        }
        setState(() => _currentStep = 2);
        break;
      case 2:
        if (!_formKey.currentState!.validate()) return;
        await _submitBooking();
        break;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: SpaColors.terracotta,
              onPrimary: Colors.white,
              surface: SpaColors.sand,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _selectedTime = null;
      _loadingSlots = true;
    });

    final slots = await SupabaseService.availableSlots(
        picked, _selectedTreatment!.durationMinutes);

    if (mounted) {
      setState(() {
        _availableSlots = slots;
        _loadingSlots = false;
      });
    }
  }

  Future<void> _submitBooking() async {
    setState(() => _submitting = true);
    try {
      await SupabaseService.createBooking(
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        treatmentId: _selectedTreatment!.id!,
        date: _selectedDate!,
        startTime: _selectedTime!,
        durationMinutes: _selectedTreatment!.durationMinutes,
      );
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) _showSnackBar('Booking failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: SpaColors.olive, size: 28),
            const SizedBox(width: 8),
            const Text('Booking Confirmed!'),
          ],
        ),
        content: Text(
          '${_selectedTreatment!.title}\n'
          '${DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!)}\n'
          '${_formatTime(_selectedTime!)}\n\n'
          'A confirmation email will be sent to\n'
          '${_emailController.text.trim()}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child:
                Text('Done', style: TextStyle(color: SpaColors.terracotta)),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _currentStep = 0;
      _selectedTreatment = null;
      _selectedDate = null;
      _selectedTime = null;
      _availableSlots = [];
      _nameController.clear();
      _emailController.clear();
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final h12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h12:$minute $period';
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(
                    color: SpaColors.deepBrown, fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: Text(value,
                  style: TextStyle(color: SpaColors.deepBrown))),
        ],
      ),
    );
  }
}
