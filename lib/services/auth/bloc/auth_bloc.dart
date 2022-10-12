import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

import '../auth_provider.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>(
      (event, emit) async {
        await provider.initialize();
        final user = provider.currentUser;

        if (user == null) {
          emit(const AuthStateLoggedOut(null));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      },
    );
    on<AuthEventLogIn>(
      (event, emit) async {
        emit(const AuthStateLoading());
        final email = event.email.trim();
        final password = event.password.trim();

        try {
          final user = await provider.logIn(
            email: email,
            password: password,
          );
          emit(AuthStateLoggedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(e));
        }
      },
    );
    on<AuthEventLogOut>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          await provider.logOut();
          emit(const AuthStateLoggedOut(null));
        } on Exception catch (e) {
          emit(AuthStateLogOutFailure(e));
        }
      },
    );
  }
}
