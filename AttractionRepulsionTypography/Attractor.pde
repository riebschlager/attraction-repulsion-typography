class Attractor extends AttractionBehavior {

  Vec2D position;
  float xNoise, yNoise, strengthNoise;
  int behavior;
  boolean isStatic;

  public Attractor(Vec2D _position, float _radius, float _strength, float _jitter, int _behavior, boolean _isStatic) {
    super(_position, _radius, _strength, _jitter);
    position = _position;
    xNoise = random(1000);
    yNoise = random(1000);
    strengthNoise = random(1000);
    behavior = _behavior;
    isStatic = _isStatic;
  }

  public void tick() {    
    strengthNoise += 0.005;
    xNoise += 0.00525;
    yNoise += 0.00525;
    if (behavior == 1) setStrength(map(noise(strengthNoise), 0, 1, 0, 1));
    if (behavior == -1) setStrength(map(noise(strengthNoise), 0, 1, -1, 0));
    if (!isStatic) {
      position.x = map(noise(xNoise), 0, 1, 0, width);
      position.y = map(noise(yNoise), 0, 1, 0, height);
    }
  }

  public void render(PGraphics _canvas) {
    if (behavior == 1) fill(0, 200, 0);
    if (behavior == -1) fill(200, 0, 0);
    _canvas.strokeWeight(0.5);
    _canvas.ellipse(position.x, position.y, 5, 5);
  }
}

