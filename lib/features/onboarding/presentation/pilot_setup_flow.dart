import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../data/registration_draft.dart';
import 'setup_widgets.dart';

class PilotSetupFlow extends StatefulWidget {
  const PilotSetupFlow({
    super.key,
    required this.draft,
    required this.onBack,
    required this.onSignIn,
    this.initialStep = 0,
  });
  final RegistrationDraft draft;
  final VoidCallback onBack;
  final VoidCallback onSignIn;
  final int initialStep;
  @override
  State<PilotSetupFlow> createState() => _PilotSetupFlowState();
}

class _PilotSetupFlowState extends State<PilotSetupFlow> {
  late int _step = widget.initialStep;
  final _form = GlobalKey<FormState>();
  final _scrollKey = GlobalKey();
  bool _manual = false;
  String _search = '';
  RegistrationDraft get draft => widget.draft;
  static const _models = [
    ('DJI', 'Mavic 3'),
    ('DJI', 'Mini 4 Pro'),
    ('Autel', 'EVO Lite+'),
    ('DJI', 'Matrice 350 RTK'),
  ];

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      draft.confirmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (_step) {
      0 => (
        'Your Pilot Profile',
        'Let’s set up your pilot profile to get you\nin the air.',
      ),
      1 => (
        'Add Your\nAircraft',
        'Tell us about your drone to keep\nyour operations compliant.',
      ),
      2 => (
        'Your\nCertifications',
        'Keep your licences and certifications\nup to date.',
      ),
      _ => (
        'Review\nYour Details',
        'Almost there! Please review your\ninformation before creating\nyour account.',
      ),
    };
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (_step == 0) {
            widget.onBack();
          } else {
            _go(_step - 1);
          }
        }
      },
      child: SetupFrame(
        key: ValueKey(_step),
        cornerLeft: _step == 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SetupHeader(
              title: title,
              subtitle: subtitle,
              pilot: _step == 0,
              height: _step == 0
                  ? 328
                  : _step == 1
                  ? 270
                  : 250,
              onBack: () => _step == 0 ? widget.onBack() : _go(_step - 1),
            ),
            SetupStepper(step: _step, onStep: _go),
            Padding(
              key: _scrollKey,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _form,
                child: switch (_step) {
                  0 => _personal(),
                  1 => _aircraft(),
                  2 => _certifications(),
                  _ => _review(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String key,
    String initial,
    String hint,
    ValueChanged<String> changed, {
    IconData? icon,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: TextFormField(
      key: ValueKey(key),
      initialValue: initial,
      onChanged: changed,
      style: setupText(11),
      keyboardType: keyboard,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: setupInputDecoration(hint, icon: icon),
    ),
  );
  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Please complete this field.'
      : null;
  Widget _personal() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SetupSectionTitle(
        title: 'Personal Details',
        subtitle: 'Tell us a bit about yourself.',
      ),
      _field(
        'name',
        draft.name,
        'Full Name',
        (v) => draft.name = v,
        icon: Icons.person_outline,
        validator: _required,
      ),
      _field(
        'email',
        draft.email,
        'Email Address',
        (v) => draft.email = v,
        icon: Icons.mail_outline,
        keyboard: TextInputType.emailAddress,
        validator: (v) =>
            RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v?.trim() ?? '')
            ? null
            : 'Enter a valid email address.',
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: DropdownButtonFormField<String>(
              initialValue: draft.callingCode,
              style: setupText(11),
              isExpanded: true,
              decoration: setupInputDecoration('', icon: Icons.phone_outlined),
              items: [
                for (final code in [
                  '+27',
                  '+267',
                  '+264',
                  '+263',
                  '+268',
                  '+266',
                  '+44',
                  '+1',
                ])
                  DropdownMenuItem(
                    value: code,
                    child: Text(code == '+27' ? '🇿🇦  +27' : code),
                  ),
              ],
              onChanged: (v) => setState(() => draft.callingCode = v!),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _field(
              'phone',
              draft.phone,
              'Phone Number',
              (v) => draft.phone = v,
              keyboard: TextInputType.phone,
              validator: (v) =>
                  (v ?? '').replaceAll(RegExp(r'\D'), '').length >= 7
                  ? null
                  : 'Enter a phone number.',
            ),
          ),
        ],
      ),
      _dateField(
        'Date of Birth',
        draft.dateOfBirth,
        (v) => draft.dateOfBirth = v,
        birth: true,
      ),
      const SizedBox(height: 9),
      DropdownButtonFormField<String>(
        initialValue: draft.country,
        style: setupText(11),
        isExpanded: true,
        decoration: setupInputDecoration('', icon: Icons.location_on_outlined)
            .copyWith(
              labelText: 'Country',
              labelStyle: setupText(10, color: setupMuted),
            ),
        items: [
          for (final country in [
            'South Africa',
            'Botswana',
            'Namibia',
            'Zimbabwe',
            'Eswatini',
            'Lesotho',
            'United Kingdom',
            'United States',
          ])
            DropdownMenuItem(value: country, child: Text(country)),
        ],
        onChanged: (v) => draft.country = v!,
      ),
      const SizedBox(height: 17),
      SetupButton(
        label: 'Continue',
        onPressed: () {
          if (_form.currentState!.validate()) _go(1);
        },
      ),
      const SizedBox(height: 44),
    ],
  );

  Widget _dateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> changed, {
    bool birth = false,
    bool compact = false,
  }) => FormField<DateTime>(
    key: ValueKey('$label-$value'),
    initialValue: value,
    validator: birth
        ? (v) => v == null ? 'Choose your date of birth.' : null
        : null,
    builder: (state) => InkWell(
      onTap: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? (birth ? DateTime(now.year - 25) : now),
          firstDate: DateTime(1900),
          lastDate: birth ? now : DateTime(now.year + 40),
        );
        if (date != null && mounted) {
          setState(() {
            changed(date);
            state.didChange(date);
          });
        }
      },
      child: InputDecorator(
        decoration:
            setupInputDecoration(
              value == null ? label : formatSetupDate(value),
              icon: compact ? null : Icons.calendar_month_outlined,
              suffix: const Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: setupMuted,
              ),
            ).copyWith(
              errorText: state.errorText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: compact ? 5 : 14,
              ),
            ),
        child: Text(
          value == null
              ? (compact ? 'Select date' : label)
              : formatSetupDate(value),
          style: setupText(
            compact ? 8 : 10.5,
            color: value == null ? setupMuted : setupNavy,
          ),
        ),
      ),
    ),
  );

  Widget _aircraft() {
    final models = _models.indexed
        .where(
          (entry) => '${entry.$2.$1} ${entry.$2.$2}'.toLowerCase().contains(
            _search.toLowerCase(),
          ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SetupSectionTitle(
          title: 'Select Aircraft Type',
          subtitle: 'Choose the type of aircraft you operate.',
        ),
        Row(
          children: [
            for (final (i, type) in [
              'Multirotor',
              'Fixed Wing',
              'VTOL',
              'Other',
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() {
                    draft.aircraftType = type;
                    draft.model = '';
                    draft.manufacturer = '';
                  }),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 2,
                    ),
                    decoration: BoxDecoration(
                      color: draft.aircraftType == type
                          ? const Color(0xFFD7F3FF)
                          : Colors.white.withValues(alpha: .5),
                      border: Border.all(
                        color: draft.aircraftType == type
                            ? const Color(0xFF41B9EA)
                            : const Color(0xFFE1E8EF),
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 34,
                          child: Center(
                            child: i == 0 || i == 2
                                ? DroneIcon(size: 37)
                                : Icon(
                                    i == 1
                                        ? Icons.flight_takeoff
                                        : Icons.more_horiz,
                                    size: 30,
                                    color: setupNavy,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type,
                          style: setupText(8.5, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 9),
                        Icon(
                          draft.aircraftType == type
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: draft.aircraftType == type
                              ? setupBlue
                              : const Color(0xFF9DA9B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 19),
        const SetupSectionTitle(
          title: 'Search Manufacturer & Model',
          subtitle: 'Find your drone in our database or add it manually.',
        ),
        TextField(
          key: const ValueKey('model-search'),
          style: setupText(10),
          onChanged: (v) => setState(() => _search = v),
          decoration: setupInputDecoration(
            'Search (e.g. DJI Mavic 3, Autel EVO, etc.)',
            icon: Icons.search,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Models',
              style: setupText(9, weight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => _showModels(),
              child: Text('View All', style: setupText(9, color: setupBlue)),
            ),
          ],
        ),
        if (draft.aircraftType == 'Multirotor')
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (position, entry) in models.indexed) ...[
                if (position > 0) const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() {
                      draft.manufacturer = entry.$2.$1;
                      draft.model = entry.$2.$2;
                    }),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 5, 4, 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .7),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: draft.model == entry.$2.$2
                              ? setupBlue
                              : const Color(0xFFE1E8EF),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AircraftThumbnail(index: entry.$1),
                          const SizedBox(height: 5),
                          Text(
                            '${entry.$2.$1} ${entry.$2.$2}',
                            style: setupText(7.5, weight: FontWeight.w600),
                          ),
                          Text(
                            entry.$2.$1,
                            style: setupText(7, color: setupMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          )
        else
          Text(
            'Add your aircraft details manually below.',
            style: setupText(11, color: setupMuted),
          ),
        if (models.isEmpty && draft.aircraftType == 'Multirotor')
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'No matching models. Add your aircraft manually.',
              style: setupText(11, color: setupMuted),
            ),
          ),
        if (_manual || draft.aircraftType != 'Multirotor') ...[
          const SizedBox(height: 12),
          _field(
            'manufacturer',
            draft.manufacturer,
            'Manufacturer',
            (v) => draft.manufacturer = v,
            validator: _required,
          ),
          _field(
            'model',
            draft.model,
            'Model',
            (v) => draft.model = v,
            validator: _required,
          ),
        ],
        if (draft.model.isNotEmpty ||
            _manual ||
            draft.aircraftType != 'Multirotor') ...[
          const SizedBox(height: 12),
          _field(
            'serial',
            draft.serial,
            'Serial Number (optional)',
            (v) => draft.serial = v,
          ),
          _field(
            'registration',
            draft.registration,
            'Registration Number (optional)',
            (v) => draft.registration = v,
          ),
        ],
        const SizedBox(height: 18),
        SetupButton(
          label: 'Next',
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            if (draft.model.isEmpty) {
              _message('Select a model or add your aircraft manually.');
              return;
            }
            _go(2);
          },
        ),
        TextButton(
          onPressed: () => setState(() => _manual = !_manual),
          child: Text(
            _manual ? 'Choose a Popular Model' : 'Add Manually Instead',
            style: setupText(10, weight: FontWeight.w600, color: setupBlue),
          ),
        ),
        const SizedBox(height: 26),
      ],
    );
  }

  void _showModels() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Popular Aircraft Models',
              style: setupText(18, weight: FontWeight.w600),
            ),
          ),
          for (final (manufacturer, model) in _models)
            ListTile(
              leading: const DroneIcon(),
              title: Text('$manufacturer $model'),
              onTap: () {
                setState(() {
                  draft.aircraftType = 'Multirotor';
                  draft.manufacturer = manufacturer;
                  draft.model = model;
                });
                Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );

  Widget _certifications() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SetupSectionTitle(
        title: 'Pilot Licences',
        subtitle: 'Add your relevant pilot licences and ratings.',
        action: _smallButton(
          'Add Licence',
          Icons.add,
          () => setState(() => draft.licences.add(CertificationDraft())),
        ),
      ),
      for (final cert in draft.licences)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _certificate(
            cert,
            () => setState(() => draft.licences.remove(cert)),
          ),
        ),
      SetupSectionTitle(
        title: 'Medical Certificate',
        subtitle: 'Add your aviation medical certificate details.',
        action: _smallButton(
          'Add Medical',
          Icons.add,
          () => setState(
            () => draft.medicals.add(CertificationDraft(medical: true)),
          ),
        ),
      ),
      for (final cert in draft.medicals)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _certificate(
            cert,
            () => setState(() => draft.medicals.remove(cert)),
          ),
        ),
      SetupButton(
        label: 'Continue',
        onPressed: () {
          if (_form.currentState!.validate()) {
            if ([...draft.licences, ...draft.medicals].any(
              (c) =>
                  c.issuedAt != null &&
                  c.expiresAt != null &&
                  c.expiresAt!.isBefore(c.issuedAt!),
            )) {
              _message('Expiry must be after the issue date.');
              return;
            }
            _go(3);
          }
        },
      ),
      TextButton(
        onPressed: () => _go(3),
        child: Text('Skip for now', style: setupText(10, color: setupBlue)),
      ),
      const SizedBox(height: 14),
    ],
  );
  Widget _smallButton(String title, IconData icon, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 12),
        label: Text(title, style: setupText(8, color: setupBlue)),
        style: OutlinedButton.styleFrom(
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: EdgeInsets.symmetric(
            horizontal: 7,
            vertical: title == 'Edit' ? 5 : 8,
          ),
          side: const BorderSide(color: Color(0xFFACDDF5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      );
  Widget _certificate(CertificationDraft cert, VoidCallback remove) =>
      SetupCard(
        key: ObjectKey(cert),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: const Color(0xFFEDF3FA),
                  child: Icon(
                    cert.medical
                        ? Icons.monitor_heart_outlined
                        : Icons.workspace_premium_outlined,
                    size: 19,
                    color: setupNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.medical
                            ? 'Class 3 Medical Certificate'
                            : 'Remote Pilot Licence (RPL)',
                        style: setupText(10, weight: FontWeight.w600),
                      ),
                      Text('SACAA', style: setupText(8, color: setupMuted)),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Remove certificate',
                  child: InkWell(
                    onTap: remove,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(Icons.delete_outline, size: 15),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _labelled(
                    cert.medical ? 'Certificate Number' : 'Licence Number',
                    TextFormField(
                      initialValue: cert.number,
                      onChanged: (v) => cert.number = v,
                      style: setupText(8.5),
                      validator: (v) =>
                          cert.hasDetails && (v ?? '').trim().isEmpty
                          ? 'Enter the number.'
                          : null,
                      decoration: setupInputDecoration(
                        cert.medical ? 'e.g. MED001234' : 'e.g. RPL001234',
                      ).copyWith(contentPadding: const EdgeInsets.all(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _labelled(
                    cert.medical ? 'Expiry Date' : 'Issue Date',
                    _dateField(
                      cert.medical ? 'Medical expiry' : 'Issue date',
                      cert.medical ? cert.expiresAt : cert.issuedAt,
                      (v) {
                        if (cert.medical) {
                          cert.expiresAt = v;
                        } else {
                          cert.issuedAt = v;
                        }
                      },
                      compact: true,
                    ),
                  ),
                ),
              ],
            ),
            if (!cert.medical) ...[
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _labelled(
                      'Expiry Date',
                      _dateField(
                        'Licence expiry',
                        cert.expiresAt,
                        (v) => cert.expiresAt = v,
                        compact: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _labelled(
                      'Licence Category',
                      DropdownButtonFormField<String>(
                        initialValue: cert.category,
                        iconSize: 14,
                        isExpanded: true,
                        style: setupText(8),
                        decoration: setupInputDecoration('').copyWith(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                        ),
                        items: [
                          for (final type in [
                            'Multirotor',
                            'Fixed Wing',
                            'Helicopter',
                            'Other',
                          ])
                            DropdownMenuItem(value: type, child: Text(type)),
                        ],
                        onChanged: (v) => cert.category = v!,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (cert.issuedAt != null &&
                cert.expiresAt != null &&
                cert.expiresAt!.isBefore(cert.issuedAt!))
              Text(
                'Expiry must be after the issue date.',
                style: setupText(9, color: Colors.red.shade700),
              ),
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              color: const Color(0xFFF1F6FB),
              child: Row(
                children: [
                  const Icon(
                    Icons.upload_file_outlined,
                    size: 19,
                    color: setupNavy,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.document?.name ??
                              (cert.medical
                                  ? 'Upload Medical Certificate'
                                  : 'Upload Licence Document'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: setupText(8),
                        ),
                        Text(
                          cert.document == null
                              ? 'PDF, JPG or PNG (Max 5MB)'
                              : 'Selected · pending account setup',
                          style: setupText(7, color: setupMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF13BDEA), Color(0xFF0065E8)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextButton(
                      onPressed: () => _selectDocument(cert),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(63, 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        cert.document == null ? 'Upload' : 'Change',
                        style: setupText(8, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  Widget _labelled(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: setupText(7.5)),
      const SizedBox(height: 4),
      child,
    ],
  );
  Future<void> _selectDocument(CertificationDraft cert) async {
    try {
      final file = await openFile(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: 'Certificates',
            extensions: ['pdf', 'jpg', 'jpeg', 'png'],
            mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
            uniformTypeIdentifiers: [
              'com.adobe.pdf',
              'public.jpeg',
              'public.png',
            ],
          ),
        ],
      );
      if (file == null) return;
      if (await file.length() > 5 * 1024 * 1024) {
        if (mounted) _message('Choose a document smaller than 5 MB.');
        return;
      }
      if (mounted) setState(() => cert.document = file);
    } catch (_) {
      if (mounted) {
        _message('The document could not be selected. Please try again.');
      }
    }
  }

  Widget _review() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _reviewCard('Personal Details', Icons.person_outline, 0, [
        ('Full Name', draft.name),
        ('Date of Birth', formatSetupDate(draft.dateOfBirth)),
        ('Email Address', draft.email),
        ('Country', draft.country),
        ('Phone Number', '${draft.callingCode} ${draft.phone}'),
      ]),
      const SizedBox(height: 10),
      _reviewCard('Aircraft Details', Icons.flight_outlined, 1, [
        ('Aircraft Type', draft.aircraftType),
        ('Serial Number', draft.serial),
        ('Manufacturer & Model', '${draft.manufacturer} ${draft.model}'),
        ('Registration Number', draft.registration),
      ]),
      const SizedBox(height: 10),
      _reviewCard('Certifications', Icons.workspace_premium_outlined, 2, [
        for (final cert in [
          ...draft.licences,
          ...draft.medicals,
        ].where((c) => c.hasDetails)) ...[
          (
            cert.medical
                ? 'Class 3 Medical Certificate'
                : 'Remote Pilot Licence (RPL)',
            cert.number,
          ),
          ('Expiry Date', formatSetupDate(cert.expiresAt)),
        ],
        if (![...draft.licences, ...draft.medicals].any((c) => c.hasDetails))
          ('No certifications added', 'You can add these later.'),
      ]),
      const SizedBox(height: 9),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(
              value: draft.confirmed,
              activeColor: setupBlue,
              onChanged: (v) => setState(() => draft.confirmed = v!),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'I confirm that the information provided is accurate and up to date.',
              style: setupText(8, color: setupMuted),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(left: 28, bottom: 12),
        child: Wrap(
          children: [
            Text(
              'By creating an account, you agree to our ',
              style: setupText(7.5, color: setupMuted),
            ),
            _legalLink('Terms of Service'),
            Text(' and ', style: setupText(7.5, color: setupMuted)),
            _legalLink('Privacy Policy'),
          ],
        ),
      ),
      SetupButton(label: 'Create Account', onPressed: _submit),
      const SizedBox(height: 24),
      Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'SAFER SKIES. BRIGHTER POSSIBILITIES.',
              style: setupText(
                6.5,
                color: setupMuted,
              ).copyWith(letterSpacing: 1.1),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
      const SizedBox(height: 38),
    ],
  );
  Widget _legalLink(String title) => InkWell(
    onTap: () => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text(
          'The account service will provide the current policy before registration is enabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    ),
    child: Text(title, style: setupText(7.5, color: setupBlue)),
  );
  Widget _reviewCard(
    String title,
    IconData icon,
    int step,
    List<(String, String)> values,
  ) => SetupCard(
    padding: const EdgeInsets.all(8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFEBF2FA),
          child: title == 'Aircraft Details'
              ? const DroneIcon(size: 23)
              : Icon(icon, size: 19, color: setupNavy),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: setupText(10, weight: FontWeight.w600),
                    ),
                  ),
                  _smallButton('Edit', Icons.edit_outlined, () => _go(step)),
                ],
              ),
              const SizedBox(height: 3),
              for (var i = 0; i < values.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _reviewValue(values[i])),
                      const SizedBox(width: 14),
                      Expanded(
                        child: i + 1 < values.length
                            ? _reviewValue(values[i + 1])
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _reviewValue((String, String) value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value.$1, style: setupText(7.5, color: setupMuted)),
      const SizedBox(height: 2),
      Text(
        value.$2.trim().isEmpty ? 'Not provided' : value.$2,
        style: setupText(8.5, color: setupMuted),
      ),
    ],
  );
  void _submit() {
    if (!draft.confirmed) {
      _message('Please confirm your details before continuing.');
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account creation is not available yet'),
        content: const Text(
          'Your details are ready to review, but YAW cannot create a mobile account yet. Nothing has been submitted and no verification email has been sent. Your details will remain here while this setup is open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep reviewing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSignIn();
            },
            child: const Text('Sign in instead'),
          ),
        ],
      ),
    );
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}

/// Only the product photography is displayed from the supplied reference.
/// Text, selection and controls are native widgets.
class AircraftThumbnail extends StatelessWidget {
  const AircraftThumbnail({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.45,
    child: ClipRect(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const starts = [62.0, 262.0, 461.0, 658.0];
          final scale = constraints.maxWidth / 154;
          return OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Transform.translate(
              offset: Offset(-starts[index] * scale, -1350 * scale),
              child: Image.asset(
                'assets/screens/aircraft_reference.png',
                width: 850 * scale,
                height: 1850 * scale,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          );
        },
      ),
    ),
  );
}
