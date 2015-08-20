;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(defpackage :arfe
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel
        :arfe.generate-non-isomorphic :arfe.dc-ds-eq :arfe.good-example
   :arfe.gtfl-output-graph)
  (:export))
