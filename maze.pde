final int WIDTH = 61;
final int HEIGHT = 29;

final int DRAW_UNIT = 16;

final int MAZE_SIZE = 480;
final int MARGIN = 16;

final int PATH = 0;
final int WALL = 1;

boolean started;
boolean done;

void settings() {
  size(WIDTH * DRAW_UNIT, HEIGHT * DRAW_UNIT + MAZE_SIZE + MARGIN * 2);
}

int map[][];

ArrayList<Cell> startCells;

void setup() {
  noLoop();

  started = false;
  done = false;

  map = new int[WIDTH][HEIGHT];
}

int cur_x, cur_y;
Directions direction;

void draw() {
  background(0);

  noStroke();
  for (int y = 0; y < HEIGHT; y++) {
    for (int x = 0; x < WIDTH; x++) {
      int offset = 0;
      if (map[x][y] == PATH) {
        fill(0);
        rect(x * DRAW_UNIT, y * DRAW_UNIT, DRAW_UNIT, DRAW_UNIT);
      } else {
        fill(255);
        offset = 1;
      }
      rect(x * DRAW_UNIT + offset, y * DRAW_UNIT + offset, DRAW_UNIT - offset * 2, DRAW_UNIT - offset * 2);
    }
  }
  
  // Draw Player
  float cx = cur_x * DRAW_UNIT + DRAW_UNIT / 2;
  float cy = cur_y * DRAW_UNIT + DRAW_UNIT / 2;
 
  if (done) {
    stroke(128, 255, 255);
    noFill();
    line(cx, cy, cx + direction.x * (DRAW_UNIT / 2 - 2), cy + direction.y * (DRAW_UNIT / 2 - 2));  
    line(cx, cy, cx - direction.x * (DRAW_UNIT / 2 - 2), cy - direction.y * (DRAW_UNIT / 2 - 2));  
    line(cx + direction.x * (DRAW_UNIT / 2 - 2), cy + direction.y * (DRAW_UNIT / 2 - 2), cx + direction.y * (DRAW_UNIT / 2 - 2), cy + direction.x * (DRAW_UNIT / 2 - 2));  
    line(cx + direction.x * (DRAW_UNIT / 2 - 2), cy + direction.y * (DRAW_UNIT / 2 - 2), cx - direction.y * (DRAW_UNIT / 2 - 2), cy - direction.x * (DRAW_UNIT / 2 - 2));
    
    draw3dMaze();
  }
}

void draw3dMaze() {
  // Draw Maze
  noFill();
  stroke(255);
  int depth = 5;
  int om = HEIGHT * DRAW_UNIT + MARGIN; 
  int field_unit = MAZE_SIZE / (depth * 2 + 1);
  float left = 0;
  float top = 0;
  float w = MAZE_SIZE - 1;
  float h = MAZE_SIZE - 1;
  
  int mx = cur_x;
  int my = cur_y;
  
  for (int d = 0; d < depth; d++) {
    if (map[mx][my] == WALL) {
      line(left + MARGIN, top + om, left + w + MARGIN, top + om);
      line(left + MARGIN, top + om + h, left + w + MARGIN, top + om + h);
      break;
    }
    
    // Draw Wall
    Directions lw = direction.turnLeft();
    Directions rw = direction.turnRight();
    
    if (map[mx + lw.x][my + lw.y] == WALL) {
      line(left + MARGIN, top + om, left + MARGIN + field_unit, top + om + field_unit);
      line(left + MARGIN, top + om + w - 1, left + MARGIN + field_unit, top + om + w - 1 - field_unit);
      line(left + MARGIN + field_unit, top + om + field_unit, left + MARGIN + field_unit, top + om + w - 1 - field_unit);
    }
    else {
      line(left + MARGIN, top + om + field_unit, left + MARGIN + field_unit, top + om + field_unit);
      line(left + MARGIN, top + om + w - 1 - field_unit, left + MARGIN + field_unit, top + om + w - 1 - field_unit);
      line(left + MARGIN + field_unit, top + om + field_unit, left + MARGIN + field_unit, top + om + w - 1 - field_unit);
    }
    
    if (map[mx + rw.x][my + rw.y] == WALL) {
      line(left + w + MARGIN - 1, top + om, left + w + MARGIN - field_unit - 1, top + om + field_unit);
      line(left + w + MARGIN - 1, top + om + w - 1, left + w + MARGIN - field_unit, top + om + w - 1 - field_unit);
      line(left + w + MARGIN - field_unit - 1, top + om + field_unit, left + w + MARGIN - field_unit - 1, top + om + w - 1 - field_unit);
    }
    else {
      line(left + w + MARGIN - 1, top + om + field_unit, left + w + MARGIN - field_unit - 1, top + om + field_unit);
      line(left + w + MARGIN - 1, top + om + w - 1 - field_unit, left + w + MARGIN - field_unit, top + om + w - 1 - field_unit);
      line(left + w + MARGIN - field_unit - 1, top + om + field_unit, left + w + MARGIN - field_unit - 1, top + om + w - 1 - field_unit);
    }

    mx += direction.x;
    my += direction.y;
    
    left += field_unit;
    top += field_unit;
    w -= field_unit * 2;
    h -= field_unit * 2;
  }
}

