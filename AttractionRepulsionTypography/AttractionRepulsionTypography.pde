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

void setup() {
  canvas = createGraphics(1920, 1080);
  canvas.beginDraw();
  canvas.endDraw();
  size(floor(canvas.width / 2), floor(canvas.height / 2));
  background = loadImage("data/img/background.png");
  if (background.width != width || background.height != height) background.resize(width, height);
  src = loadImage("http://dribbble.s3.amazonaws.com/users/244051/screenshots/1221572/dribbble1_1x.jpg");
  src.loadPixels();
  physics = new VerletPhysics2D();
  physics.setDrag(0.9f);
  RG.init(this);
  RG.setPolygonizer(RG.UNIFORMLENGTH);
  RG.setPolygonizerLength(3);
  grp = RG.getText("===", "font/SourceCodePro-Light.ttf", 200, CENTER);
  grp.centerIn(g, 50);
  grp.translate(width / 2, height / 2);
  points = grp.getPoints();
}

void draw() {
  for (int i = 0; i < 20; i++) {
    int r = floor(random(points.length));
    addParticle(points[r].x, points[r].y);
  }
  background(background);
  render();
  image(canvas, 0, 0, width, height);
  for (int i = 0; i < attractors.size(); i++) {
    Attractor a = attractors.get(i);
    if (a.behavior == 1) a.setStrength(map(noise(a.strengthNoise), 0, 1, 1, 1));
    if (a.behavior == -1) a.setStrength(map(noise(a.strengthNoise), 0, 1, -1, 0));
    if (!a.isStatic) {
      a.position.x = map(noise(a.xNoise), 0, 1, 0, width);
      a.position.y = map(noise(a.yNoise), 0, 1, 0, height);
    }
    a.strengthNoise += 0.005;
    a.xNoise += 0.00525;
    a.yNoise += 0.00525;
    if (a.behavior == 1) fill(0, 200, 0);
    if (a.behavior == -1) fill(200, 0, 0);
    strokeWeight(0.5);
    ellipse(a.position.x, a.position.y, 5, 5);
  }
  //saveFrameForVideo();
}

void mouseDragged() {
  Attractor a = attractors.get(0);
  a.position.x = mouseX;
  a.position.y = mouseY;
}

void addParticle(float _x, float _y) {
  Particle p = new Particle(_x, _y, random(0.25, 1.0), random(0, 2));
  Vec2D f = new Vec2D(random(-0.5, 0.5), random(-0.5, 0.5));
  ConstantForceBehavior cb = new ConstantForceBehavior(f);
  //p.addBehavior(cb);
  physics.addParticle(p);
  p.pixel1 = src.pixels[floor(random(src.pixels.length - 1))];
  p.pixel2 = src.pixels[floor(random(src.pixels.length - 1))];
  // physics.addBehavior(new AttractionBehavior(p, random(60), -1f));
}

void addAttractor(float _x, float _y, int _behavior, boolean _isStatic) {
  Attractor a = new Attractor(new Vec2D(_x, _y), width/4, 0, 0, _behavior, _isStatic);
  physics.addBehavior(a);
  attractors.add(a);
}

void render() {
  canvas.beginDraw();
  canvas.noStroke();
  physics.update();
  for (int i = physics.particles.size() - 1; i > 1; i--) {
    Particle p = (Particle) physics.particles.get(i);
    Particle p2 = (Particle) physics.particles.get(i-1);
    float x1 = map(p.x, 0, width, 0, canvas.width);
    float y1 = map(p.y, 0, height, 0, canvas.height);
    float x2 = map(p2.x, 0, width, 0, canvas.width);
    float y2 = map(p2.y, 0, height, 0, canvas.height);
    canvas.fill(lerpColor(p.pixel1, p.pixel2, noise(p.colorNoise)));
    p.radiusNoise += 0.005;
    p.colorNoise += 0.0075;
    float r = map(noise(p.radiusNoise), 0, 1, p.maxRadius / 20, p.maxRadius);
    //canvas.noStroke();
    //canvas.stroke(0, 14);
    //canvas.strokeWeight(8);
    if (p.getVelocity().magnitude() < 0.1) {
      canvas.noStroke();
      canvas.noFill();
    }
    canvas.ellipse(x1, y1, r, r);
    p.age++;
    if (p.age > p.maxAge) physics.removeParticle(p);
    //if (y1 < 0 || y1 > canvas.height || x1 < 0 || x1 > canvas.width) physics.removeParticle(p);
  }
  canvas.endDraw();
}

void saveFrameForVideo() {
  String fileName = nf(frameCount, 5) + ".tif";
  saveFrame("data/video/" + fileName);
}

void mousePressed() {
  addParticle(mouseX, mouseY);
}

void keyPressed() {
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
  if (key == 'p' || key == 'P') {
    for (int i = 0; i < points.length; i++) {
      //addParticle(points[i].x, points[i].y);
      addAttractor(points[i].x, points[i].y, -1, true);
    }
  }
  if (key == 'g' || key == 'G') {
    for (int i = 0; i < 500; i++) {
      addParticle(random(width), random(height));
    }
  }
  if (key == 's' || key == 'S') {
    PGraphics img = createGraphics(canvas.width, canvas.height);
    img.beginDraw();
    img.image(background, 0, 0, canvas.width, canvas.height);
    img.image(canvas, 0, 0);
    img.endDraw();
    img.save("data/output/composition-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + ".tif");
  }
}

