;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe.local-arfex)

(defvar *arfex-dir* "/home/paul/unis/MasterThesis/ksmaster-hagen/p/arfex/")

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
  (with-open-file (input pathname)
    (iter
      (for form = (read input nil :eof))
      (until (eql :eof form))
      (format t "ARFE: ~S~%" form)
      (for results = (multiple-value-list (eval form)))
      (format t "~&~{~A~%~}~%" results))))

(defun generate-example (example-file)
  (let ((*default-pathname-defaults* (example-homedir example-file)))
    (with-dribbling
      (with-generation-package
        (with-current-directory (*default-pathname-defaults*)
          (load* example-file))))))

(defun needs-regeneration (example-file)
  (let* ((*default-pathname-defaults* (example-homedir example-file))
         (log (merge-pathnames "log.txt")))
    (or (not (probe-file log))
        (> (file-write-date example-file)
           (file-write-date log)))))

(defun generate-examples (&key force)
  (dolist (example-file (list-example-files))
    (when (or force
              (needs-regeneration example-file))
      (with-simple-restart (skip "skip ~S" example-file)
        (generate-example example-file)))))
