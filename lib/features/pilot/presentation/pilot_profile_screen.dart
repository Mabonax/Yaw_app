import 'package:flutter/material.dart';

import '../../../app/theme/yaw_tokens.dart';
import '../../../core/auth/auth_models.dart';
import '../../../core/widgets/yaw_widgets.dart';

class PilotProfileScreen extends StatelessWidget {
  const PilotProfileScreen({super.key, required this.pilot});

  final YawPilotProfile pilot;

  @override
  Widget build(BuildContext context) {
    return YawScaffold(
      appBar: const YawAppBar(title: 'My Pilot Profile'),
      body: ListView(
        padding: const EdgeInsets.all(YawSpacing.page),
        children: [
          YawSectionHeader(
            title: pilot.displayName,
            subtitle: 'Pilot profile returned by /api/v1/me/pilot.',
          ),
          YawSectionCard(
            title: 'Identity',
            child: Column(
              children: [
                YawInfoRow(
                  label: 'First name',
                  value: pilot.firstName ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Last name',
                  value: pilot.lastName ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Preferred name',
                  value: pilot.preferredName ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Employee number',
                  value: pilot.employeeNumber ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Email',
                  value: pilot.email ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Phone',
                  value: pilot.phone ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Nationality',
                  value: pilot.nationality ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Date of birth',
                  value: pilot.dateOfBirth ?? 'Not supplied',
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: 'Pilot credentials',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: YawSpacing.sm,
                  runSpacing: YawSpacing.sm,
                  children: [
                    YawComplianceBadge(
                      label:
                          _formatToken(pilot.profileStatus) ??
                          'Profile status unknown',
                      tone: pilot.isActive
                          ? YawStatusTone.healthy
                          : YawStatusTone.warning,
                    ),
                    if (pilot.medicalStatus != null)
                      YawComplianceBadge(
                        label: 'Medical ${_formatToken(pilot.medicalStatus)!}',
                        tone: pilot.medicalStatus == 'valid'
                            ? YawStatusTone.healthy
                            : YawStatusTone.warning,
                      ),
                  ],
                ),
                const SizedBox(height: YawSpacing.md),
                YawInfoRow(
                  label: 'SACAA certificate',
                  value: pilot.sacaaCertificateNumber ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'RPC category',
                  value: _formatToken(pilot.rpcCategory) ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Radiotelephony',
                  value:
                      _formatToken(pilot.radiotelephonyQualification) ??
                      'Not supplied',
                ),
                YawInfoRow(
                  label: 'Language proficiency',
                  value: pilot.languageProficiency ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Ratings',
                  value: pilot.ratings.isEmpty
                      ? 'None supplied'
                      : pilot.ratings.join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: YawSpacing.lg),
          YawSectionCard(
            title: 'Regulatory context',
            child: Column(
              children: [
                YawInfoRow(
                  label: 'Source',
                  value: pilot.regulatorySource ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Version',
                  value: pilot.regulatorySourceVersion ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Effective date',
                  value: pilot.regulatoryEffectiveDate ?? 'Not supplied',
                ),
                YawInfoRow(
                  label: 'Responsible role',
                  value: pilot.responsibleRole ?? 'Not supplied',
                ),
              ],
            ),
          ),
          if (pilot.operatorAffiliations.isNotEmpty ||
              pilot.supportingDocumentReferences.isNotEmpty ||
              pilot.notes != null) ...[
            const SizedBox(height: YawSpacing.lg),
            YawSectionCard(
              title: 'Additional records',
              child: Column(
                children: [
                  if (pilot.operatorAffiliations.isNotEmpty)
                    YawInfoRow(
                      label: 'Operator affiliations',
                      value: pilot.operatorAffiliations.join(', '),
                    ),
                  if (pilot.supportingDocumentReferences.isNotEmpty)
                    YawInfoRow(
                      label: 'Documents',
                      value: pilot.supportingDocumentReferences.join(', '),
                    ),
                  if (pilot.notes != null)
                    YawInfoRow(label: 'Notes', value: pilot.notes!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String? _formatToken(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
