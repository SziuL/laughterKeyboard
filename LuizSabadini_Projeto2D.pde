import processing.sound.*;

float[] whiteKeyX;
float[] blackKeyX;
boolean[] whiteKeyActive;

SoundFile[] whiteKeySounds;
SoundFile blackSound;

SoundFile currentSound;

char[] interKeyCodes = {'C', 'D', 'E', 'F', 'G', 'A', 'B'};
String[] notesNames = {"(Dó)", "(Ré)", "(Mi)", "(Fá)", "(Sol)", "(Lá)", "(Si)"};

int NUMWHITEKEYS = 7;
int NUMBLACKKEYS = 5;

float whiteKeyWidth, whiteKeyHeight;
float blackKeyWidth, blackKeyHeight;

float buttonX, buttonY, buttonWidth, buttonHeight;
boolean keyboardIsOn = false;

void setup() {
    size(700, 600);
    
    whiteKeyWidth = width / NUMWHITEKEYS;
    whiteKeyHeight = height - 100;
    blackKeyWidth = whiteKeyWidth * 0.6;
    blackKeyHeight = whiteKeyHeight * 0.6;
    
    whiteKeyX = new float[NUMWHITEKEYS];
    blackKeyX = new float[NUMBLACKKEYS];
    whiteKeyActive = new boolean[NUMWHITEKEYS];
    whiteKeySounds = new SoundFile[NUMWHITEKEYS];
    
    for (int i = 0; i < NUMWHITEKEYS; i++) {
        whiteKeyX[i] = i * whiteKeyWidth;
        whiteKeyActive[i] = false;
        
        whiteKeySounds[i] = new SoundFile(this, "sound" + i + ".mp3");
    }
    
    int blackIndex = 0;
    for (int i = 0; i < NUMWHITEKEYS; i++) {
        if (i != 2 && i != 6) {
            blackKeyX[blackIndex++] = i * whiteKeyWidth + whiteKeyWidth - blackKeyWidth / 2;
        }
    }
    blackSound = new SoundFile(this, "bellSound.mp3");
    
    buttonWidth = 60;
    buttonHeight = 30;
    buttonX = width / 2 - 70;
    buttonY = height - 50;
}

void draw() {
    if (!keyboardIsOn)
        background(15);
    else
        background(30, 30, 60);
    
    //teclas brancas
    for (int i = 0; i < NUMWHITEKEYS; i++) {
        float x = whiteKeyX[i];
        if (whiteKeyActive[i] && keyboardIsOn) {
            fill(color(100, 0, 144));
        } else {
            fill(keyboardIsOn ? lerpColor(color(163, 24, 204), color(143, 4, 184), i / float(NUMWHITEKEYS - 1)) : color(43, 0, 44));
        }
        stroke(keyboardIsOn ? color(48, 66, 34) : color(10));
        strokeWeight(3);
        beginShape();
        vertex(x, 0);
        vertex(x + whiteKeyWidth, 0);
        vertex(x + whiteKeyWidth, whiteKeyHeight - 30);
        vertex(x + whiteKeyWidth / 2, whiteKeyHeight);
        vertex(x, whiteKeyHeight - 30);
        endShape(CLOSE);
        
        if (whiteKeyActive[i]) {
            fill(230, 30, 80);
            textSize(30);
            text(interKeyCodes[i], whiteKeyX[i] + (whiteKeyWidth / 2), whiteKeyHeight - 70);
            text(notesNames[i], whiteKeyX[i] + (whiteKeyWidth / 2), whiteKeyHeight - 30);
        }
    }
    
    //teclas pretas
    for (int i = 0; i < NUMBLACKKEYS; i++) {
        float x = blackKeyX[i];
        fill(keyboardIsOn ? lerpColor(color(48, 66, 34), color(70, 104, 22), i / float(NUMBLACKKEYS - 1)) : color(30));
        noStroke();
        quad(x, 0,
            x + blackKeyWidth, 0,
            x + blackKeyWidth - 10, blackKeyHeight,
            x + 10, blackKeyHeight);
    }
    
    // botão on
    fill(keyboardIsOn ? color(0, 200, 0) : color(255));
    rect(buttonX, buttonY, buttonWidth, buttonHeight, 10);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(20);
    text("ON", buttonX + buttonWidth / 2, buttonY + buttonHeight / 2);
    
    // botão off
    fill(keyboardIsOn ? color(255) : color(200, 0, 0));
    rect(buttonX + 80, buttonY, buttonWidth, buttonHeight, 10);
    fill(0);
    text("OFF", buttonX + 80 + buttonWidth / 2, buttonY + buttonHeight / 2);
    
    if (currentSound != null && !currentSound.isPlaying()) {
        for (int i = 0;i < NUMWHITEKEYS; i++)
            whiteKeyActive[i] = false;
    }
}

void keyPressed() {
    if (key == 'O' || key == 'o') {
        keyboardIsOn = !keyboardIsOn;
        if (currentSound != null)
            if (currentSound.isPlaying()) currentSound.stop();
    }
    
    if (keyboardIsOn) {
        if (key == 'A' || key == 'a') activateKey(0);
        else if (key == 'S' || key == 's') activateKey(1);
        else if (key == 'D' || key == 'd') activateKey(2);
        else if (key == 'F' || key == 'f') activateKey(3);
        else if (key == 'G' || key == 'g') activateKey(4);
        else if (key == 'H' || key == 'h') activateKey(5);
        else if (key == 'J' || key == 'j') activateKey(6);
    }
}

void activateKey(int index) {
    for (int i = 0; i < NUMWHITEKEYS; i++) {
        if (i != index)
            whiteKeyActive[i] = false;
        
    }
    
    whiteKeyActive[index] = true;
    playSound(index);
}

void mousePressed() {
    if (mouseButton == LEFT) {
        for (int i = 0; i < NUMBLACKKEYS; i++) {
            float x = blackKeyX[i];
            float[] vx = {x, x + blackKeyWidth, x + blackKeyWidth - 10, x + 10};
            float[] vy = {0, 0, blackKeyHeight, blackKeyHeight};
            
            if (pointInQuad(mouseX, mouseY, vx, vy) && keyboardIsOn) {
                for (int j = 0;j < NUMWHITEKEYS;j++)
                    whiteKeyActive[j] = false;
                playSound(10);
            }
        }
    }
}

boolean pointInQuad(float mouseX, float mouseY, float[] x, float[] y) {
    int intersections = 0;
    
    for (int i = 0; i < 4; i++) {
        int j = (i + 1) % 4;
        if (((y[i] > mouseY) != (y[j] > mouseY)) && 
           (mouseX < (x[j] - x[i]) * (mouseY - y[i]) / (y[j] - y[i]) + x[i])) {
            intersections++;
        }
    }
    return(intersections % 2 == 1);
}

void playSound(int index) {
    if (currentSound != null && currentSound.isPlaying())
        currentSound.stop();
    
    if (index == 10) {
        currentSound = blackSound;
    } else{
        currentSound = whiteKeySounds[index];
    }
    currentSound.play();
    
}
