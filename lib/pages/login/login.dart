import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _tgidController = TextEditingController();
  final _uuidController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final tgid = _tgidController.text.trim();
    final uuid = _uuidController.text.trim();

    if (tgid.isEmpty || uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 tgid 和 UUID')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Pull subscription automatically
      final subUrl = 'https://sni.868001.xyz/$uuid';
      final profile = Profile.normal(
        label: 'GrainTCP第五代',
        url: subUrl,
      );

      final nextProfile = await profile.update();

      await preferences.setLoginData(isLoggedIn: true, tgid: tgid, uuid: uuid);
      ref.read(profilesActionProvider.notifier).putProfile(nextProfile);
      ref.read(currentProfileIdProvider.notifier).value = nextProfile.id;

      ref.read(isLoggedInProvider.notifier).state = true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登录失败: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _tgidController,
              decoration: const InputDecoration(
                labelText: 'TGID (账号)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _uuidController,
              decoration: const InputDecoration(
                labelText: 'UUID (密码)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tgidController.dispose();
    _uuidController.dispose();
    super.dispose();
  }
}
