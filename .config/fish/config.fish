. $HOME/.config/fish/solarized.fish
set -x JAVA_HOME (/usr/libexec/java_home -v1.7)
set -x MAVEN_OPTS '-Xmx1024m -Xms512m -XX:MaxPermSize=256m'
set -x BUILD_NUMBER 99999
set -gx PATH $PATH ./node_modules/.bin
set -x JENV_ROOT /usr/local/opt/jenv
set -x NVM_DIR ~/.nvm
source ~/.config/fish/nvm-wrapper/nvm.fish
if test -f /Users/ffesseler/.autojump/share/autojump/autojump.fish; . /Users/ffesseler/.autojump/share/autojump/autojump.fish; end
fundle plugin 'edc/bass'
fundle init
. $HOME/.config/fish/frontend-aliases.fish
