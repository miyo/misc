@num = 2**8
@num = ARGV[0].to_i if ARGV.size > 0
MAX=2**31-1

def gen_switch(i)
  return "case #{i}: ret = v ^ #{rand(MAX)}; break;\n"
end

puts <<EOF

class B{
      public int t(int k, int v){
        int ret = 0;
        switch(k){
EOF
@num.times{ |i| puts gen_switch(i) }
puts <<EOF
          default: ret = 0;
        }
        return ret;
      }
}

public class A{
       public static void main(String... args){
              B b = new B();
              System.out.println(b.t(Integer.parseInt(args[0]), Integer.parseInt(args[1])));
       }
}
EOF
