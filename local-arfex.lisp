;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe.local-arfex)

(defvar *arfex-dir* "/home/paul/unis/MasterThesis/ksmaster-hagen/p/arfex/")
(defvar *force* nil)

(defvar *timings* (make-hash-table :test #'equal))

(defun logmsg (cstr &rest args)
  (apply #'format *trace-output* cstr args)
  (terpri *trace-output*))

;;; slow
(define-condition slow (error)
  ((pathname :reader slow-pathname :initarg :slow-pathname)))

(defun slow ()
  (cerror "continue with slow example" 'slow :slow-pathname *load-pathname*))

(defun list-example-files ()
  (remove-if
   (lambda (x) (not (equal (car (last (pathname-directory x)))
			   (pathname-name x))))
   (directory (merge-pathnames "*/*.lisp" *arfex-dir*))))

(defun example-homedir (example-file)
  (assert (not (cl-fad:directory-pathname-p example-file)))
  (make-pathname :name nil :type nil :defaults example-file))

(defun make-generation-package ()
  (let ((package
	  (make-package (gensym)
			:use (package-use-list :arfe))))
    (let ((arfe (find-package :arfe)))
      (do-symbols (x arfe)
	(when (eql (symbol-package x) arfe)
	  (import x package))))
    package))

(defun call-with-generation-package (thunk)
  (let ((*package* (make-generation-package)))
    (unwind-protect
	 (funcall thunk)
      (delete-package *package*))))

(defmacro with-generation-package (&body body)
  `(call-with-generation-package (lambda () ,@body)))

(defun call-with-dribbling (thunk)
  (dribble "log.txt" :if-exists :supersede)
  (unwind-protect
       (let ((*trace-output* sb-impl::*dribble-stream*))
	 (funcall thunk))
    (dribble)))

(defmacro with-dribbling (&body body)
  `(call-with-dribbling (lambda () ,@body)))

(defmacro with-current-directory ((pathname) &body body)
  (with-gensyms (old)
    `(let ((,old (sb-posix:getcwd)))
       (sb-posix:chdir ,pathname)
       (unwind-protect
	    (progn ,@body)
	 (sb-posix:chdir ,old)))))

(defun load* (pathname)
  (let ((*load-pathname* pathname))
    (with-open-file (input pathname)
      (iter
	(for form = (read input nil :eof))
	(until (eql :eof form))
	(format t "ARFE: ~S~%" form)
	(for results = (multiple-value-list (eval form)))
	(format t "~&~{~A~%~}~%" results)))))

(defun generate-example (example-file)
  (with-simple-restart (skip "skip generate example ~S"
			     (file-namestring example-file))
    (logmsg "; will generate ~A" example-file)
    (let ((start (get-internal-real-time)))
      (let ((*default-pathname-defaults* (example-homedir example-file)))
	(with-dribbling
	  (with-generation-package
	    (with-current-directory (*default-pathname-defaults*)
	      (let ((*readtable* (copy-readtable)))
		(load* example-file))))))
      (setf (gethash (file-namestring example-file)
		     *timings*)
	    (/ (- (get-internal-real-time) start)
	       (float internal-time-units-per-second))))))

(defun skip-generate-example (c)
  (declare (ignore c))
  (invoke-restart 'skip))

(defun needs-regeneration (example-file)
  (let* ((*default-pathname-defaults* (example-homedir example-file))
	 (log (merge-pathnames "log.txt")))
    (let ((result
	    (or (not (probe-file log))
		(> (file-write-date example-file)
		   (file-write-date log)))))
      (logmsg "; ~A~40T~:[no regeneration needed~;regeneration needed~]"
	      (file-namestring example-file) result)
      result)))

(defun timings-report ()
  (logmsg "; timings report")
  (with-hash-table-iterator (next *timings*)
    (loop while
	  (multiple-value-bind (ok key value) (next)
	    (when ok
	      (logmsg "; ~A~40T~8,1Fs" key value)
	      t)))))

(defun generate-examples (&key (force *force*) slow)
  (clrhash *timings*)
  (let (skipped)
    (flet ((skip (c)	 
	     (cond
	       ((null slow)
		(push (slow-pathname c) skipped)
		(skip-generate-example c))
	       (t
		(continue c)))))
      (dolist (example-file (list-example-files))
	(when (or force
		  (needs-regeneration example-file))
	  (handler-bind ((slow #'skip))
	    (generate-example example-file)))))
    (logmsg "")
    (when skipped
      (logmsg "; skipped report")
      (dolist (x skipped)
	(logmsg "; ~A~40Tskipped" (file-namestring x)))
      (logmsg "")))
  (timings-report))
