function mcist
	mvn clean install -Dmaven.test.skip=true -DskipTests=true -Dcyclonedx.skip=true -Pproduction
end
