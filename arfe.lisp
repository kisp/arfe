;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe)

(defmacro with-open-gzip-file ((var pathname) &body body)
  (with-unique-names (stream tmp-pathname)
    `(uiop:with-temporary-file (:pathname ,tmp-pathname :stream ,stream :direction :output)
       (uiop:run-program "gzip -d" :input ,pathname :output ,stream)
       :close-stream
       (with-open-file (,var ,tmp-pathname)
         ,@body))))

(defun remove-last-char (string)
  (let ((string (string string)))
    (subseq string 0 (1- (length string)))))

(defun load-data ()
  (let (symbols)
    (dolist (file (directory
                   (merge-pathnames "data/*.gz"
                                    (asdf:component-pathname
                                     (asdf:find-system :arfe)))))
      (format t "Loading ~A...~%" file)
      (let ((symbol (intern (format nil "*~A*" (string-upcase (pathname-name file))))))
        (eval `(defvar ,symbol))
        (push symbol symbols)
        (with-open-gzip-file (input file)
          (setf (symbol-value symbol)
                (loop for form = (read input nil :eof)
                      until (eql form :eof)
                      collect form)))))
    (nreverse symbols)))
