import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedRoute;
  final Widget unauthenticatedRoute;

  const AuthWrapper({
    super.key,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return authProvider.isAuthenticated
            ? authenticatedRoute
            : unauthenticatedRoute;
      },
    );
  }
}
