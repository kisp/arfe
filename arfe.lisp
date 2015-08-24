;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe)

(defmacro with-open-gzip-file ((var pathname &key (direction :input))
                               &body body)
  (ecase direction
    (:input
     (with-unique-names (stream tmp-pathname)
       `(uiop:with-temporary-file (:pathname ,tmp-pathname :stream ,stream :direction :output)
          (uiop:run-program "gzip -d" :input ,pathname :output ,stream)
          :close-stream
          (with-open-file (,var ,tmp-pathname)
            ,@body))))
    (:output
     (with-unique-names (tmp-pathname values)
       `(let (,values)
          (uiop:with-temporary-file (:pathname ,tmp-pathname :stream ,var :direction :output)
            (setq ,values (multiple-value-list (progn ,@body)))
            :close-stream
            (uiop:run-program "gzip -9" :input ,tmp-pathname :output ,pathname)
            (values-list ,values)))))))

(defvar *data*)

(defun load-data (&rest symbols)
  (let (loaded-symbols)
    (dolist (file (directory
                   (merge-pathnames "data/*.gz"
                                    (asdf:component-pathname
                                     (asdf:find-system :arfe)))))

      (let ((symbol (intern (format nil "*~A*" (string-upcase (pathname-name file))))))
        (when (member symbol symbols)
          (format t "Loading ~A...~%" file)
          (eval `(defvar ,symbol))
          (push symbol loaded-symbols)
          (with-open-gzip-file (input file)
            (setf (symbol-value symbol)
                  (loop for form = (read input nil :eof)
                        until (eql form :eof)
                        collect form))))))
    (dolist (x loaded-symbols)
      (pushnew x *data*))
    (list-data)))

(defun unload-data (&rest symbols)
  (dolist (x symbols)
    (setq *data* (remove x *data*))
    (makunbound x))
  (list-data))

(defun list-data ()
  *data*)
