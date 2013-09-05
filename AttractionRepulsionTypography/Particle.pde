class Particle extends VerletParticle2D {

  int pixel1, pixel2;
  float radiusNoise, colorNoise, xNoise, yNoise;
  float maxRadius;
  float age, lifetime;

  public Particle(float _x, float _y) {
    super(_x, _y);
    radiusNoise = random(1000);
    colorNoise = random(1000);
    xNoise = random(1000);
    yNoise = random(1000);
    age = 1;
  }

  public void tick() {
    radiusNoise += 0.005;
    colorNoise += 0.0075;
    xNoise += 0.051;
    yNoise += 0.051;
    age++;
    float vx = map(noise(xNoise), 0, 1, -1, 1);
    float vy = map(noise(yNoise), 0, 1, -1, 1);
    Vec2D vv = new Vec2D(vx, vy);
    addForce(vv);
  }

  public void render(PGraphics _canvas) {
    float x1 = map(x, 0, width, 0, _canvas.width);
    float y1 = map(y, 0, height, 0, _canvas.height);
    _canvas.noStroke();
    _canvas.fill(lerpColor(pixel1, pixel2, noise(colorNoise)));
    float r = map(noise(radiusNoise), 0, 1, maxRadius / 20, maxRadius);
    r = r - (r * (age/lifetime));
    if (getVelocity().magnitude() < 0.1) {
      _canvas.noStroke();
      _canvas.noFill();
    }
    _canvas.ellipse(x1, y1, r, r);
  }
}

