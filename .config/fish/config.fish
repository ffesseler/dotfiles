. $HOME/.config/fish/solarized.fish
set -x JAVA_HOME (/usr/libexec/java_home -v1.8)
set -x JAVA_7_HOME (/usr/libexec/java_home -v1.7)
set -x JAVA_8_HOME (/usr/libexec/java_home -v1.8)
set -x MAVEN_OPTS '-Xmx1024m -Xms512m -XX:MaxPermSize=256m'
set -x BUILD_NUMBER 99999
set -gx PATH $PATH ./node_modules/.bin
set -x JENV_ROOT /usr/local/opt/jenv
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules,logs,target,bower_components,.idea}/*"'
alias rm "trash"

if test -f /Users/ffesseler/.autojump/share/autojump/autojump.fish; . /Users/ffesseler/.autojump/share/autojump/autojump.fish; end
. $HOME/.config/fish/frontend-aliases.fish
