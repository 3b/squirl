;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10; indent-tabs-mode: nil -*-

(asdf:defsystem squirl
  :version "0.1 (unreleased)"
  :maintainer "Josh Marchán <sykopomp@sykosomatic.org>"
  :licence "MIT"
  :components
  ((:module "src"
            :components
            ((:file "arbiter"
                    :depends-on ("vec"))
             (:file "body"
                    :depends-on ("vec"))
             (:file "bounding-box"
                    :depends-on ("vec"))
             (:file "chipmunk"
                    :depends-on ("vec"))
             (:file "collision"
                    :depends-on ("vec"))
             (:file "hashset"
                    :depends-on ("utils"))
             (:file "package")
             (:file "utils"
                    :depends-on ("package"))
             (:file "vec"
                    :depends-on ("utils"))
             (:file "world"
                    :depends-on ("vec"))))))

