;;; post-init.el --- Post Init -*- no-byte-compile: t; lexical-binding: t; -*-

;;; Commentary:
;; My Emacs config


;;; Code:

(use-package on ;; Additional hooks for faster startup
  :demand)

(use-package emacs
  :ensure nil
  :init
  ;; User variables
  (defvar fab/dark-theme 'modus-vivendi-tinted)
  (defvar fab/light-theme 'modus-operandi)
  (defvar fab/org-directory (expand-file-name "~/MEGA/org/"))
  (defvar fab/bibliography-dir (concat fab/org-directory "biblio/"))
  (defvar fab/bibliography-file (concat fab/bibliography-dir "references.bib"))

  ;; User keymaps
  (defvar-keymap fab/toggle-prefix-map :doc "My toggle prefix map.")
  (defvar-keymap fab/open-prefix-map :doc "My open prefix map.")
  (defvar-keymap fab/notes-prefix-map :doc "My notes prefix map.")
  (defvar-keymap fab/llm-prefix-map :doc "My LLM-related prefix map.")

  :bind-keymap
  ("C-c t" . fab/toggle-prefix-map)
  ("C-c o" . fab/open-prefix-map)
  ("C-c n" . fab/notes-prefix-map)
  ("C-c l" . fab/llm-prefix-map)

  :custom
  (user-full-name "Fabrizio Contigiani")
  (user-mail-address "fabcontigiani@gmail.com")
  
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  :config
  ;; Font configuration
  (set-face-attribute 'default nil :family "IBM Plex Mono" :height 110)
  (set-face-attribute 'fixed-pitch nil :family "IBM Plex Mono" :height 1.0)
  (set-face-attribute 'variable-pitch nil :family "IBM Plex Sans" :height 1.0)
  (set-face-attribute 'variable-pitch-text nil :family "IBM Plex Sans" :height 1.0)
  (set-face-attribute 'fixed-pitch-serif nil :family "IBM Plex Mono" :height 1.0)

  ;; Mode-line
  (column-number-mode)

  (repeat-mode)
  
  ;; Make C-g a bit more helpful, credit to Prot:
  ;; https://protesilaos.com/codelog/2024-11-28-basic-emacs-configuration
  (defun fab/keyboard-quit-dwim ()
    "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
    (interactive)
    (cond
     ((region-active-p)
      (keyboard-quit))
     ((derived-mode-p 'completion-list-mode)
      (delete-completion-window))
     ((> (minibuffer-depth) 0)
      (abort-recursive-edit))
     (t
      (keyboard-quit))))

  (keymap-global-unset "C-z")
  (keymap-global-unset "C-x C-z")
  :bind
  ("C-g" . #'fab/keyboard-quit-dwim))

(use-package modus-themes
  :config
  (setopt modus-themes-common-palette-overrides
          modus-themes-preset-overrides-faint)
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

(use-package undo-fu
  :custom
  (undo-no-redo t)
  :bind
  ([remap undo] . #'undo-fu-only-undo)
  ([remap undo-redo] . #'undo-fu-only-redo))

(use-package undo-fu-session
  :config (undo-fu-session-global-mode))

(use-package repeat
  :ensure nil
  :hook on-first-input)

(use-package vundo
  :bind ("C-c u" . #'vundo))

(use-package display-line-numbers
  :ensure nil
  :hook (prog-mode LaTeX-mode bibtex-mode)
  :custom
  (display-line-numbers-type 'relative)
  (display-line-numbers-width-start 100))

(use-package elisp-demos
  :config
  (advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1))

(use-package whitespace
  :ensure nil
  :bind
  (:map fab/toggle-prefix-map
        ("w" . whitespace-mode)))

(use-package outline
  :ensure nil
  :hook (prog-mode . outline-minor-mode)
  :custom
  (outline-minor-mode-prefix (kbd "<Ctl-i>"))
  (outline-minor-mode-cycle t)
  (outline-minor-mode-cycle-filter 'bolp)
  (outline-minor-mode-use-buttons 'in-margins))

(use-package vertico
  :hook elpaca-after-init)

(use-package vertico-directory
  :ensure nil
  :after vertico
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-mouse
  :ensure nil
  :after vertico
  :config (vertico-mouse-mode))

(use-package vertico-multiform
  :ensure nil
  :after vertico
  :config (vertico-multiform-mode))

(use-package marginalia
  :hook elpaca-after-init)

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package consult
  :demand t
  ;; Replace bindings. Lazily loaded due by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c r" . consult-recent-file)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-fd)                  ;; Alternative: consult-find
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)

  ;; Avoid indenting when previewing org files
  ;; (add-to-list 'consult-preview-variables '(org-startup-indented . nil))

  ;; Disable automatic latex preview when using consult live preview
  ;; (add-to-list 'consult-preview-variables '(org-startup-with-latex-preview . nil))
  )

(use-package consult-dir
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file)))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)  ;; alternative for `describe-bindings'
   :map embark-symbol-map
   ("%" . #'xref-find-references-and-replace))
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package wgrep
  :after consult)

(use-package avy
  :config
  (defun avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)
  (setf (alist-get ?\; avy-dispatch-alist) 'avy-action-embark)
  :bind
  ((:map isearch-mode-map
         ("C-;" . avy-isearch))
   (:map global-map
         ("C-c C-j" . avy-resume)
         ("C-;" . avy-goto-char-timer))))

(use-package expreg
  :bind
  ("C-=" . expreg-expand)
  ("C-+" . expreg-contract))

(use-package multiple-cursors
  :bind
  ("C->" . mc/mark-next-like-this)
  ("C-<" . mc/mark-previous-like-this)
  ("C-c C-<" . mc/mark-all-like-this)
  ("C-S-c C-S-c" . mc/edit-lines))

(use-package corfu
  ;; Optional customizations
  :hook
  (eshell-mode . (lambda ()
                   (setq-local corfu-auto nil)
                   (corfu-mode)))
  ;; :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode)
  :custom
  (corfu-min-width 20))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :config
  (corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay '(1.25 . 0.5)))

(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind-keymap ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

(use-package jinx
  :hook (org-mode LaTeX-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :config
  (add-to-list 'vertico-multiform-categories
               '(jinx grid (vertico-grid-annotate . 20)))
  :custom
  (jinx-languages "es_AR en_US"))

(use-package ibuffer
  :ensure nil
  :demand t
  :hook (ibuffer-mode . ibuffer-auto-mode)
  :bind ([remap list-buffers] . ibuffer))

(use-package tab-bar
  :ensure nil
  :config
  (tab-bar-mode)
  (tab-bar-history-mode)
  :custom
  (tab-bar-show 1)
  (tab-bar-format '(tab-bar-format-menu-bar
                    tab-bar-format-history
                    tab-bar-format-tabs-groups
                    tab-bar-separator
                    tab-bar-format-add-tab))
  (tab-bar-new-tab-choice "*scratch*")
  (tab-bar-close-button-show nil)
  (tab-bar-tab-hints t)
  (tab-bar-select-tab-modifiers '(meta))
  (tab-bar-history-limit 100))

(use-package autorevert
  :ensure nil
  :commands (auto-revert-mode global-auto-revert-mode)
  :hook
  (elpaca-after-init . global-auto-revert-mode)
  :custom
  (auto-revert-interval 3)
  (auto-revert-remote-files nil)
  (auto-revert-use-notify t)
  (auto-revert-avoid-polling nil)
  (auto-revert-verbose t))

(use-package recentf
  :ensure nil
  :commands (recentf-mode recentf-cleanup)
  :hook
  (after-init . recentf-mode)

  :custom
  (recentf-auto-cleanup (if (daemonp) 300 'never))
  (recentf-exclude
   (list "\\.tar$" "\\.tbz2$" "\\.tbz$" "\\.tgz$" "\\.bz2$"
         "\\.bz$" "\\.gz$" "\\.gzip$" "\\.xz$" "\\.zip$"
         "\\.7z$" "\\.rar$"
         "COMMIT_EDITMSG\\'"
         "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
         "-autoloads\\.el$" "autoload\\.el$"))

  :config
  ;; A cleanup depth of -90 ensures that `recentf-cleanup' runs before
  ;; `recentf-save-list', allowing stale entries to be removed before the list
  ;; is saved by `recentf-save-list', which is automatically added to
  ;; `kill-emacs-hook' by `recentf-mode'.
  (add-hook 'kill-emacs-hook #'recentf-cleanup -90)
  :bind ("C-c r" . #'recentf))

(use-package savehist
  :ensure nil
  :commands (savehist-mode savehist-save)
  :hook
  (after-init . savehist-mode)
  :custom
  (savehist-autosave-interval 600)
  (savehist-additional-variables
   '(kill-ring                        ; clipboard
     register-alist                   ; macros
     mark-ring global-mark-ring       ; marks
     search-ring regexp-search-ring)))

(use-package saveplace
  :ensure nil
  :commands (save-place-mode save-place-local-mode)
  :hook
  (after-init . save-place-mode)
  :custom
  (save-place-limit 400))

;; Enable `auto-save-mode' to prevent data loss. Use `recover-file' or
;; `recover-session' to restore unsaved changes.
(setq auto-save-default t)
(setq auto-save-interval 300)
(setq auto-save-timeout 30)

(use-package isearch
  :ensure nil
  :defer t
  :custom
  (isearch-lazy-count t)
  (isearch-wrap-pause 'no)
  (search-whitespace-regexp ".?*"))

(use-package popper
  :bind (("C-`"   . popper-toggle)
         ("M-`"   . popper-cycle)
         ("C-M-`" . popper-toggle-type))
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     "Output\\*$"
     "\\*Async Shell Command\\*"
     help-mode
     compilation-mode
     eat-mode
     "\\*eshell\\*"))
  :init
  (popper-mode 1)
  (popper-tab-line-mode 1)
  :custom
  (popper-window-height 16))

(use-package minions
  :config
  (minions-mode))

(use-package spacious-padding
  :config
  (spacious-padding-mode)
  :bind
  ("<f7>" . #'spacious-padding-mode))

(use-package rainbow-delimiters
  :hook prog-mode)

(use-package indent-bars
  :custom
  (indent-bars-no-descend-lists t) ; no extra bars in continued func arg lists
  (indent-bars-treesit-support t)
  (indent-bars-treesit-ignore-blank-lines-types '("module"))
  ;; Add other languages as needed
  (indent-bars-treesit-scope '((python function_definition class_definition for_statement
                                       if_statement with_statement while_statement)))
  ;; Note: wrap may not be needed if no-descend-list is enough
  ;;(indent-bars-treesit-wrap '((python argument_list parameters ; for python, as an example
  ;;                      list list_comprehension
  ;;                      dictionary dictionary_comprehension
  ;;                      parenthesized_expression subscript)))
  :hook (python-base-mode . indent-bars-mode))

(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t))

(use-package pulsar
  :config
  (pulsar-global-mode 1))

(use-package lin
  :config
  (lin-global-mode)
  :custom
  (lin-face nil "Do not override hl-line-face"))

(use-package hl-line
  :ensure nil
  :defer t
  :custom
  (hl-line-sticky-flag nil))

(use-package olivetti
  :bind (:map fab/toggle-prefix-map
              ("o" . olivetti-mode)))

(use-package logos
  :bind
  (([remap narrow-to-region] . #'logos-narrow-dwim)
   ([remap forward-page] . #'logos-forward-page-dwim)
   ([remap backward-page] . #'logos-backward-page-dwim)
   ("<f8>" . #'logos-focus-mode))
  :custom
  (logos-outlines-are-pages t)
  (logos-olivetti t))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :hook (minibuffer-setup . nerd-icons-completion-mode)
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

(use-package dired
  :ensure nil
  :defer t
  :hook (dired-mode . dired-hide-details-mode)
  :custom
  ;; (dired-listing-switches "-alFh")
  (dired-movement-style 'bouded-files)
  (dired-kill-when-opening-new-dired-buffer t))

(use-package trashed
  :commands (trashed)
  :custom
  (delete-by-moving-to-trash t)
  (trashed-action-confirmer 'y-or-n-p)
  (trashed-use-header-line t)
  (trashed-sort-key '("Date deleted" . t))
  (trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package dired-subtree
  :bind (:map dired-mode-map
              ("<tab>" . dired-subtree-toggle)
              ("TAB" . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-remove)
              ("S-TAB" . dired-subtree-remove))
  :custom
  (dired-subtree-use-backgrounds nil))

(use-package dired-sidebar
  :bind
  (:map fab/toggle-prefix-map
        ("b" . dired-sidebar-toggle-sidebar))
  :custom
  (dired-sidebar-theme 'nerd-icons))

(use-package transient
  :defer t)

(use-package magit
  :defer t
  :custom
  (magit-tramp-pipe-stty-settings 'pty)
  (magit-format-file-function #'magit-format-file-nerd-icons))

(use-package diff-hl
  :hook
  (find-file    . diff-hl-mode)
  (vc-dir-mode  . diff-hl-dir-mode)
  (dired-mode   . diff-hl-dired-mode)
  (diff-hl-mode . diff-hl-flydiff-mode)
  :config
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :custom
  (diff-hl-draw-borders nil))

(use-package apheleia
  :commands (apheleia-format-buffer)
  :bind (:map fab/toggle-prefix-map
              ("f" . apheleia-mode))
  :config
  (add-to-list 'apheleia-formatters
               '(tex-fmt "tex-fmt" "--quiet" "--stdin"))
  (setf (alist-get 'LaTeX-mode apheleia-mode-alist) 'tex-fmt))

(use-package free-keys
  :ensure (:host github :repo "Fuco1/free-keys")
  :commands (free-keys))

(use-package gptel
  :config
  (delete (assoc "ChatGPT" gptel--known-backends) gptel--known-backends)
  (setq gptel-model 'gpt-5-mini
        gptel-backend (gptel-make-gh-copilot "Copilot"))
  :bind (:map fab/llm-prefix-map
              ("l" . #'gptel)
              ("r" . #'gptel-add) ; region
              ("f" . #'gptel-add-file)))

(use-package gptel-agent
  :defer t
  :config (gptel-agent-update)
  :bind (:map fab/llm-prefix-map
              ("a" . #'gptel-agent)))

(use-package gptel-quick
  :ensure (:host github :repo "karthink/gptel-quick")
  :bind (:map fab/llm-prefix-map
              ("q" . #'gptel-quick)))

(use-package track-changes
  :defer t) ;; copilot dependency

(use-package copilot
  :defer t
  :init
  (defun fab/toggle-copilot-mode ()
    "Toggle copilot-mode."
    (interactive)
    (if (copilot-mode 'toggle)
        (message "Copilot mode enabled")
      (message "Copilot mode disabled")))
  :bind (:map fab/toggle-prefix-map
              ("g" . #'fab/toggle-copilot-mode)
              :map copilot-completion-map
              ("C-g" . #'copilot-clear-overlay)
              ("<tab>" . #'copilot-accept-completion)
              ("M-<return>" . #'copilot-accept-completion)
              ("C-M-g" . #'copilot-panel-complete)
              ("C-e" . #'copilot-accept-completion-by-line)
              ("M-f" . #'copilot-accept-completion-by-word)
              ("M-}" . #'copilot-accept-completion-by-paragraph)
              ("M-n" . #'copilot-next-completion)
              ("M-p" . #'copilot-previous-completion)))

(use-package org
  :defer t
  :ensure nil
  ;; :ensure `(org :repo "https://code.tecosaur.net/tec/org-mode.git/"
                ;; :branch "dev")
  :hook
  (org-mode . (lambda ()
                (auto-fill-mode)
                (visual-line-mode)
                (variable-pitch-mode)))
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (latex . t)
     (C . t)
     (python . t)
     (lua . t)
     (matlab . t)
     (shell . t)
     (plantuml . t)))
  :custom
  (org-M-RET-may-split-line '((default . nil)))
  (org-insert-heading-respect-content t)
  (org-directory fab/org-directory)
  (org-agenda-files `(,(concat fab/org-directory "tasks.org")))
  (org-archive-location "::* Archived Tasks")
  (org-archive-reversed-order t)
  (org-capture-templates
   '(("t" "Tasks")
     ("tf" "Final Exam" entry
      (file+headline "tasks.org" "Finales")
      "** TODO Final %?\nSCHEDULED: %^{Scheduled: }t")
     ("te" "Exam" entry
      (file+headline "tasks.org" "Parciales")
      "** TODO Parcial %?\nSCHEDULED: %^{Scheduled: }t")
     ("tp" "Project/Assignment" entry
      (file+headline "tasks.org" "Trabajos Prácticos")
      "** TODO Trabajo Práctico %?\nDEADLINE: %^{Deadline: }t")
     ("tu" "Unscheduled" entry
      (file+headline "tasks.org" "Unscheduled")
      "** TODO %?")))
  (org-capture-bookmark nil "Don't bookmark last position when capturing")
  (org-id-method 'ts)
  (org-id-ts-format "%Y%m%dT%H%M%S")
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-todo-keywords
   '((sequence "TODO(t)" "WAIT(w!)" "|" "CANCEL(c!)" "DONE(d!)")))
  (org-pretty-entities t)
  (org-pretty-entities-include-sub-superscripts nil)
  (org-startup-with-latex-preview t)
  (org-startup-indented t)
  (org-startup-folded 'showeverything)
  (org-cycle-hide-drawers t)
  (org-fontify-quote-and-verse-blocks t)
  (org-highlight-latex-and-related '(native scripts entities))
  (org-latex-packages-alist '(("" "siunitx" t)
                              ("" "circuitikz" t)))
  (org-src-preserve-indentation nil)
  (org-edit-src-content-indentation 0)
  (org-return-follows-link t)
  (org-use-speed-commands t)
  (org-attach-auto-tag nil)
  (org-attach-id-dir (concat fab/org-directory "attach"))
  (org-attach-id-to-path-function-list '(org-attach-id-ts-folder-format
                                         org-attach-id-uuid-folder-format
                                         org-attach-id-fallback-folder-format))
  :custom-face
  (org-block ((t (:background unspecified))))
  (org-document-title ((t (:family "IBM Plex Serif" :height 1.5))))
  :bind
  (:map fab/open-prefix-map
        ("a" . #'org-agenda)
        ))

(use-package org-latex-preview
  :disabled
  :ensure nil
  :after org
  :config
  ;; Increase preview width
  (plist-put org-latex-preview-appearance-options :page-width 0.8)

  ;; Increase preview scale
  (plist-put org-latex-preview-appearance-options :zoom 1.25)

  ;; Use dvisvgm to generate previews
  ;; You don't need this, it's the default:
  (setq org-latex-preview-process-default 'dvisvgm)

  ;; Turn on auto-mode, it's built into Org and much faster/more featured than
  ;; org-fragtog. (Remember to turn off/uninstall org-fragtog.)
  (add-hook 'org-mode-hook 'org-latex-preview-auto-mode)

  ;; Block C-n and C-p from opening up previews when using auto-mode
  (add-hook 'org-latex-preview-auto-ignored-commands 'next-line)
  (add-hook 'org-latex-preview-auto-ignored-commands 'previous-line)

  ;; Enable consistent equation numbering
  (setq org-latex-preview-numbered t)

  ;; Bonus: Turn on live previews.  This shows you a live preview of a LaTeX
  ;; fragment and updates the preview in real-time as you edit it.
  ;; To preview only environments, set it to '(block edit-special) instead
  (setq org-latex-preview-live t)

  ;; More immediate live-previews -- the default delay is 1 second
  (setq org-latex-preview-live-debounce 0.25))

(use-package corg
  :ensure (:host github :repo "isamert/corg.el")
  :hook (org-mode . corg-setup))

(use-package denote
  :config
  (require 'consult-denote)
  (denote-rename-buffer-mode)
  :custom
  (denote-directory (concat fab/org-directory "denote/"))
  :hook
  (dired-mode . denote-dired-mode)
  :custom-face
  (denote-faces-link ((t (:slant italic))))
  :bind
  (:map fab/notes-prefix-map
        ("n" . denote-create-note)
        ("o" . denote-open-or-create)
        ("d" . denote-date)
        ("i" . denote-link-or-create)
        ("l" . denote-find-link)
        ("b" . denote-find-backlink)
        ("r" . denote-rename-file)
        ("R" . denote-rename-file-using-front-matter)
        ("k" . denote-rename-file-keywords)))

(use-package denote-journal
  :hook
  (calendar-mode . denote-journal-calendar-mode)
  :config
  (denote-rename-buffer-mode t)
  :bind (:map fab/notes-prefix-map
              ("j" . #'denote-journal-new-or-existing-entry)))

(use-package denote-org
  :after denote)

(use-package consult-denote
  :config
  (consult-denote-mode)
  :custom
  (consult-denote-grep-command #'consult-ripgrep)
  :bind (:map fab/notes-prefix-map
              ("f" . consult-denote-find)
              ("g" . consult-denote-grep)))

(use-package citar
  :hook ((LaTeX-mode org-mode) . citar-capf-setup)
  :init
  (setq citar--multiple-setup (cons "<tab>"  "RET")) ; <C-i> workaround
  :config
  (require 'bibtex)
  (require 'citar-denote)
  (defvar citar-indicator-notes-icons
    (citar-indicator-create
     :symbol (nerd-icons-mdicon
              "nf-md-notebook"
              :face 'nerd-icons-blue
              :v-adjust -0.3)
     :function #'citar-has-notes
     :padding "  "
     :tag "has:notes"))

  (defvar citar-indicator-links-icons
    (citar-indicator-create
     :symbol (nerd-icons-octicon
              "nf-oct-link"
              :face 'nerd-icons-orange
              :v-adjust -0.1)
     :function #'citar-has-links
     :padding "  "
     :tag "has:links"))

  (defvar citar-indicator-files-icons
    (citar-indicator-create
     :symbol (nerd-icons-faicon
              "nf-fa-file"
              :face 'nerd-icons-green
              :v-adjust -0.1)
     :function #'citar-has-files
     :padding "  "
     :tag "has:files"))

  (setq citar-indicators
        (list citar-indicator-files-icons
              citar-indicator-notes-icons
              citar-indicator-links-icons))
  :custom
  (org-cite-insert-processor 'citar)
  (org-cite-follow-processor 'citar)
  (org-cite-activate-processor 'citar)
  (citar-bibliography fab/bibliography-file)
  (citar-library-paths `(,fab/bibliography-dir))
  :bind (:map fab/notes-prefix-map
              ("c o" . citar-open)
              :map org-mode-map
              ("C-c b" . #'org-cite-insert)))

(use-package citar-embark
  :after (citar embark)
  :config
  (citar-embark-mode))

(use-package citar-denote
  :config
  (citar-denote-mode)
  :custom
  (citar-open-always-create-notes nil)
  (citar-denote-file-type 'org)
  (citar-denote-subdir nil)
  (citar-denote-signature nil)
  (citar-denote-template nil)
  (citar-denote-keyword "bib")
  (citar-denote-use-bib-keywords nil)
  (citar-denote-title-format "author-year-title")
  (citar-denote-title-format-authors 1)
  (citar-denote-title-format-andstr "and")
  :bind
  (:map fab/notes-prefix-map
        ("c c" . citar-create-note)
        ("c n" . citar-denote-open-note)
        ("c d" . citar-denote-dwim)
        ("c e" . citar-denote-open-reference-entry)
        ("c a" . citar-denote-add-citekey)
        ("c k" . citar-denote-remove-citekey)
        ("c r" . citar-denote-find-reference)
        ("c l" . citar-denote-link-reference)
        ("c f" . citar-denote-find-citation)
        ("c x" . citar-denote-nocite)
        ("c y" . citar-denote-cite-nocite)))

(use-package org-noter
  :custom
  (org-noter-always-create-frame nil)
  (org-noter-kill-frame-at-session-end nil)
  (org-noter-use-indirect-buffer nil)
  (org-noter-auto-save-last-location t)
  (org-noter-disable-narrowing t)
  (org-noter-highlight-selected-text t)
  :bind (:map fab/notes-prefix-map
              ("p" . org-noter)))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook (pdf-view-mode . (lambda ()
                           ;;for fast i-search in pdf buffers
                           (pdf-isearch-minor-mode)
                           (pdf-isearch-batch-mode)
                           (pdf-outline-minor-mode)
                           (pdf-outline-imenu-enable)
                           (pdf-annot-minor-mode)
                           (pdf-view-themed-minor-mode)
                           (pdf-sync-minor-mode))))

(use-package bibtex
  :ensure nil
  :mode ("\\.bib\\'" . bibtex-mode)
  :config
  (dolist (format '(realign
                    whitespace
                    last-comma))
    (add-to-list 'bibtex-entry-format format))
  :custom
  (bibtex-dialect 'biblatex)
  (bibtex-user-optional-fields
   '(("keywords" "Keywords to describe the entry" "")
     ("file" "Link to a document file." "")))
  (bibtex-align-at-equal-sign t)
  (bibtex-autokey-edit-before-use t)
  (bibtex-autokey-titleword-separator "-")
  (bibtex-autokey-year-title-separator "--")
  (bibtex-autokey-titleword-length 8)
  (bibtex-autokey-titlewords nil)
  (bibtex-autokey-titleword-ignore '("A" "An" "On" "The" "and" "of"
                                     "el" "la" "los" "de" "y" "a"
                                     "con" "en" "al"
                                        ;"[^[:upper:]].*"
                                     ".*[^[:upper:][:lower:]0-5].*")))

(use-package auctex
  :ensure
  (auctex :repo "https://git.savannah.gnu.org/git/auctex.git" :branch "main"
        :pre-build (("make" "elpa"))
        :build (:not elpaca--compile-info) ;; Make will take care of this step
        :files ("*.el" "doc/*.info*" "etc" "images" "latex" "style")
        :version (lambda (_) (require 'auctex) AUCTeX-version))
  :mode ("\\.tex\\'" . LaTeX-mode)
  :hook
  (LaTeX-mode . prettify-symbols-mode)
  :custom
  ;; (font-latex-fontify-script nil)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-start-server t)
  (TeX-electric-sub-and-superscript t))

(use-package cdlatex
  :hook
  (LaTeX-mode . turn-on-cdlatex)
  (org-mode . turn-on-org-cdlatex))

(use-package math-delimiters
  :ensure (:host github :repo "oantolin/math-delimiters")
  :config
  (autoload 'math-delimiters-insert "math-delimiters")
  (with-eval-after-load 'org
    (define-key org-mode-map "$" #'math-delimiters-insert))
  (with-eval-after-load 'tex              ; for AUCTeX
    (define-key TeX-mode-map "$" #'math-delimiters-insert))
  (with-eval-after-load 'cdlatex
    (define-key cdlatex-mode-map "$" nil)))

(use-package tramp
  :ensure nil
  :defer t
  :config
  (add-to-list 'tramp-remote-path "~/.local/bin")
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))
  (connection-local-set-profiles
   '(:application tramp :protocol "rsync")
   'remote-direct-async-process)
  (with-eval-after-load 'compile
    (remove-hook 'compilation-mode-hook
                 #'tramp-compile-disable-ssh-controlmaster-options))
  :custom
  (tramp-default-remote-shell "/bin/bash")
  (remote-file-name-inhibit-locks t)
  (tramp-use-scp-direct-remote-copying t)
  (remote-file-name-inhibit-auto-save-visited t)
  (tramp-copy-size-limit (* 1024 1024)) ; 1 MB
  (tramp-verbose 2)
  (tramp-default-method "rsync"))

(use-package project
  :ensure nil
  :custom
  (project-mode-line t))

(use-package treesit
  :ensure nil
  :custom
  (major-mode-remap-alist
   '((c-mode . c-ts-mode)
     (c++-mode . c++-ts-mode)))
  (treesit-language-source-alist
   '((c "https://github.com/tree-sitter/tree-sitter-c")
     (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
	 (python "https://github.com/tree-sitter/tree-sitter-python")))
  (treesit-font-lock-level 3))

(use-package eglot
  :ensure nil ;; use built-in
  :defer t
  :hook
  ((c-ts-mode c++-ts-mode python-ts-mode LaTeX-mode) . eglot-ensure)
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

(use-package tempel
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")
  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert)
         :map tempel-map
         ("M-n" . tempel-next)
         ("TAB" . tempel-next)
         ("<backtab>" . tempel-previous)
         ("M-p" . tempel-previous))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  ;; (global-tempel-abbrev-mode)
  )

(use-package tempel-collection)

(use-package lsp-snippet
  :ensure (:host github :repo "svaante/lsp-snippet")
  :after eglot
  :config
  (lsp-snippet-tempel-eglot-init))

(use-package consult-eglot
  :bind (:map eglot-mode-map ("M-g l" . consult-eglot-symbols)))

(use-package consult-eglot-embark
  :after (embark consult-eglot)
  :config
  (consult-eglot-embark-mode 1))

(use-package consult-xref-stack
  :ensure (:host github :repo "brett-lempereur/consult-xref-stack")
  :bind ("C-," . consult-xref-stack-backward))

(use-package breadcrumb
  :hook (eglot-connect . breadcrumb-local-mode))

(use-package flymake
  :ensure nil ;; use built-in
  ;; :custom
  ;; (flymake-show-diagnostics-at-end-of-line 'short)
  :bind
  (:map flymake-mode-map
        ("M-n" . #'flymake-goto-next-error)
        ("M-p" . #'flymake-goto-prev-error)))

(use-package eldoc-box
  :commands (eldoc-box-hover-at-point-mode)
  ;; :bind (:map eglot-mode-map
              ;; ([remap display-local-help] . #'eldoc-box-help-at-point)
              ;; ([remap eldoc-doc-buffer] . #'eldoc-box-help-at-point))
  :custom
  (eldoc-box-only-multi-line t)
  (eldoc-box-max-pixel-height 500)
  (eldoc-box-clear-with-C-g t))

(use-package markdown-mode
  :mode "\\.md\\'"
  :hook
  (markdown-mode . visual-line-mode))

(use-package plantuml-mode
  :after org
  :config
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  :custom
  (org-plantuml-exec-mode 'plantuml)
  (plantuml-default-exec-mode 'executable))

(use-package yaml-ts-mode
  :ensure nil
  :mode "\\.yaml\\'")

(use-package yaml-pro
  :hook
  (yaml-ts-mode . yaml-pro-ts-mode))

(use-package outline-yaml
  :ensure (:host github :repo "jamescherti/outline-yaml.el")
  :hook
  (yaml-ts-mode . outline-yaml-minor-mode))

(use-package matlab-mode
  :ensure (:host github :repo "mathworks/Emacs-MATLAB-Mode")
  :mode "\\.m\\'"
  :custom
  (matlab-shell-command-switches '("-nodesktop" "-nosplash")))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . eglot-ensure))

;;; post-init.el ends here
