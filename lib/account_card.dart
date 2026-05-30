import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'o_core.dart';
import 'title_card.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return TitleCard(
      title: AppLocalizations.of(context)!.account,
      subtitle: AppLocalizations.of(context)!.accountSubtitle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Consumer<OCore>(
          builder: (context, oCore, child) {
            return switch (oCore.loginStatus) {
              LoginStatus.loading => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeCap: StrokeCap.round),
                ),
              ),
              LoginStatus.loggedIn => _LoggedInRow(oCore: oCore),
              LoginStatus.loggedOut => Center(
                child: FilledButton.icon(
                  onPressed: oCore.launchLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: Text(AppLocalizations.of(context)!.loginMicrosoft),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _LoggedInRow extends StatelessWidget {
  final OCore oCore;
  const _LoggedInRow({required this.oCore});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = (oCore.userName?.isNotEmpty == true) ? oCore.userName![0].toUpperCase() : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                oCore.userName ?? AppLocalizations.of(context)!.unknownUser,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                oCore.userEmail ?? AppLocalizations.of(context)!.unknownEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmLogout),
                content: Text(AppLocalizations.of(context)!.confirmLogoutMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: Text(AppLocalizations.of(context)!.logout),
                  ),
                ],
              ),
            );
            if (confirmed == true) oCore.launchLogout();
          },
          child: Text(AppLocalizations.of(context)!.logout, style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }
}
