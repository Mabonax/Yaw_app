import 'package:flutter/material.dart';

import '../data/operator_models.dart';
import 'operator_workspace_controller.dart';

class OperatorWorkspaceScreen extends StatelessWidget {
  const OperatorWorkspaceScreen({super.key, required this.controller, required this.onSelected});
  final OperatorWorkspaceController controller;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.state;
      final active = state.memberships.where((m) => m.isActive).toList();
      final invitations = state.memberships.where((m) => m.isInvitation).toList();
      final requests = state.memberships.where((m) => m.isJoinRequest).toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Operator workspace')),
        body: RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Choose how you are operating', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Your pilot identity stays with you. Use personal pilot mode, or enter an operator workspace for fleet operations.'),
              const SizedBox(height: 16),
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Personal pilot', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                const Text('Manage your own pilot identity and personal records without entering an operator tenant.'),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: () async { await controller.enterPersonalMode(); onSelected(); }, child: const Text('Continue as personal pilot')),
              ]))),
              if (state.errorMessage != null) Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              if (invitations.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Operator invitations', style: Theme.of(context).textTheme.titleMedium),
                ...invitations.map((m) => _MembershipCard(membership:m, controller:controller, invitation:true, onSelected:onSelected)),
              ],
              if (requests.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Join requests', style: Theme.of(context).textTheme.titleMedium),
                ...requests.map((m) => Card(margin: const EdgeInsets.only(top: 12), child: ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: Text(m.operatorName),
                  subtitle: const Text('Pending operator approval'),
                  trailing: const Chip(label: Text('Pending')),
                ))),
              ],
              const SizedBox(height: 24),
              Text('Active workspaces', style: Theme.of(context).textTheme.titleMedium),
              if (active.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('You do not currently have an active operator workspace. You can continue using your personal pilot profile while an operator invitation or join request is processed.'),
                ),
              ...active.map((m) => _MembershipCard(membership:m, controller:controller, invitation:false, onSelected:onSelected)),
            ],
          ),
        ),
      );
    },
  );
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.membership, required this.controller, required this.invitation, required this.onSelected});
  final OperatorMembership membership;
  final OperatorWorkspaceController controller;
  final bool invitation;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text(membership.operatorName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height:4),
        Text(membership.role.replaceAll('_',' ')),
        if (membership.message != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(membership.message!)),
        const SizedBox(height:12),
        if (invitation)
          Row(children:[
            Expanded(child: OutlinedButton(onPressed:()=>controller.decline(membership), child:const Text('Decline'))),
            const SizedBox(width:12),
            Expanded(child: FilledButton(onPressed:() async { await controller.accept(membership); onSelected(); }, child:const Text('Accept'))),
          ])
        else
          FilledButton(onPressed:() async { await controller.select(membership); onSelected(); }, child:const Text('Open workspace')),
      ]),
    ),
  );
}
