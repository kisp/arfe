;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe-test)

(defsuite* :arfe-test)

(defun set-set-equal (a b)
  (set-equal a b :test (lambda (a b) (set-equal a b :test #'equal))))

(defun init-kernel (condition)
  (declare (ignore condition))
  (invoke-restart 'lparallel:make-kernel 1))

(defmacro with-init-kernel-handler (&body body)
  `(handler-bind ((lparallel:no-kernel-error #'init-kernel))
     ,@body))

(deftest estimate-dc-ds-eq-classes
  (with-init-kernel-handler
    (is (set-set-equal
         '(((:DS :PR)) ((:DS :ST)) ((:DC :ST)) ((:DC :PR) (:DC :CO))
           ((:DS :CO) (:DS :GR) (:DC :GR)))
         (estimate-dc-ds-eq-classes)))))
