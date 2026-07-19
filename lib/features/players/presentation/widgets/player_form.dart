import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volley_match/core/theme/app_colors.dart';
import 'package:volley_match/shared/widgets/player_photo_avatar.dart';

import '../../data/services/player_photo_storage.dart';

class PlayerFormData {
  const PlayerFormData({
    required this.name,
    required this.position,
    required this.skillRating,
    required this.photoPath,
  });

  final String name;
  final String position;
  final int skillRating;
  final String? photoPath;
}

class PlayerForm extends StatefulWidget {
  const PlayerForm({
    super.key,
    required this.playerId,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialPosition = _defaultPosition,
    this.initialSkillRating = 5,
    this.initialPhotoPath,
    this.secondaryAction,
  });

  static const _defaultPosition = 'Ponteiro';
  static const _positions = [
    'Ponteiro',
    'Levantador',
    'Central',
    'Oposto',
    'Libero',
  ];

  final int playerId;
  final String submitLabel;
  final ValueChanged<PlayerFormData> onSubmit;
  final String initialName;
  final String initialPosition;
  final int initialSkillRating;
  final String? initialPhotoPath;
  final Widget? secondaryAction;

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  late final TextEditingController _nameController;
  late final PlayerPhotoStorage _photoStorage;
  late String _selectedPosition;
  late double _skillRating;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _nameController.addListener(_refreshAvatarFallback);
    _photoStorage = PlayerPhotoStorage();
    _selectedPosition = widget.initialPosition;
    _skillRating = widget.initialSkillRating.toDouble();
    _photoPath = widget.initialPhotoPath;
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshAvatarFallback);
    _nameController.dispose();
    super.dispose();
  }

  void _refreshAvatarFallback() {
    if (_photoPath == null || _photoPath!.trim().isEmpty) {
      setState(() {});
    }
  }

  Future<void> _showPhotoOptions() async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Escolher da galeria'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PhotoAction.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Tirar foto'),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PhotoAction.camera),
                ),
                if (_photoPath != null && _photoPath!.trim().isNotEmpty)
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                    ),
                    title: const Text('Remover foto'),
                    textColor: AppColors.danger,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_PhotoAction.remove),
                  ),
              ],
            ),
          ),
        );
      },
    );

    switch (action) {
      case _PhotoAction.gallery:
        await _pickPhoto(ImageSource.gallery);
      case _PhotoAction.camera:
        await _pickPhoto(ImageSource.camera);
      case _PhotoAction.remove:
        setState(() {
          _photoPath = null;
        });
      case null:
        return;
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final photoPath = await _photoStorage.pickAndStorePhoto(
        playerId: widget.playerId,
        source: source,
      );

      if (!mounted || photoPath == null) {
        return;
      }

      setState(() {
        _photoPath = photoPath;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel carregar a foto.')),
      );
    }
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do jogador.')),
      );
      return;
    }

    widget.onSubmit(
      PlayerFormData(
        name: name,
        position: _selectedPosition,
        skillRating: _skillRating.round(),
        photoPath: _photoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PlayerPhotoAvatar(
                name: _nameController.text,
                size: 112,
                photoPath: _photoPath,
                backgroundColor: AppColors.surfaceMuted,
                icon: Icons.person_outline,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _showPhotoOptions,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Digite o nome do jogador',
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Posicao',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 12,
            children: PlayerForm._positions
                .map(
                  (position) => ChoiceChip(
                    label: Text(position),
                    selected: position == _selectedPosition,
                    onSelected: (_) {
                      setState(() {
                        _selectedPosition = position;
                      });
                    },
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: position == _selectedPosition
                          ? Colors.white
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.surfaceMuted,
                    selectedColor: AppColors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Habilidade',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '${_skillRating.round()}/10',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
        ),
        Slider(
          min: 1,
          max: 10,
          divisions: 9,
          value: _skillRating,
          activeColor: AppColors.primary,
          label: _skillRating.round().toString(),
          onChanged: (value) {
            setState(() {
              _skillRating = value;
            });
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitForm,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(widget.submitLabel),
          ),
        ),
        if (widget.secondaryAction != null) ...[
          const SizedBox(height: 20),
          widget.secondaryAction!,
        ],
      ],
    );
  }
}

enum _PhotoAction { gallery, camera, remove }
