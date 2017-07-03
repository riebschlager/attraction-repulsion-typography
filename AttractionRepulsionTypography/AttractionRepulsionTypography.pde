import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import geomerative.*;

VerletPhysics2D physics;
ArrayList<Attractor> attractors = new ArrayList<Attractor>();
PImage src;
PGraphics canvas;
PImage background;
Vec2D mousePos;
RPoint[] points;
RShape grp;
boolean isSpawning;

void setup() {
  size(1920, 1080);
  canvas = createGraphics(1920, 1080);
  canvas.beginDraw();
  canvas.endDraw();
  background = loadImage("data/img/background.png");
  if (background.width != width || background.height != height) background.resize(width, height);
  src = loadImage("data/img/foreground.jpg");
  src.loadPixels();
  physics = new VerletPhysics2D();
  physics.setDrag(0.975f);
  RG.init(this);
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(1);
  grp = RG.getText("816", "font/Aldrich-Regular.ttf", 200, CENTER);
  grp.centerIn(g, 60);
  grp.translate(width / 2, height / 2);
  points = grp.getPoints();
  isSpawning = true;
}

void draw() {
  background(background);
  while (physics.particles.size () < 1000 && isSpawning) {
    int r = floor(random(points.length));
    addParticle(points[r].x, points[r].y);
  }
  canvas.beginDraw();
  physics.update();
  for (int i = physics.particles.size() - 1; i >= 0; i--) {
    Particle p = (Particle) physics.particles.get(i);
    p.tick();
    p.render(canvas);
    if (p.age > p.lifetime) physics.removeParticle(p);
  }
  canvas.endDraw();
  image(canvas, 0, 0, width, height);
  for (int i = 0; i < attractors.size(); i++) {
    Attractor a = attractors.get(i);
    a.tick();
    a.render(g);
  }
  //saveFrameForVideo();
}

void addParticle(float _x, float _y) {
  noiseDetail(8);
  Particle p = new Particle(_x, _y);
  p.maxRadius = random(1, 10);
  if (random(1) > 0.9) p.maxRadius = random(50, 100);
  p.lifetime = random(150, 500);
  if (random(1) > 0.9) p.lifetime = random(500, 2000);
  p.pixel1 = src.pixels[floor(random(src.pixels.length - 1))];
  p.pixel2 = src.pixels[floor(random(src.pixels.length - 1))];
  physics.addParticle(p);
}

void addAttractor(float _x, float _y, int _behavior, boolean _isStatic) {
  Attractor a = new Attractor(new Vec2D(_x, _y), width / 4, 0, 0, _behavior, _isStatic);
  physics.addBehavior(a);
  attractors.add(a);
}

void saveFrameForVideo() {
  String fileName = nf(frameCount, 5) + ".tif";
  saveFrame("data/video/" + fileName);
}

void keyPressed() {
  if (key == 'i' || key == 'I') isSpawning = !isSpawning;
  if (key == 'a' || key == 'A') addAttractor(0, 0, 1, false);
  if (key == 'r' || key == 'R') addAttractor(0, 0, -1, false);
  if (key == 'c' || key == 'C') {
    canvas.beginDraw();
    canvas.clear();
    canvas.endDraw();
    physics.clear();
    attractors.clear();
  }
  if (key == ' ') attractors.clear();
  if (key == 'q') physics.clear();
  if (key == 's' || key == 'S') {
    PGraphics img = createGraphics(canvas.width, canvas.height);
    img.beginDraw();
    img.image(background, 0, 0, canvas.width, canvas.height);
    img.image(canvas, 0, 0);
    img.endDraw();
    img.save("data/output/composition-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".tif");
  }
}