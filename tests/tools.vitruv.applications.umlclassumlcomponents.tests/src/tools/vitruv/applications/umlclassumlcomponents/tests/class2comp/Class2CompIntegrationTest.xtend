package tools.vitruv.applications.umlclassumlcomponents.tests.class2comp

import org.eclipse.uml2.uml.InterfaceRealization
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.NamedElement
import org.eclipse.uml2.uml.Usage
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.DataType
import org.eclipse.uml2.uml.Interface
import org.eclipse.uml2.uml.Operation
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.Property

import static extension tools.vitruv.applications.umlclassumlcomponents.tests.util.SharedIntegrationTestUtil.*
import org.junit.jupiter.api.Test

import static org.junit.jupiter.api.Assertions.assertTrue
import java.nio.file.Path

class Class2CompIntegrationTest extends AbstractClass2CompTest {

	override protected isInitializeTestModel() {
		return false
	}

	def Model integrationTest(String fileName) {
		resourceAt(Path.of(OUTPUT_NAME)).propagate [
			contents += Model.from(fileName.testModelResource)
		]

		return Model.from(Path.of(OUTPUT_NAME))
	}

	/*******
	 * Tests:*
	 ********/
	@Test
	def void integrationTestWith2Classses() {
		userInteraction // 2x Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No").onNextMultipleChoiceSingleSelection.respondWith("No") // 2x Decide to create a Component for the Class:
		.onNextMultipleChoiceSingleSelection.respondWith("Yes").onNextMultipleChoiceSingleSelection.respondWith("Yes")

		val umlModel = integrationTest("TestModel2Classes.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 2) // There should be 2 original Packages
		assertCountOfTypeInPackage(modelElements, 0, Class, 1) // Class Package 1 should have 1 original Class
		assertCountOfTypeInPackage(modelElements, 1, Class, 1) // Class Package 2 should have 1 original Class
		assertCountOfTypeInList(modelElements, Component, 2) // There should be 2 new Components
	}

	@Test
	def void integrationTestWith2ClasssesWithoutPackage() {
		// Temporary test to check created changes while debugging
		val umlModel = integrationTest("TestModel2ClassesWithoutPackage.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 0) // There should be no original Packages
		assertCountOfTypeInList(modelElements, Class, 2) // There should be 2 original Classes
		assertCountOfTypeInList(modelElements, Component, 0) // There should be no new Components
	}

	@Test
	def void integrationTestWithClassAndDataType() {
		userInteraction // 2x Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No").onNextMultipleChoiceSingleSelection.respondWith("No") // Decide to create a Class as a DataType (no Interactions)
		// Decide to create a Component for the Class:
		.onNextMultipleChoiceSingleSelection.respondWith("Yes")

		val umlModel = integrationTest("TestModel1Class1Datatype.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 2) // There should be 2 original Packages
		assertCountOfTypeInPackage(modelElements, 0, Class, 1) // Class DataTypes Package should have 1 Class
		assertCountOfTypeInPackage(modelElements, 1, Class, 1) // Class Package 1 should have 1 Class
		assertCountOfTypeInList(modelElements, Component, 1) // There should be 1 new Component
		assertCountOfTypeInList(modelElements, DataType, 1) // There should be 1 new DataType
	}

	@Test
	def void integrationTestWithClassAndDataTypeWithPropertyAndOperation() {
		userInteraction // Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No")
		// Decide to create a Class as a DataType (no Interactions)
		val umlModel = integrationTest("TestModel1DatatypeWithPropertyAndOperation.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 1) // There should be 1 original Packages
		assertCountOfTypeInPackage(modelElements, 0, Class, 1) // Class DataTypes Package should have 1 Class
		assertCountOfTypeInList(modelElements, Component, 0) // There should be no new Components
		assertCountOfTypeInList(modelElements, DataType, 1) // There should be 1 new DataType
		// Check new DataType for Property & Operation:
		val compDataType = modelElements.filter(DataType).get(0)
		val ownedAttributes = compDataType.ownedAttributes.map[e|e as NamedElement]
		assertCountOfTypeInList(ownedAttributes, Property, 1) // There should be 1 Property
		val ownedOperations = compDataType.operations.map[e|e as NamedElement]
		assertCountOfTypeInList(ownedOperations, Operation, 1) // There should be 1 Operation
	}

	@Test
	def void integrationTestWithTestModel2ClassesAndRequiredAndProvidedInterface() {
		userInteraction // 2x Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No").onNextMultipleChoiceSingleSelection.respondWith("No") // 2x Decide to create a Component for the Class:
		.onNextMultipleChoiceSingleSelection.respondWith("Yes").onNextMultipleChoiceSingleSelection.respondWith("Yes")

		val umlModel = integrationTest("TestModel2ClassesWithInterfaceRequiredAndProvided.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 2) // There should be 2 original Packages
		assertCountOfTypeInPackage(modelElements, 0, Class, 1) // Class Package 1 should have 1 original Class
		assertCountOfTypeInPackage(modelElements, 1, Class, 1) // Class Package 2 should have 1 original Class
		assertCountOfTypeInList(modelElements, Component, 2) // There should be 2 new Components		
		assertCountOfTypeInPackage(modelElements, 0, Interface, 1) // Class Package 1 should have 1 Interface
		assertCountOfTypeInPackage(modelElements, 1, Interface, 0) // Class Package 2 should have no Interfaces
		// Check Component 1 for InterfaceRealization and inspect if its setup correctly:
		val umlComp1 = modelElements.filter(Component).get(0)
		val iFRealizations = umlComp1.interfaceRealizations.map[e|e as NamedElement]
		assertCountOfTypeInList(iFRealizations, InterfaceRealization, 1) // There should be 1 InterfaceRealization
		val iFRealization = iFRealizations.get(0) as InterfaceRealization
		val compInterface = modelElements.filter(Interface).get(0)
		assertTrue(iFRealization.clients.contains(umlComp1))
		assertTrue(iFRealization.contract == compInterface)
		assertTrue(iFRealization.suppliers.contains(compInterface))
		assertTrue(umlComp1.interfaceRealizations.contains(iFRealization))

		// Check Component 2 for Usage and inspect if its setup correctly:
		val umlComp2 = modelElements.filter(Component).get(1)
		val usages = umlComp2.packagedElements.filter(Usage).toList.map[e|e as NamedElement]
		assertCountOfTypeInList(usages, Usage, 1) // There should be 1 Usage
		val compUsage = usages.get(0) as Usage
		assertTrue(compUsage.clients.contains(umlComp2))
		assertTrue(compUsage.suppliers.contains(compInterface))
		assertTrue(umlComp2.packagedElements.contains(compUsage))
	}

	@Test
	def void integrationTestAllCombined() {
		userInteraction // 3x Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No").onNextMultipleChoiceSingleSelection.respondWith("No").
			onNextMultipleChoiceSingleSelection.respondWith("No") // Decide to create a Class as a DataType (no Interactions)
			// 2x Decide to create a Component for the Class:
			.onNextMultipleChoiceSingleSelection.respondWith("Yes").onNextMultipleChoiceSingleSelection.
			respondWith("Yes")

		val umlModel = integrationTest("TestModelAllCombined.uml")

		// Validate expected contents:
		val modelElements = umlModel.packagedElements.map[e|e as NamedElement]
		assertCountOfTypeInList(modelElements, Package, 3) // There should be 3 original Packages		
		assertCountOfTypeInPackage(modelElements, 0, Class, 1) // Class DataTypes Package should have 1 Class
		assertCountOfTypeInPackage(modelElements, 1, Class, 1) // Class Package 1 should have 1 original Class
		assertCountOfTypeInPackage(modelElements, 2, Class, 1) // Class Package 2 should have 1 original Class
		assertCountOfTypeInList(modelElements, Component, 2) // There should be 2 new Components		
		assertCountOfTypeInPackage(modelElements, 1, Interface, 1) // Class Package 1 should have 1 Interface
		assertCountOfTypeInPackage(modelElements, 2, Interface, 0) // Class Package 2 should have no Interfaces
		assertCountOfTypeInList(modelElements, DataType, 1) // There should be 2 new DataTypes
		// Check Component DataType for Property & Operation:
		val compDataType1 = modelElements.filter(DataType).get(0)
		val ownedAttributes = compDataType1.ownedAttributes.map[e|e as NamedElement]
		assertCountOfTypeInList(ownedAttributes, Property, 1) // There should be 1 Property
		val ownedOperations = compDataType1.operations.map[e|e as NamedElement]
		assertCountOfTypeInList(ownedOperations, Operation, 1) // There should be 1 Operation
		// Check Component 1 for InterfaceRealization and inspect if its setup correctly:
		val umlComp1 = modelElements.filter(Component).get(0)
		val iFRealizations = umlComp1.interfaceRealizations.map[e|e as NamedElement]
		assertCountOfTypeInList(iFRealizations, InterfaceRealization, 1) // There should be 1 InterfaceRealization
		val iFRealization = iFRealizations.get(0) as InterfaceRealization
		val compInterface = modelElements.filter(Interface).get(0)
		assertTrue(iFRealization.clients.contains(umlComp1))
		assertTrue(iFRealization.contract == compInterface)
		assertTrue(iFRealization.suppliers.contains(compInterface))
		assertTrue(umlComp1.interfaceRealizations.contains(iFRealization))

		// Check Component 2 for Usage and inspect if its setup correctly:
		val umlComp2 = modelElements.filter(Component).get(1)
		val usages = umlComp2.packagedElements.filter(Usage).toList.map[e|e as NamedElement]
		assertCountOfTypeInList(usages, Usage, 1) // There should be 1 Usage
		val compUsage = usages.get(0) as Usage
		assertTrue(compUsage.clients.contains(umlComp2))
		assertTrue(compUsage.suppliers.contains(compInterface))
		assertTrue(umlComp2.packagedElements.contains(compUsage))
	}

	@Test
	def void integrationTestMatthiasSmallExampleClassResult() {
		userInteraction // 3x Decide to create an empty Package:
		.onNextMultipleChoiceSingleSelection.respondWith("No").onNextMultipleChoiceSingleSelection.respondWith("No").
			onNextMultipleChoiceSingleSelection.respondWith("No") // Decide to create a Class as a DataType (no Interactions)
			// Decide to create a Component for the Class:
			.onNextMultipleChoiceSingleSelection.respondWith("Yes") // Decide to create a Component for the Class:
			.onNextMultipleChoiceSingleSelection.respondWith("Yes")

		integrationTest("Matthias_small_example_Class_Result.uml")
	}
}
