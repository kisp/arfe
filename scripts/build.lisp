(in-package :cl-user)

(require 'asdf)

(if (sb-ext:posix-getenv "PORTAGE_BUILD_USER")
    (asdf:initialize-source-registry `(:source-registry (:directory (,(uiop:getcwd) "asd")) :ignore-inherited-configuration))
    (load (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))

(push :standalone *features*)

(ql:quickload "arfe")

(require 'sb-aclrepl)

(defun in-package-arfe ()
  (in-package :arfe))

(push 'in-package-arfe *init-hooks*)
(push 'sb-ext:enable-debugger *init-hooks*)

(sb-ext:save-lisp-and-die "arfe"
                          ;; :toplevel #'day-plan::day-plan
                          :executable t
                          :compression nil)
