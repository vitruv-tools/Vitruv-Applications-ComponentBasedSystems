package tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Model

import org.junit.Test

import org.palladiosimulator.pcm.repository.BasicComponent
import org.palladiosimulator.pcm.repository.Repository

import tools.vitruv.framework.util.datatypes.VURI
import tools.vitruv.framework.versioning.mococo.PushState

import static org.hamcrest.CoreMatchers.equalTo
import static org.hamcrest.CoreMatchers.is
import static org.hamcrest.CoreMatchers.not

import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.hamcrest.collection.IsIterableWithSize.iterableWithSize

import static org.junit.Assert.assertThat
import org.eclipse.xtext.xbase.lib.Functions.Function1
import tools.vitruv.framework.versioning.Conflict
import java.util.List
import tools.vitruv.framework.change.echange.EChange
import tools.vitruv.framework.tuid.TuidManager

class PCMtoUMLBothDirectionsVersioningTest extends PCMtoUMLBothDirectionsTest {

	override setup() {
		super.setup
		myPCMVURI = VURI::getInstance(myPCMRepository.eResource)
		myUMLVURI = myPCMRepository.correspondentVURI
		initializeTheirVURIs
	}

	private def void testCreateAndRenameConflictAndAccept(
		Function1<Conflict, List<EChange>> callback,
		String expectedName
	) {
		// PS Same base in both virtual models.
		val myPCMComponent = createABasicComponent(COMPONENT_NAME)

		assertThat(mylocalRepository.commit(BASE_COMMIT_MESSAGE, myPCMVURI).changes, hasSize(2))
		assertThat(mylocalRepository.push, is(PushState::SUCCESS))

		theirLocalRepository.pull
		theirLocalRepository.checkout(theirPCMVURI)

		// PS Check if changes are in new virtual model.
		val theirPCMRepository = theirLocalRepository.virtualModel.getModelInstance(theirPCMVURI).
			firstRootEObject as Repository

		// PS TODO When reapplying the already recorded changes to other virtual model, only the original changes 
		// are applied. So the correspondent PCM elements get new IDs. To handle the objects in PCM still as the same object 
		// although the IDs are different, this mapping is used. 
		theirLocalRepository.addIDPair(theirPCMRepository.id -> myPCMRepository.id)
		val theirPCMComponent1 = theirPCMRepository.components__Repository.get(0) as BasicComponent
		theirLocalRepository.addIDPair(myPCMComponent.id -> theirPCMComponent1.id)
		assertThat(theirPCMComponent1.entityName, equalTo(COMPONENT_NAME))

		val correspondences1 = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[theirPCMComponent1]).flatten
		assertThat(correspondences1, iterableWithSize(1))
		val theirUMLComponent = correspondences1.get(0) as Component
		assertThat(theirUMLComponent.name, equalTo(COMPONENT_NAME))
		val viceVersaCorrespondence = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[theirUMLComponent]).flatten

		assertThat(viceVersaCorrespondence, iterableWithSize(1))
		val theirViceVersaPCMComponent = viceVersaCorrespondence.get(0) as BasicComponent
		assertThat(theirViceVersaPCMComponent.entityName, equalTo(COMPONENT_NAME))

		// PS Change entityName to MY_NAME in PCM 
		myPCMComponent.entityName = MY_NAME
		saveAndSynchronizeChanges(rootElement)

		assertThat(mylocalRepository.commit(MY_COMMIT_MESSAGE, myPCMVURI).changes, hasSize(1))
		assertThat(mylocalRepository.push, is(PushState::SUCCESS))

		// PS Change name in UML, commit and push should abort 
		val correspondences = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[theirPCMComponent1]).flatten.toList
		assertThat(correspondences, hasSize(1))
		val theirUMLComponent1 = correspondences.get(0) as Component
		assertThat(theirUMLComponent1.name, equalTo(COMPONENT_NAME))
		val ResourceSet testResourceSet = new ResourceSetImpl
		testResourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("*", new XMIResourceFactoryImpl)
		val sourceModel = testResourceSet.getResource(theirUMLComponent1.eResource.URI, true)
		val theirModifiableModel = sourceModel.contents.get(0) as Model
		val theirModifiableComponent = theirModifiableModel.packagedElements.get(0) as Component
		startRecordingChanges(theirModifiableModel)
		theirModifiableComponent.name = THEIR_NAME
		saveAndSynchronizeChanges(theirLocalRepository.virtualModel, theirModifiableModel)

		assertThat(theirLocalRepository.commit(THEIR_COMMIT_MESSAGE, theirUMLVURI).changes, hasSize(1))
		assertThat(theirLocalRepository.push, is(PushState::COMMIT_NOT_ACCEPTED))

		// PS Pull new commit and merge 
		val remoteBranch = theirLocalRepository.currentBranch.remoteBranch
		assertThat(theirLocalRepository.getCommits(remoteBranch), hasSize(2))
		theirLocalRepository.pull
		assertThat(theirLocalRepository.getCommits(remoteBranch), hasSize(3))
		val lastRemoteCommit = theirLocalRepository.getCommits(remoteBranch).last
		val lastLocalCommit = theirLocalRepository.getCommits(theirLocalRepository.currentBranch).last
		assertThat(lastRemoteCommit.identifier, not(equalTo(lastLocalCommit.identifier)))

		// PS Merge and accept their changes 
		val mergeCommit = theirLocalRepository.merge(
			remoteBranch -> mylocalRepository.virtualModel,
			theirLocalRepository.currentBranch -> theirLocalRepository.virtualModel,
			callback,
			triggeredCallback,
			theirLocalRepository.virtualModel
		)
		assertThat(mergeCommit.changes, hasSize(1))
		assertThat(theirLocalRepository.push, is(PushState::SUCCESS))
		val theirPCMRepositoryAgain = theirLocalRepository.virtualModel.getModelInstance(theirPCMVURI).
			firstRootEObject as Repository
		val theirPCMComponentAgain = theirPCMRepositoryAgain.components__Repository.get(0) as BasicComponent
		assertThat(theirPCMComponentAgain.entityName, is(expectedName))
		val theirUMLModelAgain = theirLocalRepository.virtualModel.getModelInstance(theirUMLVURI).
			firstRootEObject as Model
		val theirUMLComponentAgain = theirUMLModelAgain.packagedElements.get(0) as Component
		assertThat(theirUMLComponentAgain.name, is(expectedName))
	}

	@Test
	def void testCreateAndRenameConflictAndAcceptTheirName() {
		testCreateAndRenameConflictAndAccept(acceptTheirChangesCallback, THEIR_NAME)
	}

	@Test
	def void testCreateAndRenameConflictAndAcceptMyName() {
		testCreateAndRenameConflictAndAccept(acceptMyChangesCallback, MY_NAME)
	}
}
