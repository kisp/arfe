;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe)

(defreadtable arfe
  (:merge :standard)
  (:macro-char
   #\[ #'arfe.scribble:read-skribe-bracket)
  (:macro-char
   #\] #'arfe.scribble:unbalanced-paren)
  (:dispatch-macro-char
   #\# #\?
   #'cl-interpol::interpol-reader))
