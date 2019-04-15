all:
	javac net/wasamon/javaplugintest/*.java
	jar cvf p.jar net META-INF
	javac -cp p.jar -Xplugin:SampleJavacPlugin samples/Test.java

clean:
	-rm -f net/wasamon/javaplugintest/*.class
	-rm -f p.jar
	-rm -f samples/*.class
