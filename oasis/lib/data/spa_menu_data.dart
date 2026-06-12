class SpaTreatment {
  final int? id; // Supabase row id (null for local-only data)
  final String title;
  final int durationMinutes;
  final double priceEuros;
  final String description;

  const SpaTreatment({
    this.id,
    required this.title,
    required this.durationMinutes,
    required this.priceEuros,
    required this.description,
  });

  /// Human-readable duration and price string for display.
  String get durationAndPrice => '$durationMinutes min - €${priceEuros.toStringAsFixed(0)}';

  /// Create from a Supabase JSON row.
  factory SpaTreatment.fromJson(Map<String, dynamic> json) {
    return SpaTreatment(
      id: json['id'] as int,
      title: json['title'] as String,
      durationMinutes: json['duration_minutes'] as int,
      priceEuros: (json['price_euros'] as num).toDouble(),
      description: (json['description'] as String?) ?? '',
    );
  }
}

/// Fallback local menu data (used if Supabase is unreachable).
const List<SpaTreatment> spaMenuFallback = [
  SpaTreatment(
    title: 'Classic Relaxation Massage (60 min)',
    durationMinutes: 60,
    priceEuros: 65,
    description: 'Deeply relaxing full-body massage using nourishing jojoba oil.',
  ),
  SpaTreatment(
    title: 'Classic Relaxation Massage (80 min)',
    durationMinutes: 80,
    priceEuros: 85,
    description: 'Extended deeply relaxing full-body massage using nourishing jojoba oil.',
  ),
  SpaTreatment(
    title: 'Back Relief Massage',
    durationMinutes: 45,
    priceEuros: 50,
    description: 'Targeted treatment to ease tension in the upper body.',
  ),
  SpaTreatment(
    title: 'Sport Massage',
    durationMinutes: 60,
    priceEuros: 70,
    description: 'Targeted treatment to relieve muscle tension and improve flexibility.',
  ),
  SpaTreatment(
    title: 'Head Relaxation Massage',
    durationMinutes: 30,
    priceEuros: 40,
    description: 'Relaxing treatment focused on head, neck, and shoulders.',
  ),
  SpaTreatment(
    title: 'Leg & Foot Relief Massage',
    durationMinutes: 45,
    priceEuros: 50,
    description: 'Soothing massage to relieve tired, swollen, and heavy legs.',
  ),
  SpaTreatment(
    title: 'Foot Reflexology Ritual',
    durationMinutes: 30,
    priceEuros: 40,
    description: 'Targets specific pressure points on the feet to support balance.',
  ),
  SpaTreatment(
    title: 'Oasis Salt Glow Ritual',
    durationMinutes: 90,
    priceEuros: 110,
    description: 'Exfoliating mineral-rich salt scrub and soothing massage.',
  ),
  SpaTreatment(
    title: 'Oasis Salt Glow Scrub',
    durationMinutes: 45,
    priceEuros: 55,
    description: 'Mineral-rich salt exfoliation to smooth and brighten skin.',
  ),
  SpaTreatment(
    title: 'Facial exfoliation ritual',
    durationMinutes: 30,
    priceEuros: 40,
    description: 'Revitalising facial exfoliation to smooth and brighten your skin.',
  ),
  SpaTreatment(
    title: 'Facial Massage',
    durationMinutes: 30,
    priceEuros: 40,
    description: 'Gentle, soothing facial massage designed to restore your natural glow.',
  ),
  SpaTreatment(
    title: 'Oasis Glow Ritual',
    durationMinutes: 45,
    priceEuros: 55,
    description: 'Exfoliating mineral-rich scrub followed by a relaxing body massage.',
  ),
  SpaTreatment(
    title: 'Oasis Special Glow Ritual',
    durationMinutes: 55,
    priceEuros: 65,
    description: 'Our signature premium treatment for deep hydration and skin radiance.',
  ),
];
