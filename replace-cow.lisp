;;;; replace-cow.lisp

(defpackage #:cl-cowsay.replace-cow
  (:export #:replace-cow))

(in-package #:cl-cowsay.replace-cow)

(defun replace-cow (cow eyes tongue thoughts)
  (setf cow (extract-cow cow)
        cow (cl-ppcre:regex-replace-all "\\$thoughts" cow thoughts)
        cow (cl-ppcre:regex-replace-all "\\$eyes" cow eyes)
        cow (cl-ppcre:regex-replace-all "\\$\\{eyes\\}" cow eyes)
        cow (cl-ppcre:regex-replace-all "\\$tongue" cow tongue)
        cow (cl-ppcre:regex-replace-all "\\$\\{tongue\\}" cow tongue)
        cow (cl-ppcre:regex-replace "\\$eye" cow (string (char eyes 0)))
        cow (cl-ppcre:regex-replace "\\$eye" cow (string (char eyes 1)))))

(defun extract-cow (str)
  (cl-ppcre:register-groups-bind (cow)
      ("\\$the_cow\\s*=\\s*<<\"*EOC\"*;*\\n([\\s\\S]+)\\nEOC\\n" str) cow))
