(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/vendor")
(add-to-list 'load-path "~/.emacs.d/vendor/sml-mode-4.1")
(add-to-list 'load-path "~/.emacs.d/vendor/color-theme-6.6.0")

(defun coding-mode ()
  (turn-on-auto-fill)
  (set-fill-column 79)
  )

(add-hook 'text-mode-hook               ;; Turn on Auto Fill mode automatically
          'coding-mode)
(add-hook 'c-mode-hook
          'coding-mode)
(add-hook 'c++-mode-hook
          'coding-mode)
(add-hook 'octave-mode-hook
          'coding-mode)
(setq-default word-wrap t)              ;; Do not wrap lines in the middle of
                                        ;; words.

(setq-default scroll-step 1)            ;; Line-by-line scrolling
(setq-default make-backup-files nil)    ;; Do not create backup files

(line-number-mode t)                    ;; Show line-number in the mode line
(column-number-mode t)                  ;; Show column-number in the mode line

(show-paren-mode t)                     ;; Automatic paranthesis matching
(setq-default show-paren-delay 0)       ;; No delay for paranthesis matching

;; Highlight trailing spaces
(setq-default show-trailing-whitespace t)

(setq-default require-final-newline t)  ;; Require final newline

;; Automatically delete trailing spaces before saving files
(add-hook 'before-save-hook
          'delete-trailing-whitespace)

(add-hook 'term-mode-hook               ;; Disable word wrapping and trailing
          '(lambda ()                   ;; whitespace in the shell
             (setq word-wrap nil)
             (setq show-trailing-whitespace nil)))

;; Font size key bindings
(define-key global-map (kbd "C-=") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)

(require 'ido)                          ;; Load ido.el package
(global-set-key                         ;; Configure M-x to use ido suggestions
 "\M-x"
 (lambda ()
   (interactive)
   (call-interactively
    (intern
     (ido-completing-read
      "M-x "
      (all-completions "" obarray 'commandp))))))
(setq-default
 ido-enable-flex-matching t)            ;; Enable fuzzy matching for ido
(ido-mode)                              ;; Enable ido

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

(require 'osx-config)                   ;; OS X specific configuration options

(require 'color-theme)                  ;; Color theme support
(color-theme-initialize)
(color-theme-dark-laptop)

(xterm-mouse-mode t)
(global-set-key [mouse-4] '(lambda ()
                             (interactive)
                             (scroll-down 1)))
(global-set-key [mouse-5] '(lambda ()
                             (interactive)
                             (scroll-up 1)))
(defun track-mouse (e))
(setq mouse-sel-mode t)

(require 'indentation-config)           ;; (Auto)indentation options

(require 'auto-complete)                ;; Autocomplete mode
(global-auto-complete-mode t)

;; Enable YASnippet
(require 'yasnippet)
(yas-global-mode 1)

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings 'meta)) ;; Enable keybindings for easily
                                        ;; switching between windows
;; Window resizing keybindings
(global-set-key (kbd "M-S-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "M-S-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-S-<down>") 'shrink-window)
(global-set-key (kbd "M-S-<up>") 'enlarge-window)

;; Major mode configurations
(require 'php)                          ;; PHP and XHP major mode

(require 'piglatin-mode)
(add-to-list 'auto-mode-alist '("\\.piglet$" . piglatin-mode))

(require 'thrift-mode)

(require 'scala-mode)

;; ML major mode
(autoload 'sml-mode "sml-mode" "Major mode for editing SML." t)
(add-to-list 'auto-mode-alist '("\\.sml$" . sml-mode))

;; Octave major mode
(add-to-list 'auto-mode-alist '("\\.m$" . octave-mode))

;; Ocaml major mode
(autoload 'tuareg-mode "tuareg" "Major mode for editing Caml code" t)
(autoload 'camldebug "camldebug" "Run the Caml debugger" t)
(setq auto-mode-alist
      (append '(("\\.ml[ily]?$" . tuareg-mode)
                ("\\.topml$" . tuareg-mode))
              auto-mode-alist))

;; Merlin mode
;; Add opam emacs directory to the load-path
(setq opam-share (substring (shell-command-to-string "opam config var share 2> /dev/null") 0 -1))
(add-to-list 'load-path (concat opam-share "/emacs/site-lisp"))
;; Load merlin-mode
(require 'merlin)
;; Start merlin on ocaml files
(add-hook 'tuareg-mode-hook 'merlin-mode t)
(add-hook 'caml-mode-hook 'merlin-mode t)
;; Enable auto-complete
(setq merlin-use-auto-complete-mode 'easy)
;; Use opam switch to lookup ocamlmerlin binary
(setq merlin-command 'opam)

;; Ocaml standard indenting
(require 'ocp-indent)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ispell-program-name "/usr/local/bin/aspell")
 '(ocp-indent-config "JaneStreet"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
