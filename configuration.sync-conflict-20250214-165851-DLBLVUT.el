(require 'package)
(setq package-archives
      '(("GNU ELPA"     . "https://elpa.gnu.org/packages/")
	("MELPA"        . "https://melpa.org/packages/")
	("ORG"          . "https://orgmode.org/elpa/")
	("MELPA Stable" . "https://stable.melpa.org/packages/")
	("nongnu"       . "https://elpa.nongnu.org/nongnu/"))
      package-archive-prioritites
      '(("GNU ELPA"     . 20)
	("MELPA"        . 15)
	("ORG"          . 10)
	("MELPA Stable" . 5)
	("nongnu"       . 0)))
(package-initialize)

;;(unless (package-installed-p 'evil)
;;  (package-install 'evil))
;;(require 'evil)
;;(evil-mode 1)
;;(evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)

(setq completion-styles '(partial-completion substring flex))
(unless (package-installed-p 'vertico)
  (with-demoted-errors "%s"
	(unless package-archive contents
		(package-refresh-contents))
	(package-install 'vertico)))
(with-demoted-errors "%s" (vertico-mode +1))

(unless (package-installed-p 'marginalia)
  (with-demoted-errors "%s"
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'marginalia)))
(with-demoted-errors "%s" (marginalia-mode +1))

(global-set-key (kbd "M-j") 'avy-goto-char-timer)

(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))

(setq url-cookie-untrusted-urls '(".*"))

(defun exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun exwm-update-title ()
          (pcase exwm-class-name
            ("LibreWolf" (exwm-workspace-rename-buffer (format "Librewolf: %s" exwm-title)))
            ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))))

  (use-package exwm
          :config
          ;; Set the default number of workspaces
          (setq exwm-workspace-number 1)

          (add-hook 'exwm-update-class-hook 'exwm-update-class)

          (add-hook 'exwm-update-title-hook 'exwm-update-title)

          ;; These keys should always pass through to Emacs
          (setq exwm-input-prefix-keys
            '(?\C-x
              ?\C-u
              ?\C-h
              ?\M-x
              ?\M-`
              ?\M-&
              ?\M-:
              ?\C-\M-j  ;; Buffer list
              ?\C-\ ))  ;; Ctrl+Space

          ;; Ctrl+Q will enable the next key to be sent directly
          (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

          ;; Set up global key bindings.  These always work, no matter the input state!
          ;; Keep in mind that changing this list after EXWM initializes has no effect.
          (setq exwm-input-global-keys
                `(
                  ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
                  ([?\s-r] . exwm-reset)

                  ;; Move between windows
                  ([?\s-b] . windmove-left)
                  ([?\s-f] . windmove-right)
                  ([?\s-p] . windmove-up)
                  ([?\s-n] . windmove-down)

                  ;; Launch applications via shell command
                  ([?\s-d] . (lambda (command)
                               (interactive (list (read-shell-command "$ ")))
                               (start-process-shell-command command nil command)))

                  ;; Switch workspace
                  ([?\s-w] . exwm-workspace-switch)

                  ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
                  ,@(mapcar (lambda (i)
                              `(,(kbd (format "s-%d" i)) .
                                (lambda ()
                                  (interactive)
                                  (exwm-workspace-switch-create ,i))))
                            (number-sequence 0 9))
                ))

          (exwm-enable))

(setq custom-file (locate-user-emacs-file "custom-vars.el"))
(load custom-file 'noerror 'nomessage)

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(setq use-file-dialog nil use-dialog-box nil)

;; Theming
(when (display-graphic-p)
  (load-theme 'catppuccin :no-confirm)
  (setq catppuccin-flavor 'frappe)
  (catppuccin-reload))

(setq scroll-conservatively 100000)

(setq initial-scratch-message ""
      initial-buffer-choice t)

(add-hook 'text-mode-hook 'abbrev-mode)
(add-hook 'prog-mode-hook 'abbrev-mode)

(add-hook 'occur-mode-hook 'hl-line-mode)
(add-hook 'dired-mode-hook 'hl-line-mode)
(add-hook 'package-menu-mode-hook 'hl-line-mode)

(add-hook 'text-mode-hook 'flyspell-mode)

(setq dired-dwim-target t)
(add-hook 'dired-load-hook (lambda () (require 'dired-x)))

(setq view-read-only t)
(add-hook 'doc-view-mode-hook 'auto-revert-mode)
(add-hook 'pdf-view-mode-hook 'auto-revert-mode)

(save-place-mode +1)

(setq history-length 25)
(savehist-mode 1)

(require 'org)
(setq initial-major-mode 'org-mode)

(require 'org-tempo)

(setq org-structure-template-alist
       '(("s" . "src")
         ("sg" . "src gnuplot :eval yes :file graph.png")
         ("e" . "src emacs-lisp")
         ("x" . "example")
         ("X" . "export")
         ("q" . "quote")))

(setq org-agenda-files '("~/Documents/org"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "|" "DONE(d!)" "WONT-DO(w@/!)" )
        ))

(setq org-log-done 'time)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'visual-line-mode)

(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)
(define-key org-mode-map "\C-cf" 'org-metaright)
(define-key org-mode-map "\C-cb" 'org-metaleft)
(define-key org-mode-map "\C-cn" 'org-metadown)
(define-key org-mode-map "\C-cp" 'org-metaup)

(setq org-capture-templates
      '(    
        ("g" "General To-Do"
         entry (file+headline "~/Documents/org/todos.org" "General Tasks")
         "* TODO [#B] %?\n:Created: %T\n "
         :empty-lines 0)
	("n" "Note"
         entry (file+headline "~/Documents/org/notes.org" "Random Notes")
         "** %?"
         :empty-lines 0)
	))

(setq org-tag-alist '(
                      ("lesson" . ?l)
                      ("slides" . ?s)
                      ("export" . ?e)
                      ("noexport" . ?n)
                      ))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((gnuplot . t)))

(defun org-teacher-export ()
  "export as pdf handout and slideshow with blank spaces for vocabulary"
  (interactive)
  (save-buffer)
  (let (
        (obj-dir "~/Documents/org/materials")
        (filename-stem (file-name-sans-extension (expand-file-name (concat "~/Documents/org/materials/" (buffer-name)))))
        (filename (file-name-sans-extension buffer-file-name))
        )
    (setq org-confirm-babel-evaluate nil)
    (org-export-to-file 'beamer (concat filename-stem "_slides.tex"))
    (org-latex-compile (concat  filename-stem "_slides.tex"))
    (beginning-of-buffer)
    (search-forward "Goet" nil t)
    (org-beginning-of-line)
    (org-kill-line)
    (org-export-to-file 'latex (concat filename-stem "_handout.tex"))
    (org-latex-compile (concat filename-stem "_handout.tex"))
    (setq org-confirm-babel-evaluate t)
    (revert-buffer nil t)))


(define-key org-mode-map (kbd "C-c t") 'org-teacher-export)

(require 'go-translate)

(setq gt-langs '(en es))

(setq gt-default-translator
      (gt-translator
       :taker (gt-taker :text 'region :pick 'nil)
       :engines (list (gt-google-engine))
       :render (gt-buffer-render)))
