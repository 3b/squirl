(when (not (find-package 'SDL))
  (pushnew "/home/michael/lisp-libs/lispbuilder-read-only/lispbuilder-sdl/" asdf:*central-registry* :test #'equal)
  (pushnew "/home/michael/lisp-libs/lispbuilder-read-only/lispbuilder-sdl-image/" asdf:*central-registry* :test #'equal)
  (asdf:oos 'asdf:load-op 'lispbuilder-sdl)
;  (asdf:oos 'asdf:load-op :bordeaux-threads)
  (asdf:oos 'asdf:load-op :lispbuilder-sdl-image))

(in-package squirl)

(defparameter *bitmap-store* nil)
(defparameter *asset-directory* #P"/image/")

(defun world-box (a1 b1 a2 b2 a3 b3 a4 b4 space static-body)
  (let ((shape (make-segment static-body a1 b1 0.0)))
    (setf (shape-elasticity shape) 1.0)
    (setf (shape-friction shape) 1.0)
    (setf (shape-layers shape) 1)
    (world-add-static-shape space shape)
    
    (setf shape (make-segment static-body a2 b2 0.0))
    (setf (shape-elasticity shape) 1.0)
    (setf (shape-friction shape) 1.0)
    (setf (shape-layers shape) 1)
    (world-add-static-shape space shape)
    
    (setf shape ( make-segment static-body a3 b3 0.0))
    (setf (shape-elasticity shape) 1.0)
    (setf (shape-friction shape) 1.0)
    (setf (shape-layers shape) 1)
    (world-add-static-shape space shape)
    
    (setf shape (make-segment static-body a4 b4 0.0))
    (setf (shape-elasticity shape) 1.0)
    (setf (shape-friction shape) 1.0)
    (setf (shape-layers shape) 1)
    (world-add-static-shape space shape)))

(defun init-world ()
  (reset-shape-id-counter)
  (let* ((static-body (make-body most-positive-double-float most-positive-double-float))
	 (world (make-world :iterations 10))
	 (body (make-body 100.0 10000.0))
	 (shape (make-segment body (vec -75 0) (vec 75 0) 5)))
    (world-box (vec -320 -240) (vec -320 240)
	       (vec 320 -240) (vec 320 240)
	       (vec -320 -240) (vec 320 -240)
	       (vec -320 240) (vec 320 240)
	       world static-body)
    (world-add-body world body)
    (setf (shape-elasticity shape) 1.0)
    (setf (shape-friction shape) 1.0)
    (world-add-shape world shape)
    (world-add-constraint world (make-pivot-joint body static-body +zero-vector+ +zero-vector+))
    (return-from init-world world)))

(defun update (ticks world)
  (let* ((steps 3)
	(dt (/ 1.0 60.0 steps)))
    (dotimes (count steps)
      (world-step world dt))))

(defun add-box (world)
  (let* ((size 10.0)
	(mass 1.0)
	(verts #((vec -size -size) (vec -size size) (vec size size) (vec size -size)))
	(radius (vec-length (vec size size)))
	(body (make-body mass (moment-for-poly mass 4 verts +zero-vector+))))
    (setf (body-position body) (vec (- (* (random 100) (- 640 (* 2 radius))) (- 320 radius)) (- (* (random 100) (- 400 (* 2 radius))) (- 240 radius))))
    (setf (body-velocity body) (vec* (vec (- (* 2 (random 100)) 1) (- (* 2 (random 100)) 1)) 200))
    (world-add-body world body)
    (let ((shape (make-poly body verts +zero-vector+)))
      (setf (shape-elasticity shape) 1.0)
      (setf (shape-friction shape) 0.0)
      (world-add-shape world shape))))

(defgeneric draw-shape (shape color))

(defun shape-with-color (color)
  (lambda (element)
    (draw-shape element color)))

(defmethod draw-shape ((seg segment) color)
  (sdl:draw-line-* (vec-x (segment-a seg)) (vec-y (segment-a seg)) (vec-x (segment-b seg)) (vec-y (segment-b seg)) :color color))

(defun render (world)
  (world-hash-map (shape-with-color sdl:*green*) (world-static-shapes world)))

(defun quick-and-dirty ()
  (sdl:with-init ()
    (sdl:window 800 600 :title-caption "SQIRL PHYSICS" :icon-caption "SQUIRL-DEMO")
    (let ((world (init-world)))
      (sdl:with-events ()
	(:idle () (update (sdl:sdl-get-ticks) world)  (render world))
	(:quit-event () t)
	(:video-expose-event ())
	(:key-down-event ()
			 (when (sdl:key-down-p :sdl-key-escape)
			   (sdl:push-quit-event))
			 (when (sdl:key-down-p :sdl-key-a)
			   (add-box world))))
      (sdl:quit-sdl :force t))))