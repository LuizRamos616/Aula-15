import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/media_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _mediaService = MediaService();
  File? _imagemPerfil;
  final _nomeController = TextEditingController(text: 'Diego Menegassi');

  static const _prefKey = 'imagem_perfil_path';

  @override
  void initState() {
    super.initState();
    _carregarImagemSalva();
  }

  Future<void> _carregarImagemSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null && File(path).existsSync()) {
      setState(() {
        _imagemPerfil = File(path);
      });
    }
  }

  Future<void> _persistirCaminho(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_prefKey);
    } else {
      await prefs.setString(_prefKey, path);
    }
  }

  Future<void> _capturarImagem(bool daCamera) async {
    Navigator.pop(context);
    final File? imagem = daCamera
        ? await _mediaService.tirarFoto()
        : await _mediaService.selecionarDaGaleria();
    if (imagem != null) {
      setState(() {
        _imagemPerfil = imagem;
      });
      await _persistirCaminho(imagem.path);
    }
  }

  Future<void> _removerFoto() async {
    Navigator.pop(context);
    setState(() {
      _imagemPerfil = null;
    });
    await _persistirCaminho(null);
  }

  void _exibirOpcoesMidia() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: _imagemPerfil != null ? 210 : 160,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.pink),
              title: const Text('Tirar Foto com a Câmera'),
              onTap: () => _capturarImagem(true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.pink),
              title: const Text('Escolher da Galeria'),
              onTap: () => _capturarImagem(false),
            ),
            if (_imagemPerfil != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.pink),
                title: const Text('Remover Foto'),
                onTap: _removerFoto,
              ),
          ],
        ),
      ),
    );
  }

  void _abrirFotoEmTelaCheia() {
    if (_imagemPerfil == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoFullScreenScreen(imagem: _imagemPerfil!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Usuário'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _abrirFotoEmTelaCheia,
                    child: Hero(
                      tag: 'perfil_foto',
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.pink.shade100,
                        backgroundImage: _imagemPerfil != null
                            ? FileImage(_imagemPerfil!)
                            : null,
                        child: _imagemPerfil == null
                            ? const Icon(Icons.person, size: 70, color: Colors.pink)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _exibirOpcoesMidia,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FotoFullScreenScreen extends StatelessWidget {
  final File imagem;
  const FotoFullScreenScreen({super.key, required this.imagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: 'perfil_foto',
          child: InteractiveViewer(
            child: Image.file(imagem, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
