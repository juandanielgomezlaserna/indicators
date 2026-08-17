import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Si estás usando GetX para navegación
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/models/authService.dart';
import 'package:indicator/views/HomePrincipal.dart';
import 'package:indicator/views/login/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        _usuarioController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navegación directa con GetX sin usar rutas nombradas
        Get.offAll(() => const Homeprincipal());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.bg, // Dark Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("lib/assets/complete_logo.png", width: 217,),
                SizedBox(height: 10,),
                SizedBox(
                  width: 400, // Tu ancho personalizado (o double.infinity para ocupar todo el ancho)
                  child: TextFormField(
                    controller: _usuarioController,
                    style: GoogleFonts.inter(color: Global.text),
                    // Esto es clave para que el texto se centre verticalmente con el nuevo alto del SizedBox
                    decoration: InputDecoration(
                      labelText: 'usuario',
                      labelStyle: TextStyle(color: Global.text),
                      filled: true,
                      fillColor: Global.card,
                      // Ajusta el padding interno vertical/horizontal para que encaje perfecto en la altura
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'por favor ingresa tu usuario';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Campo Contraseña
                SizedBox(
                  width: 400,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'contraseña',
                      labelStyle: TextStyle(color: Global.text),
                      filled: true,
                      fillColor: Global.card,
                      // Ajusta el padding interno vertical/horizontal para que encaje perfecto en la altura
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 10,),
                          ],
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Botón Iniciar Sesión
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                    'iniciar sesión',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -1
                    ),
                  ),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(() => RegisterPage());
                  },
                  child: Text(
                    '¿primera vez? regístrate',
                    style: TextStyle(
                      color: Global.text,
                      fontWeight: FontWeight.w200,
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                      decorationColor: Global.text
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}