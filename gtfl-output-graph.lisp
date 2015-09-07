;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:arfe.gtfl-output-graph)

(defgeneric output-graph (graph &optional extension))

(defmethod output-graph ((graph cons) &optional extension)
  (output-graph (from-adj graph) extension))

(defmethod output-graph ((graph graph) &optional extension)
  (uiop:with-temporary-file (:stream stream :pathname pathname)
    (arfe.dot:print-af-to-dot-with-extension graph extension stream)
    :close-stream
    (multiple-value-bind (output error-output exit-code)
        (uiop:run-program (list "/bin/bash"
                                "-c"
                                "set -o pipefail ; dot -Tsvg | sed -e '1,3d'")
                          :input pathname
                          :output :string
                          :error-output :string)
      (unless (zerop exit-code)
        (error "~A" (list output error-output exit-code)))
      output)))

(defun gtfl-output-graph (graph &optional extension)
  (gtfl:gtfl-out (:p (who:str (output-graph graph extension)))))

(defun gtfl-output-graphs (graphs)
  (let ((i -1))
    (dolist (x graphs)
      (gtfl:gtfl-out
       (:hr)
       (:h1 "graph " (who:str (incf i))))
      (arfe.gtfl-output-graph:gtfl-output-graph x)
      (let ((x (if (consp x)
                   (from-adj x)
                   x)))
        (gtfl:gtfl-out
         (:div :style "font-size:150%"
               (:p "complete-extensions: "
                   (who:esc (prin1-to-string (list-extensions x #'complete-extension-p))))
               (:p "preferred-extensions: "
                   (who:esc (prin1-to-string (list-extensions x #'preferred-extension-p))))
               (:p "stable-extensions: "
                   (who:esc (prin1-to-string (list-extensions x #'stable-extension-p))))))))))
