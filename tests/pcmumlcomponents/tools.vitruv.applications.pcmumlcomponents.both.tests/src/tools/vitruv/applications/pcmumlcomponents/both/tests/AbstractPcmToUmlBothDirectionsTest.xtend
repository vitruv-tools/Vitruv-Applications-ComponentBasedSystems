package tools.vitruv.applications.pcmumlcomponents.both.tests

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl

import org.eclipse.uml2.uml.Model

import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.PrimitiveDataType
import org.palladiosimulator.pcm.repository.PrimitiveTypeEnum
import org.palladiosimulator.pcm.repository.Repository

import tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning.AbstractPcmUmlBothDirectionsTest

abstract class AbstractPcmToUmlBothDirectionsTest extends AbstractPcmUmlBothDirectionsTest<Repository> {
	// Static values.
	protected static val ATTRIBUTE_NAME = "fooAttribute"
	protected static val INTERFACE_NAME = "TestInterface"
	protected static val OPERATION_NAME = "fooOperation"
	protected static val OPERATION_NAME_2 = "barOperation"
	protected static val PARAMETER_NAME = "fooParameter"
	protected static val PARAMETER_NAME_2 = "barParameter"
	static val PRIMITIVETYPES_URI = "pathmap://PCM_MODELS/PrimitiveTypes.repository"

	// static val PRIMITIVETYPES_URI = "platform:/plugin/org.palladiosimulator.pcm.resources/defaultModels/PrimitiveTypes.repository"
	// Static variables.
	protected static Repository primitiveTypesRepository = null

	// Variables.
	protected Repository myPCMRepository

	override protected getModelFileExtension() { "repository" }

	override initializeTestModel() {
		myPCMRepository = createRepository
		myPCMRepository.entityName = MY_MODEL_NAME
		createAndSynchronizeModel(MY_MODEL_NAME.projectModelPath, myPCMRepository)
	}

	protected def Model getUmlModel() {
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[rootElement]).flatten
		return (correspondingElements.get(0) as Model)
	}

	protected def Repository loadPrimitiveTypes() {
		if (primitiveTypesRepository !== null)
			return primitiveTypesRepository

		val ResourceSet resSet = new ResourceSetImpl
		return loadPrimitiveTypes(resSet)
	}

	protected def Repository loadPrimitiveTypes(ResourceSet resourceSet) {
		if (primitiveTypesRepository !== null)
			return primitiveTypesRepository
		val uri = URI::createURI(PRIMITIVETYPES_URI)

		val resource = resourceSet.getResource(uri, true)

		primitiveTypesRepository = resource.contents.head as Repository
		return primitiveTypesRepository
	}

	protected def PrimitiveDataType getPrimitiveType(PrimitiveTypeEnum type) {
		return loadPrimitiveTypes.dataTypes__Repository.get(type.value) as PrimitiveDataType
	}

	protected def Iterable<EObject> correspondingElements(EObject element) {
		return correspondenceModel.getCorrespondingEObjects(#[element]).flatten
	}

	protected def BasicComponent createABasicComponent(String name) {
		val pcmComponent = createBasicComponent
		pcmComponent.entityName = name
		rootElement.components__Repository += pcmComponent
		saveAndSynchronizeChanges(pcmComponent)
		return pcmComponent
	}
}
