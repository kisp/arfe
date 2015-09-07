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
  :serial t
  :components ((:static-file "version" :pathname #p"version.lisp-expr")
	       (:file "packages")
               (:file "readtable")
               (:file "generate")
               (:file "dc-ds-eq")
               (:file "good-example")
	       (:file "dot")
               (:file "gtfl-output-graph")
               (:file "directg")               
               (:file "pl2af")
               (:file "local-arfex")          
               (:file "arfe"))
  :depends-on (:alexandria :swank
               :argsem-soundness :graph-adj
               :trivial-graph-canonization
                           :graph-apx :graph-tgf :graph-dot
               :lparallel :gtfl :gzip-stream :clpl
               :sqlite :cl-interpol :named-readtables))

(defmethod perform ((op test-op)
                    (system (eql (find-system :arfe))))
  (oos 'load-op :arfe-test)
  (funcall (intern "RUN!" "MYAM") :arfe-test))
