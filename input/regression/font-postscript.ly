\header {

    texidoc = "This file demonstrates how to load different
    (postscript) fonts. The file @file{font.scm} shows how to define
    the scheme-function @code{make-century-schoolbook-tree}."

}

\bookpaper
{
    #(define text-font-defaults
      '((font-encoding . latin1)
	(baseline-skip . 2)
	(word-space . 0.6)))

    #(set! fonts (make-century-schoolbook-tree 1.0))
}

%ugh.
% do this here so we don't forget the connection with
% this file.
#(system "afm2tfm `kpsewhich uncb8a.afm` uncb8a.tfm") 

\paper {
    linewidth = 160 \mm - 2.0 * 9.0 \mm

    
    indent = 0.0\mm
    raggedright = ##t
}

    {
        \key a \major
\time 6/8
cis''8. d''16 cis''8 e''4 e''8
    }
