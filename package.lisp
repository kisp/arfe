;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe
  (:use
   :alexandria
   :arfe.dc-ds-eq
   :arfe.directg
   :arfe.dot
   :arfe.generate-non-isomorphic
   :arfe.good-example
   :arfe.gtfl-output-graph
   :arfe.pl2af
   :arfe.local-arfex
   :argsem-soundness
   :clpl
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
   #:load-data
   #:list-data
   #:with-open-gzip-file))
