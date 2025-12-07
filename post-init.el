;;; post-init.el --- Post Init -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; My Emacs config


;;; Code:

;; User variables
(defvar fab/dark-theme 'modus-vivendi-tinted)
(defvar fab/light-theme 'modus-operandi)
(defvar fab/org-directory (expand-file-name "~/MEGA/org/"))
(defvar fab/bibliography-dir (concat fab/org-directory "biblio/"))
(defvar fab/bibliography-file (concat fab/bibliography-dir "references.bib"))

(use-package modus-themes
  :config
  (setopt modus-themes-common-palette-overrides modus-themes-preset-overrides-faint)
  (modus-themes-select fab/dark-theme)
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-to-toggle `(,fab/dark-theme ,fab/light-theme))
  (modus-themes-headings
   '((1 . (1.2))
     (2 . (1.15))
     (agenda-date . (variable-pitch 1.15))
     (agenda-structure . (variable-pitch 1.2))
     (t . (1.1))))
  :bind
  ("<f9>" . #'modus-themes-toggle))

(use-package transient
  :defer t)

(use-package magit
  :defer t
  :custom
  (magit-tramp-pipe-stty-settings 'pty)
  ;; (magit-format-file-function #'magit-format-file-nerd-icons))
  )

;;; post-init.el ends here
