import 'package:flutter/material.dart';

class FinnShimmerList extends StatelessWidget {
  const FinnShimmerList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Container(
        height: 88,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemCount: itemCount,
    );
  }
}
