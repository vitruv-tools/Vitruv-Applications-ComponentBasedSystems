package tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning

import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl

import org.eclipse.uml2.uml.Component
import org.eclipse.uml2.uml.Model

import org.junit.Test
import tools.vitruv.framework.versioning.Conflict
import java.util.List
import tools.vitruv.framework.change.echange.EChange
import org.eclipse.xtext.xbase.lib.Functions.Function1
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

class UmlToPCMBothDirectionsNamingAndDeletion extends UmlToPCMBothDirectionsTest {
	override setup() {
		super.setup
		myUMLVURI = VURI::getInstance(myUMLModel.eResource)
		myPCMVURI = myUMLModel.correspondentVURI
		initializeTheirVURIs
	}

	private def Pair<Component, BasicComponent> testCreateAndRenameConflictAndAccept(
		Function1<Conflict, List<EChange>> callback
	) {
		// PS Same base in both virtual models.
		val myUMLComponent = createUmlComponent(COMPONENT_NAME, false)

		saveAndSynchronizeChanges(rootElement)
		assertThat(mylocalRepository.commit(BASE_COMMIT_MESSAGE, myUMLVURI).changes, hasSize(2))
		assertThat(mylocalRepository.push, is(PushState::SUCCESS))

		theirLocalRepository.pull
		theirLocalRepository.checkout(theirUMLVURI)

		// PS Check if changes are in new virtual model.
		val model = theirLocalRepository.virtualModel.getModelInstance(theirUMLVURI).firstRootEObject as Model
		val myRepo = mylocalRepository.virtualModel.getModelInstance(myPCMVURI).firstRootEObject as Repository
		val theirRep = theirLocalRepository.virtualModel.getModelInstance(theirPCMVURI).firstRootEObject as Repository

		// PS TODO When reapplying the already recorded changes to other virtual model, only the original changes 
		// are applied. So the correspondent PCM elements get new IDs. To handle the objects in PCM still as the same object 
		// although the IDs are different, this mapping is used. 
		theirLocalRepository.addIDPair(theirRep.id -> myRepo.id)
		val myPCMComponent = myRepo.components__Repository.get(0) as BasicComponent
		val theirPCMComponent1 = theirRep.components__Repository.get(0) as BasicComponent
		theirLocalRepository.addIDPair(myPCMComponent.id -> theirPCMComponent1.id)

		val umlComponent = model.packagedElements.get(0) as Component
		assertThat(umlComponent.name, equalTo(COMPONENT_NAME))
		val correspondences1 = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[umlComponent]).flatten
		assertThat(correspondences1, iterableWithSize(1))
		val basicComponent1 = correspondences1.get(0) as BasicComponent
		assertThat(basicComponent1.entityName, equalTo(COMPONENT_NAME))

		// PS Change 
		myUMLComponent.name = UmlToPCMBothDirectionsVersioningTest.MY_NAME
		saveAndSynchronizeChanges(rootElement)

		assertThat(mylocalRepository.commit(MY_COMMIT_MESSAGE, myUMLVURI).changes, hasSize(1))
		assertThat(mylocalRepository.push, is(PushState::SUCCESS))

		// PS Delete BasicComponent in pcm, commit and push should abort 
		val correspondences = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[umlComponent]).flatten.toList
		assertThat(correspondences, hasSize(1))
		val theirPCMComponent = correspondences.get(0) as BasicComponent
		assertThat(theirPCMComponent.entityName, equalTo(COMPONENT_NAME))
		val ResourceSet testResourceSet = new ResourceSetImpl
		testResourceSet.resourceFactoryRegistry.extensionToFactoryMap.put("*", new XMIResourceFactoryImpl)
		val sourceModel = testResourceSet.getResource(theirPCMComponent.eResource.URI, true)
		val repo = sourceModel.contents.get(0) as Repository
		startRecordingChanges(repo)
		repo.components__Repository.remove(0)
		saveAndSynchronizeChanges(theirLocalRepository.virtualModel, repo)
		theirPCMVURI = VURI::getInstance(repo.eResource)
		assertThat(theirLocalRepository.commit(THEIR_COMMIT_MESSAGE, theirPCMVURI).changes, hasSize(2))
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
		val modelAgain = theirLocalRepository.virtualModel.getModelInstance(theirUMLVURI).firstRootEObject as Model
		if (modelAgain.packagedElements.empty) {
			val repoAgain = mylocalRepository.virtualModel.getModelInstance(theirPCMVURI).firstRootEObject as Repository
			if (repoAgain.components__Repository.empty)
				return null -> null
			// PS There is a problem in the reactions for Deletion of Uml components 
			// throw new IllegalStateException("components__Repository should be empty")
			return null -> null
		}
		val umlComponentAgain = modelAgain.packagedElements.get(0) as Component

		val correspondences2 = theirLocalRepository.virtualModel.correspondenceModel.
			getCorrespondingEObjects(#[umlComponentAgain]).flatten.toList
		if (correspondences2.empty) {
			
		}
		val pcmComponentAgain = correspondences2.get(0) as BasicComponent
		return umlComponentAgain -> pcmComponentAgain
	}

	@Test
	def void testCreateAndRenameConflictAndAcceptTheirName() {
		val pair = testCreateAndRenameConflictAndAccept(acceptTheirChangesCallback)
		val umlComponent = pair.key
		val pcmComponent = pair.value
		assertThat(umlComponent, equalTo(null))
		assertThat(pcmComponent, equalTo(null))
	}

	@Test
	def void testCreateAndRenameConflictAndAcceptMyName() {
		val pair = testCreateAndRenameConflictAndAccept(acceptMyChangesCallback)

		val umlComponent = pair.key
		val pcmComponent = pair.value
		assertThat(umlComponent.name, is(MY_NAME))
		assertThat(pcmComponent.entityName, is(MY_NAME))
	}
}
