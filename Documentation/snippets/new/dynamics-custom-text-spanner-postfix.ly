\version "2.13.8"

\header {
  lsrtags = "expressive-marks, tweaks-and-overrides"
  texidoc = "Postfix functions for custom crescendo text spanners.  The spanners
should start on the first note of the measure.  One has to use -\mycresc,
otherwise the spanner start will rather be assigned to the next note.
"
  doctitle = "Dynamics custom text spanner postfix"
}

% Two functions for (de)crescendo spanners where you can explicitly give the
% spanner text.
mycresc =
#(define-music-function (parser location mymarkup) (markup?)
   (make-music 'CrescendoEvent
               'span-direction START
               'span-type 'text
               'span-text mymarkup))
mydecresc =
#(define-music-function (parser location mymarkup) (markup?)
   (make-music 'DecrescendoEvent
               'span-direction START
               'span-type 'text
               'span-text mymarkup))

\relative c' {
  c4-\mycresc "custom cresc" c4 c4 c4 |
  c4 c4 c4 c4 |
  c4-\mydecresc "custom decresc" c4 c4 c4 |
  c4 c4\! c4 c4
}



