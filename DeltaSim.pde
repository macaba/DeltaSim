import g4p_controls.*; //<>//

DeltaConfig theoretical;
DeltaConfig actual;
Location testEffectorLocation  = null;
int selectedTower = 0;
float xAngle = 0;
float zAngle = 0;
float xBedAngle = 0;
float yBedAngle = 0;
ArrayList<Location> testPoints;  // The (X, Y, Z) location for test points
ArrayList<Location> effectorErrors;      // The (X, Y, Z) errors for each of the test points
ArrayList<Location> heightErrors;

void setup() {
  size(1000, 600, P3D);
  theoretical = new DeltaConfig();
  actual = new DeltaConfig();
  printLocation("Motors: ", theoretical.motorsLocation);
  printLocation("Effector: ", theoretical.effectorLocation);
  
  theoretical.effectorLocation.x = 0;
  theoretical.effectorLocation.y = 0;
  theoretical.effectorLocation.z = 0;

  theoretical.CalculateMotorHeights(theoretical.effectorLocation, theoretical.motorsLocation);
  theoretical.CalculateEffectorLocation(theoretical.motorsLocation, theoretical.effectorLocation);
  printLocation("Motors: ", theoretical.motorsLocation);
  printLocation("Effector: ", theoretical.effectorLocation);
  
  testPoints = new ArrayList<Location>();
  effectorErrors = new ArrayList<Location>();
  heightErrors = new ArrayList<Location>();
  int angle = 360;
  for (int radius = 0; radius < (theoretical.deltaRadius); radius+= 5) {
    for (angle = angle - 360; angle < 360; angle += (radius > 0? (theoretical.deltaRadius + 5 - radius)/3 : 360)) {
      Location l = new Location(radius*Math.sin(radians(angle)), radius*Math.cos(radians(angle)), 0);
      testPoints.add(l);
      effectorErrors.add(new Location());
      heightErrors.add(new Location());
    }
  }
  
  calculateErrors();
  println("whee");
}

void calculateErrors() {
  for (int i = 0; i < testPoints.size(); i++) {
    Location l = testPoints.get(i);
    theoretical.effectorLocation.x = l.x;
    theoretical.effectorLocation.y = l.y;
    theoretical.effectorLocation.z = 0;
    
    theoretical.CalculateMotorHeights(theoretical.effectorLocation, theoretical.motorsLocation);
    actual.motorsLocation.x = theoretical.motorsLocation.x;
    actual.motorsLocation.y = theoretical.motorsLocation.y;
    actual.motorsLocation.z = theoretical.motorsLocation.z;
    actual.CalculateEffectorLocation(actual.motorsLocation, actual.effectorLocation);

    Location e = effectorErrors.get(i);
    e.x = theoretical.effectorLocation.x - actual.effectorLocation.x;
    e.y = theoretical.effectorLocation.y - actual.effectorLocation.y;
    e.z = theoretical.effectorLocation.z - actual.effectorLocation.z;
    
    Location h = heightErrors.get(i);
    h.x = theoretical.effectorLocation.x;
    h.y = theoretical.effectorLocation.y;
    h.z = actual.calculateActualBedHeight(theoretical.effectorLocation.x, theoretical.effectorLocation.y) - actual.effectorLocation.z;
  }
}

void draw() {
  background(100);
  actual.drawDelta(heightErrors);
}

void mouseWheel(MouseEvent e) {
  theoretical.effectorLocation.z += e.getCount();
  theoretical.CalculateMotorHeights(theoretical.effectorLocation, theoretical.motorsLocation);
  actual.motorsLocation.x = theoretical.motorsLocation.x;
  actual.motorsLocation.y = theoretical.motorsLocation.y;
  actual.motorsLocation.z = theoretical.motorsLocation.z;
  actual.CalculateEffectorLocation(actual.motorsLocation, actual.effectorLocation);
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    zAngle += (pmouseX - mouseX) / 150.0;
    xAngle += (pmouseY - mouseY) / 150.0;
  }
  
  if (mouseButton == RIGHT) {
    theoretical.effectorLocation.x += (mouseX - pmouseX);
    theoretical.effectorLocation.y += (mouseY - pmouseY);
    theoretical.CalculateMotorHeights(theoretical.effectorLocation, theoretical.motorsLocation);
    
    actual.motorsLocation.x = theoretical.motorsLocation.x;
    actual.motorsLocation.y = theoretical.motorsLocation.y;
    actual.motorsLocation.z = theoretical.motorsLocation.z;
    actual.CalculateEffectorLocation(actual.motorsLocation, actual.effectorLocation);
  }
}

