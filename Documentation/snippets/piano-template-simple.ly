%% DO NOT EDIT this file manually; it is automatically
%% generated from LSR http://lsr.dsi.unimi.it
%% Make any changes in LSR itself, or in Documentation/snippets/new/ ,
%% and then run scripts/auxiliar/makelsr.py
%%
%% This file is in the public domain.
\version "2.14.0"

\header {
%% Translation of GIT committish: 4077120c18ac1dc490501b3d7d5886bc93e61a42
  texidocit = "
Ecco un semplice pentagramma per pianoforte con un po' di note.

"
  doctitleit = "Modello per pianoforte (semplice)"

  lsrtags = "keyboards, template"




%% Translation of GIT committish: 70f5f30161f7b804a681cd080274bfcdc9f4fe8c
  texidoces = "
Presentamos a continuación una plantilla de piano sencilla con algunas
notas.

"
  doctitlees = "Plantilla de piano (sencilla)"


%% Translation of GIT committish: 0a868be38a775ecb1ef935b079000cebbc64de40
  texidocde = "
Hier ein einfaches Klaviersystem.

"
  doctitlede = "Vorlage für einfache Klaviernotation"

%% Translation of GIT committish: ceb0afe7d4d0bdb3d17b9d0bff7936bb2a424d16
  texidocfr = "
Voici une simple partition pour piano avec quelques notes.

"
  doctitlefr = "Piano -- cannevas simple"

  texidoc = "
Here is a simple piano staff with some notes.

"
  doctitle = "Piano template (simple)"
} % begin verbatim

upper = \relative c'' {
  \clef treble
  \key c \major
  \time 4/4

  a4 b c d
}

lower = \relative c {
  \clef bass
  \key c \major
  \time 4/4

  a2 c
}

\score {
  \new PianoStaff <<
    \set PianoStaff.instrumentName = #"Piano  "
    \new Staff = "upper" \upper
    \new Staff = "lower" \lower
  >>
  \layout { }
  \midi { }
}

