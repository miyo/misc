```
miyo@sagardo:% rm A.java
miyo@sagardo:% ruby gen_large_case.rb 4384 > A.java
miyo@sagardo:% javac A.java
miyo@sagardo:% java A 0 0
1335902683
miyo@sagardo:% rm A.java
miyo@sagardo:% ruby gen_large_case.rb 4385 > A.java
miyo@sagardo:% javac A.java
A.java:3: error: code too large
      public int t(int k, int v){
                 ^
1 error
miyo@sagardo:% java -version
java version "1.8.0_181"
Java(TM) SE Runtime Environment (build 1.8.0_181-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.181-b13, mixed mode)
miyo@sagardo:% javac -version
javac 1.8.0_181
```

