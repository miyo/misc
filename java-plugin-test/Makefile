all:
	javac net/wasamon/javaplugintest/*.java
	jar cvf p.jar net META-INF

test:
	javac -cp p.jar -Xplugin:"Sample arg1 arg2" samples/Test.java

clean:
	-rm -f net/wasamon/javaplugintest/*.class
	-rm -f p.jar
	-rm -f samples/*.class
