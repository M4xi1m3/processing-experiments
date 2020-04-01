/**
 * Puissance 4.
 *
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 * @version 1.0.0
 */

class Constants {
    static final int BOARD_WIDTH  = 7;
    static final int BOARD_HEIGHT = 6;
    
    static final int SCREEN_WIDTH  = 800;
    static final int SCREEN_HEIGHT = 600;
    
    static final int CHIP_SIZE    = 30;
    static final int CHIP_SPACING = 5;
    
    static final int CONNECT_NUMBER = 4;
    
    static final int BOARD_PIX_WIDTH  = (CHIP_SIZE + CHIP_SPACING) * BOARD_WIDTH  + CHIP_SPACING;
    static final int BOARD_PIX_HEIGHT = (CHIP_SIZE + CHIP_SPACING) * BOARD_HEIGHT + CHIP_SPACING;
    
    static final int BOARD_MARGIN_X = (SCREEN_WIDTH  - BOARD_PIX_WIDTH)  / 2;
    static final int BOARD_MARGIN_Y = (SCREEN_HEIGHT - BOARD_PIX_HEIGHT) / 2;
}

enum Color {
    BACKGROUND(0xFF000000),
    ARROW(0xFFFFFFFF),
    BOARD(0xFF0000FF),
    CHIP1(0xFFFF0000),
    CHIP2(0xFFFFFF00);
    
    private int number = 0;
    
    Color(int number) {
        this.number = number;
    }
    
    int getColor() {
        return this.number;
    }
};

class Board {
    Chip[][] chips_list;
    
    Board() {
        chips_list = new Chip[Constants.BOARD_WIDTH][Constants.BOARD_HEIGHT];
        
        for(int i = 0; i < chips_list.length; i++) {
            for(int j = 0; j < chips_list[i].length; j++) {
                chips_list[i][j] = null;
            }
        }
    }
    
    int getAvaliableSpace(int x) {
        if (x >= 0 && x < chips_list.length) {
            Chip[] arr = chips_list[x];
            
            int available;
            for(available = 0; available < arr.length && arr[available] == null; available++);
            return available - 1;
        } else {
            return 0;
        }
    }
    
    void draw() {
        fill(Color.BOARD.getColor());
        rect(Constants.BOARD_MARGIN_X, Constants.BOARD_MARGIN_Y, Constants.BOARD_PIX_WIDTH, Constants.BOARD_PIX_HEIGHT);
    
        fill(Color.BACKGROUND.getColor());
        for(int i = 0; i < chips_list.length; i++) {
            for(int j = 0; j < chips_list[i].length; j++) {
                int x = Constants.BOARD_MARGIN_X + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (i + 1) - Constants.CHIP_SIZE/2;
                int y = Constants.BOARD_MARGIN_Y + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (j + 1) - Constants.CHIP_SIZE/2;
            
                circle(x, y, Constants.CHIP_SIZE);
            }
        }
        
        
        for(int i = 0; i < chips_list.length; i++) {
            for(int j = 0; j < chips_list[i].length; j++) {
                if (chips_list[i][j] != null) {
                    chips_list[i][j].draw();
                }
            }
        }
    }
    
    boolean checkWin(int x, int y) {
        return this.checkWin(x, y, 0, 0, 0, null);
    }
    
    boolean checkWin(int x, int y, int dx, int dy, int count, Player owner) {
        if (x < 0 || x >= chips_list.length) {
            return false;
        } else {
            if (y < 0 || y >= chips_list[x].length) {
                return false;
            }
        }
        
        if (count == Constants.CONNECT_NUMBER - 1) {
            return true;
        }
        
        Chip c = chips_list[x][y];
        if (c == null) {
            return false;
        }
        
        if (dx == 0 && dy == 0) {
            boolean isWon = false;
            
            for(int i = -1; i <= 1; i++) {
                for(int j = -1; j <= 1; j++) {
                    if (i == 0 && j == 0)
                        continue;
                    isWon |= checkWin(x, y, i, j, 0, c.owner);
                }
            }
            
            return isWon;
        } else {
            if (x + dx < 0 || x + dx >= chips_list.length) {
                return false;
            } else {
                if (y + dy < 0 || y + dy >= chips_list[x].length) {
                    return false;
                }
            }
            
            Chip c1 = chips_list[x + dx][y + dy];
            
            if (c1 == null) return false;
            
            if (owner == c1.owner) {
                return checkWin(x + dx, y + dy, dx, dy, count + 1, owner);
            } else {
                return false;
            }
        }
    }
}

