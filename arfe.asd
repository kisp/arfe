;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :asdf-user)

(pushnew :hunchentoot-no-ssl *features*)

(defsystem :arfe
  :name "arfe"
  :description "argumentation framework explorer"
  :author "Kilian Sprotte <kilian.sprotte@gmail.com>"
  :version #.(with-open-file
                 (vers (merge-pathnames "version.lisp-expr" *load-truename*))
               (read vers))
  :components ((:static-file "version" :pathname #p"version.lisp-expr")
               (:file "generate")
               (:file "dc-ds-eq")
               (:file "good-example")
               (:file "gtfl-output-graph" :depends-on ("dot"))
               (:file "directg")
               (:file "dot")
               (:file "pl2af")
               (:file "local-arfex")
               (:file "package"
                :depends-on ("generate"
                             "dc-ds-eq"
                             "good-example"
                             "gtfl-output-graph"
                             "directg"
                             "dot"
                             "pl2af"
                             "local-arfex"
                             ))
               (:file "arfe" :depends-on ("package")))
  :depends-on (:alexandria :swank
               :argsem-soundness :graph-adj
               :trivial-graph-canonization
                           :graph-apx :graph-tgf :graph-dot
               :lparallel :gtfl :gzip-stream :clpl
               :sqlite))

(defmethod perform ((op test-op)
                    (system (eql (find-system :arfe))))
  (oos 'load-op :arfe-test)
  (funcall (intern "RUN!" "MYAM") :arfe-test))
