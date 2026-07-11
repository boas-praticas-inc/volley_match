import 'package:flutter/material.dart';
import 'package:volley_match/core/theme/app_colors.dart';

class PlayerFormData {
  const PlayerFormData({
    required this.name,
    required this.position,
    required this.skillRating,
  });

  final String name;
  final String position;
  final int skillRating;
}

class PlayerForm extends StatefulWidget {
  const PlayerForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialPosition = _defaultPosition,
    this.initialSkillRating = 5,
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

  final String submitLabel;
  final ValueChanged<PlayerFormData> onSubmit;
  final String initialName;
  final String initialPosition;
  final int initialSkillRating;
  final Widget? secondaryAction;

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  late final TextEditingController _nameController;
  late String _selectedPosition;
  late double _skillRating;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedPosition = widget.initialPosition;
    _skillRating = widget.initialSkillRating.toDouble();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showPhotoPickerPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Seleção de foto será conectada na proxima iteração.'),
      ),
    );
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
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 48,
                  color: AppColors.textSubtle,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _showPhotoPickerPlaceholder,
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
          'Posição',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_skillRating.round()}/10',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textMuted,
          ),
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
