;;; pre-early-init.el --- Pre Early Init -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;;


;;; Code:

(defun display-startup-time ()
  "Display the startup time and number of garbage collections."
  (message "Emacs init loaded in %.2f seconds (Full emacs-startup: %.2fs) with %d garbage collections."
           (float-time (time-subtract after-init-time before-init-time))
           (time-to-seconds (time-since before-init-time))
           gcs-done))

(add-hook 'emacs-startup-hook #'display-startup-time 100)

;;; Reducing clutter in ~/.emacs.d by redirecting files to ~/.emacs.d/var/
(setq user-emacs-directory (expand-file-name "var/" minimal-emacs-user-directory))

;; Bonus keys (GUI only)
(add-hook
 'after-make-frame-functions
 (defun fab/setup-bonus-keys (frame)
   "Reclaim keys for GUI Emacs.

- When you type `Ctrl-i', Emacs sees it as `<C-i>', and NOT as 'Tab'
- When you type `Ctrl-m', Emacs sees it as `<C-m>', and NOT as 'Return'
- When you type `Ctrl-[', Emacs sees it as `C-<lsb>', and not as 'Esc'

That is,

- `Ctrl-i' and 'Tab' keys are different
- `Ctrl-m' and 'Return' keys are different
- `Ctrl-[' and 'Esc' keys are different"
   (with-selected-frame frame
     (when (display-graphic-p) ; don't remove this condition, if you want
                                        ; terminal Emacs to be usable
       (define-key input-decode-map (kbd "C-i") [C-i])
       (define-key input-decode-map (kbd "C-[") [C-lsb]) ; left square
                                                             ; bracket
       (define-key input-decode-map (kbd "C-m") [C-m])))))

(setq minimal-emacs-package-initialize-and-refresh nil)

;;; pre-early-init.el ends here
