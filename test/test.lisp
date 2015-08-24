;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe-test)

(defsuite* :arfe-test)

(defun set-equal* (a b)
  (set-equal a b :test #'equal))

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

(deftest generate-non-isomorphic
  (with-init-kernel-handler
    (is (eql 2 (length (generate-non-isomorphic 1))))
    (is (eql 10 (length (generate-non-isomorphic 2))))
    (is (eql 104 (length (generate-non-isomorphic 3))))))

(deftest generate-non-isomorphic.irreflexive
  (with-init-kernel-handler
    (is (eql 1 (length (generate-non-isomorphic 1 :irreflexive t))))
    (is (eql 3 (length (generate-non-isomorphic 2 :irreflexive t))))
    (is (eql 16 (length (generate-non-isomorphic 3 :irreflexive t))))))

(deftest list-good-examples.1
  (finishes (list-good-examples)))
