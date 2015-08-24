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
     (once-only (pathname)
       (with-unique-names (tmp-pathname values)
         `(let (,values)
            (uiop:with-temporary-file (:pathname ,tmp-pathname :stream ,var :direction :output)
              (setq ,values (multiple-value-list (progn ,@body)))
              :close-stream
              (when (probe-file ,pathname)
                (delete-file ,pathname))
              (with-open-file (output ,pathname :direction :output)
                output)
              (uiop:run-program "gzip -9" :input ,tmp-pathname :output ,pathname)
              (values-list ,values))))))))

(defvar *data* nil)

(defun arfe-system-dir ()
  (asdf:component-pathname (asdf:find-system :arfe)))

(defun data-file2symbol (file)
  (intern (format nil "*~A*" (string-upcase (pathname-name file)))))

(defun symbol2data-file (symbol)
  (labels ((w/o-first-last (x)
             (subseq x 1 (1- (length x)))))
    (let ((name (w/o-first-last (string-downcase symbol))))
      (merge-pathnames
       (make-pathname :name name :type "gz"
                      :directory '(:relative "data"))
       (arfe-system-dir)))))

(defun list-data-files ()
  (directory
   (merge-pathnames "data/*.gz" (arfe-system-dir))))

(defun list-data-symbols ()
  (mapcar #'data-file2symbol (list-data-files)))

(defun load-data (&rest symbols)
  (let (loaded-symbols)
    (dolist (file (list-data-files))

      (let ((symbol (data-file2symbol file)))
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

(defun save-data-symbol (symbol)
  (assert (boundp symbol))
  (let ((file (symbol2data-file symbol)))
    (with-open-gzip-file (output file
                          :direction :output)
      (format t "Saving ~A...~%" file)
      (dolist (x (symbol-value symbol))
        (format output "~S~%" x)))))

(defun list-data ()
  *data*)
