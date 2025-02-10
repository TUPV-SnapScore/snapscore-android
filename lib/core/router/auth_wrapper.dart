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

  static void forceAuthenticatedRoute(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Provider.of<AuthWrapper>(context, listen: false).authenticatedRoute,
      ),
      (route) => false,
    );
  }

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

        // Only show authenticated route if we have both Firebase and MongoDB user
        if (authProvider.user != null && authProvider.userId != null) {
          return authenticatedRoute;
        }

        return unauthenticatedRoute;
      },
    );
  }
}
