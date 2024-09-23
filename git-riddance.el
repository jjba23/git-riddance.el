;;; git-riddance.el --- completely rewrite the Git history of a repository -*- lexical-binding: t -*-

;; Copyright (C) 2024 Free Software Foundation, Inc.

;; Version: 0.3.1
;; Author: Josep Bigorra <jjbigorra@gmail.com>
;; Maintainer: Josep Bigorra <jjbigorra@gmail.com>
;; URL: https://github.com/jjba23/git-riddance.el
;; Keywords: git, git-riddance, history
;; Package: git-riddance
;; Package-Requires: ((emacs "24.1"))

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Git Riddance - for Good Riddance!

;; git-riddance is an Emacs package that will help you completely destroy the
;; Git history of your desired directory, and allow you to start
;; a new one with 1 commit, effectively obliterating other history in that branch.

;;; Code:

(defgroup git-riddance ()
  "Git Riddance customization group."
  :group 'tools)

(defcustom git-riddance-remote-name "github"
  "Default name for the Git remote to push to."
  :type 'string)

(defcustom git-riddance-branch-name "trunk"
  "Default name for the Git branch to rewrite."
  :type 'string)

(defcustom git-riddance-commit-message "In the beginning there was darkness..."
  "Default commit message for the first commit of new history."
  :type 'string)

(defcustom git-riddance-target-directory "."
  "Default directory for the repository to rewrite history."
  :type 'string)

(defcustom git-riddance-remote-url nil
  "Default URL/SSH for the remote of the repository to rewrite history."
  :type 'string)

(defcustom git-riddance-message-prefix "git-riddance -"
  "Default prefix for messages shown to the user."
  :type 'string)

(defcustom git-riddance-msg-new-commit-message (format "%s enter the new commit message: " git-riddance-message-prefix)
  "Message to show the user when asking for a new commit message."
    :type 'string)

(defcustom git-riddance-msg-branch-name (format "%s enter the name of the branch: " git-riddance-message-prefix)
  "Message to show the user when asking for the name of the branch."
    :type 'string)

(defcustom git-riddance-msg-remote-name (format "%s please enter the name of the remote to force push to: " git-riddance-message-prefix)
  "Message to show the user when asking for the remote to force push to."
    :type 'string)

(defcustom git-riddance-msg-target-dir (format "%s please enter the name of the target directory: " git-riddance-message-prefix)
  "Message to show the user when asking for the target directory."
    :type 'string)

(defcustom git-riddance-msg-remote-url (format "%s please enter the URL/SSH of the remote: " git-riddance-message-prefix)
  "Message to show the user when asking for the remote URL/SSH."
    :type 'string)

(defun git-riddance-read-commit-message ()
  "Read the wanted commit message for the first commit of new history."
  (read-string git-riddance-msg-new-commit-message git-riddance-commit-message))
(defun git-riddance-read-branch-name ()
  "Read the wanted branch to rewrite history."
  (read-string git-riddance-msg-branch-name git-riddance-branch-name))

(defun git-riddance-read-remote-name ()
  "Read the name of the remote to force push to."
  (read-string git-riddance-msg-remote-name git-riddance-remote-name))

(defun git-riddance-read-target-dir ()
  "Read the target directory where to rewrite."
  (read-directory-name git-riddance-msg-target-dir git-riddance-target-directory))

(defun git-riddance-read-remote-url ()
  "Read the URL/SSH remote to force push to."
  (read-string git-riddance-msg-remote-url git-riddance-remote-url))

(defun git-riddance-cmd-checkout-orphan ()
  "Shell command to run to checkout the latest commit as orphan."
  (shell-command "git checkout --orphan latest_branch"))
(defun git-riddance-cmd-add-all-files ()
  "Shell command to run to add all files."
  (shell-command "git add -A"))

(defun git-riddance-cmd-first-commit (gr-commit-message)
  "Shell command to run to perform the first commit in new history.
GR-COMMIT-MESSAGE will be used as commit message."
  (shell-command (format "git commit -am \"%s\"" gr-commit-message)))

(defun git-riddance-cmd-delete-old-branch (gr-branch-name)
  "Shell command to run to delete the old branch.
GR-BRANCH-NAME is the name of the branch we are working with"
  (shell-command (format "git branch -D %s || true" gr-branch-name)))

(defun git-riddance-cmd-rename-new-branch (gr-branch-name)
  "Shell command to run to rename new branch.
GR-BRANCH-NAME is the name of the branch we are working with"
  (shell-command (format "git branch -m %s" gr-branch-name)))

(defun git-riddance-cmd-add-remote (gr-remote-name gr-remote-url)
  "Shell command to run to add the remote.
GR-REMOTE-NAME is the name of the remote to force push to.
GR-REMOTE-URL is the URL/SSH to force push to."
  (shell-command (format "git remote add %s %s || true" gr-remote-name gr-remote-url)))

(defun git-riddance-cmd-force-push (gr-remote-name gr-branch-name)
  "Shell command to run to force push.
GR-REMOTE-NAME is the name of the remote to force push to.
GR-BRANCH-NAME is the name of the branch we are working with"
  (shell-command (format "git push -uf %s %s" gr-remote-name gr-branch-name)))

(defun git-riddance ()
  "Rewrite Git history of a directory.
Completely rewrite Git history of the
specified directory with a new commit and branch."
  (interactive)
  (let* (
         (default-directory (git-riddance-read-target-dir))
         (gr-remote-url (git-riddance-read-remote-url))
         (gr-commit-message (git-riddance-read-commit-message))
         (gr-branch-name (git-riddance-read-branch-name))
         (gr-remote-name (git-riddance-read-remote-name))
         )
        ;; Checkout/create orphan branch (this branch won't show in git branch command).
        (git-riddance-cmd-checkout-orphan)
        ;; Add all the files to the newly created branch.
        (git-riddance-cmd-add-all-files)
        ;; Commit the changes.
        (git-riddance-cmd-first-commit gr-commit-message)
        ;; Delete main (default) branch (this step is permanent).
        (git-riddance-cmd-delete-old-branch gr-branch-name)
        ;; Rename the new branch.
        (git-riddance-cmd-rename-new-branch gr-branch-name)
        ;; Add the remote.
        (git-riddance-cmd-add-remote gr-remote-name gr-remote-url)
        ;; Finally, all changes are completed on your local repository,
        ;; and force update your remote repository:
        (git-riddance-cmd-force-push gr-remote-name gr-branch-name)))

(provide 'git-riddance)

;;; git-riddance.el ends here

