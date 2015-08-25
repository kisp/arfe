;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe.dot
  (:use :common-lisp :alexandria :graph :graph-dot)
  (:export
   #:print-af-to-dot
   #:print-af-to-dot-with-extension))

(in-package #:arfe.dot)

(defun m (x)
  (or (nth x '(a b c d e f g h i j k l m n o p q r s t u v))
      (error "not found")))

(defun convert-graph-to-abc (graph)
  (let ((new-graph (make-instance 'digraph)))
    (dolist (node (nodes graph))
      (add-node new-graph (m node)))
    (dolist (edge (edges graph))
      (add-edge new-graph (mapcar #'m edge)))
    new-graph))

(defun sub-print (graph node-attrs stream)
  (let ((*print-case* :downcase))
    (to-dot graph
            :attributes '(("rankdir" . "LR"))
            :node-attrs node-attrs
            :stream stream)))

(defun print-af-to-dot (graph &optional (stream *standard-output*))
  (sub-print (convert-graph-to-abc graph) nil stream))

(defun print-af-to-dot-with-extension (graph extension &optional (stream *standard-output*))
  (let ((extension (mapcar #'m extension)))
    (sub-print (convert-graph-to-abc graph)
               `(("shape" .,(lambda (x) (when (member x extension)
                                          "diamond")))
                 ("style" . ,(lambda (x) (when (member x extension)
                                           "bold"))))
               stream)))
