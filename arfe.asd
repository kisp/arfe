;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :asdf-user)

(defsystem :arfe
  :name "arfe"
  :description "argumentation framework explorer"
  :author "Kilian Sprotte <kilian.sprotte@gmail.com>"
  :version #.(with-open-file
                 (vers (merge-pathnames "version.lisp-expr" *load-truename*))
               (read vers))
  :components ((:static-file "version" :pathname #p"version.lisp-expr")
               (:file "package")
               (:file "arfe" :depends-on ("package"))
               )
  :depends-on (:alexandria
               :argsem-soundness :graph-adj
               :trivial-graph-canonization
               :graph-apx :graph-tgf :graph-dot
               :lparallel))

(defmethod perform ((op test-op)
                    (system (eql (find-system :arfe))))
  (oos 'load-op :arfe-test)
  (funcall (intern "RUN!" "MYAM") :arfe-test))
