import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ubuntu_bootstrap/l10n.dart';
import 'package:ubuntu_bootstrap/widgets.dart';
import 'package:ubuntu_provision/ubuntu_provision.dart';
import 'package:ubuntu_utils/ubuntu_utils.dart';
import 'package:ubuntu_wizard/ubuntu_wizard.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'bitlocker_model.dart';

class BitLockerPage extends ConsumerWidget {
  const BitLockerPage({super.key});

  static Future<bool> load(WidgetRef ref) {
    return ref.read(bitLockerModelProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(bitLockerModelProvider);
    final lang = UbuntuBootstrapLocalizations.of(context);
    final flavor = ref.watch(flavorProvider);
    return WizardPage(
      title: YaruWindowTitleBar(
        title: Text(lang.bitlockerTitle),
      ),
      content: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: SvgPicture.asset(
                'assets/storage/bitlocker.svg',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 48),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(lang.bitlockerTitle,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: kWizardSpacing),
                  Text(lang.bitlockerDescription(
                      lang.installationTypeErase(flavor.name))),
                  const SizedBox(height: kWizardSpacing),
                  Html(
                    data:
                        lang.bitlockerInstructions('help.ubuntu.com/bitlocker'),
                    style: {
                      'body': Style(margin: Margins.zero),
                      'a': Style(color: Theme.of(context).colorScheme.link),
                    },
                    onLinkTap: (url, _, __) => launchUrl(url!),
                  ),
                  const SizedBox(height: kWizardSpacing),
                  FilledButton(
                    onPressed: () async {
                      final window = YaruWindow.of(context);
                      final confirmed = await showConfirmationDialog(
                        context,
                        title: lang.bitlockerTitle,
                        message:
                            lang.restartIntoWindowsDescription(flavor.name),
                        okLabel: UbuntuLocalizations.of(context).restartLabel,
                        okElevated: true,
                      );
                      if (confirmed) {
                        model.reboot().then((_) => window.close());
                      }
                    },
                    child: Text(lang.restartIntoWindows),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomBar: WizardBar(
        leading: WizardButton.previous(context),
      ),
    );
  }
}
