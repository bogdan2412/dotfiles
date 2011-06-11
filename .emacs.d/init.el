(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")
(add-to-list 'load-path "~/.emacs.d/vendor/auto-complete-1.3.1")
(add-to-list 'load-path "~/.emacs.d/vendor/yasnippet-0.6.1c")

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

(when                                   ;; Load Emacs Lisp Package Archive
    (load (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

(load-library "osx-config")             ;; OS X specific configuration options

(load-library "indentation-config")     ;; (Auto)indentation options

(require 'auto-complete)                ;; Autocomplete mode
(global-auto-complete-mode t)

;; Enable YASnippet
(require 'yasnippet)
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet-0.6.1c/snippets")

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings 'meta)) ;; Enable keybindings for easily
                                        ;; switching between windows
;; Window resizing keybindings
(global-set-key (kbd "M-S-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "M-S-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-S-<down>") 'shrink-window)
(global-set-key (kbd "M-S-<up>") 'enlarge-window)

;; Customized settings
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-backspace-function (quote backward-delete-whitespace-to-column))
 '(c-default-style (quote ((c-mode . "stroustrup") (c++-mode . "stroustrup") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(octave-auto-indent t)
 '(octave-block-offset 4))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
