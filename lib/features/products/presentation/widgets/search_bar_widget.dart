/// ویجت نوار جستجو
/// جستجوی لحظه‌ای (Realtime) بر اساس نام، بارکد و کد محصول
/// طراحی Glassmorphism با افکت نئون
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_manager.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final Function(String) onChanged;
  final Function(bool)? onSearchActive;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onSearchActive,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      widget.onSearchActive?.call(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      height: 52,
      decoration: BoxDecoration(
        // افکت Glassmorphism
        color: themeManager.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? themeManager.neonColor.withOpacity(0.6)
              : Colors.white.withOpacity(0.1),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: themeManager.neonColor.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // آیکون جستجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search_rounded,
              color: _isFocused
                  ? themeManager.neonColor
                  : Colors.white.withOpacity(0.4),
              size: 22,
            ),
          ),

          // فیلد ورودی
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'جستجو با نام، بارکد یا کد محصول...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          // دکمه پاک کردن
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.5),
                size: 20,
              ),
            ),

          // دکمه اسکن بارکد
          IconButton(
            onPressed: () {
              // TODO: باز کردن صفحه اسکنر بارکد
            },
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: themeManager.neonColor.withOpacity(0.8),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
