;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:arfe.dot)

(defvar *conver-graph-use-underscore* t)

(defun malpha (x)
  (let ((symbol
          (or (nth x '(|a| |b| |c| |d| |e| |f| |g| |h| |i| |j| |k| |l| |m| |n| |o|
                       |p| |q| |r| |s| |t| |u| |v|))
              (error "not found"))))
    (intern (string symbol))))

(defun mindex (x)
  (symbolicate "A_" (princ-to-string (1+ x))))

(defun m (x)
  (if *conver-graph-use-underscore*
      (mindex x)
      (malpha x)))

(defun convert-graph-to-abc (graph)
  (let ((new-graph (make-instance 'digraph)))
    (dolist (node (nodes graph))
      (add-node new-graph (m node)))
    (dolist (edge (edges graph))
      (add-edge new-graph (mapcar #'m edge)))
    new-graph))

(defun convert-graph-to-abc-if-needed (graph)
  (if (every #'integerp (nodes graph))
      (convert-graph-to-abc graph)
      graph))

(defun sub-print (graph node-attrs stream)
  (let ((*print-case* :downcase))
    (to-dot graph
	    :attributes '(("rankdir" . "LR"))
	    :node-attrs node-attrs
	    :stream stream)))

(defun print-af-to-dot (graph &optional (stream *standard-output*))
  (sub-print (convert-graph-to-abc-if-needed graph)
             `(("shape" . ,(constantly "none")))
             stream))

(defun print-af-to-dot-with-extension (graph extension &optional (stream *standard-output*))
  (let ((extension (mapcar #'m extension)))
    (sub-print (convert-graph-to-abc-if-needed graph)
	       `(("shape" . ,(lambda (x) (if (member x extension)
                                             "circle"
                                             "none"))))
	       stream)))
