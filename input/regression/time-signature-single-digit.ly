\header {
  texidoc = "The single-digit time signature style prints the numerator only."
}

\new Staff {
  \relative d' {
    \override Staff.TimeSignature.style = #'single-digit
    \time 1/2 d2
    \time 2/4 d4 d
    \time 3/4 d2.
    \time 16/4 d\longa
  }
}