class SelectArrow {
    int position;
    boolean display;
    Board board;
    
    SelectArrow(Board board) {
        this.position = 1;
        this.display = true;
        this.board = board;
    }
    
    void draw() {
        if (this.display) {
            fill(Color.ARROW.getColor());
            int x = Constants.BOARD_MARGIN_X + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * position + Constants.CHIP_SPACING;
            triangle(x, Constants.BOARD_MARGIN_Y - 22, x + Constants.CHIP_SIZE, Constants.BOARD_MARGIN_Y - 22, x + Constants.CHIP_SIZE / 2, Constants.BOARD_MARGIN_Y - 2);
        }
    }
    
    void mouseMoved(int mouseX) {
        if (mouseX > Constants.BOARD_MARGIN_X && mouseX < Constants.BOARD_PIX_WIDTH + Constants.BOARD_MARGIN_X - Constants.CHIP_SPACING) {
            this.display = true;
            
            this.position = (int) (mouseX - Constants.BOARD_MARGIN_X) / (Constants.CHIP_SIZE + Constants.CHIP_SPACING);
        } else {
            this.display = false;
        }
    }
    
    void mouseClicked(int mouseX, Game game) {
        if (this.display) {
            int y = board.getAvaliableSpace(this.position);
            
            if (y != -1) {
                board.chips_list[this.position][y] = new Chip(this.position, y, game.current);
                
                if (board.checkWin(this.position, y)) {
                    println("GGWP!");
                }
                
                game.switchPlayer();
            }
        }
    }
}

class Chip {
    int x, y;
    Player owner;

    Chip(int x, int y, Player owner) {
        this.x = x;
        this.y = y;
        this.owner = owner;
    }
    
    void draw() {
        int i = Constants.BOARD_MARGIN_X + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (this.x + 1) - Constants.CHIP_SIZE/2;
        int j = Constants.BOARD_MARGIN_Y + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (this.y + 1) - Constants.CHIP_SIZE/2;
    
        fill(owner.chip_color.getColor());
        circle(i, j, Constants.CHIP_SIZE);
    }
}

class Player {
    Color chip_color;
    String name;
    
    Player(Color chip_color, String name) {
        this.chip_color = chip_color;
        this.name = name;
    }
}

class Game {
    Board board;
    SelectArrow arrow;

    Player p1;
    Player p2;

    Player current;
    
    Game() {
        
    }
    
    void switchPlayer() {
        if (current == p1) {
            current = p2;
        } else {
            current = p1;
        }
    }
    
    void setup() {
        board = new Board();
        arrow = new SelectArrow(board);
        p1 = new Player(Color.CHIP1, "Rouge");
        p2 = new Player(Color.CHIP2, "Jaune");
        current = p1;
        
        noStroke();
    }
    
    void draw() {
        background(Color.BACKGROUND.getColor());

        board.draw();
        arrow.draw();
    }
    
    void mouseMoved(int mouseX) {
        arrow.mouseMoved(mouseX);
    }
    
    void mouseClicked(int mouseX) {
        arrow.mouseClicked(mouseX, this);
    }
}


// Processing-specific stuff, pass events to the Game class.
Game g;

void setup() {
    g = new Game();
    
    size(800, 600);
    surface.setSize(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
    
    g.setup();
}

void draw() {
    g.draw();
}

void mouseMoved() {
    g.mouseMoved(mouseX);
}

void mouseClicked() {
    g.mouseClicked(mouseX);
}

