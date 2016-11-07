#!/bin/fish

set WORKING_DIRECTORY "src/main/resources/client-html-src/"

function __client_html_pom
  echo $PWD | sed 's|/server/client-html.*$|/server/client-html/pom.xml|'
end

function __mvn_frontend
  set goal $argv[1]
  set argsProperty $argv[2]
  set commandName $argv[3]
  set args $argv[4..-1]
  set pom (__client_html_pom)
  if test -f $pom
    mvn -f $pom \
      com.github.eirslett:frontend-maven-plugin:$goal \
      -DworkingDirectory=$WORKING_DIRECTORY \
      -D$argsProperty="$args"
  else
    $commandName $args
  end
end

function g
  __mvn_frontend grunt "frontend.grunt.arguments" grunt $argv
end

function n
  __mvn_frontend npm   "frontend.npm.arguments"   npm $argv
end

function b
  __mvn_frontend bower "frontend.bower.arguments" bower $argv
end
