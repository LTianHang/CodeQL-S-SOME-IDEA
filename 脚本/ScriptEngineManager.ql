import java
import semmle.code.java.dataflow.DataFlow
import DataFlow
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.security.TemplateInjection

module ScriptEngineConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  predicate isSink(DataFlow::Node sink) {
    exists(MethodCall methodCall |
      methodCall.getMethod().getName() = "eval" and
      methodCall.getQualifier().getType().getName() = "ScriptEngine" and
      sink.asExpr() = methodCall.getAnArgument()
    )
  }
}

module ScriptEngineFlow = DataFlow::Global<ScriptEngineConfig>;

from DataFlow::Node source, DataFlow::Node sink
where ScriptEngineFlow::flow(source, sink)
select source, sink, "Script Engine Remote Command Execute"
