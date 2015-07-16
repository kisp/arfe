;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :asdf-user)

(defsystem :arfe-test
  :name "arfe-test"
  :description "Tests for arfe"
  :components ((:module "test"
                :components ((:file "package")
                             (:file "test" :depends-on ("package")))))
  :depends-on (:arfe :myam :alexandria))

(defmethod perform ((op test-op)
                    (system (eql (find-system :arfe-test))))
  (perform op (find-system :arfe)))
