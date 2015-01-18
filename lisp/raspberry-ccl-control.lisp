;; /usr/share/arduino/hardware/tools/avrdude -C/usr/share/arduino/hardware/tools/avrdude.conf -v -v -v -v -patmega328p -carduino -P/dev/ttyUSB1 -b57600 -D -Uflash:w:/tmp/build438434850780539443.tmp/rgb_led_matrix.cpp.hex:i 

(load "/home/pi/ccl/library/serial-streams.lisp")

(defparameter *a*
  (ccl::make-serial-stream "/dev/ttyUSB0"
			   :format :binary
			   :baud-rate 115200
			   :parity nil
			   :char-bits 8
			   :stop-bits 1
			   :flow-control nil))


(let ((a (make-array (+ 1 (* 256 3))  :element-type '(unsigned-byte 8))))
  (setf (aref a 0) 254)
  (dotimes (c 3)
    (dotimes (j 16)
     (dotimes (i 16)
       (setf (aref a (+ 1 (+ i (* 16 j)) (* 256 c))) 
	     (if (= 0 (mod j 2)) 10 0)))))
  (write-sequence a *a*)
  nil)


(let* ((a1 (make-array (* 3 256)  :element-type '(unsigned-byte 8)))
       (a (make-array (list 16 16 3)  :element-type '(unsigned-byte 8)
		      :displaced-to a1)))
  (dotimes (c 3)
    (dotimes (j 16)
      (dotimes (i 16)
	(let ((r (sqrt (+ (* i i) (* j j)))))
	  (setf (aref a j i c) ;; x
		(if (or (= i j) (= (- 16 i) j)) 34 0))))))
  (write-byte 254 *a*)
  (write-sequence a1 *a*)
  nil)

(let* ((a1 (make-array (* 3 256)  :element-type '(unsigned-byte 8)))
       (a (make-array (list 16 16 3)  :element-type '(unsigned-byte 8)
		      :displaced-to a1)))
  (loop for k below 100 do
   (dotimes (c 3)
     (dotimes (j 16)
       (dotimes (i 16)
	 (let* ((ii (- i 7.5))
		(jj (* .8 (- j 7.5)))
		(r (sqrt (+ (* ii ii) (* jj jj)))))
	   (setf (aref a j i c) 
		 (min 253 (max 0 (floor (+ -8 (* 12 (+ 1 (sin (+ (* .3 k) r)))))))))))))
   (write-byte 254 *a*)
   (write-sequence a1 *a*))
  nil)


(let* ((a1 (make-array (* 3 256)  :element-type '(unsigned-byte 8)))
       (a (make-array (list 16 16 3)  :element-type '(unsigned-byte 8)
		      :displaced-to a1)))
  (loop for k below 100 do
       (dotimes (c 3)
	 (dotimes (j 16)
	   (dotimes (i 16)
	     (let* ((ii (- i 7.5))
		    (jj (* .8 (- j 7.5)))
		    (r (sqrt (+ (* ii ii) (* jj jj)))))
	       (setf (aref a j i c) 
		     (if (or (= i 0) (= i 15)
			     (= j 0) (= j 15))
			 255 0)))))))
  (write-byte 254 *a*)
  (write-sequence a1 *a*)
  nil)

(defun read-pgm (filename)
  (declare ((or pathname string) filename)
           (values (or (simple-array (unsigned-byte 8) 2)
                       (simple-array (unsigned-byte 16) 2)) &optional))
  (with-open-file (s filename)
    (unless (equal (symbol-name (read s)) "P5")
      (error "no PGM file"))
    (let* ((w (read s))
           (h (read s))
           (grays (read s))
           (pos (file-position s)))
      (declare ((integer 0 65535) grays w h))
      (let* ((type (if (<= grays 255)
                       '(unsigned-byte 8)
                       '(unsigned-byte 16)))
             (data (make-array (list h w)
                               :element-type type))
             (data-1d (make-array (* h w)
                                  :element-type type
                                  :displaced-to data)))
        (with-open-file (s2 filename :element-type type)
          (file-position s2 pos)
          (read-sequence data-1d s2))
        data))))

 
(defparameter *font-img* (read-pgm "font_arial.pgm"))

(defparameter *font*
 (let ((a (make-array (list 16 16 16 16) :element-type '(unsigned-byte 8))))
   (dotimes (ii 16)
     (dotimes (jj 16)
       (dotimes (i 16)
	 (dotimes (j 16)
	   (setf (aref a jj ii j i)
		 (aref *font-img* (+ j (* 16 jj)) (+ i (* 16 ii))))))))
   a))


(let* ((a1 (make-array (* 3 256)  :element-type '(unsigned-byte 8)))
       (a (make-array (list 16 16 3)  :element-type '(unsigned-byte 8)
		      :displaced-to a1)))
  (loop for k below 100 do
       (let ((ii (random 16)
     )
	     (jj (random 16)))
	(dotimes (c 3)
	  (dotimes (j 16)
	    (dotimes (i 16)
	      (setf (aref a j i c)
		    (floor (aref *font*  jj ii (- 15 j) i) 10))))))
       (write-byte 254 *a*)
       (write-sequence a1 *a*)
       (sleep .3))
  nil)

(defparameter *arial-font-map*
  " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ ")

(char-code #\!)
(floor (char-code #\1) 16)

(defparameter *font-map*
 (let ((a (make-array 256 :element-type '(unsigned-byte 8))))
   (loop for c across *arial-font-map* and i from 16
      do (setf (aref a (char-code c)) i))
   a))

(loop for c across "!\"01@das ist ein test" collect
     (let ((v (aref *font-map* (char-code c))))
       (multiple-value-list (floor v 16))))


(let* ((a1 (make-array (* 3 256)  :element-type '(unsigned-byte 8)))
       (a (make-array (list 16 16 3)  :element-type '(unsigned-byte 8)
		      :displaced-to a1)))
  (loop for c across "12345" do
       (let ((v (char-code c)))
	 (multiple-value-bind (jj ii) (floor v 16)
	   (dotimes (c 3)
	     (dotimes (j 16)
	       (dotimes (i 16)
		 (setf (aref a j i c)
		       (floor (aref *font*  jj ii  (- 15 j) i) 10)))))))
       (progn
	 (write-byte 254 *a*)
	 (write-sequence a1 *a*)
	 (sleep 1)))
  
  nil)