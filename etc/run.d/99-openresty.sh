suexec openresty -g "daemon off; user $PUSER $PGROUP; $OPENRESTY_DIRECTIVES" &
