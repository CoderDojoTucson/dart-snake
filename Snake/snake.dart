import 'dart:html';
import 'dart:math';
import 'dart:collection';

const int CELL_SIZE = 10;

CanvasElement canvas;
CanvasRenderingContext2D ctx;
Keyboard keyboard = new Keyboard();

/**
 * A helper method to draw a 10x10 cell.
 * @param coords the upper left corner of the cell
 * @param color the color to use to fill the cell
 */
void drawCell(Point coords, String color) {
  ctx..fillStyle = color
    ..strokeStyle = "white";
  
  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;
  
  ctx..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}

/**
 * A method to clear the game area by overwriting the 
 * canvas with a white background.
 */
void clear() {
  ctx..fillStyle = "white"
    ..fillRect(0, 0, canvas.width, canvas.height);
}

/**
 * The main method for the game.
 */
void main() {
  canvas = querySelector('#canvas')..focus();
  ctx = canvas.getContext('2d');
  
  new Game()..run();
}

/**
 * A class to handle keyboard inputs for the game.
 */
class Keyboard {
  HashMap<int, int> _keys = new HashMap<int, int>();
  
  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      if (!_keys.containsKey(event.keyCode)) {
        _keys[event.keyCode] = event.timeStamp;
      }
    });
    
    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }
  
  bool isPressed(int keyCode) => _keys.containsKey(keyCode);
}

/**
 * A class to create and control the snake.
 */
class Snake {
  
  // Direction definitions for snake movement.
  static const Point LEFT = const Point(-1, 0);
  static const Point RIGHT = const Point(1, 0);
  static const Point UP = const Point(0, -1);
  static const Point DOWN = const Point(0, 1);
  
  // Starting size for the snake.
  static const int START_LENGTH = 6;
  
  // Coordinates for the body segments of the snake.
  List<Point> _body;
  
  // Current travel direction for the snake (right to start).
  Point _dir = RIGHT;
  
  /**
   * Constructor method for the snake.
   */
  Snake() {
    int i = START_LENGTH - 1;
    _body = new List<Point>.generate(START_LENGTH, 
      (int index) => new Point(i--, 0));
  }
  
  // Getter function to create the head property for the snake.
  Point get head => _body.first;
  
  /**
   * Check the keyboard input and change direction - 
   * as long as the requested direction isn't the opposite of 
   * the current direction (can't turn around on yourself).
   */
  void _checkInput() {
    if (keyboard.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
      _dir = LEFT;
    } else if (keyboard.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
      _dir = RIGHT;
    } else if (keyboard.isPressed(KeyCode.UP) && _dir != DOWN) {
      _dir = UP;
    } else if (keyboard.isPressed(KeyCode.DOWN) && _dir != UP) {
      _dir = DOWN;
    }
  }
  
  /**
   * Grow the snake by one cell.
   */
  void grow() {
    // Add a new head cell in the current direction.
    _body.insert(0, head + _dir);
  }
  
  /**
   * Move the snake in the current direction.
   */
  void _move() {
    // Add a new head segment in the current direction.
    grow();
    
    // Remove the tail segment (making the snake appear to move
    // in the current direction).
    _body.removeLast();
  }
  
  /**
   * Draw the snake on the screen. (Normally used at the beginning
   * of the game.)
   */
  void _draw() {
    // Draw each cell in the body, starting with the head.
    for (Point p in _body) {
      drawCell(p, "green");
    }
  }
  
  /**
   * Check to see if the head of the snake has collided with a 
   * body segment.
   * @returns true if the head has collided with a body segment
   */
  bool checkForBodyCollision() {
    for (Point p in _body.skip(1)) {
      if (p == head) {
        return true; // collision
      }
    }
    return false;  // no collision
  }
  
  /**
   * Method to update the snake's position.
   */
  void update() {
    _checkInput();
    _move();
    _draw();
  }
}

/**
 * The class that controls the execution of the game.
 */
class Game {
  
  // Set the delay between interations of the game loop (in ms).
  static const num GAME_SPEED = 50;
  
  // Track the last execution time for the game loop.
  num _lastTimeStamp = 0;
  
  // Variables to keep track of the canvas size. (Top and left are 0.)
  int _rightEdgeX;
  int _bottomEdgeY;
  
  // Member variables for the game elements.
  Snake _snake;
  Point _food;
  
  /**
   * Constructor for the Game class.
   */
  Game() {
    _rightEdgeX = canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = canvas.height ~/ CELL_SIZE;
    
    init();
  }
  
  /**
   * Initialize the game elements. 
   */
  void init() {
    _snake = new Snake();
    _food = _randomPoint();
  }
  
  /**
   * Generate a random point.
   * @returns the random point
   */
  Point _randomPoint() {
    Random random = new Random();
    return new Point(random.nextInt(_rightEdgeX),
                    random.nextInt(_bottomEdgeY));
  }
  
  /**
   * Check to see if the snake has collided with elements in
   * the game world. 
   */
  void _checkForCollisions() {
    // Check for collision with food.
    if (_snake.head == _food) {
      _snake.grow();
      _food = _randomPoint();
    }
    
    // Check for death conditions.
    if (_snake.head.x <= -1 ||
       _snake.head.x >= _rightEdgeX ||
       _snake.head.y <= -1 ||
       _snake.head.y >= _bottomEdgeY ||
       _snake.checkForBodyCollision()) {
      init();
    }
  }
  
  /**
   * Run the animation. 
   */
  void run() {
    window.animationFrame.then(update);
  }
  
  /**
   * Update the game state.
   */
  void update(num delta) {
    final num diff = delta - _lastTimeStamp;
    
    if (diff > GAME_SPEED) {
      _lastTimeStamp = delta;
      clear();
      drawCell(_food, "blue");
      _snake.update();
      _checkForCollisions();
    }
    
    // Keep looping
    run();
  }
}