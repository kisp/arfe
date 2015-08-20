;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe.directg
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot)
  (:export
   #:map-directg-file))

(in-package :arfe.directg)

(defun plist-alist* (plist)
  (let (alist)
    (do ((tail plist (cddr tail)))
        ((endp tail) (nreverse alist))
      (push (list (car tail) (cadr tail)) alist))))

(defun line2graph (line)
  (destructuring-bind (order num-edges &rest rest)
      (read-from-string (format nil "(~A)" line))
    (declare (ignore num-edges))
    (populate (make-instance 'digraph)
              :nodes (iota order)
              :edges (plist-alist* rest))))

(defun map-directg-file (fn pathname)
  (with-open-file (input pathname)
    (loop for line = (read-line input nil)
          while line
          do (funcall fn (line2graph line)))))
