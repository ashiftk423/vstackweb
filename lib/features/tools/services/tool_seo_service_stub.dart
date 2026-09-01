import 'package:vstackweb/features/tools/models/tool_definition.dart';

abstract class ToolSeoService {
  void apply(ToolDefinition tool);
  void reset();
}

ToolSeoService createToolSeoService() => ToolSeoServiceStub();

class ToolSeoServiceStub implements ToolSeoService {
  @override
  void apply(ToolDefinition tool) {}

  @override
  void reset() {}
}
