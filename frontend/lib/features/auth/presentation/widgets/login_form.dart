// Path: frontend/lib/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Username Field
              _buildUsernameField(isLoading),

              const SizedBox(height: 16),

              // Password Field
              _buildPasswordField(isLoading),

              const SizedBox(height: 16),

              // Remember Me Checkbox
              _buildRememberMeCheckbox(isLoading),

              const SizedBox(height: 24),

              // Login Button
              _buildLoginButton(isLoading),

              if (state is LoginFailure) ...[
                const SizedBox(height: 16),
                _buildErrorMessage(state.message),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsernameField(bool isLoading) {
    return TextFormField(
      controller: _usernameController,
      enabled: !isLoading,
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'Enter your username',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textInputAction: TextInputAction.next,
      validator: Validators.username,
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      enabled: !isLoading,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      textInputAction: TextInputAction.done,
      validator: Validators.password,
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildRememberMeCheckbox(bool isLoading) {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: isLoading
              ? null
              : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
        ),
        Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
            child: Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                color: isLoading ? Colors.grey : Colors.grey[700],
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forgot password feature coming soon'),
                    ),
                  );
                },
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Sign In',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
