package net.wasamon.javaplugintest;


import com.sun.source.util.JavacTask;
import com.sun.source.util.Plugin;

public class SampleJavacPlugin implements Plugin {
 
    @Override
    public String getName() {
        return "Sample";
    }
 
    @Override
    public void init(JavacTask task, String... args) {
		for(String s: args){
			System.out.println(s);
		}
        task.addTaskListener(new SampleTaskListener());
    }
}
