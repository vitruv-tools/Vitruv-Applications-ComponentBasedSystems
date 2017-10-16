package tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning

import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.junit.runners.Suite.SuiteClasses

@RunWith(Suite)
@SuiteClasses(#[
	PCMtoUMLBothDirectionsVersioningTest,
	UmlToPCMBothDirectionsVersioningTest
])
class PCMUMLBothTestSuite {
}
