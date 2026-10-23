/* Note 1. */

/* [General] */

// Note 2.
/* [Assembly display] */
// Note 3.
view = "default"; // [default, together, exploded]

Part = 1; // [1: Container, 2: Lid, 3: Container Corner Section - For Testing, 4: Lid Corner Section - For Testing, 5: All - Preview Only]

// Note 4.
Inside_Length = 150; // [10:1:300]

// Note 5.
Inside_Width = 120; // [10:1:300]

// Note 6.
Inside_Height = 60; // [10:1:300]

// Note 7.
Inside_Corner_Radius = 10; // [0:1:20]

// Note 8.
Front = 1; // [0:Solid, 1: Cutout, 2: Pattern]

// Note 9.
Bottom = 1; // [0:Solid, 1: Pattern]

// Note 10.
Sides = 1; // [0:Solid, 1: Pattern]

// Note 11.
Rear = 1; // [0:Solid, 1: Pattern]

// Note 12.
Material_Thickness = 4; // [2.5:0.1:10]

/* [Cutout] */

// Note 13.
Front_Cutout_Width_Percent = 90; // [0:1:100]

// Note 14.
Front_Cutout_Height_Percent = 90; // [0:1:100]

/* [Lip] */

// Note 15.
Lip = 1; // [0: No, 1: Yes]

// Note 16.
Lip_Gap = 0.6; // [0.1:0.1:1]

/* [Pattern] */

// Note 17.
Pattern_Type = 6; // [0: None, 1: Hole, 2: Lines, 3: Triangles, 4: Diamonds, 5: Circles, 6: Hexagons, 7: Stars, 8: Hearts]

// Note 18.
Pattern_Padding = 0; // [0:1:100]

// Note 19.
Pattern_Width = 5; // [1:1:100]

// Note 20.
Pattern_Material_Thickness = 2; // [2:0.1:10]

/* [Preview] */

// Note 21.
Split_Parts_In_Preview = 10; // [0:1:100]

module caddy() {
  $fn = 120;

  insideCornerRadius = min(Inside_Corner_Radius, (Inside_Length / 2) - 0.01, (Inside_Width / 2) - 0.01, (Inside_Height / 2) - 0.01);
  lipHeight = (Material_Thickness / 2);
  lipRecessHeight = min(lipHeight + 1, Material_Thickness - 1);
  lipThickness = (Material_Thickness / 2);

  module insideProfile() {
    translate([Material_Thickness, Material_Thickness, 0]) {
      offset(r = insideCornerRadius) {
        offset(delta = -insideCornerRadius) {
          square(size=[Inside_Width, Inside_Length]);
        }
      }
    }
  }

  module outsideProfile() {
    offset(r = Material_Thickness) {
      insideProfile();
    }
  }

  module wallProfile() {
    difference() {
      outsideProfile();
      insideProfile();
    }
  }

  module lipProfile(outsidePad, insidePad) {
    difference() {
      offset(r = lipThickness + (outsidePad != undef ? outsidePad : 0)) {
        insideProfile();
      }

      offset(r = -(insidePad != undef ? insidePad : 0)) {
        insideProfile();
      }
    }
  }

  module linesPatternProfile(width, length, lineWidth, materialThickness) {
    longestSide = max(width, length);
    hypotenuse = sqrt(pow(longestSide, 2) + pow(longestSide, 2));

    module lines(start) {
      for (i=[start:ceil(longestSide / (lineWidth + materialThickness))]) {
        translate([(i * (lineWidth + materialThickness)), 0, 0]) {
          square(size=[lineWidth, hypotenuse], center = true);
        }
      }
    }

    translate([width / 2, length / 2, 0]) {
      rotate([0, 0, -45]) {
        lines(0);

        mirror([1, 0, 0]) {
          lines(1);
        }
      }
    }
  }

  module triangle(altitude) {
    radius = altitude * 2 / 3;
    translate([0, (radius / 2) - (altitude / 2), 0]) {
      rotate([0, 0, 90]) {
        circle(r = radius, $fn = 3);
      }
    }
  }

