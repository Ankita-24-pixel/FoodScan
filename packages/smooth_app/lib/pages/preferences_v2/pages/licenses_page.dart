import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmoothBrightnessOverride(
      brightness: context.lightTheme() ? Brightness.dark : Brightness.light,
      child: SmoothScaffold(
        body: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final PackageInfo? packageInfo = snapshot.data;
            if (packageInfo == null) {
              return const CircularProgressIndicator.adaptive();
            }

            return LicensePage(
              applicationName: packageInfo.appName,
              applicationVersion: packageInfo.version,
              applicationIcon: Image.asset(
                'assets/app/foodscan_logo.png',
                height: MediaQuery.sizeOf(context).height * 0.1,
              ),
            );
          },
        ),
      ),
    );
  }
}
