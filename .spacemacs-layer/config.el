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

(defun ocaml-autoformat ()
  "Before saving a .ml or .mli file, format it"
  (interactive)
  (when (eq major-mode 'tuareg-mode)
    (progn
      (setq old-point (point))
      (setq old-window-start (window-start))
      (setq is-interface (if buffer-file-name (numberp (string-match "\.mli$" buffer-file-name)) nil))
      (setq ocamlformat-arg (if is-interface "--intf" "--impl"))
      (setq command
            (concat "set -euo pipefail; ocamlformat " ocamlformat-arg " /dev/stdin | ocp-indent -c JaneStreet"))
      (setq temporary-buffer (get-buffer-create "*ocamlformat output*"))
      (with-current-buffer temporary-buffer (erase-buffer))
      (setq return_code (call-shell-region
                         (point-min) (point-max) command nil temporary-buffer))
      (if (eq return_code 0)
          (progn
            (erase-buffer)
            (insert-buffer-substring temporary-buffer))
        (message (concat "ocamlformat output:\n"
                         (with-current-buffer temporary-buffer (buffer-string)))))
      (goto-char old-point)
      (set-window-start nil old-window-start))))

(add-hook 'before-save-hook 'ocaml-autoformat)