void keyPressed() {
  println("Key: " + key);
  if (key == '1') {
    selectedTower = 0;
  } else if (key == '2') {
    selectedTower = 1;
  } else if (key == '3') {
    selectedTower = 2;
  } else if (key == 'r') {
    selectedTower = 3;
  } else if (key == 'd') {
    selectedTower = 4;
  } else if (key == 'b') {
    selectedTower = 5;
  } else if (key == 'i') {
    xBedAngle += radians(0.1);
    actual.CalculateBedNormal();
    calculateErrors();
  } else if (key == 'j') {
    yBedAngle -= radians(0.1);
    actual.CalculateBedNormal();
    calculateErrors();
  } else if (key == 'k') {
    xBedAngle -= radians(0.1);
    actual.CalculateBedNormal();
    calculateErrors();
  } else if (key == 'l') {
    yBedAngle += radians(0.1);
    actual.CalculateBedNormal();
    calculateErrors();
  } else if (key == 'a') {
    actual.bedNormal.d += 0.025;
    calculateErrors();
  } else if (key == 'z') {
    actual.bedNormal.d -= 0.025;
    calculateErrors();
  } else if (key == CODED) {
    println("coded key:");
    Location loc;
    switch (selectedTower) {
      case 0: 
        loc = actual.aTowerLocation;
        break;
      case 1:
        loc = actual.bTowerLocation;
        break;
      case 2:
        loc = actual.cTowerLocation;
        break;
      default:
        loc = null;
        break;
    }
    if (keyCode == UP) {
      if (loc != null) {
        loc.y += 0.1;
      } else {
        actual.rodLength += 0.025;
      }
    } else if (keyCode == DOWN) {
      if (loc != null) {
        loc.y -= 0.1;
      } else {
        actual.rodLength -= 0.025;
      }
    } else if (keyCode == LEFT) {
      if (loc != null) {
        loc.x -= 0.1;
      } else {
        actual.deltaRadius -= 0.1;
        actual.CalculateFromAngles();
      }
    } else if (keyCode == RIGHT) {
      if (loc != null) {
        loc.x += 0.1;
      } else {
        actual.deltaRadius += 0.1;
        actual.CalculateFromAngles();
      }
    }
    actual.CalculateCenter();
    calculateErrors();
  }
}

class Location {
  double x;
  double y;
  double z;
  
  Location() {
    this(0, 0, 0);
  }
  
  Location(double x, double y) {
    this(x, y, 0);
  }
  
  Location(double x, double y, double z) {
    set(x, y, z);
  }
  
