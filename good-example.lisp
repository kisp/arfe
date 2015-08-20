;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe.good-example
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel
        :arfe.generate-non-isomorphic
   :argsem-soundness)
  (:import-from :metabang.bind #:bind)
  (:export
   #:find-good-example
   #:good-example-p
   #:list-good-examples))

(in-package :arfe.good-example)

(defun sseql (a b)
  (set-equal a b :test #'set-equal))

(defun sseql/= (a &rest more)
  (when more
    (do ((n a (nth i more))
         (i 0 (1+ i)))
        ((>= i (length more))
         t)
      (LET ((i2 I))
        (LOOP
          (COND
            ((< i2 (LENGTH MORE))
             (LET ((N2 (NTH i2 MORE)))
               (WHEN (sseql N N2) (RETURN-FROM sseql/= NIL)))
             (INCF i2))
            (T (RETURN NIL)))))))
  t)

(defun connectedp* (graph)
  "My notion of connectedness."
  (connectedp (graph-of graph)))

(defun good-example-p (graph)
  (let ((graph (from-adj graph)))
    (and (connectedp* graph)
         (let ((complete-extensions (list-extensions graph #'complete-extension-p))
               (preferred-extensions (list-extensions graph #'preferred-extension-p))
               (stable-extensions (list-extensions graph #'stable-extension-p)))
           (sseql/= complete-extensions preferred-extensions stable-extensions)))))

(defun find-good-example
    (&optional
       (graphs (mapcar #'from-adj
                       (generate-non-isomorphic 3 :irreflexive t))))
  (pfind-if #'good-example-p graphs))

(defun list-good-examples
    (&optional
       (graphs (mapcar #'from-adj
                       (generate-non-isomorphic 3 :irreflexive t))))
  (premove-if-not #'good-example-p graphs))
