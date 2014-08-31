;;; shinchoku-do-desuka.el --- ask you proceeding.

;; Copyright (C) 2014  

;; Author:  <tatsuhiro@TATSUHIRO-PC>
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This program ask you proceeding your works.

;;; Installation.

;; (require 'shinchoku-do-dosuka)

;;; Tasks

;;

;;; Code:

(defcustom shinchoku:default-memory-file "~/.shinchoku"
  "Your shinchoku memorize in this file")

(defcustom shinchoku:interval-min nil
  "Execute shinchoku-ask every shinchoku-interval-min.")

(defcustom shinchoku:reported-buffer "*shinchoku*"
  "The program asks you shinchoku in buffer named after this variable")

(defvar shinchoku:default-message "進捗どうですか?
## If you finish report, submit it by \"C-c C-c\".
## If you cancel report, \"C-c C-k\". 
-------------------
"
  "Default message displayed in shinchoku:reported-buffer.")
(defvar shinchoku:window-config nil
  "window configration for shinchoku-do-desuka.el")
(defvar shinchoku:keymap  (make-keymap))
(defvar shinchoku:start-char (1+ (length shinchoku:default-message))
  "shinchocku:start-char is a variable for trimming shinchoku sentences.")
(defvar shinchoku:timer-object nil
  "When you want to cancel timer, cancel this object.
Actually, you should use shinchoku:kill-timer")

(defun shinchoku:start (&optional interval)
  (interactive "nintarval?(min):")
  (setq shinchoku:interval-min (concat (number-to-string interval) " min"))
  (shinchoku:set-timer))

(defun shinchoku:set-timer ()
  (setq shinchoku:timer-object (run-at-time shinchoku:interval-min nil 'shinchoku:ask)))

(defun shinchoku:kill-timer ()
  (interactive)
  (cancel-timer shinchoku:timer-object))

(defun shinchoku:ask ()
  "ask you shinchoku"
  (interactive)
  (let ((ww (window-width))
        (wh (window-height))
        (buf (get-buffer-create shinchoku:reported-buffer)))
    (setq shinchoku:window-config (current-window-configuration))
    (select-window (split-window-vertically (* 8 (/ wh 10))))
    (switch-to-buffer (get-buffer-create shinchoku:reported-buffer))
    (shinchoku:prepare-buffer)))

(defun shinchoku:prepare-buffer ()
  (insert (concat shinchoku:default-message (format-time-string "[%Y/%m/%d %H:%M:%S]\n\n")))
  (goto-char (point-max))
  (use-local-map shinchoku:keymap)
  (define-key (current-local-map) (kbd "C-c C-c") 'shinchoku:submit)
  (define-key (current-local-map) (kbd "C-c C-k") 'shinchoku:cancel))

(defun shinchoku:submit ()
  (interactive)
  (write-region (concat (buffer-substring shinchoku:start-char (point-max))
                        "\n\n")
                nil shinchoku:default-memory-file t)
  (shinchoku:cancel))

(defun shinchoku:cancel ()
  (interactive)
  (shinchoku:set-timer)
  (kill-buffer shinchoku:reported-buffer)
  (set-window-configuration shinchoku:window-config))

(provide 'shinchoku-do-desuka)
;;; shinchoku-do-desuka.el ends here

