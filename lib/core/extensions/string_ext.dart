extension StringExt on String {
  String get titleCased {
    if (trim().isEmpty) return this;
    return split(' ')
        .where((segment) => segment.trim().isNotEmpty)
        .map(
          (segment) =>
              '${segment[0].toUpperCase()}${segment.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String get initials {
    final parts = split(
      ' ',
    ).where((segment) => segment.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
