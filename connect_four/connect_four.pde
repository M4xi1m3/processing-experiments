/**
 * Puissance 4.
 *
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 * @version 1.0.0
 */

/**
 * Stores constants used accross the game.
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

/**
 * Stores different color used in the game.
 */
enum Color {
    BACKGROUND(0xFF000000),
    TEXT(0xFFFFFFFF),
    
    BUTTON_BG(0xFF444444),
    BUTTON_FG(0xFFFFFFFF),
    BUTTON_HOVER_BG(0xFFFFFFFF),
    BUTTON_HOVER_FG(0xFF444444),
    
    ARROW(0xFFFFFFFF),
    BOARD(0xFF0000FF),
    CHIP1(0xFFFF0000),
    CHIP2(0xFFFFFF00);
    
    private int number = 0;
    
    /**
     * Creates a color
     *
     * @param number    The int value of the color, as ARGB.
     */
    Color(int number) {
        this.number = number;
    }
    
    /**
     * Get the int value of a color
     *
     * @return      The value of the color.
     */
    int getColor() {
        return this.number;
    }
};

/**
 * Stores the board.
 */
class Board {
    // List of the chips in the board.
    Chip[][] chips_list;
    
    /**
     * Init the board.
     *
     * We create the chips array and fill it with null.
     */
    Board() {
        chips_list = new Chip[Constants.BOARD_WIDTH][Constants.BOARD_HEIGHT];
        
        for(int i = 0; i < chips_list.length; i++) {
            for(int j = 0; j < chips_list[i].length; j++) {
                chips_list[i][j] = null;
            }
        }
    }
    
    /**
     * Get the vertical space avalible a position x
     *
     * @param   x       The horizontal position to get avaliable space from
     *
     * @]return     Avaliable horizontal space at position x.
     */
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
    
    /**
     * Draws the board.
     */
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
    
    /**
     * Recusive function to check win at position (x;y)
     *
     *  @param  x       X position to start from
     *  @param  y       Y position to start from
     *
     *  @return     Wether or not there is a win.
     */
    boolean checkWin(int x, int y) {
        return this.checkWin(x, y, 0, 0, 0, null);
    }
    
    /**
     * Recusive function to check win.
     *
     * If dx == dy == 0, we go in all 8 directions.
     *
     * @param   x       X position to start from
     * @param   y       Y position to start from
     * @param   dx      Direction X to go
     * @param   dy      Direction Y to go
     * @param   count   Current number of alligned chips
     * @param   owner   Owner to check from
     *
     * @return      Wether or not there is a win.
     */
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

/**
 * Represents the select arrow overing over the board.
 */
class SelectArrow {
    int position;
    boolean display;
    Board board;
    
    /**
     * Init the arrow.
     *
     * @param   board       The board.
     */
    SelectArrow(Board board) {
        this.position = 1;
        this.display = true;
        this.board = board;
    }
    
    /**
     * Draws the arrow
     */
    void draw() {
        if (this.display) {
            fill(Color.ARROW.getColor());
            int x = Constants.BOARD_MARGIN_X + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * position + Constants.CHIP_SPACING;
            triangle(x, Constants.BOARD_MARGIN_Y - 22, x + Constants.CHIP_SIZE, Constants.BOARD_MARGIN_Y - 22, x + Constants.CHIP_SIZE / 2, Constants.BOARD_MARGIN_Y - 2);
        }
    }
    
    /**
     * Method called when the mouse if moved.
     *
     * @param   mouseX      X position of the mouse.
     */
    void mouseMoved(int mouseX) {
        if (mouseX > Constants.BOARD_MARGIN_X && mouseX < Constants.BOARD_PIX_WIDTH + Constants.BOARD_MARGIN_X - Constants.CHIP_SPACING) {
            this.display = true;
            
            this.position = (int) (mouseX - Constants.BOARD_MARGIN_X) / (Constants.CHIP_SIZE + Constants.CHIP_SPACING);
        } else {
            this.display = false;
        }
    }
    
    /**
     * Method called when the mouse is clicked.
     *
     * @param   mouseX      X position of the mouse.
     * @param   game        Game object.
     */
    void mouseClicked(int mouseX, Game game) {
        if (this.display) {
            int y = board.getAvaliableSpace(this.position);
            
            if (y != -1) {
                board.chips_list[this.position][y] = new Chip(this.position, y, game.current);
                
                if (board.checkWin(this.position, y)) {
                    game.sm.swap(new MainMenu("GGWP " + game.current.name + "!"));
                }
                
                game.switchPlayer();
            }
        }
    }
}

/**
 * Represent a chip.
 */
class Chip {
    int x, y;
    Player owner;

    /**
     * Inits the chip.
     *
     * @param   x       X position
     * @param   y       Y position
     * @param   owner   Owner of the chip
     */
    Chip(int x, int y, Player owner) {
        this.x = x;
        this.y = y;
        this.owner = owner;
    }
    
    /**
     * Draws the chip.
     */
    void draw() {
        int i = Constants.BOARD_MARGIN_X + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (this.x + 1) - Constants.CHIP_SIZE/2;
        int j = Constants.BOARD_MARGIN_Y + (Constants.CHIP_SIZE + Constants.CHIP_SPACING) * (this.y + 1) - Constants.CHIP_SIZE/2;
    
        fill(owner.chip_color.getColor());
        circle(i, j, Constants.CHIP_SIZE);
    }
}

/**
 * Represents a player
 */
class Player {
    Color chip_color;
    String name;
    