void mousePressed() {
  if (!started) {
    started = true;
    done = false;

    for (int y = 0; y < HEIGHT; y++) {
      for (int x = 0; x < WIDTH; x++) {
        if (x == 0 || y == 0 || x == WIDTH - 1 || y == HEIGHT - 1) {
          map[x][y] = PATH;
        } else {
          map[x][y] = WALL;
        }
      }
    }

    startCells = new ArrayList<Cell>();

    dig(1, 1);

    for (int x = 0; x < WIDTH; x++) {
      map[x][0] = WALL;
      map[x][HEIGHT - 1] = WALL;
    }

    for (int y = 0; y < HEIGHT; y++) {
      map[0][y] = WALL;
      map[WIDTH - 1][y] = WALL;
    }
    redraw();
  }

  println("done");
  
  done = true;
  started = false;
  cur_x = 1;
  cur_y = 1;
  direction = Directions.Right;
  
  redraw();
}

void keyPressed() {
  if (keyCode == LEFT) {
    direction = direction.turnLeft();
  }
  else if (keyCode == RIGHT) {
    direction = direction.turnRight();
  }
  else if (keyCode == UP) {
    // step forward
    if (map[cur_x + direction.x][cur_y + direction.y] == PATH) {
      cur_x += direction.x;
      cur_y += direction.y;
    }
  }
  else if (keyCode == DOWN) {
    // backward
    if (map[cur_x - direction.x][cur_y - direction.y] == PATH) {
      cur_x -= direction.x;
      cur_y -= direction.y;
    }
  }
  
  redraw();
}

void dig(int x, int y) {
  map[x][y] = PATH;

  while (true) {
    ArrayList<Cell> directions = new ArrayList<Cell>();
    for (int x1 = -1; x1 < 2; x1++) {
      for (int y1 = -1; y1 < 2; y1++) {
        if (x1 * y1 == 0 && x1 + y1 != 0) {
          if (checkDirection(x, y, x1, y1)) {
            directions.add(new Cell(x1, y1));
          }
        }
      }
    }

    if (directions.size() == 0) {
      break;
    }

    int index = int(random(directions.size()));
    Cell dir = directions.get(index);
    
    if (x == 1 && y == 1) {
      println("first", dir.x, dir.y);
    }


    map[x + dir.x][y + dir.y] = PATH;
    map[x + dir.x * 2][y + dir.y * 2] = PATH;

    startCells.add(new Cell(x + dir.x * 2, y + dir.y * 2));

    redraw();

    x = x + dir.x * 2;
    y = y + dir.y * 2;
  }

  if (startCells.size() > 0) {
    int newCellIndex = int(random(startCells.size()));
    Cell cell = startCells.get(newCellIndex);
    startCells.remove(newCellIndex);
    dig(cell.x, cell.y);
  }
}

boolean checkDirection(int x, int y, int x1, int y1) {
  return (map[x + x1][y + y1] == WALL && map[x + x1 * 2][y + y1 * 2] == WALL);
}

class Cell {
  public int x;
  public int y;

  public Cell(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

enum Directions {
  Left(-1, 0),
  Right(1, 0),
  Up(0, -1),
  Down(0, 1);
  
  int x, y;
  
  private Directions(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  private Directions find(int x, int y) {
    for (Directions dir: Directions.values()) {
      if (dir.x == x && dir.y == y) {
        return dir;
      }
    }
    
    return null;
  }
  
  public Directions turnLeft() {
    int nx = this.y;
    int ny = -this.x;
    
    return find(nx, ny);
  }
  
  public Directions turnRight() {
    int nx = -this.y;
    int ny = this.x;
    
    return find(nx, ny);
  }
}