  module trianglePatternProfile(width, length, altitude, materialThickness) {
    edge = (2 / sqrt(3)) * altitude;
    xBaseOffset = ((edge / 2) + materialThickness) * 2;
    yBaseOffset = altitude + materialThickness;
    xIterations = ceil(width / xBaseOffset);
    yIterations = ceil(length / yBaseOffset);
    totalWidth = xBaseOffset * xIterations;
    totalLength = yBaseOffset * yIterations;

    translate([-((totalWidth - width) / 2), -((totalLength - length) / 2), 0]) {
      for (x=[0:xIterations]) {
        for (y=[0:yIterations]) {
          translate([xBaseOffset * x, yBaseOffset * y, 0]) {
            mirror([0, (y % 2 == 0 ? 0 : 1), 0]) {
              triangle(altitude);
            }

            translate([(edge / 2) + materialThickness, 0, 0]) {
              mirror([0, (y % 2 == 0 ? 1 : 0), 0]) {
                triangle(altitude);
              }
            }
          }
        }
      }
    }
  }

  module diamondPatternProfile(width, length, diamondWidth, materialThickness) {
    intersection() {
      linesPatternProfile(width, length, diamondWidth, materialThickness);

      translate([width, 0, 0]) {
        mirror([1, 0, 0]) {
          linesPatternProfile(width, length, diamondWidth, materialThickness);
        }
      }
    }
  }

  module circlePatternProfile(width, length, diameter, materialThickness) {
    baseOffset = (diameter + materialThickness);
    xIterations = ceil(width / (diameter + materialThickness));
    yIterations = ceil(length / (diameter + materialThickness));
    totalWidth = baseOffset * xIterations;
    totalLength = baseOffset * yIterations;
    // Note 22.
    fn = ceil(min(max(diameter * PI, 20), 60));

    translate([-((totalWidth - width) / 2), -((totalLength - length) / 2), 0]) {
      for (x=[0:xIterations]) {
        for (y=[0:yIterations]) {
          translate([x * (diameter + materialThickness), y * (diameter + materialThickness), 0]) {
            circle(d = diameter, $fn = fn);
          }
        }
      }
    }
  }

  module hexPatternProfile(width, length, diameter, materialThickness) {
    radius = diameter / 2;
    apothem = radius * cos(180 / 6);

    xBaseOffset = ((radius * 1.5) + (materialThickness)) * 2;
    yBaseOffset = (apothem * 2) + materialThickness;
    xIterations = ceil(width / xBaseOffset);
    yIterations = ceil(length / yBaseOffset);
    totalWidth = xBaseOffset * xIterations;
    totalLength = yBaseOffset * yIterations;

    translate([-((totalWidth - width) / 2), -((totalLength - length) / 2), 0]) {
      for (x=[0:xIterations]) {
        for (y=[0:yIterations]) {
          translate([xBaseOffset * x, yBaseOffset * y, 0]) {
            circle(r = radius, $fn = 6);

            translate([(radius * 1.5) + materialThickness, apothem + (materialThickness / 2), 0]) {
              circle(r = radius, $fn = 6);
            }
          }
        }
      }
    }
  }

  module starPatternProfile(width, length, diameter, materialThickness) {
    baseOffset = (diameter + materialThickness);
    xIterations = ceil(width / (diameter + materialThickness));
    yIterations = ceil(length / (diameter + materialThickness));
    totalWidth = baseOffset * xIterations;
    totalLength = baseOffset * yIterations;
    altitude = (diameter / 4) + (diameter / 2);

    translate([-((totalWidth - width) / 2), -((totalLength - length) / 2), 0]) {
      for (x=[0:xIterations]) {
        for (y=[0:yIterations]) {
          translate([x * (diameter + materialThickness), y * (diameter + materialThickness), 0]) {
            translate([0, (diameter / 2) - (altitude / 2), 0]) {
              triangle(altitude);
            }

            mirror([0, 1, 0]) {
              translate([0, (diameter / 2) - (altitude / 2), 0]) {
                triangle(altitude);
              }
            }
          }
        }
      }
    }
  }

