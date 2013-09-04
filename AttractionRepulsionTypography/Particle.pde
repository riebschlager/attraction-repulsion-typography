class Particle extends VerletParticle2D {

  int pixel1, pixel2;
  float radiusNoise;
  float colorNoise;
  float maxRadius;
  float age, maxAge;

  public Particle(float _x, float _y, float _w, float _maxRadius) {
    super(_x, _y, _w);
    radiusNoise = random(1000);
    colorNoise = random(1000);
    maxRadius = _maxRadius;
    age = 1;
    maxAge = random(250);
  }
}