    /**
     * Init the player.
     *
     * @param   chip_color  Color of the player
     * @param   name        Name of the player
     */
    Player(Color chip_color, String name) {
        this.chip_color = chip_color;
        this.name = name;
    }
}

/**
 * Represents a scene.
 */
interface Scene {
    /**
     * Init the scene
     *
     * @param   sm      The scene manager
     */
    void init(SceneManager sm);
    
    /**
     * Un-init the scene
     *
     * @param   sm      The scene manager
     */
    void deinit(SceneManager sm);
    
    /**
     * Draws the scene
     */
    void draw();
    
    /**
     * Handle mouse moved on the scene
     *
     * @param   x       Mouse X position
     * @param   y       Mouse Y position
     */
    void mouseMoved(int x, int y);
    
    /**
     * Handle mouse clicks on the scene
     *
     * @param   x       Mouse X position
     * @param   y       Mouse Y position
     */
    void mouseClicked(int x, int y);
}

/**
 * Handle the differents scenes.
 */
class SceneManager {
    Scene current = null;

    /**
     * Constructor.
     *
     * @param   first       First scene to display.
     */
    SceneManager(Scene first) {
        current = first;
        current.init(this);
    }
    
    /**
     * Un-init the current scene, init the newScene, and set it as current
     *
     * @param newScene      The nes scene to display.
     */
    void swap(Scene newScene) {
        if (current != null) {
            current.deinit(this);
        }
        
        current = newScene;
        current.init(this);
    }
    
    /**
     * Drwas the current scene.
     */
    void draw() {
        if (current != null) {
            current.draw();
        }
    }
    
    /**
     * Handle mouse moving.
     *
     * @param   x       Mouse X position
     * @param   y       Mouse Y position
     */
    void mouseMoved(int x, int y) {
        if (current != null) {
            current.mouseMoved(x, y);
        }
    }
    
    /**
     * Handle mouse clicking.
     *
     * @param   x       Mouse X position
     * @param   y       Mouse Y position
     */
    void mouseClicked(int x, int y) {
        if (current != null) {
            current.mouseClicked(x, y);
        }
    }
}

/**
 * The game
 */
class Game implements Scene {
    Board board;
    SelectArrow arrow;
    SceneManager sm;

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
    
    @Override
    void init(SceneManager sm) {
        this.sm = sm;
        board = new Board();
        arrow = new SelectArrow(board);
        p1 = new Player(Color.CHIP1, "Rouge");
        p2 = new Player(Color.CHIP2, "Jaune");
        current = p1;
        
        noStroke();
    }
    
    @Override
    void deinit(SceneManager sm) {
        
    }
    
    @Override
    void draw() {
        background(Color.BACKGROUND.getColor());

        board.draw();
        arrow.draw();
    }
    
    @Override
    void mouseMoved(int x, int y) {
        arrow.mouseMoved(x);
    }
    
    @Override
    void mouseClicked(int x, int y) {
        arrow.mouseClicked(y, this);
    }
}

/**
 * Main menu of the game.
 */
class MainMenu implements Scene {
    SceneManager sm;
    boolean hover_play = false;
    String message = "";
    
    MainMenu(String message) {
        this.message = message;
    }
    
    MainMenu() {
        
    }
    
    @Override
    void init(SceneManager sm) {
        this.sm = sm;
    }
    
    @Override
    void deinit(SceneManager sm) {
        
    }
    
    @Override
    void draw() {
        background(0);
        textSize(32);
        textAlign(CENTER);
        fill(Color.TEXT.getColor());
        text("Puissance Quatre", Constants.SCREEN_WIDTH/2, 50);
        text(message, Constants.SCREEN_WIDTH/2, 100);
        
        
        if (hover_play) {
            fill(Color.BUTTON_HOVER_BG.getColor());
            rect(Constants.SCREEN_WIDTH/2 - 50, Constants.SCREEN_HEIGHT/2 - 20, 100, 40);
            fill(Color.BUTTON_HOVER_FG.getColor());
            text("Play", Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2 + 10);
        } else {
            fill(Color.BUTTON_BG.getColor());
            rect(Constants.SCREEN_WIDTH/2 - 50, Constants.SCREEN_HEIGHT/2 - 20, 100, 40);
            fill(Color.BUTTON_FG.getColor());
            text("Play", Constants.SCREEN_WIDTH/2, Constants.SCREEN_HEIGHT/2 + 10);
        }
    }
    
    @Override
    void mouseMoved(int x, int y) {
        hover_play = x >= Constants.SCREEN_WIDTH/2 - 50  && x <= Constants.SCREEN_WIDTH/2 + 50 &&
                     y >= Constants.SCREEN_HEIGHT/2 - 20 && y <= Constants.SCREEN_HEIGHT/2 + 20;
    }
    
    @Override
    void mouseClicked(int x, int y) {
        if (hover_play) {
            sm.swap(new Game());
        }
    }
}

// Processing-specific stuff, pass events to the Game class.
SceneManager sm;

void setup() {
    size(800, 600);
    surface.setSize(Constants.SCREEN_WIDTH, Constants.SCREEN_HEIGHT);
    
    sm = new SceneManager(new MainMenu());
}

void draw() {
    sm.draw();
}

void mouseMoved() {
    sm.mouseMoved(mouseX, mouseY);
}

void mouseClicked() {
    sm.mouseClicked(mouseX, mouseY);
}

