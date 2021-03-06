% DO NOT EDIT this file manually; it is automatically
% generated from Documentation/snippets/new
% Make any changes in Documentation/snippets/new/
% and then run scripts/auxiliar/makelsr.py
%
% This file is in the public domain.
%% Note: this file works from version 2.19.20

\version "2.19.20"

\header {
  lsrtags = "staff-notation, workaround"

  texidoc = "
By default, metronome marks do not influence horizontal spacing.   This
can be solved through a simple override, as shown in the second half of
the example.

"
  doctitle = "Forcing measure width to adapt to MetronomeMark's width"
} % begin verbatim


example = {
  \tempo "Allegro"
  R1*6
  \tempo "Rall."
  R1*2
  \tempo "A tempo"
  R1*8
}

{
  \compressMMRests {
    \example
    R1
    R1
    \override Score.MetronomeMark.extra-spacing-width = #'(-3 . 0)
    \example
  }
}
