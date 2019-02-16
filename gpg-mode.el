;; Copyright 2019 Sergey Berezin (github.com/sergey-a-berezin)

;;   Licensed under the Apache License, Version 2.0 (the "License");
;;   you may not use this file except in compliance with the License.
;;   You may obtain a copy of the License at

;;       http://www.apache.org/licenses/LICENSE-2.0

;;   Unless required by applicable law or agreed to in writing, software
;;   distributed under the License is distributed on an "AS IS" BASIS,
;;   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;;   See the License for the specific language governing permissions and
;;   limitations under the License.

;; Major mode for transparently decrypting a file on load and encrypting on save.

(defvar gpg-command "gpg"
  "Command to run gpg")

(defvar gpg-stderr nil
  "File name to write stderr output")

(defvar gpg-default-recipient nil
  "Default recipient for encryption.")

(defvar gpg-mode-hooks nil)

(defun gpg-decrypt-buffer ()
  "Decrypts the entire buffer (widens if narrowed)."
  (interactive)
  (widen)
  (call-process-region (point-min) (point-max) gpg-command t (list t gpg-stderr) nil "-d"))

(defun gpg-encrypt-and-save ()
  (let ((gpg-recipient gpg-default-recipient)
	(file-name (buffer-file-name)))
    (while (not gpg-recipient)
      (setq  gpg-recipient (read-from-minibuffer "Encrypt for: ")))
    (widen)
    ;; Encrypt the buffer directly to the visited file. Return t if successful.
    (let ((res (eq 0 (call-process-region nil nil gpg-command
			       nil nil nil "-ear" gpg-recipient
			       "-o" file-name
			       "--no-tty" "--batch" "--yes"))))
      (if res
	  (set-buffer-modified-p nil))
      res)))

(defun gpg-mode ()
  "Major mode for transparently editing GPG encrypted files."
  (interactive)
  (emacs-lisp-mode)
  (setq major-mode 'gpg-mode)
  (setq mode-name "GPG")
  (run-mode-hooks 'gpg-mode-hooks)
  (add-hook 'write-contents-functions 'gpg-encrypt-and-save)
  ;; Check if the buffer needs to be decrypted
  (widen)
  (let ((header "-----BEGIN PGP MESSAGE-----"))
    (if (and (>= (buffer-size) (length header))
	     (string= (buffer-substring (point-min) (+ (point-min) (length header)))
		      header))
	(progn
	  (gpg-decrypt-buffer)
	  (set-buffer-modified-p nil)))))

(provide 'gpg-mode)
