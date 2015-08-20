;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe)

(defun remove-last-char (string)
  (let ((string (string string)))
    (subseq string 0 (1- (length string)))))

(defun load-data ()
  (let (symbols)
    (dolist (file (directory
                   (merge-pathnames "data/*.data"
                                    (asdf:component-pathname
                                     (asdf:find-system :arfe)))))
      (format t "Loading ~A...~%" file)
      (let ((symbol (intern (format nil "*~A*" (string-upcase (pathname-name file))))))
        (push symbol symbols)
        (with-open-file (input file)
          (setf (symbol-value symbol)
                (loop for form = (read input nil :eof)
                      until (eql form :eof)
                      collect form)))))
    (nreverse symbols)))

(defun load-data-graph ()
  (let ((result)
        (symbols (load-data)))
    (dolist (symbol symbols)
      (push symbol result)
      (let ((graph-symbol
              (intern (format nil "~A-GRAPH*" (remove-last-char symbol)))))
        (push graph-symbol result)
        (setf (symbol-value graph-symbol)
              (mapcar #'from-adj (symbol-value symbol)))))
    (nreverse result)))
