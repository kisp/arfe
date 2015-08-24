;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe
  (:use
   :alexandria
   :arfe.dc-ds-eq
   :arfe.directg
   :arfe.generate-non-isomorphic
   :arfe.good-example
   :arfe.gtfl-output-graph
   :argsem-soundness
   :common-lisp
   :graph
   :graph-adj
   :graph-apx
   :graph-dot
   :graph-tgf
   :gtfl
   :lparallel
   :trivial-graph-canonization
   )
  #+sbcl(:import-from :sb-ext #:quit #:exit)
  (:export
   #:load-data))
