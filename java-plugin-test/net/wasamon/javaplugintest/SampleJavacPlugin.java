package net.wasamon.javaplugintest;


import com.sun.source.util.JavacTask;
import com.sun.source.util.Plugin;

public class SampleJavacPlugin implements Plugin {
 
    @Override
    public String getName() {
        return "SampleJavacPlugin";
    }
 
    @Override
    public void init(JavacTask task, String... args) {
        task.addTaskListener(new SampleTaskListener());
    }
}