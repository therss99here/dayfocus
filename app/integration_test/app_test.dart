import 'package:patrol/patrol.dart';

import 'flows/onboarding_flow_test.dart' as onboarding;
import 'flows/priority_flow_test.dart' as priority;
import 'flows/timeline_flow_test.dart' as timeline;
import 'flows/premium_gate_flow_test.dart' as premium_gate;
import 'flows/settings_flow_test.dart' as settings;
import 'flows/share_flow_test.dart' as share;
import 'flows/day_navigation_flow_test.dart' as day_nav;

void main() {
  onboarding.main();
  priority.main();
  timeline.main();
  premium_gate.main();
  settings.main();
  share.main();
  day_nav.main();
}
