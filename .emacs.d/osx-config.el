;; OS X specific configuration options

(if (eq system-type 'darwin)
    (normal-erase-is-backspace-mode)    ;; Make delete key work
)
