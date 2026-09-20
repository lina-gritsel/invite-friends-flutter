import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invite_friends/app/app_theme.dart';
import 'package:invite_friends/features/invite/invite_layout.dart';
import 'package:invite_friends/features/invite/invite_models.dart';
import 'package:invite_friends/features/invite/widgets/invite_shared_widgets.dart';

enum EventCategory { dinner, cinema, walk, games, other }

abstract final class _EventLayout {
  static const compactCategoryColumns = 3;
  static const initialFriendCount = 3;
  static const categoryTileMinWidth = 48.0;
  static const friendAvatarRadius = 26.0;
  static const friendItemWidth = 68.0;
  static const removeIconSize = 26.0;
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    required this.friends,
    this.initialCategory = EventCategory.dinner,
    super.key,
  });

  final List<Friend> friends;
  final EventCategory initialCategory;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const _initialTitle = 'Ужин в ресторане';
  static const _initialTime = TimeOfDay(hour: 19, minute: 0);
  static final _initialDate = DateTime(2026, 9, 20);

  late final TextEditingController _titleController;
  late EventCategory _category;
  late final Set<Friend> _selectedFriends;
  DateTime _date = _initialDate;
  TimeOfDay _time = _initialTime;
  bool _reminderEnabled = true;
  String _reminderInterval = 'За 1 час';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: _initialTitle);
    _category = widget.initialCategory;
    _selectedFriends = widget.friends
        .take(_EventLayout.initialFriendCount)
        .toSet();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2026),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Выберите дату события',
      cancelText: 'Отмена',
      confirmText: 'Готово',
    );
    if (selectedDate != null && mounted) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Выберите время события',
      cancelText: 'Отмена',
      confirmText: 'Готово',
    );
    if (selectedTime != null && mounted) {
      setState(() => _time = selectedTime);
    }
  }

  Future<void> _selectFriends() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Выберите друзей',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (widget.friends.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('Список друзей пока пуст'),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final friend in widget.friends)
                        CheckboxListTile(
                          value: _selectedFriends.contains(friend),
                          secondary: const _FriendAvatar(),
                          title: Text(friend.name),
                          subtitle: Text(friend.status.replaceAll('\n', ' · ')),
                          onChanged: (selected) {
                            setState(() {
                              if (selected ?? false) {
                                _selectedFriends.add(friend);
                              } else {
                                _selectedFriends.remove(friend);
                              }
                            });
                            setSheetState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Готово'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReminderInterval() async {
    const intervals = ['За 15 минут', 'За 30 минут', 'За 1 час', 'За день'];
    final selectedInterval = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Когда напомнить?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            RadioGroup<String>(
              groupValue: _reminderInterval,
              onChanged: (value) => Navigator.pop(context, value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final interval in intervals)
                    RadioListTile<String>(
                      value: interval,
                      title: Text(interval),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
    if (selectedInterval != null && mounted) {
      setState(() => _reminderInterval = selectedInterval);
    }
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showValidationMessage('Введите название события');
      return;
    }
    if (_selectedFriends.isEmpty) {
      _showValidationMessage('Выберите хотя бы одного друга');
      return;
    }
    Navigator.pop(context, true);
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorSoft,
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.errorInk,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.errorInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('create-event-screen'),
      appBar: AppBar(title: const Text('Создать событие')),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: InviteLayout.maxContentWidth,
            ),
            child: ListView(
              key: const Key('create-event-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                _TitleCard(controller: _titleController),
                const SizedBox(height: AppSpacing.xs),
                _CategoryCard(
                  selected: _category,
                  onSelected: (category) =>
                      setState(() => _category = category),
                ),
                const SizedBox(height: AppSpacing.xs),
                _FriendsCard(
                  friends: _selectedFriends.toList(),
                  onAdd: () => unawaited(_selectFriends()),
                  onRemove: (friend) {
                    setState(() => _selectedFriends.remove(friend));
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                _DateTimeCard(
                  date: _date,
                  time: _time,
                  onDatePressed: () => unawaited(_selectDate()),
                  onTimePressed: () => unawaited(_selectTime()),
                ),
                const SizedBox(height: AppSpacing.xs),
                const _NoteCard(),
                const SizedBox(height: AppSpacing.xs),
                _ReminderCard(
                  enabled: _reminderEnabled,
                  interval: _reminderInterval,
                  onChanged: (value) {
                    setState(() => _reminderEnabled = value);
                  },
                  onIntervalPressed: () => unawaited(_selectReminderInterval()),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: InviteLayout.ctaMaxWidth,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('create-event-submit'),
                onPressed: _submit,
                child: const Text('Создать событие'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Что планируем?'),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            key: const Key('create-event-title'),
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: _fieldDecoration(
              hintText: 'Название события',
              prefixIcon: Icons.calendar_today_outlined,
              suffix: IconButton(
                tooltip: 'Очистить название',
                onPressed: controller.clear,
                icon: const Icon(Icons.cancel_rounded),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Короткое название, которое увидят друзья',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.selected, required this.onSelected});

  final EventCategory selected;
  final ValueChanged<EventCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Выберите категорию'),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = AppSpacing.xs;
              final useCompactGrid =
                  constraints.maxWidth <
                      EventCategory.values.length *
                              _EventLayout.categoryTileMinWidth +
                          spacing * (EventCategory.values.length - 1) ||
                  MediaQuery.textScalerOf(context).scale(1) >
                      InviteLayout.largeTextScale;
              final columnCount = useCompactGrid
                  ? _EventLayout.compactCategoryColumns
                  : EventCategory.values.length;
              final tileWidth =
                  (constraints.maxWidth - spacing * (columnCount - 1)) /
                  columnCount;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final category in EventCategory.values)
                    SizedBox(
                      width: tileWidth,
                      child: _CategoryTile(
                        category: category,
                        selected: category == selected,
                        onTap: () => onSelected(category),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final EventCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.primary : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: category.label,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: InkWell(
          key: Key('event-category-${category.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(category.icon, color: foreground, size: 26),
                const SizedBox(height: AppSpacing.xs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category.label,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w600 : null,
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

class _FriendsCard extends StatelessWidget {
  const _FriendsCard({
    required this.friends,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Friend> friends;
  final VoidCallback onAdd;
  final ValueChanged<Friend> onRemove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('С кем идём?')),
              TextButton(
                onPressed: onAdd,
                child: const Text('Выбрать из друзей'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final friend in friends) ...[
                  _SelectedFriend(
                    key: Key('event-friend-${friend.name}'),
                    friend: friend,
                    onRemove: () => onRemove(friend),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                _AddFriendButton(onPressed: onAdd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedFriend extends StatelessWidget {
  const _SelectedFriend({
    required this.friend,
    required this.onRemove,
    super.key,
  });

  final Friend friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _EventLayout.friendItemWidth,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const _FriendAvatar(radius: _EventLayout.friendAvatarRadius),
              Positioned(
                right: -AppSpacing.sm,
                top: -AppSpacing.sm,
                child: IconButton(
                  tooltip: 'Убрать ${friend.name}',
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  icon: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: _EventLayout.removeIconSize,
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.muted,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(friend.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _AddFriendButton extends StatelessWidget {
  const _AddFriendButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.outlined(
          tooltip: 'Добавить друга',
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const CircleBorder(),
            minimumSize: const Size(52, 52),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.add_rounded),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Добавить',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({this.radius = 20});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySoft,
      child: Icon(
        Icons.person_rounded,
        size: radius,
        color: AppColors.avatarForeground,
      ),
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.date,
    required this.time,
    required this.onDatePressed,
    required this.onTimePressed,
  });

  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDatePressed;
  final VoidCallback onTimePressed;

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(date);
    final formattedTime = _formatTime(time);
    final dateButton = _ValueButton(
      key: const Key('event-date'),
      icon: Icons.calendar_today_outlined,
      label: formattedDate,
      semanticLabel: 'Дата события: $formattedDate',
      onPressed: onDatePressed,
    );
    final timeButton = _ValueButton(
      key: const Key('event-time'),
      icon: Icons.schedule_rounded,
      label: formattedTime,
      semanticLabel: 'Время события: $formattedTime',
      onPressed: onTimePressed,
    );
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Когда?'),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack =
                  constraints.maxWidth < InviteLayout.stackActionsBelow ||
                  MediaQuery.textScalerOf(context).scale(1) >
                      InviteLayout.largeTextScale;
              if (stack) {
                return Column(
                  children: [
                    dateButton,
                    const SizedBox(height: AppSpacing.xs),
                    timeButton,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 3, child: dateButton),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(flex: 2, child: timeButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ValueButton extends StatelessWidget {
  const _ValueButton({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSize.primaryButtonHeight),
          alignment: Alignment.centerLeft,
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        icon: Icon(icon),
        label: Row(
          children: [
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SectionTitle('Заметка'),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '(необязательно)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: _fieldDecoration(
              hintText: 'Забронирую столик на 4',
              prefixIcon: Icons.chat_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.enabled,
    required this.interval,
    required this.onChanged,
    required this.onIntervalPressed,
  });

  final bool enabled;
  final String interval;
  final ValueChanged<bool> onChanged;
  final VoidCallback onIntervalPressed;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              const RoundIcon(icon: Icons.notifications_rounded),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Напомнить о событии',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Мы отправим вам уведомление',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('event-reminder'),
                value: enabled,
                onChanged: onChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: _ValueButton(
                icon: Icons.alarm_rounded,
                label: interval,
                semanticLabel: 'Напомнить $interval',
                onPressed: onIntervalPressed,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

extension on EventCategory {
  String get label => switch (this) {
    EventCategory.dinner => 'Ужин',
    EventCategory.cinema => 'Кино',
    EventCategory.walk => 'Парк',
    EventCategory.games => 'Игры',
    EventCategory.other => 'Другое',
  };

  IconData get icon => switch (this) {
    EventCategory.dinner => Icons.restaurant_rounded,
    EventCategory.cinema => Icons.local_movies_rounded,
    EventCategory.walk => Icons.directions_walk_rounded,
    EventCategory.games => Icons.sports_esports_rounded,
    EventCategory.other => Icons.more_horiz_rounded,
  };
}

InputDecoration _fieldDecoration({
  required String hintText,
  required IconData prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    hintText: hintText,
    hintStyle: const TextStyle(color: AppColors.muted),
    prefixIcon: Icon(prefixIcon, color: AppColors.ink),
    suffixIcon: suffix,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}

String _formatDate(DateTime date) {
  const months = [
    'янв.',
    'февр.',
    'марта',
    'апр.',
    'мая',
    'июня',
    'июля',
    'авг.',
    'сент.',
    'окт.',
    'нояб.',
    'дек.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