  module heart(edge, altitude) {
    topDiameter = ((edge / 2) + altitude - (sqrt(pow(edge / 2, 2) + pow(altitude, 2))));
    bottomDiameter = topDiameter * 2 / 3;
    topTranslateX = ((sqrt(3) / 2) * topDiameter) - edge / 2;
    topTranslateY = (topDiameter / 2) - (altitude / 2);
    bottomTranslateY = altitude / 2;

    // Note 23.
    fn = ceil(min(max(altitude * PI, 20), 60));

    hull() {
      translate([-topTranslateX, topTranslateY, 0]) {
        circle(d = topDiameter, $fn = fn);
      }

      translate([0, bottomTranslateY - bottomDiameter, 0]) {
        circle(d = bottomDiameter, $fn = fn);
      }
    }

    hull() {
      translate([topTranslateX, topTranslateY, 0]) {
        circle(d = topDiameter, $fn = fn);
      }

      translate([0, bottomTranslateY - bottomDiameter, 0]) {
        circle(d = bottomDiameter, $fn = fn);
      }
    }
  }

  module heartPatternProfile(width, length, altitude, materialThickness) {
    edge = (2 / sqrt(3)) * altitude;
    xBaseOffset = ((edge / 2) + materialThickness) * 2;
    yBaseOffset = altitude + materialThickness;
    xIterations = ceil(width / xBaseOffset);
    yIterations = ceil(length / yBaseOffset);
    totalWidth = xBaseOffset * xIterations;
    totalLength = yBaseOffset * yIterations;

    translate([-((totalWidth - width) / 2), -((totalLength - length) / 2), 0]) {
      for (x=[0:xIterations]) {
        for (y=[0:yIterations]) {
          translate([xBaseOffset * x, yBaseOffset * y, 0]) {
            mirror([0, (y % 2 == 0 ? 0 : 1), 0]) {
              heart(edge, altitude);
            }

            translate([(edge / 2) + materialThickness, 0, 0]) {
              mirror([0, (y % 2 == 0 ? 1 : 0), 0]) {
                heart(edge, altitude);
              }
            }
          }
        }
      }
    }
  }

  module patternMask(width, length) {
    if (Pattern_Type == 1) {
      // Note 24.
      square(size=[width, length]);
    }
    else if (Pattern_Type == 2) {
      // Note 25.
      linesPatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 3) {
      // Note 26.
      trianglePatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 4) {
      // Note 27.
      diamondPatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 5) {
      // Note 28.
      circlePatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 6) {
      // Note 29.
      hexPatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 7) {
      // Note 30.
      starPatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
    else if (Pattern_Type == 8) {
      // Note 31.
      heartPatternProfile(width, length, Pattern_Width, Pattern_Material_Thickness);
    }
  }

  module bottom() {
    linear_extrude(height = Material_Thickness, convexity = 10) {
      outsideProfile();
    }
  }

  module containerBody() {
    bottom();

    // Note 32.
    linear_extrude(height = Material_Thickness + Inside_Height, convexity = 10) {
      wallProfile();
    }

    // Note 33.
    if (Lip) {
      linear_extrude(height = Material_Thickness + Inside_Height + lipHeight, convexity = 10) {
        lipProfile();
      }
    }
  }

  module frontCutout() {
    width = (Inside_Width - (2 * insideCornerRadius)) * (Front_Cutout_Width_Percent / 100);
    height = (Inside_Height + lipHeight) * (Front_Cutout_Height_Percent / 100);
    roundingRadius = min(width / 2, height / 2, insideCornerRadius) - 0.00001;
    depth = Material_Thickness + 1;
    lipRoundingRadius = min(lipHeight, (Inside_Width - width) / 2, height - roundingRadius);

