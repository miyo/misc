```
% rm A.java
% ruby gen_large_case.rb > A.java
%javac A.java
A.java:3: error: code too large
      public int t(int k, int v){
                 ^
1 error
%
```

