import 'package:expense_tracker/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authServices) : super(const AuthInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  final AuthServices _authServices;

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(const AuthFailure('Passwords do not match.'));
      return;
    }

    emit(const AuthLoading());
    try {
      await _authServices.signUp(event.email.trim(), event.password.trim());
      emit(
        const AuthSuccess(
          message: 'Account created successfully.',
          flowType: AuthFlowType.signup,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authServices.signIn(event.email.trim(), event.password.trim());
      emit(
        const AuthSuccess(
          message: 'Login successful.',
          flowType: AuthFlowType.login,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } catch (_) {
      emit(const AuthFailure('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authServices.signInWithGoogle();
      if (user == null) {
        emit(const AuthFailure('Google sign-in was cancelled.'));
        return;
      }
      emit(
        AuthSuccess(
          message: 'Signed in with Google successfully.',
          flowType: event.source == AuthFlowType.signup
              ? AuthFlowType.signup
              : AuthFlowType.login,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapFirebaseAuthError(e)));
    } on GoogleSignInException catch (e) {
      emit(AuthFailure(_mapGoogleSignInError(e)));
    } catch (_) {
      emit(const AuthFailure('Google sign-in failed. Please try again.'));
    }
  }

  String _mapGoogleSignInError(GoogleSignInException exception) {
    switch (exception.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return 'Google sign-in was cancelled.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Google sign-in is not configured correctly for this app.';
      default:
        return exception.description ??
            'Google sign-in failed. Please try again.';
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException exception) {
    switch (exception.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'account-exists-with-different-credential':
        return 'Account exists with a different sign-in method.';
      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }
}
