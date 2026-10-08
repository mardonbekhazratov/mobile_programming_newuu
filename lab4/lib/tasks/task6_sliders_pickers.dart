import 'package:flutter/material.dart';

/// Task 6: Sliders & Pickers (Slider & showDatePicker)
///
/// Exercise 6.1: a volume control screen whose Slider updates the displayed
/// percentage while it is dragged.
/// Exercise 6.2: a button opens the native date picker via showDatePicker
/// and the chosen date is shown formatted.
class VolumePage extends StatefulWidget {
  const VolumePage({super.key});

  @override
  State<VolumePage> createState() => _VolumePageState();
}

class _VolumePageState extends State<VolumePage> {
  // Slider values run from 0.0 to 1.0; the text shows them as 0% to 100%.
  double _volume = 0.5;
  DateTime? _selectedDate;

  IconData get _volumeIcon {
    if (_volume == 0) return Icons.volume_off;
    if (_volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    // Cancelling the picker returns null.
    if (date == null || !mounted) return;
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = (_volume * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Volume & Date')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Volume', style: textTheme.titleLarge),
          const SizedBox(height: 16.0),
          Icon(_volumeIcon, size: 64),
          Text(
            '$percent%',
            textAlign: TextAlign.center,
            style: textTheme.displaySmall,
          ),
          Slider(
            value: _volume,
            onChanged: (value) => setState(() => _volume = value),
          ),
          const Divider(height: 48.0),
          Text('Date', style: textTheme.titleLarge),
          const SizedBox(height: 16.0),
          Text(
            _selectedDate == null
                ? 'No date selected'
                // Formats the date for the device's language,
                // e.g. "Thursday, October 8, 2026" in English.
                : MaterialLocalizations.of(context)
                      .formatFullDate(_selectedDate!),
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Pick a date'),
          ),
        ],
      ),
    );
  }
}
