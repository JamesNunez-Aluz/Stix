import '../models/idea.dart';
import '../models/jar.dart';

/// Builds the default social caption for a polaroid — short, with hashtags,
/// and a shoutout to Stix. The user can edit it before posting.
class CaptionBuilder {
  static String build(Idea idea, {Jar? jar}) {
    final title = idea.title.trim();
    final stars = '⭐' * (idea.rating ?? 0);
    final tags = <String>['#Stix', '#StixApp'];
    final jarTag = _hashtag(jar?.name);
    if (jarTag != null) tags.add(jarTag);

    final lines = <String>[
      title.isEmpty ? 'tried it ✅' : 'tried it ✅ $title',
      if (stars.isNotEmpty) stars,
      'pulled it from my Stix jar 🥫',
      tags.join(' '),
    ];
    return lines.join('\n');
  }

  static String? _hashtag(String? name) {
    if (name == null) return null;
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return slug.isEmpty ? null : '#$slug';
  }
}
