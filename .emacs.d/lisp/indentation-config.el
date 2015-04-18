;; Emacs (auto)indentation options

(setq-default indent-tabs-mode nil)     ;; Use only spaces for indentation
(setq-default tab-width 4)              ;; Set tab width of 4
(setq-default tab-stop-list '(4 8 16 20 24 28 32 36 40
                                44 48 52 56 60 64 68 72 76))
(setq-default c-default-style
              '((c-mode . "stroustrup") (c++-mode . "stroustrup")
                (java-mode . "java") (awk-mode . "awk") (other . "gnu")))
(setq-default octave-auto-indent t)
(setq-default octave-block-offset 4)

(global-set-key (kbd "RET")             ;; Automatic indentation for new-lines
                'newline-and-indent)

(dolist (command '(yank yank-pop))      ;; Automatically indent pasted text
  (eval `(defadvice ,command (after indent-region activate)
           (and (not current-prefix-arg)
                (member major-mode '(emacs-lisp-mode
                                     lisp-mode
                                     clojure-mode    scheme-mode
                                     haskell-mode    ruby-mode
                                     rspec-mode      python-mode
                                     c-mode          c++-mode
                                     objc-mode       latex-mode
                                     plain-tex-mode))
                (let ((mark-even-if-inactive transient-mark-mode))
                  (indent-region (region-beginning) (region-end) nil))))))

(defun backward-delete-whitespace-to-column (&optional arg)
  "Delete back to the previous column of whitespace, or as much whitespace as
   possible, or just one char if that's not possible"
  (interactive)
  (if indent-tabs-mode
      (call-interactively 'backward-delete-char-untabify)
    (let ((movement (% (current-column) tab-width))
          (p (point)))
      (when (= movement 0) (setq movement tab-width))
      (save-match-data
        (if (string-match "\\w*\\(\\s-+\\)$" (buffer-substring-no-properties (- p movement) p))
            (backward-delete-char-untabify (- (match-end 1) (match-beginning 1)))
          (call-interactively 'backward-delete-char-untabify))))))
(global-set-key (kbd "DEL")
                'backward-delete-whitespace-to-column)
(setq-default c-backspace-function
              'backward-delete-whitespace-to-column)

(defun kill-and-join-forward (&optional arg)
  "If at end of line, join with following; otherwise kill line.
   Deletes whitespace at join."
  (interactive "P")
  (if (and (eolp) (not (bolp)))
      (delete-indentation t)
    (kill-line arg)))
(global-set-key "\C-k"                  ;; Modifies C-k to remove unnecessary
                'kill-and-join-forward) ;; whitespace from next line.

(provide 'indentation-config)
