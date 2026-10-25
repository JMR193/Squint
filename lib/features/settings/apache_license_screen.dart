import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApacheLicenseScreen extends StatelessWidget {
  const ApacheLicenseScreen({super.key});

  static const String _apacheText = '''
                               Apache License
                         Version 2.0, January 2004
                      http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.
      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      patent license to make, have made, use, offer to sell, sell, import,
      and otherwise transfer the Work.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and
      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and
      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work on an "AS IS"
      BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
      or implied.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      shall any Contributor be liable to You for damages.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apache License 2.0'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy License Text',
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _apacheText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apache 2.0 License text copied to clipboard.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.cyanAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Open Source Apache License 2.0',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Squint Clinical Suite is distributed under the Apache License Version 2.0. Grants perpetual, royalty-free rights for research, clinical, and commercial use.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SelectableText(
                  _apacheText,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
