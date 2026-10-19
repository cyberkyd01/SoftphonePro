class ContactNumber {
  const ContactNumber({this.label = 'mobile', required this.value});
  final String label;
  final String value;

  factory ContactNumber.fromJson(Map<String, dynamic> j) => ContactNumber(
    label: j['label'] as String? ?? 'other',
    value: j['value'] as String? ?? '',
  );
  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class Contact {
  const Contact({
    required this.id,
    required this.name,
    this.company = '',
    this.numbers = const [],
    this.sipUris = const [],
    this.email = '',
    this.notes = '',
    this.favorite = false,
    this.ringtone = 'default',
    this.avatarColor = 0xFF3F51E0,
    this.blf = false,
    this.presenceUri,
  });

  final String id;
  final String name;
  final String company;
  final List<ContactNumber> numbers;
  final List<String> sipUris;
  final String email;
  final String notes;
  final bool favorite;
  final String ringtone;
  final int avatarColor;
  final bool blf;
  final String? presenceUri;

  /// All dialable addresses (numbers then SIP URIs).
  List<String> get addresses => [
    ...numbers.map((n) => n.value),
    ...sipUris,
  ].where((s) => s.trim().isNotEmpty).toList();

  String get primary => addresses.isEmpty ? '' : addresses.first;

  /// The URI to subscribe to for presence/BLF.
  String get watchTarget => presenceUri?.isNotEmpty == true
      ? presenceUri!
      : primary;

  String get displayName => name.isNotEmpty
      ? name
      : (company.isNotEmpty ? company : primary);

  Contact copyWith({
    String? name,
    String? company,
    List<ContactNumber>? numbers,
    List<String>? sipUris,
    String? email,
    String? notes,
    bool? favorite,
    String? ringtone,
    int? avatarColor,
    bool? blf,
    String? presenceUri,
  }) => Contact(
    id: id,
    name: name ?? this.name,
    company: company ?? this.company,
    numbers: numbers ?? this.numbers,
    sipUris: sipUris ?? this.sipUris,
    email: email ?? this.email,
    notes: notes ?? this.notes,
    favorite: favorite ?? this.favorite,
    ringtone: ringtone ?? this.ringtone,
    avatarColor: avatarColor ?? this.avatarColor,
    blf: blf ?? this.blf,
    presenceUri: presenceUri ?? this.presenceUri,
  );

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
    id: j['id'] as String,
    name: j['name'] as String? ?? '',
    company: j['company'] as String? ?? '',
    numbers: [
      for (final n in (j['numbers'] as List? ?? const []))
        ContactNumber.fromJson(Map<String, dynamic>.from(n as Map)),
    ],
    sipUris: [for (final s in (j['sipUris'] as List? ?? const [])) '$s'],
    email: j['email'] as String? ?? '',
    notes: j['notes'] as String? ?? '',
    favorite: j['favorite'] == true,
    ringtone: j['ringtone'] as String? ?? 'default',
    avatarColor: (j['avatarColor'] as num?)?.toInt() ?? 0xFF3F51E0,
    blf: j['blf'] == true,
    presenceUri: j['presenceUri'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'company': company,
    'numbers': numbers.map((n) => n.toJson()).toList(),
    'sipUris': sipUris,
    'email': email,
    'notes': notes,
    'favorite': favorite,
    'ringtone': ringtone,
    'avatarColor': avatarColor,
    'blf': blf,
    'presenceUri': presenceUri,
  };
}
