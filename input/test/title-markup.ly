\version "2.1.30"
%{
   Experimental markup titles are available in direct PostScript output:

   export GS_LIB=$(pwd)/mf/out:/usr/share/texmf/fonts/type1/bluesky/cm
   lilypond-bin -fps input/title/title-markup.ly

%}

latinTest = \markup { \latin-i "Hell�" }
    
sizeTest = \markup {
	\column <
            { \normalsize "normalsize"
              \hspace #5
              \smaller "smaller"
              \hspace #5
              \smaller \smaller "smaller"
              \hspace #5
              \smaller \smaller \smaller "smaller"
            }
            " " 
            { \normalsize "normalsize"
              \hspace #5
              \bigger "bigger"
              \hspace #5
              \bigger \bigger "bigger"
              \hspace #5
              \bigger \bigger \bigger "bigger"
            }
       >
}

spaceTest = \markup { "two space chars" }
\header {
    texidoc = "Make titles using markup.  Only in direct PostScript output."

    ##tagline = "my tagline for v \version"
    copyright = "Copyright by /me"
    
    %dedication = "F�r my d�r Lily"
    % ugh: encoding char-size
    %dedication = "For my ������ so dear Lily"
    dedication = \markup { "For my "
			   \latin-i { "������" }
			   " so dear Lily" }
    title = "Title"
    subtitle = "(and (the) subtitle)"
    subsubtitle = "Sub sub title"
    poet = "Poet"
    composer = "Composer"
    texttranslator = "Text Translator"
    opus = "opus 0"
    meter = "Meter (huh?)"
    arranger = "Arranger"
    instrument = "Instrument"
    piece = "Piece"

    %% Override automatic book title
    %% bookTitle = \markup { \fill-line < \huge\bold \title > > }
}

\score {
    \context Staff \notes \relative c' {
	c2-\sizeTest c2-\spaceTest
    }
    \paper {
	#(paper-set-staff-size (* 11.0 pt)) 
	}
}

\header {
    %% Override automatic score title
    %% scoreTitle = \markup { "Tweetje" }
    opus = "opus 1"
    piece = "Second"
}

\score {
    \context Staff \notes \relative c' {
	\repeat unfold 35 { a b c d \break }
	c1
    }
}