  void set(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Vector {
  double a;
  double b;
  double c;
  double d;
  
  Vector() {
    this(0, 0, 0, 0);
  }
  
  Vector(double a, double b, double c) {
    this(a, b, c, 0);
  }
  
  Vector(double a, double b, double c, double d) {
    set(a, b, c, d);
  }
  
  void set(double a, double b, double c) {
    set(a, b, c, 0);
  }
  
  void set(double a, double b, double c, double d) {
    this.a = a;
    this.b = b;
    this.c = c;
    this.d = d;
  }
}

class DeltaConfig {
  // Measured, not calibrated
  double rodLength;
  
  // Distance from center of delta circle to towers
  double deltaRadius;
  
  // Location of endstops
  double aTowerHeight;
  double bTowerHeight;
  double cTowerHeight;
  
  // Angles
  double aTowerAngle;
  double bTowerAngle;
  double cTowerAngle;
  
  // Locations of towers
  Location aTowerLocation;
  Location bTowerLocation;
  Location cTowerLocation;
  
  // Center of circle that intersects the tower locations
  Location centerLocation;
  
  Location motorsLocation;
  Location effectorLocation;
  
  // Normal vector of bed
  Vector bedNormal;
  
  DeltaConfig() {
    this.rodLength = 215;
    this.deltaRadius = 110;
    this.aTowerHeight = 400;
    this.bTowerHeight = 400;
    this.cTowerHeight = 400;
    this.aTowerAngle = 0;
    this.bTowerAngle = radians(120);
    this.cTowerAngle = radians(240);
    this.bedNormal = new Vector(0, 0, 1);
    
    this.aTowerLocation = new Location();
    this.bTowerLocation = new Location();
    this.cTowerLocation = new Location();
    this.centerLocation = new Location();
    
    this.motorsLocation = new Location(this.aTowerHeight, this.bTowerHeight, this.cTowerHeight);
    this.effectorLocation = new Location();
    
    CalculateFromAngles();
    CalculateCenter();
    CalculateEffectorLocation(this.motorsLocation, this.effectorLocation);
  }

  void drawDelta(ArrayList<Location> heightErrors) {
    pushMatrix();
    translate(width/2, 2*height/3, -50);
    rotateX(xAngle);
    rotateZ(zAngle);
    
    // draw bed
    //fill(255);
    noFill();
    ellipse(0, 0, (float)this.deltaRadius*2, (float)this.deltaRadius*2);
    
    //noStroke();
    colorMode(HSB, 360, 100, 100);
    
    float[] heightErrorsFloat = new float[5000];
    int i = 0;
    for (Location l : heightErrors) {
      heightErrorsFloat[i++] = (float)l.z;
    }
    float maxDeviation = max(abs(min(heightErrorsFloat)), abs(max(heightErrorsFloat))); 
    float maxDeviationCoerced = max(maxDeviation, 0.1);
    float hueFactor = 120/maxDeviationCoerced;
       
    for (Location l : heightErrors) {
      //println("l.z:"+l.z);
      if (Double.isNaN(l.z)) {
        fill(0,100,100);
      } else {
        fill((int)((l.z * hueFactor)+120), 100, 50);
      }
    
      pushMatrix(); 
      translate(0,0,(float)l.z*50);
      ellipse((float)l.x, (float)l.y, 5, 5);
      popMatrix();      
    }
    stroke(0);
    
    colorMode(RGB);
    
    // draw tower A
    pushMatrix();
    if (selectedTower == 0) {
      fill(256, 0, 0);
    } else {
      fill(256);
    }
    translate((float)this.aTowerLocation.x, (float)this.aTowerLocation.y, 0);
    rotateY(-PI/2);
    rect(0, -2, (float)this.aTowerHeight, 2);
    popMatrix();
    
    // draw motor A
    pushMatrix();
    translate((float)this.aTowerLocation.x, (float)this.aTowerLocation.y, (float)this.motorsLocation.x);
    line(-5, 0, 5, 0);
    rotateY(PI/2);
    line(-5, 0, 5, 0);
    rotateZ(PI/2);
    line(-5, 0, 5, 0);
    popMatrix();

    // draw tower B
    pushMatrix();
    if (selectedTower == 1) {
      fill(256, 0, 0);
    } else {
      fill(256);
    }
    translate((float)this.bTowerLocation.x, (float)this.bTowerLocation.y, 0);
    rotateY(-PI/2);
    rect(0, -2, (float)this.bTowerHeight, 2);
    popMatrix();

    // draw motor B
    pushMatrix();
    translate((float)this.bTowerLocation.x, (float)this.bTowerLocation.y, (float)this.motorsLocation.y);
    line(-5, 0, 5, 0);
    rotateY(PI/2);
    line(-5, 0, 5, 0);
    rotateZ(PI/2);
    line(-5, 0, 5, 0);
    popMatrix();

    // draw tower C
    pushMatrix();
    if (selectedTower == 2) {
      fill(256, 0, 0);
    } else {
      fill(256);
    }
    translate((float)this.cTowerLocation.x, (float)this.cTowerLocation.y, 0);
    rotateY(-PI/2);
    rect(0, -2, (float)this.cTowerHeight, 2);
    popMatrix();

    // draw motor C
    pushMatrix();
    translate((float)this.cTowerLocation.x, (float)this.cTowerLocation.y, (float)this.motorsLocation.z);
    line(-5, 0, 5, 0);
    rotateY(PI/2);
    line(-5, 0, 5, 0);
    rotateZ(PI/2);
    line(-5, 0, 5, 0);
    popMatrix();

    // draw effector
    pushMatrix();
    fill(256);
    translate((float)this.effectorLocation.x, (float)this.effectorLocation.y, (float)this.effectorLocation.z);
    line(-5, 0, 5, 0);
    line(0, -5, 0, 5);
    ellipse(0, 0, 10, 10);
    popMatrix();
    
    // draw rod A
    pushMatrix();
    translate((float)this.effectorLocation.x, (float)this.effectorLocation.y, (float)this.effectorLocation.z);
    if (this.aTowerLocation.x < this.effectorLocation.x) {
      rotateZ(PI+atan((float)((this.aTowerLocation.y - this.effectorLocation.y) / (this.aTowerLocation.x - this.effectorLocation.x))));
    } else {
      rotateZ(atan((float)((this.aTowerLocation.y - this.effectorLocation.y) / (this.aTowerLocation.x - this.effectorLocation.x))));
    }
    rotateY(-asin((float)((this.motorsLocation.x - this.effectorLocation.z) / this.rodLength)));
    line(0, 0, (float)this.rodLength, 0);
    popMatrix();
    
    // draw rod B
    pushMatrix();
    translate((float)this.effectorLocation.x, (float)this.effectorLocation.y, (float)this.effectorLocation.z);
    if (this.bTowerLocation.x < this.effectorLocation.x) {
      rotateZ(PI+atan((float)((this.bTowerLocation.y - this.effectorLocation.y) / (this.bTowerLocation.x - this.effectorLocation.x))));
    } else {
      rotateZ(atan((float)((this.bTowerLocation.y - this.effectorLocation.y) / (this.bTowerLocation.x - this.effectorLocation.x))));
    }
    rotateY(-asin((float)((this.motorsLocation.y - this.effectorLocation.z) / this.rodLength)));
    line(0, 0, (float)this.rodLength, 0);
    popMatrix();
    
    // draw rod C
    pushMatrix();
    translate((float)this.effectorLocation.x, (float)this.effectorLocation.y, (float)this.effectorLocation.z);
    if (this.cTowerLocation.x < this.effectorLocation.x) {
      rotateZ(PI+atan((float)((this.cTowerLocation.y - this.effectorLocation.y) / (this.cTowerLocation.x - this.effectorLocation.x))));
    } else {
      rotateZ(atan((float)((this.cTowerLocation.y - this.effectorLocation.y) / (this.cTowerLocation.x - this.effectorLocation.x))));
    }
    rotateY(-asin((float)((this.motorsLocation.z - this.effectorLocation.z) / this.rodLength)));
    line(0, 0, (float)this.rodLength, 0);
    popMatrix();

    popMatrix();

    fill(0);
    textSize(18);
    text(String.format("Tower A: [%.5f, %.5f]", this.aTowerLocation.x, this.aTowerLocation.y), 25, 100);
    text(String.format("Tower A Angle: %.5f", degrees((float)this.aTowerAngle)), 25, 150);
    text(String.format("Tower B: [%.5f, %.5f]", this.bTowerLocation.x, this.bTowerLocation.y), 25, 200);
    text(String.format("Tower B Angle: %.5f", degrees((float)this.bTowerAngle)), 25, 250);
    text(String.format("Tower C: [%.5f, %.5f]", this.cTowerLocation.x, this.cTowerLocation.y), 25, 300);
    text(String.format("Tower C Angle: %.5f", degrees((float)this.cTowerAngle)), 25, 350);
    text(String.format("Delta Radius: %.5f", this.deltaRadius), 25, 400);
    text(String.format("Rod Length: %.5f", this.rodLength), 25, 450);
    text(String.format("Effector: [%.5f, %.5f, %.5f]", this.effectorLocation.x, this.effectorLocation.y, this.effectorLocation.z), 25, 500);
    text(String.format("Bed Normal: [%.5f, %.5f, %.5f, %.5f]", this.bedNormal.a, this.bedNormal.b, this.bedNormal.c, this.bedNormal.d), 25, 550);
    text(String.format("Max Deviation: %.3f (Red: %.3f, Blue: %.3f)", maxDeviation, -maxDeviationCoerced, maxDeviationCoerced), 25, 590);
  }

  void CalculateFromAngles() {
    this.aTowerLocation.x = this.deltaRadius * Math.cos(this.aTowerAngle);
    this.aTowerLocation.y = this.deltaRadius * Math.sin(this.aTowerAngle);
    
    this.bTowerLocation.x = this.deltaRadius * Math.cos(this.bTowerAngle);
    this.bTowerLocation.y = this.deltaRadius * Math.sin(this.bTowerAngle);
    
    this.cTowerLocation.x = this.deltaRadius * Math.cos(this.cTowerAngle);
    this.cTowerLocation.y = this.deltaRadius * Math.sin(this.cTowerAngle);
    
    this.centerLocation.x = 0;
    this.centerLocation.y = 0;
    
    println("Calculating tower locations:");
    println("Rod Length: " + this.rodLength);
    println("Delta radius: " + this.deltaRadius);
    println("Tower Angle A: " + degrees((float)this.aTowerAngle));
    println("Tower Angle B: " + degrees((float)this.bTowerAngle)); 
    println("Tower Angle C: " + degrees((float)this.cTowerAngle)); 
    println("Tower A: (" + this.aTowerLocation.x + ", " + this.aTowerLocation.y + ")");
    println("Tower B: (" + this.bTowerLocation.x + ", " + this.bTowerLocation.y + ")");
    println("Tower C: (" + this.cTowerLocation.x + ", " + this.cTowerLocation.y + ")");
  }  
  
  void CalculateCenter() {
    double abMidY = (this.aTowerLocation.y + this.bTowerLocation.y) / 2.0;
    double slopeABp = -(this.aTowerLocation.x - this.bTowerLocation.x) / (this.aTowerLocation.y - this.bTowerLocation.y);
    double acMidX = (this.aTowerLocation.x + this.cTowerLocation.x) / 2.0;
    double acMidY = (this.aTowerLocation.y + this.cTowerLocation.y) / 2.0;
    double slopeACp = -(this.aTowerLocation.x - this.cTowerLocation.x) / (this.aTowerLocation.y - this.cTowerLocation.y);
    
    this.centerLocation.x = (abMidY - acMidY + acMidX * (slopeACp - slopeABp)) / (slopeACp - slopeABp);
    this.centerLocation.y = acMidY - slopeACp * (acMidX - this.centerLocation.x);
    
    this.deltaRadius = Math.sqrt((this.aTowerLocation.x - this.centerLocation.x) * (this.aTowerLocation.x - this.centerLocation.x) + 
                                 (this.aTowerLocation.y - this.centerLocation.y) * (this.aTowerLocation.y - this.centerLocation.y));
                                 
    this.aTowerAngle = Math.asin((this.aTowerLocation.y - this.centerLocation.y) / this.deltaRadius);                             
    this.bTowerAngle = PI - Math.asin((this.bTowerLocation.y - this.centerLocation.y) / this.deltaRadius);                             
    this.cTowerAngle = PI - Math.asin((this.cTowerLocation.y - this.centerLocation.y) / this.deltaRadius);                             
    
    println("Calculating center:");
    println("Center: (" + this.centerLocation.x + ", " + this.centerLocation.y + ")");
    println("Radius: " + this.deltaRadius);
    println("aTowerAngle: " + this.aTowerAngle);
    println("bTowerAngle: " + this.bTowerAngle);
    println("cTowerAngle: " + this.cTowerAngle);
  }
  
  double calculateActualBedHeight(double pX, double pY) {
    return (this.bedNormal.d - this.bedNormal.a * pX - this.bedNormal.b * pY) / this.bedNormal.c;
  }
  
  void CalculateBedNormal() {
    this.bedNormal.a = sin(yBedAngle);
    this.bedNormal.b = sin(xBedAngle);
    this.bedNormal.c = cos(xBedAngle) + cos(yBedAngle);
  }
  
  // (1): Create a bunch of locations--sample locations
  // (2): Compute the motor heights for each location in (1) using "ideal" delta config
  // (3): Compute the effector location for the "actual" delta config using motor heights in (2)
  // ERROR == effector(3).z - bed.z 
  // (4): Using (x,y) of effector in (3), calculate actual bed height (aka bed intercept)
  // (5): Using bed intercept, calculate motor heights
  // ERROR == motor(5).x - motor(2).x  --or-- motor(5).y - motor(2).y  --or--  motor(5).z - motor(2).z 
  
  
  // Given an effector location, calculate the motor heights
  Location CalculateMotorHeights(Location effector, Location motorHeights) {
    if (motorHeights == null) {
      motorHeights = new Location();
    }
    motorHeights.x = effector.z + Math.sqrt((this.rodLength*this.rodLength) - 
                                          (this.aTowerLocation.x - effector.x)*(this.aTowerLocation.x - effector.x) - 
                                          (this.aTowerLocation.y - effector.y)*(this.aTowerLocation.y - effector.y));
    motorHeights.y = effector.z + Math.sqrt((this.rodLength*this.rodLength) - 
                                          (this.bTowerLocation.x - effector.x)*(this.bTowerLocation.x - effector.x) - 
                                          (this.bTowerLocation.y - effector.y)*(this.bTowerLocation.y - effector.y));
    motorHeights.z = effector.z + Math.sqrt((this.rodLength*this.rodLength) - 
                                          (this.cTowerLocation.x - effector.x)*(this.cTowerLocation.x - effector.x) - 
                                          (this.cTowerLocation.y - effector.y)*(this.cTowerLocation.y - effector.y));
    return motorHeights;
  }
  
  // Xe = effector X location
  // Ye = effector Y location
  // Ze = effector Z location
  // Xa,Xb,Xc = tower A,B,C X location
  // Ya,Yb,Yc = tower A,B,C Y location
  // Za,Zb,Zc = motor A,B,C Z location
  
  // Starting with equations for circles:
  // (0a): (Xe-Xa)^2 + (Ye-Ya)^2 + (Ze-Za)^2 = RL^2
  // (0b): (Xe-Xb)^2 + (Ye-Yb)^2 + (Ze-Zb)^2 = RL^2
  // (0c): (Xe-Xc)^2 + (Ye-Yc)^2 + (Ze-Zc)^2 = RL^2
  // Intersection of towers A & B:
  // (1): Xe = ((Xb^2+Yb^2+Zb^2-Xa^2-Ya^2-Za^2)/(2*(Xb-Xa)) - Ye((Yb-Ya)/(Xb-Xa)) - Ze*((Zb-Za)/(Xb-Xa))
  // (2): Xe = K1 - K2*Ye - K3*Ze
  // Intersection of towers B & C:
  // (3): Xe = ((Xc^2+Yc^2+Zc^2-Xb^2-Yb^2-Zb^2)/(2*(Xc-Xb)) - Ye((Yc-Yb)/(Xc-Xb)) - Ze*((Zc-Zb)/(Xc-Xb))
  // (4): Xe = L1 - L2*Ye - L3*Ze
  // Intersection of both intersections
  // (5): Ye = Ze*(K3-L3)/(L2-K2) + (L1-K1)/(L2-K2)
  // (6): Ye = A1*Ze + B1
  // Substituting (5) for Ye in (2):
  // (7): Xe = Ze*(-K2*A1-K3) + (K1-K2*B1)
  // (8): Xe = A2*Ze + B2
  // Substituting (8) and (6) into (0a):
  // (9): (A1^2+A2^2+1)*Ze^2 + (2*A1*(B1-Yb)+2*A2*(B2-Xb)-2*Zb)*Ze + ((B2-Xb)^2+(B1-Yb)^2)+Zb^2-RL^2) = 0
  // (10): A3*Ze^2 + B3*Ze + C3 = 0
  // (11): Ze = (-B3 +- sqrt(B3^2 - 4*A3*C3)) / (2*A3)
  double sq(double value) {
    return value * value;
  }
  
  Location CalculateEffectorLocation(Location motorHeights, Location effector) {
    if (effector == null) {
      effector = new Location();
    }
    double k1 = (sq(this.bTowerLocation.x)+sq(this.bTowerLocation.y)+sq(motorHeights.y)
                 -sq(this.aTowerLocation.x)-sq(this.aTowerLocation.y)-sq(motorHeights.x)) 
                / (2*(this.bTowerLocation.x-this.aTowerLocation.x));
    double k2 = (this.bTowerLocation.y-this.aTowerLocation.y)/(this.bTowerLocation.x-this.aTowerLocation.x);                 
    double k3 = (motorHeights.y-motorHeights.x)/(this.bTowerLocation.x-this.aTowerLocation.x);
    double l1 = (sq(this.cTowerLocation.x)+sq(this.cTowerLocation.y)+sq(motorHeights.z)
                 -sq(this.bTowerLocation.x)-sq(this.bTowerLocation.y)-sq(motorHeights.y)) 
                / (2*(this.cTowerLocation.x-this.bTowerLocation.x));
    double l2 = (this.cTowerLocation.y-this.bTowerLocation.y)/(this.cTowerLocation.x-this.bTowerLocation.x);                 
    double l3 = (motorHeights.z-motorHeights.y)/(this.cTowerLocation.x-this.bTowerLocation.x);
    double a1 = (k3 - l3) / (l2 - k2); 
    double b1 = (l1 - k1) / (l2 - k2);
    double a2 = (-k2 * a1 - k3);
    double b2 = (k1 - k2 * b1);
    double a3 = sq(a1) + sq(a2) + 1;
    double b3 = 2*a1*(b1-this.bTowerLocation.y)+2*a2*(b2-this.bTowerLocation.x)-2*motorHeights.y;
    double c3 = sq(b2-this.bTowerLocation.x) + sq(b1-this.bTowerLocation.y) + sq(motorHeights.y) - sq(this.rodLength);
    double z1 = (-b3 + Math.sqrt(sq(b3) - 4*a3*c3)) / (2*a3);
    double x1 = a2 * z1 + b2;
    double y1 = a1 * z1 + b1;
    double z2 = (-b3 - Math.sqrt(sq(b3) - 4*a3*c3)) / (2*a3);
    double x2 = a2 * z2 + b2;
    double y2 = a1 * z2 + b1;
    
    if (z1 > z2) {
      effector.x = x2;
      effector.y = y2;
      effector.z = z2;
    } else {
      effector.x = x1;
      effector.y = y1;
      effector.z = z1;
    }
    return effector;
  }

  
  
  
  // X = J1*Y + K1*Z + L1
  // X = J2*Y + K2*Z + L2
  // X = J3*Y + K3*Z + L3
  // Y * (J1 - J2) = Z * (K2 - K1) + (L2 - L1)
  // Y = Z * (K2 - K1) / (J1 - J2) + (L2 - L1) / (J1 - J2)
  // Y = Z * (K3 - K1) / (J1 - J3) + (L3 - L1) / (J1 - J3)
  // Z * ((K2-K1)/(J1-J2) - (K3-K1)/(J1-J3)) + (L2-L1)/(J1-J2) - (L3-L1)/(J1-J3) = 0
  // Z = (L3-L1)/(J1-J3) - (L2-L1)/(J1-J2) / ....
  Location CalculateEffectorLocation2(Location motorHeights, Location effector) {
    if (effector == null) {
      effector = new Location();
    }
    
    Vector plane1 = new Vector((2.0*this.bTowerLocation.x - 2.0*this.aTowerLocation.x),
                               (2.0*this.bTowerLocation.y - 2.0*this.aTowerLocation.y),
                               (2.0*motorHeights.y - 2.0*motorHeights.x),
                               ((this.aTowerLocation.x*this.aTowerLocation.x - this.bTowerLocation.x*this.bTowerLocation.x) +
                                (this.aTowerLocation.y*this.aTowerLocation.y - this.bTowerLocation.y*this.bTowerLocation.y) +
                                (motorHeights.x*motorHeights.x - motorHeights.y*motorHeights.y)));
    Vector plane2 = new Vector((2.0*this.cTowerLocation.x - 2.0*this.bTowerLocation.x),
                               (2.0*this.cTowerLocation.y - 2.0*this.bTowerLocation.y),
                               (2.0*motorHeights.z - 2.0*motorHeights.y),
                               ((this.bTowerLocation.x*this.bTowerLocation.x - this.cTowerLocation.x*this.cTowerLocation.x) +
                                (this.bTowerLocation.y*this.bTowerLocation.y - this.cTowerLocation.y*this.cTowerLocation.y) +
                                (motorHeights.y*motorHeights.y - motorHeights.z*motorHeights.z)));
    Vector plane3 = new Vector((2.0*this.aTowerLocation.x - 2.0*this.cTowerLocation.x),
                               (2.0*this.aTowerLocation.y - 2.0*this.cTowerLocation.y),
                               (2.0*motorHeights.x - 2.0*motorHeights.z),
                               ((this.cTowerLocation.x*this.cTowerLocation.x - this.aTowerLocation.x*this.aTowerLocation.x) +
                                (this.cTowerLocation.y*this.cTowerLocation.y - this.aTowerLocation.y*this.aTowerLocation.y) +
                                (motorHeights.z*motorHeights.z - motorHeights.x*motorHeights.x)));
    double determinant = (plane1.a * (plane2.b*plane3.c - plane2.c*plane3.b) -
                          plane1.b * (plane2.a*plane3.c - plane2.c*plane3.a) + 
                          plane1.c * (plane2.a*plane3.b - plane2.b*plane3.a));

    effector.x = ((plane1.d * (plane2.b*plane3.c - plane2.c*plane3.b) -
                   plane1.b * (plane2.d*plane3.c - plane2.c*plane3.d) +
                   plane1.c * (plane2.d*plane3.b - plane2.b*plane3.d)) / determinant);
    effector.y = ((plane1.a * (plane2.d*plane3.c - plane2.c*plane3.d) -
                   plane1.d * (plane2.a*plane3.c - plane2.c*plane3.a) +
                   plane1.c * (plane2.a*plane3.d - plane2.d*plane3.a)) / determinant);
    effector.z = ((plane1.a * (plane2.b*plane3.d - plane2.d*plane3.b) -
                   plane1.b * (plane2.a*plane3.d - plane2.d*plane3.a) +
                   plane1.d * (plane2.a*plane3.b - plane2.b*plane3.a)) / determinant);
    
    return effector;
  }
}

class Point {
  double x;
  double y;
  double z;
  
  Point(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

float[] CalcTowerOffsets(float[] position) {
  return null;
}

float ProbeHeight(float[] towerOffsets) {
  return 0;
}

void printLocation(String title, Location location) {
  println(title + "[" + location.x + ", " + location.y + ", " + location.z + "]");
}