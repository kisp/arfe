(in-package :scribble)
(named-readtables:in-readtable :meta)

(defun parse-bracket (stream &aux c (s (make-string-output-stream)) (l '()))
  (with-stream-meta (st stream)
   (labels
    ((head ()
       (match
        { [#\: !(let* ((head (within-scribble-package
			      (read-preserving-whitespace st t t nil)))
		       (ignore (skip-spaces))
		       (body (body)))
		  (declare (ignore ignore))
		  (scribble-cons head body))]
          !(apply 'scribble-list (body)) }))
     (add-char (c)
       (write-char c s))
     (flush ()
       (add-string (get-output-stream-string s)))
     (add-string (s)
       (or (= (length s) 0)
	   (add (scribble-preprocess s))))
     (add (x)
       (or (null x)
	   (push x l)))
     (skip-spaces ()
       (match {[@(spacing-character c) !(skip-spaces)]}))
     (body ()
       (match
        {[#\[ !(simple-parse-error
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
