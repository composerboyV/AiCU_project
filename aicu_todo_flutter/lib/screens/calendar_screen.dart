import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<Todo> _getEventsForDay(DateTime day, List<Todo> todos) {
    return todos.where((todo) {
      if (todo.dueDate == null) return false;
      return isSameDay(todo.dueDate!, day);
    }).toList();
  }

  Color _getCategoryColor(TodoCategory category) {
    switch (category) {
      case TodoCategory.DAILY:
        return Colors.green;
      case TodoCategory.WEEKLY:
        return Colors.orange;
      case TodoCategory.MONTHLY:
        return Colors.purple;
    }
  }

  String _getCategoryDisplayName(TodoCategory category) {
    switch (category) {
      case TodoCategory.DAILY:
        return '매일';
      case TodoCategory.WEEKLY:
        return '주간';
      case TodoCategory.MONTHLY:
        return '월간';
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '달력 보기',
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 달력
          TableCalendar<Todo>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(day, todoState.todos),
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: GoogleFonts.crimsonText(color: Colors.red[400]),
              holidayTextStyle: GoogleFonts.crimsonText(color: Colors.red[400]),
              defaultTextStyle: GoogleFonts.crimsonText(),
              selectedTextStyle: GoogleFonts.crimsonText(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: GoogleFonts.crimsonText(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.crimsonText(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left),
              rightChevronIcon: const Icon(Icons.chevron_right),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: GoogleFonts.crimsonText(color: Colors.red[400]),
              weekdayStyle: GoogleFonts.crimsonText(),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const Divider(),
          // 선택된 날짜의 할 일 목록
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('날짜를 선택해주세요'),
                  )
                : _buildTodoListForDay(_selectedDay!, todoState.todos),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoListForDay(DateTime selectedDay, List<Todo> allTodos) {
    final todosForDay = _getEventsForDay(selectedDay, allTodos);
    final dateString = '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '$dateString의 할 일',
            style: GoogleFonts.crimsonText(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: todosForDay.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_note, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        '이 날에 예정된 할 일이 없습니다',
                        style: GoogleFonts.crimsonText(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: todosForDay.length,
                  itemBuilder: (context, index) {
                    final todo = todosForDay[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(todo.category),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              todo.done ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: todo.done ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                        title: Text(
                          todo.title,
                          style: GoogleFonts.crimsonText(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: todo.done ? TextDecoration.lineThrough : null,
                            color: todo.done ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(todo.category).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getCategoryColor(todo.category),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getCategoryDisplayName(todo.category),
                                style: GoogleFonts.crimsonText(
                                  fontSize: 12,
                                  color: _getCategoryColor(todo.category),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (todo.category == TodoCategory.WEEKLY || todo.category == TodoCategory.MONTHLY)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 40,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(todo.category),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                          ],
                        ),
                        trailing: todo.done
                            ? const Icon(Icons.done, color: Colors.green)
                            : todo.dueDate!.isBefore(DateTime.now())
                                ? const Icon(Icons.warning, color: Colors.red)
                                : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}