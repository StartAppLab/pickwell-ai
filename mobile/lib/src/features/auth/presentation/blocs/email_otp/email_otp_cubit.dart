import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/use_cases/email_otp_use_case.dart';

enum EmailOtpPhase { checking, email, sending, code, verifying, authorized }

class EmailOtpState {
  final EmailOtpPhase phase;
  final String email;
  final String? error;
  final int resendAfter;
  const EmailOtpState({
    this.phase = EmailOtpPhase.checking,
    this.email = '',
    this.error,
    this.resendAfter = 0,
  });
  bool get busy =>
      [EmailOtpPhase.checking, EmailOtpPhase.sending, EmailOtpPhase.verifying].contains(phase);
}

@injectable
class EmailOtpCubit extends Cubit<EmailOtpState> {
  final EmailOtpUseCase otp;
  Timer? _timer;
  int _generation = 0;
  EmailOtpCubit(this.otp) : super(const EmailOtpState());
  Future<void> check() async {
    if (isClosed) return;
    final generation = ++_generation;
    emit(const EmailOtpState());
    final result = await otp();
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(EmailOtpState(phase: EmailOtpPhase.email, error: f.error.statusCode)),
      (verified) => emit(
        EmailOtpState(
          phase: verified ? EmailOtpPhase.authorized : EmailOtpPhase.email,
          resendAfter: otp.resendAfter,
        ),
      ),
    );
    if (state.phase == EmailOtpPhase.email) _countdown();
  }

  Future<void> send(String raw) async {
    if (isClosed || state.busy || state.phase == EmailOtpPhase.authorized) return;
    final email = raw.trim();
    if (email.length > 254 || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      emit(EmailOtpState(phase: EmailOtpPhase.email, error: 'invalid_email'));
      return;
    }
    final previous = state;
    final generation = ++_generation;
    emit(EmailOtpState(phase: EmailOtpPhase.sending, email: email));
    final result = await otp.send(email);
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(
        EmailOtpState(
          phase: previous.phase,
          email: previous.email,
          error: f.error.statusCode,
          resendAfter: otp.resendAfter,
        ),
      ),
      (_) => emit(
        EmailOtpState(phase: EmailOtpPhase.code, email: email, resendAfter: otp.resendAfter),
      ),
    );
    _countdown();
  }

  void _countdown() {
    _timer?.cancel();
    if (otp.resendAfter <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed || state.phase == EmailOtpPhase.authorized) {
        timer.cancel();
        return;
      }
      if (!state.busy) {
        emit(
          EmailOtpState(
            phase: state.phase,
            email: state.email,
            error: state.error,
            resendAfter: otp.resendAfter,
          ),
        );
      }
      if (otp.resendAfter <= 0) timer.cancel();
    });
  }

  Future<void> verify(String code) async {
    if (isClosed || state.busy || state.phase != EmailOtpPhase.code) return;
    // Current hosted project uses eight digits; legacy six-digit deployments are
    // also supported. Do not weaken server settings to match an old mockup.
    if (!RegExp(r'^(\d{6}|\d{8})$').hasMatch(code)) {
      emit(
        EmailOtpState(
          phase: state.phase,
          email: state.email,
          error: 'invalid_code',
          resendAfter: otp.resendAfter,
        ),
      );
      return;
    }
    final email = state.email, generation = ++_generation;
    emit(EmailOtpState(phase: EmailOtpPhase.verifying, email: email, resendAfter: otp.resendAfter));
    final result = await otp.verify(email, code);
    if (isClosed || generation != _generation) return;
    result.fold(
      (f) => emit(
        EmailOtpState(
          phase: EmailOtpPhase.code,
          email: email,
          error: f.error.statusCode,
          resendAfter: otp.resendAfter,
        ),
      ),
      (verified) => emit(
        EmailOtpState(
          phase: verified ? EmailOtpPhase.authorized : EmailOtpPhase.code,
          email: email,
          error: verified ? null : 'invalid_code',
          resendAfter: otp.resendAfter,
        ),
      ),
    );
  }

  void changeEmail() {
    if (!isClosed && !state.busy) {
      emit(EmailOtpState(phase: EmailOtpPhase.email, resendAfter: otp.resendAfter));
    }
  }

  @override
  Future<void> close() {
    _generation++;
    _timer?.cancel();
    return super.close();
  }
}
