;; OS X specific configuration options

(if (eq system-type 'darwin)
    (normal-erase-is-backspace-mode)    ;; Make delete key work
    (setq-default ispell-program-name "/usr/local/bin/aspell")
)

(provide 'osx-config)
