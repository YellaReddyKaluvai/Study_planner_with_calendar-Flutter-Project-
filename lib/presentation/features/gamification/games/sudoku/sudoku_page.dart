import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  // Simple Easy Puzzle (0 represents empty)
  final List<List<int>> solvedGrid = [
    [5, 3, 4, 6, 7, 8, 9, 1, 2],
    [6, 7, 2, 1, 9, 5, 3, 4, 8],
    [1, 9, 8, 3, 4, 2, 5, 6, 7],
    [8, 5, 9, 7, 6, 1, 4, 2, 3],
    [4, 2, 6, 8, 5, 3, 7, 9, 1],
    [7, 1, 3, 9, 2, 4, 8, 5, 6],
    [9, 6, 1, 5, 3, 7, 2, 8, 4],
    [2, 8, 7, 4, 1, 9, 6, 3, 5],
    [3, 4, 5, 2, 8, 6, 1, 7, 9],
  ];

  List<List<int>> displayGrid = [];
  List<List<bool>> editableGrid = [];
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    // Create a copy for display with some missing numbers
    displayGrid = List.generate(9, (i) => List.from(solvedGrid[i]));
    editableGrid = List.generate(9, (i) => List.filled(9, false));

    // Remove some numbers to make it a puzzle
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if ((i + j) % 2 != 0) {
          // Removing roughly half checkerboard style for ease
          displayGrid[i][j] = 0;
          editableGrid[i][j] = true;
        }
      }
    }
    setState(() {});
  }

  void onNumberSelected(int number) {
    if (selectedRow != null && selectedCol != null) {
      if (editableGrid[selectedRow!][selectedCol!]) {
        setState(() {
          displayGrid[selectedRow!][selectedCol!] = number;
          checkWin();
        });
      }
    }
  }

  void checkWin() {
    bool isFull = true;
    bool isCorrect = true;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (displayGrid[i][j] == 0) isFull = false;
        if (displayGrid[i][j] != solvedGrid[i][j]) isCorrect = false;
      }
    }

    if (isFull && isCorrect) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text("Sudoku Master!"),
                content: const Text("You solved it!"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        resetGame();
                      },
                      child: const Text("Play Again"))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Sudoku"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetGame),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    int row = index ~/ 9;
                    int col = index % 9;
                    bool isSelected = row == selectedRow && col == selectedCol;
                    bool isEditable = editableGrid[row][col];
                    // Create thicker borders for 3x3 grids
                    BorderSide borderSide =
                        const BorderSide(color: Colors.white24, width: 0.5);
                    BorderSide thickBorder =
                        const BorderSide(color: Colors.white, width: 2.0);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRow = row;
                          selectedCol = col;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withOpacity(0.3)
                                : (isEditable
                                    ? Colors.transparent
                                    : Colors.white10),
                            border: Border(
                              top: row % 3 == 0 ? thickBorder : borderSide,
                              left: col % 3 == 0 ? thickBorder : borderSide,
                              // Add right/bottom borders for the edges
                              right: col == 8 ? thickBorder : BorderSide.none,
                              bottom: row == 8 ? thickBorder : BorderSide.none,
                            )),
                        alignment: Alignment.center,
                        child: Text(
                          displayGrid[row][col] == 0
                              ? ""
                              : "${displayGrid[row][col]}",
                          style: TextStyle(
                              color: isEditable
                                  ? (displayGrid[row][col] ==
                                          solvedGrid[row][col]
                                      ? Colors.greenAccent
                                      : Colors.redAccent)
                                  : Colors.white,
                              fontWeight: isEditable
                                  ? FontWeight.w400
                                  : FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Number Pad
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(9, (index) {
                  return GestureDetector(
                    onTap: () => onNumberSelected(index + 1),
                    child: Container(
                      width: 35,
                      height: 45,
                      decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24)),
                      alignment: Alignment.center,
                      child: Text("${index + 1}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18)),
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
