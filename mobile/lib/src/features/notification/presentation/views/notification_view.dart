import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: SafeArea(
        child: BlocListener<NotificationCubit, NotificationState>(
          listener: (context, state) {
            state.whenOrNull(
              success: () {},
              error: (error) {
                var message = 'Error Message';
                if (error.message?.isNotEmpty ?? false) {
                  message = error.message!;
                }
                AppWidgets.showErrorSnackBar(context, message);
              },
            );
          },
          child: Stack(
            children: [
              const SingleChildScrollView(
                child: Column(children: [NotificationWidget(text: 'Notification')]),
              ),
              BlocSelector<NotificationCubit, NotificationState, NotificationState>(
                selector: (state) => state,
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
              BlocSelector<NotificationCubit, NotificationState, NotificationState>(
                selector: (state) => state,
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: AbsorbPointer(
                      absorbing: state.maybeWhen(loading: () => true, orElse: () => false),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
