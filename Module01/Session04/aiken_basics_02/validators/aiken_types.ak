const pi: Int = 314159265359

fn circle_area(radius: Int) -> Int {
  pi * radius * radius
}

fn circle_circumference(radius: Int) -> Int {
  2 * pi * radius
}

test area_test_set4() {
  circle_area(10) == 31415926535900
}

test circumference_test_set4() {
  circle_circumference(10) == 6283185307180
}
