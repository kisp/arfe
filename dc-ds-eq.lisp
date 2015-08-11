(defpackage :arfe.dc-ds-eq
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel)
  (:export
   ))

(in-package :arfe.dc-ds-eq)

(defun ggg (graph problem-a problem-b)
  (destructuring-bind (task-a sem-a)
      problem-a
    (destructuring-bind (task-b sem-b)
        problem-b
      )))
