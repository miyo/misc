package net.wasamon.javaplugintest;

import com.sun.source.util.TaskListener;
import com.sun.source.util.TaskEvent;
import com.sun.source.util.TreeScanner;
import com.sun.source.tree.ClassTree;
import com.sun.source.tree.MethodTree;
	
public class SampleTaskListener implements TaskListener {
	
    public SampleTaskListener() {
    }

    @Override
    public void started(TaskEvent e) {
		if (e.getKind() == TaskEvent.Kind.GENERATE){
            System.out.println("Task event " + e + " has started");
			e.getCompilationUnit().accept(new MyScanner(), null);
        }
	}

    @Override
    public void finished(TaskEvent e) {
        if (e.getKind() == TaskEvent.Kind.PARSE){
            System.out.println("Task event " + e + " has ended");
			e.getCompilationUnit().accept(new MyScanner(), null);
		}
        if (e.getKind() == TaskEvent.Kind.ENTER){
            System.out.println("Task event " + e + " has ended");
			e.getCompilationUnit().accept(new MyScanner(), null);
		}
        if (e.getKind() == TaskEvent.Kind.ANALYZE){
            System.out.println("Task event " + e + " has ended");
			e.getCompilationUnit().accept(new MyScanner(), null);
        }
        if (e.getKind() == TaskEvent.Kind.GENERATE){
            System.out.println("Task event " + e + " has ended");
        }
	}

	class MyScanner extends TreeScanner<Void, Void>{
		@Override
		public Void visitClass(ClassTree node, Void aVoid) {
			System.out.println(node);
			return super.visitClass(node, aVoid);
		}
		@Override
		public Void visitMethod(MethodTree node, Void aVoid) {
			return super.visitMethod(node, aVoid);
		}
	}
			
}
