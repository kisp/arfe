#!/usr/local/bin/sbcl --script

(in-package #:common-lisp-user)

(require :sb-posix)

(defun main ()
  (let ((pauldist (merge-pathnames "quicklisp/dists/pauldist/"
                                   (user-homedir-pathname))))
    (if (probe-file pauldist)
        (progn
          (warn "~S already exists" pauldist))
        (let ((*default-pathname-defaults* pauldist))
          (ensure-directories-exist pauldist)
          (sb-posix:chdir pauldist)
          (sb-ext:run-program "/usr/bin/curl"
                              (list "http://pauldist.kisp.in/pauldist.txt")
                              :output "distinfo.txt"
                              :error nil)
          (sb-ext:run-program "/usr/bin/touch"
                              (list "enabled.txt"))))))

(main)
