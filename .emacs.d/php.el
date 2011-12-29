;; PHP programming style
(defconst php-style
  '((c-basic-offset . 2)
    (c-offsets-alist . (
                        (arglist-intro . +)
                        (case-label . +)
                        (arglist-close . c-lineup-close-paren)
                        )))
  "PHP Programming style"
  )
(c-add-style "php-style" php-style)

;; PHP major mode
(autoload 'php-mode "php-mode" "Major mode for editing PHP code." t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

(add-hook 'php-mode-hook
          (lambda ()
            (c-set-style "php-style")))

;; XHP major mode
(autoload 'xhp-mode "xhp-mode"
  "Major mode for editing PHP code with the XHP extension." t)

(add-hook 'xhp-mode-hook
          (lambda ()
            (c-set-style "php-style")))

(provide 'php)
