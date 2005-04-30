;;;; framework-ps.scm --
;;;;
;;;;  source file of the GNU LilyPond music typesetter
;;;;
;;;; (c) 2004--2005 Han-Wen Nienhuys <hanwen@cs.uu.nl>

(define-module (scm framework-ps))

;;; this is still too big a mess.

(use-modules (ice-9 regex)
	     (ice-9 string-fun)
	     (ice-9 format)
	     (guile)
	     (srfi srfi-1)
	     (srfi srfi-13)
	     (lily))

(define framework-ps-module (current-module))

;;(define pdebug stderr)
(define (pdebug . rest) #f)

(define mm-to-bigpoint
  (/ 72 25.4))


(define-public (ps-font-command font)
  (let* ((name (munge-lily-font-name (ly:font-file-name font)))
	 (magnify (ly:font-magnification font)))

    (string-append
     "magfont"
     (string-regexp-substitute "[ /%]" "_" name)
     "m" (string-encode-integer (inexact->exact (round (* 1000 magnify)))))))

(define (tex-font? fontname)
  (or
   (equal? (substring fontname 0 2) "cm")
   (equal? (substring fontname 0 2) "ec")))


(define (define-fonts paper)
  (define font-list (ly:paper-fonts paper))
  (define (define-font command fontname scaling)
    (string-append
     "/" command " { /" fontname " findfont "
     (ly:number->string scaling) " output-scale div scalefont } bind def\n"))

  (define (standard-tex-font? x)
    (or (equal? (substring x 0 2) "ms")
	(equal? (substring x 0 2) "cm")))

  (define (font-load-command font)
    (let* ((specced-font-name (ly:font-name font))
	   (fontname (if specced-font-name
			 (munge-lily-font-name specced-font-name)
			 (ly:font-file-name font)))
	   (command (ps-font-command font))

	   ;; FIXME -- see (ps-font-command )
	   (plain (ps-font-command font))
	   (designsize (ly:font-design-size font))
	   (magnification (* (ly:font-magnification font)))
	   (ops (ly:output-def-lookup paper 'outputscale))
	   (scaling (* ops magnification designsize)))

      ;; Bluesky pfbs have UPCASE names (sigh.)
      ;; FIXME - don't support Bluesky?
      (if (standard-tex-font? fontname)
	  (set! fontname (string-upcase fontname)))
      (if (equal? fontname "unknown")
	  (display (list font fontname)))
      (define-font plain fontname scaling)))


  (apply string-append
	 (map (lambda (x) (font-load-command x))
	      (filter (lambda (x) (not (ly:pango-font? x)))
		      font-list))))

;; FIXME: duplicated in other output backends
;; FIXME: silly interface name
(define (output-variables layout)
  ;; FIXME: duplicates output-layout's scope-entry->string, mostly
  (define (value->string  val)
    (cond
     ((string? val) (string-append "(" val ")"))
     ((symbol? val) (symbol->string val))
     ((number? val) (number->string val))
     (else "")))

  (define (output-entry ps-key ly-key)
    (string-append
     "/" ps-key " "
     (value->string (ly:output-def-lookup layout ly-key)) " def\n"))

  (string-append
   "/lily-output-units "
     (number->string mm-to-bigpoint)
     " def %% millimeter\n"
   (output-entry "staff-line-thickness" 'linethickness)
   (output-entry "line-width" 'linewidth)
   (output-entry "paper-size" 'papersizename)
   (output-entry "staff-height" 'staffheight)	;junkme.
   "/output-scale "
     (number->string (ly:output-def-lookup layout 'outputscale))
     " def\n"
   (output-entry "page-height" 'vsize)
   (output-entry "page-width" 'hsize)))

(define (dump-page outputter page page-number page-count landscape?)
  (ly:outputter-dump-string
   outputter
   (string-append
    "%%Page: "
    (number->string page-number) " " (number->string page-count) "\n"
    
    "%%BeginPageSetup\n"
    (if landscape?
	"page-width output-scale lily-output-units mul mul 0 translate 90 rotate\n"
	"")
    "%%EndPageSetup\n"
    
    "start-page { "
    "set-ps-scale-to-lily-scale "
    "\n"))
  (ly:outputter-dump-stencil outputter page)
  (ly:outputter-dump-string outputter "} stop-system \nshowpage\n"))

(define (supplies-or-needs paper load-fonts?)
  (define (extract-names font)
    (if (ly:pango-font? font)
	(map car (ly:pango-font-physical-fonts font))
	(list (munge-lily-font-name (ly:font-name font)))))
  
  (let* ((fonts (ly:paper-fonts paper))
	 (names (apply append (map extract-names fonts))))
    
    (apply string-append
	   (map (lambda (f)
		  (format
		   (if load-fonts?
		    "%%DocumentSuppliedResources: font ~a\n"
		    "%%DocumentNeededResources: font ~a\n")
		   f))
		(uniq-list (sort names string<?))))))

(define (eps-header paper bbox load-fonts?)
  (string-append "%!PS-Adobe-2.0 EPSF-2.0\n"
		 "%%Creator: LilyPond\n"
		 "%%BoundingBox: "
		 (string-join (map ly:number->string bbox) " ") "\n"
		 "%%Orientation: "
		 (if (eq? (ly:output-def-lookup paper 'landscape) #t)
		     "Landscape\n"
		     "Portrait\n")
		 (supplies-or-needs paper load-fonts?)
		 "%%EndComments\n"))

(define (page-header paper page-count load-fonts?)
  (string-append "%!PS-Adobe-3.0\n"
		 "%%Creator: LilyPond\n"
		 "%%Pages: " (number->string page-count) "\n"
		 "%%PageOrder: Ascend\n"
		 "%%Orientation: "
		 (if (eq? (ly:output-def-lookup paper 'landscape) #t)
		     "Landscape\n"
		     "Portrait\n")
		 "%%DocumentPaperSizes: "
		 (ly:output-def-lookup paper 'papersizename) "\n"
		 (supplies-or-needs paper load-fonts?)
		 "%%EndComments\n"))

(define (procset file-name)
  (string-append
   (format
    "%%BeginResource: procset (~a) 1 0
~a
%%EndResource
"
    file-name (cached-file-contents file-name))))

(define (setup paper)
  (string-append
   "\n"
   "%%BeginSetup\n"
   (define-fonts paper)
   (output-variables paper)
   "%%EndSetup\n"))

(define-public (munge-lily-font-name name)
  (regexp-substitute/global #f "([eE]mmentaler|[aA]ybabtu)"
			    name 'pre "PFA" 1 'post))

(define (write-preamble paper load-fonts? port)
  (define (load-font font-pair)
    (let* ((name (car font-pair))
	   (file-name (cdr font-pair))
		 
	   (bare-file-name (ly:find-file file-name))
	   (cffname (string-append file-name ".cff.ps"))
	   (cff-file-name (ly:find-file cffname)))

      (cons 
       (munge-lily-font-name name)
       (cond
	((and bare-file-name (string-match "\\.pfa" bare-file-name))
	 (cached-file-contents bare-file-name))
	((and bare-file-name (string-match "\\.pfb" bare-file-name))
	 (ly:pfb->pfa bare-file-name))
	
	((string-match "([eE]mmentaler|[Aa]ybabtu)" file-name)
	 (cached-file-contents
	  (format "~a.pfa" (munge-lily-font-name file-name))))

	((and bare-file-name
	      (string-match "\\.(otf|cff)" bare-file-name))

					; replace with the CFF.ps, which lives in a
					; separate subdir.
	 (for-each (lambda (tup)
		     (set! bare-file-name
			   (string-regexp-substitute
			    (car tup) (cdr tup) bare-file-name)))
		   '(("/fonts/otf/" . "/ps/")
		     ("/fonts/cff/" . "/ps/")
		     ("\\.(otf|cff)" . ".cff.ps")))

	 (cached-file-contents bare-file-name))
	((and bare-file-name (string-match "\\.ttf" bare-file-name))
	 (ly:ttf->pfa bare-file-name))
	(bare-file-name (cached-file-contents bare-file-name))
	(cff-file-name  (cached-file-contents cff-file-name))
	(else
	 (ly:warning (_ "can't find CFF/PFA/PFB font ~S=~S" name file-name))
	 (cons font-name ""))))))
  
  (define (load-fonts paper)
    (let* ((fonts (ly:paper-fonts paper))

	   (all-font-names
	    (map
	     (lambda (font)
	       (cond
		((string? (ly:font-file-name font))
		 (list (cons (ly:font-name font)
			     (ly:font-file-name font))))
		((ly:pango-font? font)
		 (ly:pango-font-physical-fonts font))
		(else
		 (ly:font-sub-fonts font))))
		   
	     fonts))
	   (font-names
	    (uniq-list
	     (sort (apply append all-font-names)
		   (lambda (x y) (string<? (car x) (car y))))))
	   
	   (pfas (map load-font font-names)))
      pfas))

  (if load-fonts?
      (for-each
       (lambda (f)
	 (format port "\n%%BeginFont: ~a\n" (car f))
	 (display (cdr f) port)
	 (display "\n%%EndFont\n" port))
       (load-fonts paper)))
      
  (display (setup paper) port)

  ; adobe note 5002: should initialize variables before loading routines.
  (display (procset "music-drawing-routines.ps") port)
  (display (procset "lilyponddefs.ps") port)
  (display "init-lilypond-parameters\n" port)

  )

(define-public (output-framework basename book scopes fields)
  (let* ((filename (format "~a.ps" basename))
	 (outputter  (ly:make-paper-outputter filename "ps"))
	 (paper (ly:paper-book-paper book))
	 (pages (ly:paper-book-pages book))
	 (landscape? (eq? (ly:output-def-lookup paper 'landscape) #t))
	 (page-number (1- (ly:output-def-lookup paper 'firstpagenumber)))
	 (page-count (length pages))
	 (port (ly:outputter-port outputter)))

    (output-scopes scopes fields basename)
    (display (page-header paper page-count #t) port)
    (write-preamble paper #t  port)

    (for-each
     (lambda (page)
       (set! page-number (1+ page-number))
       (dump-page outputter page page-number page-count landscape?))
     pages)

    (display "%%Trailer\n%%EOF\n" port)
    (ly:outputter-close outputter)
    (postprocess-output book framework-ps-module filename
			 (completize-formats (ly:output-formats)))))

(if (not (defined? 'nan?))
    (define (nan? x) #f))

(if (not (defined? 'inf?))
    (define (inf? x) #f))

(define-public (dump-stencil-as-EPS paper dump-me filename load-fonts?)
  (define (mm-to-bp-box mmbox)
    (let* ((scale  (ly:output-def-lookup paper 'outputscale))
	   (box (map 
		 (lambda (x)
		   (inexact->exact
		    (round (* x scale mm-to-bigpoint)))) mmbox)))

    (list (car box) (cadr box)
	  (max (1+ (car box)) (caddr box))
	  (max (1+ (cadr box)) (cadddr box)))))

  (let* ((outputter (ly:make-paper-outputter (format "~a.eps" filename) "ps"))
	 (port (ly:outputter-port outputter))
	 (xext (ly:stencil-extent dump-me X))
	 (yext (ly:stencil-extent dump-me Y))
	 (bbox
	  (map
	   (lambda (x)
	     (if (or (nan? x) (inf? x))
		 0.0 x))
	   (list (car xext) (car yext)
	       (cdr xext) (cdr yext))))
	 (rounded-bbox (mm-to-bp-box bbox))
	 (port (ly:outputter-port outputter))
	 (header (eps-header paper rounded-bbox load-fonts?)))

    (display header port)
    (write-preamble paper load-fonts? port)
    (display "start-system { set-ps-scale-to-lily-scale \n" port)
    (ly:outputter-dump-stencil outputter dump-me)
    (display "} stop-system\n%%Trailer\n%%EOF\n" port)
    (ly:outputter-close outputter)))


(define-public (output-preview-framework basename book scopes fields)
  
  (let* ((paper (ly:paper-book-paper book))
	 (systems (ly:paper-book-systems book))
	 (scale (ly:output-def-lookup paper 'outputscale))
	 (to-dump-systems '())
	 )

    
    
    ;; skip booktitles.
    (if (and
	 (not
	  (cdr (assoc
	       'preview-include-book-title
	       (ly:get-option 'command-line-settings)
	       )))
	 (< 1 (length systems))
	 (ly:paper-system-title? (list-ref systems 0))
	 (ly:paper-system-title? (list-ref systems 1)))
	(set! systems (cdr systems)))
    
    (for-each
     (lambda (sys)
       (if (or
	    (ly:paper-system-title? sys)
	    (not (pair? to-dump-systems))
	    (ly:paper-system-title? (car to-dump-systems)))
	   (set! to-dump-systems (cons sys to-dump-systems))))
     systems)

    (dump-stencil-as-EPS
     paper
     (stack-stencils Y DOWN 0.0
		     (map ly:paper-system-stencil (reverse to-dump-systems)))
     (format "~a.preview" basename)
     #t)

    (postprocess-output book framework-ps-module
			(format "~a.preview.eps" basename)
			(completize-formats (cons "png" (ly:output-formats))))
    
    ))
(if #f
    (define-public (output-preview-framework basename book scopes fields)
      
      (let* ((paper (ly:paper-book-paper book))
	     (systems (ly:paper-book-systems book))
	     (scale (ly:output-def-lookup paper 'outputscale))
	     (titles (take-while ly:paper-system-title? systems))
	     (non-title (find (lambda (x)
				(not (ly:paper-system-title? x))) systems))
	     (dump-me
	      (stack-stencils Y DOWN 0.0
			      (map ly:paper-system-stencil
				   (append titles (list non-title))))))
	(output-scopes scopes fields basename)
	(dump-stencil-as-EPS paper dump-me
			     (format "~a.preview" basename)
			     #t)

	(postprocess-output book framework-ps-module
			    (format "~a.preview.eps" basename)
			    (completize-formats (ly:output-formats)))
	
	))
    )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (convert-to-pdf book name)
  (let* ((defs (ly:paper-book-paper book))
	 (papersizename (ly:output-def-lookup defs 'papersizename)))

    (if (equal? (basename name ".ps") "-")
	(ly:warning (_ "can't convert <stdout> to ~S" "PDF"))
	(postscript->pdf (if (string? papersizename) papersizename "a4")
			 name))))

(define-public (convert-to-png book name)
  (let* ((defs (ly:paper-book-paper book))
	 (defs-resolution (ly:output-def-lookup defs 'pngresolution))
	 (resolution (if (number? defs-resolution)
			 defs-resolution
			 (cdr (assoc 'resolution
				(ly:get-option 'command-line-settings)))))
	 (papersizename (ly:output-def-lookup defs 'papersizename)))

    (postscript->png resolution
		     (if (string? papersizename)
			 papersizename "a4")
		     
		     name)))

(define-public (convert-to-dvi book name)
  (ly:warning (_ "can't generate ~S using the postscript back-end") "DVI"))

(define-public (convert-to-tex book name)
  (ly:warning (_ "can't generate ~S using the postscript back-end") "TeX"))

(define-public (convert-to-ps book name)
  #t)
