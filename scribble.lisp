;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

;;; using simple version of the scribble reader
;;; http://cliki.net/Scribble

(in-package :arfe.scribble)

(named-readtables:in-readtable :meta)

(deftype spacing-character ()
  "spacing character"
  '(member #\space #\newline #\tab #\linefeed #\return #\page))

(defun unbalanced-paren (stream char)
  (alexandria:simple-parse-error "Unbalanced ~A on ~A @ ~A." char stream (file-position stream)))

(defun read-skribe-bracket (stream char)
  (declare (ignore char))
  (let ((result (parse-bracket stream)))
    (if (and (null (cdr result))
	     (stringp (car result)))
	(car result)
	`(list ,@result))))

(defun parse-bracket (stream &aux c (s (make-string-output-stream)) (l '()))
  (with-stream-meta (st stream)
   (labels
    ((head ()
       (match
	   { [#\: !(let* ((head (read-preserving-whitespace st t t nil))
		       (ignore (skip-spaces))
		       (body (body)))
		  (declare (ignore ignore))
		  (cons head body))]
	  !(apply 'list (body)) }))
     (add-char (c)
       (write-char c s))
     (flush ()
       (add-string (get-output-stream-string s)))
     (add-string (s)
       (or (= (length s) 0)
	   (add s)))
     (add (x)
       (or (null x)
	   (push x l)))
     (skip-spaces ()
       (match {[@(spacing-character c) !(skip-spaces)]}))
     (body ()
       (match
	{[#\[ !(alexandria:simple-parse-error
		"Nested bracket neither after backslash or comma on ~A @ ~A."
		stream (file-position stream))]
	 [#\] !(progn
		(flush)
		(close s)
		(return-from body (reverse l)))]
	 [#\, { [#\( !(progn (flush)
			     (add (read-delimited-list #\) st t))
			     (body))]
		[#\, !(progn (flush)
			     (unread-char #\, st)
			     (add (read-preserving-whitespace st t t nil))
			     (body))]
		[#\[ !(progn (flush)
			     (add (parse-bracket st))
			     (body))]
		!(progn (add-char #\,) (body)) }]
	 ;; [#\\ @(character c) !(progn (add-char c) (body))]
	 [@(character c) !(progn (add-char c) (body))]})))
    (head))))
