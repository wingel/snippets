;; Make Emacs' python.el behave more like I would like it to
;; http://blog.weinigel.se/2020/09/11/emacs-and-python-el.html

;; Parse any #! line at the top of the file to figure out what
;; interpreter to use
(defun get-script-interpreter ()
  (interactive)
  (let ((l (save-excursion
	     (goto-char (point-min))
	     (setq s (point))
	     (move-end-of-line 1)
	     (setq e (point))
	     (buffer-substring-no-properties s e))))
    (if (string-match "^\#![ \t]*\\(.*\\)" l)
	(match-string 1 l))
    )
  )

;; I don't like that the first line printed by the python code is
;; output on the same line as the ">>>" prompt, so this whole thing
;; here finds ut where it is and inserts a newline after the prompt.
;; Another variant is to delete everything up to the prompt which
;; makes the output a bit cleaner.  This whole thing feels a bit
;; fragile, but it does seem to work.

(defun python-do-something-at-first-prompt ()
  (remove-hook 'python-shell-first-prompt-hook
	       'python-do-something-at-first-prompt)

  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward python-shell-prompt-regexp 1000 t)
	(progn
	  (newline)
          ;; (delete-region (point-min) (point))
	  )
      )
    )
  )

;; Run Python in a classic way like old python-mode.el used to do.

(defun run-python-classic ()
  "Run the python code in the current buffer in a new Python process."
  (interactive)

  ;; Kill any existing python process
  (ignore-errors (delete-process (python-shell-get-process)))

  ;; Erase an existing *Python* buffer or create a new one.
  ;; Make it visible and switch focus to it.
  (let ((d default-directory))
    (save-current-buffer
      (set-buffer (get-buffer-create "*Python*"))
      (message "cd %s" d)
      (cd d)
      (let ((inhibit-read-only t)) (erase-buffer))
      (display-buffer (current-buffer))
      (switch-to-buffer-other-frame (current-buffer))
      )
    )

  ;; Try to clean up the contents a bit as soon as the first >>>
  ;; prompt shows up.
  ;; (add-hook 'python-shell-first-prompt-hook
  ;;	    'python-do-something-at-first-prompt)

  ;; If there is a #! line at the beginning of the buffer use it as
  ;; the command to start the interpreter.  If not, pass nil and use
  ;; the default interpreter
  (let ((cmd (get-script-interpreter)))
    (run-python cmd))

  ;; Since there shouldn't be any long lived data in the *Python*
  ;; buffer buffer, don't ask for confirmation when killing it.
  (set-process-query-on-exit-flag (python-shell-get-process) nil)

  ;; Finally send the buffer contents to the process and bypass the
  ;; code that strips out if __name__ == '__main__'.
  (save-restriction
    (widen)
    (let* ((process (python-shell-get-process))
	   (string (buffer-substring-no-properties (point-min) (point-max))))
      (python-shell-send-string string process)
      )
    )
  )

;; This doesn't play well with the interpreter stuff, so disable it
(setq python-shell-completion-native-enable nil)

(defun wingel-python-mode ()
  (setq py-indent-offset 4)
  (setq indent-tabs-mode nil)
  (define-key python-mode-map "\C-c\C-c" 'run-python-classic)
  )

;; Finally add a hook to replace C-c C-c with the classic variant
(add-hook 'python-mode-hook 'wingel-python-mode)