    translate([Material_Thickness + (Inside_Width / 2), depth, Material_Thickness + Inside_Height + lipHeight - height]) {
      rotate([90, 0, 0]) {
        linear_extrude(height = depth + 1, convexity = 10) {
          translate([-width / 2, 0, 0]) {
            offset(r = roundingRadius) {
              offset(r = -roundingRadius) {
                square(size=[width, height + roundingRadius + 1]);
              }
            }

            translate([-lipRoundingRadius, height - lipRoundingRadius, 0]) {
              difference() {
                square(size=[lipRoundingRadius, lipRoundingRadius + 1]);
                circle(r=lipRoundingRadius);
              }
            }

            translate([width + lipRoundingRadius, height - lipRoundingRadius, 0]) {
              mirror([1, 0, 0]) {
                difference() {
                  square(size=[lipRoundingRadius, lipRoundingRadius + 1]);
                  circle(r=lipRoundingRadius);
                }
              }
            }
          }
        }
      }
    }
  }

  module body(part) {
    difference() {
      if (part == 1) {
        containerBody();
      } else if (part == 2) {
        bottom();
      }

      // Note 34.
      if (Lip) {
        translate([0, 0, -0.01]) {
          linear_extrude(height = lipRecessHeight + 0.01, convexity = 10) {
            lipProfile(Lip_Gap / 2, Lip_Gap / 2);
          }
        }
      }

      // Note 35.
      if (Bottom == 1) {
        translate([0, 0, -0.5]) {
          linear_extrude(height = Material_Thickness + 1, convexity = 10) {
            intersection() {
              translate([Material_Thickness, Material_Thickness, 0]) {
                patternMask(Inside_Width, Inside_Length);
              }

              offset(r = -Material_Thickness - Pattern_Padding) {
                insideProfile();
              }
            }
          }
        }
      }

      if (part != 2) {
        if (Front == 1) {
          frontCutout();
        } else if (Front == 2) {
          translate([Material_Thickness, Material_Thickness + 0.5, Material_Thickness]) {
            rotate([90, 0, 0]) {
              linear_extrude(height = Material_Thickness + 1, convexity = 10) {
                intersection() {
                  patternMask(Inside_Width, Inside_Height);
                  patternWidth = Inside_Width - (insideCornerRadius * 2);
                  patternHeight = Inside_Height;

                  translate([insideCornerRadius, 0, 0]) {
                    offset(r = -Material_Thickness - Pattern_Padding) {
                      offset(r = insideCornerRadius) {
                        offset(delta = -insideCornerRadius) {
                        square([patternWidth, patternHeight]);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Note 36.
        if (Sides == 1) {
          translate([-0.5, Material_Thickness, Material_Thickness]) {
            rotate([90, 0, 90]) {
              linear_extrude(height = Inside_Width + (Material_Thickness * 2) + 1, convexity = 10) {
                intersection() {
                  patternMask(Inside_Length, Inside_Height);
                  patternWidth = Inside_Length - (insideCornerRadius * 2);
                  patternHeight = Inside_Height;

                  translate([insideCornerRadius, 0, 0]) {
                    offset(r = -Material_Thickness - Pattern_Padding) {
                      offset(r = insideCornerRadius) {
                        offset(delta = -insideCornerRadius) {
                        square([patternWidth, patternHeight]);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        // Note 37.
        if (Rear == 1) {
          translate([Material_Thickness, Inside_Length + (Material_Thickness * 2) + 0.5, Material_Thickness]) {
            rotate([90, 0, 0]) {
              linear_extrude(height = Material_Thickness + 1, convexity = 10) {
                intersection() {
                  patternMask(Inside_Width, Inside_Height);
                  patternWidth = Inside_Width - (insideCornerRadius * 2);
                  patternHeight = Inside_Height;

                  translate([insideCornerRadius, 0, 0]) {
                    offset(r = -Material_Thickness - Pattern_Padding) {
                      offset(r = insideCornerRadius) {
                        offset(delta = -insideCornerRadius) {
                        square([patternWidth, patternHeight]);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  module containerPart() {
    body(1);
  }

  module lidPart() {
    translate([0, 0, Material_Thickness]) {
      translate([Inside_Width + (Material_Thickness * 2), 0, 0]) {
        rotate([0, 180, 0]) {
          body(2);
        }
      }
    }
  }

  if (view == "together" || view == "exploded") {
    color("SteelBlue") body(1);
    color("DarkOrange") translate([0,0,Material_Thickness+Inside_Height+(view == "exploded" ? 40 : 0)]) body(2);
  } else if (Part != 5) {
    if (Part == 1) {
      containerPart();

      echo("Container dimensions:");

      echo(str("\tOutside length: ", Inside_Length + (Material_Thickness * 2), "mm"));
      echo(str("\tOutside width: ", Inside_Width + (Material_Thickness * 2), "mm"));
      echo(str("\tOutside height: ", Inside_Height + Material_Thickness + lipHeight, "mm"));

      echo(str("\tLip width: ", Material_Thickness / 2, "mm"));
      echo(str("\tLip height: ", lipHeight, "mm"));

      echo(str("\tLip recess width: ", (Material_Thickness / 2) + Lip_Gap, "mm"));
      echo(str("\tLip recess height: ", lipRecessHeight, "mm"));
    } else if (Part == 2) {
      lidPart();

      echo("Lid dimensions:");

      echo(str("\tOutside length: ", Inside_Length + (Material_Thickness * 2), "mm"));
      echo(str("\tOutside width: ", Inside_Width + (Material_Thickness * 2), "mm"));
      echo(str("\tOutside height: ", Material_Thickness, "mm"));

      echo(str("\tLip recess width: ", (Material_Thickness / 2) + Lip_Gap, "mm"));
      echo(str("\tLip recess height: ", lipRecessHeight, "mm"));
    } else if (Part == 3) {
      intersection() {
        containerPart();
        cube([Inside_Corner_Radius + (Material_Thickness * 1.5), Inside_Corner_Radius + (Material_Thickness * 1.5), Inside_Height + Material_Thickness + lipHeight]);
      }
    } else if (Part == 4) {
      intersection() {
        lidPart();
        cube([Inside_Corner_Radius + (Material_Thickness * 1.5), Inside_Corner_Radius + (Material_Thickness * 1.5), Material_Thickness]);
      }
    }
  } else {
    if ($preview) {
      %body(1);

      translate([0, 0, Material_Thickness + Inside_Height + Split_Parts_In_Preview]) {
        %body(1);

        translate([0, 0, Material_Thickness + Inside_Height + Split_Parts_In_Preview]) {
          %body(2);
        }
      }
    }
  }
}

echo("\r\tThis design is completely free and shared under a permissive license.\r\tYour support is hugely appreciated: codeandmake.com/support\r");
// Note 38.
module feral_default_output_714e668148a7() {
caddy();
}

module feral_assembly_view_714e668148a7(explode=false) {
caddy();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_714e668148a7();
else feral_assembly_view_714e668148a7(view == "exploded");

// Notes

// Note 1. Copyright 2022 Code and Make (codeandmake.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// Stackable Storage Caddies by Code and Make (https://codeandmake.com/)
//
// https://codeandmake.com/post/stackable-storage-caddies
//
// Stackable Storage Caddies v1.4 (5 August 2022)

// Note 2. Part to display

// Note 3. default preserves the original part, coupon and print selectors.

// Note 4. Inner length

// Note 5. Inner width

// Note 6. Inner height

// Note 7. Inner corner radius

// Note 8. Front type

// Note 9. Bottom type

// Note 10. Side type

// Note 11. Rear type

// Note 12. Thickness of the walls and base

// Note 13. Width of front cutout as a percentage

// Note 14. Width of front cutout as a percentage

// Note 15. Should a lip and lip recess be added

// Note 16. Gap between the lip and the recess

// Note 17. Type of pattern

// Note 18. Amount of padding around the pattern

// Note 19. The width of the pattern elements

// Note 20. Minimum pattern material thickness

// Note 21. Amount to split the parts (preview only)

// Note 22. base facets on circumference, clamp between 20 and 60

// Note 23. base facets on altitude, clamp between 20 and 60

// Note 24. hole

// Note 25. lines

// Note 26. triangles

// Note 27. diamonds

// Note 28. circles

// Note 29. hexagons

// Note 30. stars

// Note 31. hearts

// Note 32. walls

// Note 33. lip

// Note 34. lip recess (underneath)

// Note 35. bottom pattern

// Note 36. side pattern

// Note 37. rear pattern

// Note 38. Assembly display changes placement only; the original output remains the default.
