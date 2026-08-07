diff --git a/packages/tmux/.tmux.conf b/packages/tmux/.tmux.conf
index 7ed5337..f8b3682 100755
--- a/packages/tmux/.tmux.conf
+++ b/packages/tmux/.tmux.conf
@@ -53,6 +53,7 @@ set -gu terminal-features
 set -sa terminal-features ',xterm*:RGB'
 set -sa terminal-features ',xterm*:extkeys'
 set -g extended-keys on
+set -g extended-keys-format csi-u
 
 # prefix+c should still create the window in the session's default path
 # Use prefix+control+c to create a window in the current directory.
