;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe.gtfl-output-graph
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot)
  (:export
   #:gtfl-output-graph
   #:gtfl-output-graphs))

(in-package #:arfe.gtfl-output-graph)

(defun output-graph (graph)
  (uiop:with-temporary-file (:stream stream :pathname pathname)
    (to-dot graph :stream stream)
    :close-stream
    (uiop:run-program "set -o pipefail ; dot -Tsvg -Grankdir=LR | sed -e '1,3d'"
                      :input pathname
                      :output :string
                      :error-output :string)))

(defun gtfl-output-graph (graph)
  (gtfl:gtfl-out (:p (who:str (output-graph graph)))))

(defun gtfl-output-graphs (graphs)
  (let ((i -1))
    (dolist (x graphs)
      (gtfl:gtfl-out
       (:hr)
       (:h1 "graph " (who:str (incf i))))
      (arfe.gtfl-output-graph:gtfl-output-graph x)
      (gtfl:gtfl-out
       (:div :style "font-size:150%"
             (:p "complete-extensions: "
                 (who:esc (prin1-to-string (list-extensions x #'complete-extension-p))))
             (:p "preferred-extensions: "
                 (who:esc (prin1-to-string (list-extensions x #'preferred-extension-p))))
             (:p "stable-extensions: "
                 (who:esc (prin1-to-string (list-extensions x #'stable-extension-p)))))))))
