/**
 * Mini proejt ISN - 2019-2020
 * @author Maxime "M4x1m3" FRIESS
 * @license WTFPL v2
 */

PImage image;
PVector start, end;

/**
 * Début du programme
 * 
 * Chargement de l'image, initialisation de la fenêtre.
 */
void setup() {
    size(10, 10);
    image = loadImage("Paris.png");
    background(0);
  
    start = new PVector();
    end = new PVector();

    /* 
     * "Hack" pour avoir une taille de fenêtre dynamique
     * utilisant l'object surface (type PSurface) défini
     * dans la classe processing.core.PApplet, classe mère
     * de ce projet.
     */
    surface.setSize(image.width * 2, image.height);
}

/**
 * Boucle principale
 *
 * On affiche l'image et le rectangle de sélection.
 */
void draw() {
    image(image, 0, 0);
    fill(0, 64);
    
    /*
     * La fonction rect accepte les largeurs et hauteurs
     * négatives. Cepandant, cette usage de la fonction
     * n'est pas décrit dans la doc (edge-case) et peut
     * surement changer d'une version à l'autre.
     */
    rect(min(start.x, end.x), min(start.y, end.y), abs(end.x - start.x), abs(end.y - start.y));
}

/**
 * Restreind val entre min et max
 *
 * @param min  valeur minimale.
 * @param max  valeur maximale.
 * @param val  valeur à resterindre.
 *
 * @return val compris entre min et max.
 */
float cap(float min, float val, float max) {
    return min(max, max(min, val));
}

/**
 * Handler click enfoncé.
 *
 * On stoque la position du pointeur dans start et end
 * et on réinitialise la partie de droite de la fenêtre.
 */
void mousePressed() {
    start.x = cap(0, mouseX, image.width);
    start.y = cap(0, mouseY, image.height);
    end.x = start.x;
    end.y = start.y;
    fill(0);
    rect(image.width, 0, image.width, image.height);
}

/**
 * Handler souris déplacé click maintenu.
 * 
 * On stoque la position du pointeur dans end.
 */
void mouseDragged() {
    end.x = cap(0, mouseX, image.width);
    end.y = cap(0, mouseY, image.height);
}

/**
 * Handler click relaché.
 *
 * On calcule la taille de l'image de droite,
 * on l'extrait de l'image principale et on l'affiche.
 */
void mouseReleased() {
    // PVector est composé de floats, obligé de cast.
    int subWidth = (int) abs(end.x - start.x);
    int subHeight = (int) abs(end.y - start.y);
    
    PImage subImage = image.get((int) min(start.x, end.x), (int) min(start.y, end.y), subWidth, subHeight);
    image(subImage, image.width + (image.width - subWidth) / 2, (image.height - subHeight) / 2);
}
