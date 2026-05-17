class SpaTreatment {
  final String title;
  final String durationAndPrice;
  final String description;

  const SpaTreatment({
    required this.title,
    required this.durationAndPrice,
    required this.description,
  });
}

const List<SpaTreatment> spaMenu = [
  SpaTreatment(
    title: 'Classic Relaxation Massage',
    durationAndPrice: '60 min - €65 / 80 min - €85',
    description:
        'Deeply relaxing full-body massage using nourishing jojoba oil.',
  ),
  SpaTreatment(
    title: 'Back Relief Massage',
    durationAndPrice: '45 min - €50',
    description: 'Targeted treatment to ease tension in the upper body.',
  ),
  SpaTreatment(
    title: 'Sport Massage',
    durationAndPrice: '60 min - €70',
    description:
        'Targeted treatment to relieve muscle tension and improve flexibility.',
  ),
  SpaTreatment(
    title: 'Head Relaxation Massage',
    durationAndPrice: '30 min - €40',
    description: 'Relaxing treatment focused on head, neck, and shoulders.',
  ),
  SpaTreatment(
    title: 'Leg & Foot Relief Massage',
    durationAndPrice: '45 min - €50',
    description: 'Soothing massage to relieve tired, swollen, and heavy legs.',
  ),
  SpaTreatment(
    title: 'Foot Reflexology Ritual',
    durationAndPrice: '30 min - €40',
    description:
        'Targets specific pressure points on the feet to support balance.',
  ),
  SpaTreatment(
    title: 'Oasis Salt Glow Ritual',
    durationAndPrice: '90 min - €110',
    description:
        'Exfoliating mineral-rich salt scrub and soothing massage (Aloe Vera or Orange).',
  ),
  SpaTreatment(
    title: 'Oasis Salt Glow Scrub',
    durationAndPrice: '45 min - €55',
    description:
        'Mineral-rich salt exfoliation to smooth and brighten skin (Aloe Vera or Orange).',
  ),
];
