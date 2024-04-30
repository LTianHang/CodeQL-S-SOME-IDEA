import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources

module ShiroDefaultKeyConfig implements DataFlow::ConfigSig {
  predicate isSource(DataFlow::Node source) { source = source }

  predicate isSink(DataFlow::Node sink) {
    exists(MethodCall methodCall |
      methodCall.getMethod().getName() = "setCipherKey" and
      methodCall.getQualifier().getType().getName() = "CookieRememberMeManager" and
      sink.asExpr() = methodCall.getAnArgument()
    )
  }
}

module ShiroDefaultKeyFlow = DataFlow::Global<ShiroDefaultKeyConfig>;

from DataFlow::Node source, DataFlow::Node sink
where ShiroDefaultKeyFlow::flow(source, sink)
select source, sink, "Shiro Default Key"
