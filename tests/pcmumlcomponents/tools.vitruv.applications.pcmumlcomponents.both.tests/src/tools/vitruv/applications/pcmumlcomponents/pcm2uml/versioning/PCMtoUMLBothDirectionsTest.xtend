package tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Model

import org.junit.Test

import org.palladiosimulator.pcm.repository.BasicComponent

import tools.vitruv.applications.pcmumlcomponents.both.tests.AbstractPcmToUmlBothDirectionsTest
import tools.vitruv.framework.change.echange.feature.attribute.ReplaceSingleValuedEAttribute

import static org.hamcrest.CoreMatchers.equalTo
import static org.hamcrest.CoreMatchers.instanceOf
import static org.hamcrest.CoreMatchers.not
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.collection.IsEmptyCollection.empty
import static org.hamcrest.collection.IsIterableWithSize.iterableWithSize
import static org.junit.Assert.assertThat

class PCMtoUMLBothDirectionsTest extends AbstractPcmToUmlBothDirectionsTest {
	static val componentName = "ComponentName"

	@Test
	def void changeNameInPCMAndAfterwardsInUML() {
		val pcmComponent1 = createBasicComponent
		pcmComponent1.entityName = componentName
		rootElement.components__Repository += pcmComponent1
		val ppC1 = saveAndSynchronizeChanges(pcmComponent1)
		assertThat(ppC1, hasSize(1))
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[pcmComponent1]).flatten

		assertThat(correspondingElements, iterableWithSize(1))
		val umlComponent = correspondingElements.get(0) as Component
		assertThat(umlComponent, instanceOf(Component))
		assertThat(umlComponent.name, equalTo(componentName))
		val ResourceSet testResourceSet = new ResourceSetImpl
		testResourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("*", new XMIResourceFactoryImpl)
		val sourceModel = testResourceSet.getResource(umlComponent.eResource.URI, true)
		val model = sourceModel.contents.get(0) as Model
		val newUmlComponent = model.packagedElements.get(0)
		startRecordingChanges(model)
		newUmlComponent.name = "newName"
		val propagatedChanges = saveAndSynchronizeChanges(newUmlComponent)
		assertThat(propagatedChanges, hasSize(1))
		val propagatedChange = propagatedChanges.get(0)
		assertThat(propagatedChange.originalChange.EChanges, not(empty))
		assertThat(propagatedChange.consequentialChanges.EChanges, hasSize(1))
		val consequentialEChange1 = propagatedChange.consequentialChanges.EChanges.get(0)
		assertThat(consequentialEChange1, instanceOf(ReplaceSingleValuedEAttribute))
		val viceVersaCorrespondingElements = correspondenceModel.getCorrespondingEObjects(#[newUmlComponent]).flatten
		assertThat(viceVersaCorrespondingElements, iterableWithSize(1))
		val pcmComponent2 = viceVersaCorrespondingElements.get(0) as BasicComponent
		assertThat(pcmComponent2.entityName, equalTo("newName"))
	}

	def void changeNameInUMLAndAfterwardsInPCM() {
		val pcmComponent1 = createBasicComponent
		pcmComponent1.entityName = componentName
		rootElement.components__Repository += pcmComponent1
		saveAndSynchronizeChanges(pcmComponent1)
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[pcmComponent1]).flatten

		assertThat(correspondingElements, iterableWithSize(1))
		val umlComponent = correspondingElements.get(0) as Component
		assertThat(umlComponent, instanceOf(Component))
		assertThat(umlComponent.name, equalTo(componentName))
		val ResourceSet testResourceSet = new ResourceSetImpl
		testResourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("*", new XMIResourceFactoryImpl)
		val sourceModel = testResourceSet.getResource(umlComponent.eResource.URI, true)
		val model = sourceModel.contents.get(0) as Model
		val newUmlComponent = model.packagedElements.get(0)
		startRecordingChanges(model)
		newUmlComponent.name = "newName"
		val propagatedChanges = saveAndSynchronizeChanges(newUmlComponent)
		assertThat(propagatedChanges, hasSize(1))
		val propagatedChange = propagatedChanges.get(0)
		assertThat(propagatedChange.originalChange.EChanges, not(empty))
		assertThat(propagatedChange.consequentialChanges.EChanges, not(empty))
		val viceVersaCorrespondingElements = correspondenceModel.getCorrespondingEObjects(#[newUmlComponent]).flatten
		assertThat(viceVersaCorrespondingElements, iterableWithSize(1))
		val pcmComponent2 = viceVersaCorrespondingElements.get(0) as BasicComponent
		assertThat(pcmComponent2.entityName, equalTo("newName"))
	}

	@Test
	def void testCreateComponent() {
		val pcmComponent1 = createBasicComponent
		pcmComponent1.entityName = componentName
		rootElement.components__Repository += pcmComponent1
		saveAndSynchronizeChanges(pcmComponent1)
		val correspondingElements = correspondenceModel.getCorrespondingEObjects(#[pcmComponent1]).flatten
		assertThat(correspondingElements, iterableWithSize(1))
		val umlComponent = correspondingElements.get(0) as Component
		assertThat(umlComponent, instanceOf(Component))
		assertThat(umlComponent.name, equalTo(componentName))
	}
}
