package tools.vitruv.applications.pcmumlcomponents.both.tests

import java.util.Arrays
import java.util.List

import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.UMLFactory
import org.eclipse.uml2.uml.resource.UMLResource

import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.CompositeComponent
import org.palladiosimulator.pcm.repository.PrimitiveTypeEnum
import org.palladiosimulator.pcm.repository.RepositoryFactory

import tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning.AbstractPcmUmlBothDirectionsTest
import tools.vitruv.applications.pcmumlcomponents.uml2pcm.UmlToPcmTypesUtil

class AbstractUmlToPCMBothDirectionsTest extends AbstractPcmUmlBothDirectionsTest<Model> {
	protected static val INTERFACE_NAME = "TestInterface"
	static val OPERATION_NAME = "fooOperation"
	protected static val PARAMETER_NAME = "fooParameter"
	protected static val PARAMETER_NAME_2 = "barParameter"
	protected static val UML_TYPE_BOOL = "Boolean"
	protected static val UML_TYPE_INT = "Integer"
	protected static val UML_TYPE_REAL = "Real"
	protected static val UML_TYPE_STRING = "String"

	protected Model myUMLModel

	override initializeTestModel() {
		myUMLModel = createModel
		myUMLModel.name = MY_MODEL_NAME
		createAndSynchronizeModel(MY_MODEL_NAME.getProjectModelPath, myUMLModel)
	}

	override getModelFileExtension() { "uml" }

	protected def importPrimitiveTypes() {
		// val resourceSet = rootElement.eResource.resourceSet
		val resourceSet = new ResourceSetImpl
		resourceSet.createResource(URI::createURI(UMLResource.UML_PRIMITIVE_TYPES_LIBRARY_URI))
		val primitiveTypesUri = URI::createURI(UMLResource.UML_PRIMITIVE_TYPES_LIBRARY_URI).appendFragment("_0")
		val primitiveTypes = resourceSet.getEObject(primitiveTypesUri, true)
		val package = primitiveTypes as Package
		rootElement.createPackageImport(package)
		saveAndSynchronizeChanges(rootElement)
		return package
	}

	protected def int getDataTypeUserSelection(String umlTypeName) {
		val pcmType = UmlToPcmTypesUtil::getDataTypeEnumValue(umlTypeName)
		return Arrays::asList(PrimitiveTypeEnum.values).indexOf(pcmType) % PrimitiveTypeEnum::values.length + 1
	}

	protected def Iterable<EObject> correspondingElements(EObject element) {
		return correspondenceModel.getCorrespondingEObjects(#[element]).flatten
	}

	protected def <T> EList<T> toEList(List<T> elements) {
		val eList = new BasicEList<T>
		eList += elements
		return eList
	}

	protected def CompositeComponent getCorrespondingCompositeComponent(Component umlComponent) {
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[umlComponent]).flatten
		return (correspondingElements.get(0) as CompositeComponent)
	}

	protected def BasicComponent getCorrespondingBasicComponent(Component umlComponent) {
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[umlComponent]).flatten
		return (correspondingElements.get(0) as BasicComponent)
	}
}
