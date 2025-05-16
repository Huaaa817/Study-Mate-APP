import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/view_models/user_id_vm.dart';
import 'package:go_router/go_router.dart';

class UserIdInputPage extends StatelessWidget {
  const UserIdInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserIdInputViewModel>();
    final controller = TextEditingController();

    Future<void> submit() async {
      final userId = controller.text.trim();
      if (userId.isEmpty) return;

      final isNewUser = await viewModel.submitUserId(userId);

      if (isNewUser == null) return; // 錯誤發生，中止

      // 將 userId 存入 ViewModel 或全域狀態（可改成其他管理方式）
      viewModel.setCurrentUserId(userId);

      if (isNewUser) {
        // 導向 generate page
        context.go('/generate');
      } else {
        // 導向 home page
        context.go('/home');
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Enter User ID')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'User ID',
                errorText: viewModel.error,
              ),
              onSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 20),
            viewModel.loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: submit,
                  child: const Text('Continue'),
                ),
          ],
        ),
      ),
    );
  }
}
