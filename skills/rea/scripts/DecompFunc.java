// DecompFunc.java - Ghidra headless postScript: print the decompiled C of ONE function (or list function names).
// Usage: analyzeHeadless PROJDIR NAME -import BIN -scriptPath DIR -postScript DecompFunc.java NAME|-list [REGEX] -deleteProject
//@category RE
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.FunctionIterator;

public class DecompFunc extends GhidraScript {
	@Override
	protected void run() throws Exception {
		String[] a = getScriptArgs();
		if (a.length < 1) { println("usage: DecompFunc.java NAME | -list [REGEX]"); return; }
		if (a[0].equals("-list")) {
			String re = a.length > 1 ? a[1] : ".*";
			for (Function f : currentProgram.getFunctionManager().getFunctions(true))
				if (f.getName().matches(re)) println(f.getEntryPoint() + " " + f.getName());
			return;
		}
		DecompInterface d = new DecompInterface();
		d.openProgram(currentProgram);
		FunctionIterator it = currentProgram.getFunctionManager().getFunctions(true);
		for (Function f : it) {
			if (!f.getName().equals(a[0])) continue;
			DecompileResults r = d.decompileFunction(f, 60, monitor);
			if (r.decompileCompleted()) println(r.getDecompiledFunction().getC());
			else println("decompile failed: " + r.getErrorMessage());
			return;
		}
		println("no function named " + a[0]);
	}
}
