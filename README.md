# emacs-gpg
Emacs mode for transparently editing text encrypted by GnuPG.

## Install

- Copy `gpg-mode.el` file somewhere where emacs can find it, e.g. in `/path/to/emacs-lisp`.
- Add the following to your `~/.emacs`:

```lisp
(add-to-list 'load-path "/path/to/emacs-lisp")  ; If needed
(require 'gpg-mode)
(add-to-list 'auto-mode-alist '("\\.asc$" . gpg-mode))
(setq gpg-default-recipient "John Doe") ; (optional)
```

Restart `emacs`. Now opening a file `*.asc` will cause it to be automatically decrypted, and saving changes will automatically encrypt it back.

## Known issues

Decrypton currenly relies on `gpg`'s pop-up password prompt. It will not work in a terminal-only environment.
