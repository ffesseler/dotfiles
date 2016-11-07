function mcist
	mvn clean install -Dmaven.test.skip=true -DskipTests=true -Pproduction
end
