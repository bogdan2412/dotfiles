;; Automatically delete trailing spaces before saving files
(add-hook 'before-save-hook
          'delete-trailing-whitespace)

;; Enable keybindings for easily switching between windows
(when (fboundp 'windmove-default-keybindings)[]
  (windmove-default-keybindings 'super))

;; Window resizing keybindings
(global-set-key (kbd "M-s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "M-s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-s-<down>") 'shrink-window)
(global-set-key (kbd "M-s-<up>") 'enlarge-window)

(defun kill-and-join-forward (&optional arg)
  "If at end of line, join with following; otherwise kill line.
   Deletes whitespace at join."
  (interactive "P")
  (if (and (eolp) (not (bolp)))
      (delete-indentation t)
    (kill-line arg)))

;; Modifies C-k to remove unnecessary whitespace from next line.
(global-set-key "\C-k" 'kill-and-join-forward)

(custom-set-variables
 '(ocp-indent-config "JaneStreet"))
