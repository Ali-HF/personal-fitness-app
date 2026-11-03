import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class FuelGuideScreen extends StatelessWidget {
  const FuelGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body & Fuel Guidance'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Notice card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Informational guidance only (not medical advice). Calorie counting is not required; focus on sustainable habits.',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildSection(
              context,
              title: 'Target & Realistic Timeline',
              content:
                  '• Target: about 65 kg while maintaining muscle (a healthy BMI ~21 at 5\'9"). Currently ~76 kg (~24.7 BMI).\n• Realistic pace: 0.4 - 0.6 kg per week. Realistic milestone: ~71-72.5 kg by early January, reaching 65 kg by April if sustained.\n• Hard ceiling: never lose faster than 0.75 kg per week (over 1% bodyweight) to preserve muscle mass.',
            ),

            _buildSection(
              context,
              title: 'Weigh-in & Deficit Rules',
              content:
                  '• Weigh in daily or weekly at the same time upon waking. Judge by the 7-day average, NOT single daily fluctuations.\n• Add a weekly waist measurement at navel level.\n• Modest deficit: 10-15% below maintenance. Do not stack a heavy deficit on top of running and finals!\n• Trend adjustment: if average drops >0.75 kg/wk for 2 weeks, eat 150-200 kcal more per day. If average is flat for 2-3 weeks, trim 100-150 kcal or increase daily walking.',
            ),

            _buildSection(
              context,
              title: 'Protein & Timing',
              content:
                  '• Protein goal: 1.6 - 2.0 g per kg body weight (roughly 120-150 g/day at 76 kg).\n• Distribution: spread evenly across 3-4 meals of 20-40 g protein each to optimize muscle protein synthesis.',
            ),

            _buildSection(
              context,
              title: 'Carbs & Run Fueling',
              content:
                  '• Keep carbohydrate intake adequate around running days. Do NOT follow a low-carb diet during this endurance build.\n• Eat easily digestible carbs before any run longer than 60 minutes.\n• Drink strictly to thirst (do not force water) to avoid hyponatremia.',
            ),

            _buildSection(
              context,
              title: 'Exam Finals & Race Week Rules',
              content:
                  '• Finals period (Dec 1-15): hold at maintenance or a tiny deficit. Academic stress + running requires adequate energy.\n• Race week (last 7-10 days before Jan 3): NO deficit. Eat at full maintenance, hydrate to thirst, and consume only 100% familiar foods.',
            ),

            _buildSection(
              context,
              title: 'Face Fat & Spot Reduction Truth',
              content:
                  '• Localized exercise does not remove fat from one spot. Face fat comes off naturally with overall whole-body fat loss.\n• Where fat sheds first is determined genetically. Be patient and consistent with the steady 7-day average.',
            ),

            _buildSection(
              context,
              title: 'Warning Signs of Under-fueling',
              content:
                  '• Constant fatigue or mental fog\n• Worsening sleep quality or insomnia\n• Frequent illness or lingering aches\n• Preoccupation with food or low mood\nIf you experience these, immediately bump calories to maintenance and rest.',
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
