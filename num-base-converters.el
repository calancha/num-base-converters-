;;; num-base-converters.el --- Convert integers between different numeric bases  -*- lexical-binding: t -*-

;; Copyright (C) 2017 Tino Calancha

;; Author: Tino Calancha <tino.calancha@gmail.com>
;; Maintainer: Tino Calancha <tino.calancha@gmail.com>
;; Keywords: convenience, numbers, converters, tools

;; Created: Tue Aug 15 02:04:55 JST 2017
;; Package-Requires: ((emacs "24.4"))
;; Version: 0.1

;; This file is NOT part of GNU Emacs.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library defines the command `nbc-number-base-converter' to
;; translate a given integer in a numeric base to a different one.
;;
;; For instance, 10 in hexadecimal is 'A':
;; (nbc-number-base-converter "10" 10 16)
;; => "A"
;;
;; In addition, this file adds the following commands to convert
;; between the most common bases (2, 8, 10, 16):
;; `nbc-hex2dec', `nbc-hex2oct', `nbc-hex2bin'
;; `nbc-dec2hex', `nbc-dec2oct', `nbc-dec2bin'
;; `nbc-oct2hex', `nbc-oct2dec', `nbc-oct2bin'
;; `nbc-bin2hex', `nbc-bin2dec', `nbc-bin2oct'.

;;; Code:


(require 'calc-bin)
(eval-when-compile (require 'subr-x))

(defgroup num-base-converters nil
  "Convert integers between different numeric bases."
  :group 'nbc)

(defcustom nbc-define-aliases nil
  "If non-nil, create aliases without prefix 'nbc' for the converters."
  :type 'boolean
  :group 'nbc)



(defun nbc-number-base-converter (num base-in base-out)
  "Translate NUM, a string representing an integer, to a different base.
BASE-IN, an integer, is the basis of the input NUM.
BASE-OUT, an integer, is the basis to display NUM.
Both bases must satisfy: 2<= base <= 36."
  (interactive
   (let ((num (read-string "Number: "))
         (base-in (read-number "Base input: "))
         (base-out (read-number "Base output: ")))
     (list num base-in base-out)))
  (if (not (stringp num))
      (signal 'wrong-type-argument (list 'stringp num))
    (setq num (string-trim num))) ; Trim leading/trailing spaces.
  (unless (and (>= base-in 2) (<= base-in 36) (>= base-out 2) (<= base-out 36))
    (error "Base `b' must satisfy 2 <= b <= 36: base-in `%d' base-out `%d'"
           base-in base-out))
  (let* ((case-fold-search nil)
         (input (progn
                  ;; Drop base info from NUMB.
                  (cond ((string-match "\\`\\(b\\|0x\\|o\\)\\(.+\\)\\'" num)
                         (setq num (match-string 2 num)))
                        ((string-match "\\`#\\(b\\|x\\|o\\|[0-9]+r\\)\\(.+\\)\\'" num)
                         (setq num (match-string 2 num))))
                  (condition-case nil
                      ;; Translate to canonical syntaxis: #(base)r(number).
                      (read (format "#%dr%s" base-in num))
                    (invalid-read-syntax
                     (error "Wrong input: `%s' for base `%s'" num base-in))))))
    (condition-case nil
        (let* ((regexp "\\`\\([0-9]*#\\)?\\(.+\\'\\)")
               (calc-number-radix base-out)
               (output (math-format-radix input)))
          (when (string-match regexp output) ; Drop base info from OUTPUT.
            (setq output (match-string-no-properties 2 output)))
          (message "%s base %s = %s base %s" num base-in output base-out)
          output)
      (wrong-type-argument
       (error "Wrong input: `%s' for base `%s'" num base-in)))))


;;; Add translators for the most common basis: decimal, hexadecimal,
;;  octal and binary.
(eval-when-compile
  (defmacro nbc--create-converters-1 ()
    (let ((bases (list "hex" "dec" "oct" "bin"))
          forms)
      (dolist (base-out bases)
        (dolist (base-in bases)
          (if (equal base-out base-in)
              nil
            (push `(nbc--create-command ,base-in ,base-out) forms))))
      `(progn ,@forms)))

  (defmacro nbc--create-command (base-in base-out)
    (let* ((input-fn
            (lambda (x)
              (pcase x
                (`"hex" (cons "hexadecimal" 16))
                (`"dec" (cons "decimal" 10))
                (`"oct" (cons "octal" 8))
                (`"bin" (cons "binary" 2)))))
           (in-lst (funcall input-fn base-in))
           (base-in-name (car in-lst))
           (out-lst (funcall input-fn base-out))
           (func-name (format "nbc-%s2%s" base-in
                              (substring (car out-lst) 0 3)))
           (prefix-len (length "nbc-"))
           (docstring (format "Translate NUM, a string, from %s to %s."
                              (car in-lst) (car out-lst)))
           (ispec (format "sNumber in %s: " (car in-lst))))
      `(progn
         (when (bound-and-true-p nbc-define-aliases)
           (defalias (intern ,(substring func-name prefix-len))
             (intern ,func-name)))
         (defun ,(intern func-name) ,(list 'num)
           ,docstring (interactive ,ispec)
           (let ((res (nbc-number-base-converter
                       num ,(cdr in-lst) ,(cdr out-lst))))
             (message "%s %s = %s %s"
                      num ,base-in-name res ,(car out-lst))
             res))))))

(defun nbc--create-converters ()
  "Create converters between the bases 2, 8, 10 and 16."
  (nbc--create-converters-1))

(nbc--create-converters)

(provide 'num-base-converters)
;;; num-base-converters.el ends here
