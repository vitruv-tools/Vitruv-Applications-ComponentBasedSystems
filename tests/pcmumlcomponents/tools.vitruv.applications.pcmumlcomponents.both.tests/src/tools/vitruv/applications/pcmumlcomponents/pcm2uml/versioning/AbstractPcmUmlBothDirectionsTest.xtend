package tools.vitruv.applications.pcmumlcomponents.pcm2uml.versioning

import org.eclipse.uml2.uml.UMLFactory
import org.palladiosimulator.pcm.repository.RepositoryFactory
import tools.vitruv.framework.tests.VitruviusApplicationTest
import tools.vitruv.framework.versioning.Conflict
import tools.vitruv.framework.versioning.MultiChangeConflict
import tools.vitruv.framework.versioning.SimpleChangeConflict
import tools.vitruv.framework.util.datatypes.VURI
import org.eclipse.emf.ecore.EObject
import static org.hamcrest.collection.IsCollectionWithSize.hasSize
import static org.junit.Assert.assertThat
import tools.vitruv.framework.versioning.ConflictDetector
import tools.vitruv.framework.versioning.mococo.InternalTestLocalRepository
import tools.vitruv.framework.versioning.mococo.RemoteRepository
import tools.vitruv.framework.vsum.VersioningVirtualModel
import tools.vitruv.framework.versioning.author.Author
import tools.vitruv.framework.versioning.mococo.impl.RemoteRepositoryImpl
import tools.vitruv.framework.versioning.mococo.impl.LocalRepositoryImpl
import tools.vitruv.framework.tests.util.TestUtil
import tools.vitruv.applications.pcmumlcomponents.uml2pcm.UmlToPcmComponentsChangePropagationSpecification
import tools.vitruv.applications.pcmumlcomponents.pcm2uml.PcmToUmlComponentsChangePropagationSpecification
import tools.vitruv.domains.uml.UmlDomainProvider
import tools.vitruv.domains.pcm.PcmDomainProvider

abstract class AbstractPcmUmlBothDirectionsTest<T extends EObject> extends VitruviusApplicationTest {
	protected def void initializeTestModel()

	protected def String getModelFileExtension()

	// Static extensions.
	protected static extension UMLFactory = UMLFactory::eINSTANCE
	protected static extension RepositoryFactory = RepositoryFactory::eINSTANCE

	// Static values.
	protected static val AUTHOR_NAMES = #["Me", "Not me"]
	protected static val MY_MODEL_NAME = "my_model"
	protected static val MY_NAME = "myComponent"
	protected static val THEIR_MODEL_NAME = "their_model"
	protected static val THEIR_NAME = "theirComponent"
	protected static val COMPONENT_NAME = "TestComponent"
	protected static val BASE_COMMIT_MESSAGE = "Base commit"
	protected static val MY_COMMIT_MESSAGE = "My commit"
	protected static val THEIR_COMMIT_MESSAGE = "Their commit"

	// Static functions.
	protected static val acceptTheirChangesCallback = [ Conflict c |
		if (c instanceof MultiChangeConflict) {
			return c.targetChanges
		} else if (c instanceof SimpleChangeConflict) {
			return #[c.targetChange]
		} else
			#[]
	]

	protected static val acceptMyChangesCallback = [ Conflict c |
		if (c instanceof MultiChangeConflict) {
			return c.sourceChanges
		} else if (c instanceof SimpleChangeConflict) {
			return #[c.sourceChange]
		} else
			#[]
	]

	protected static val triggeredCallback = [ Conflict c |
		if (c instanceof MultiChangeConflict) {
			return c.triggeredTargetChanges
		} else
			#[]
	]

	// Variables.
	protected VURI myPCMVURI
	protected VURI myUMLVURI
	protected VURI theirPCMVURI
	protected VURI theirUMLVURI
	protected ConflictDetector conflictDetector = ConflictDetector::createConflictDetector
	protected InternalTestLocalRepository<RemoteRepository> mylocalRepository
	protected InternalTestLocalRepository<RemoteRepository> theirLocalRepository
	protected RemoteRepository remoteRepository

	protected def VURI getCorrespondentVURI(EObject e) {
		val correspondences1 = correspondenceModel.getCorrespondingEObjects(#[e])
		assertThat(correspondences1, hasSize(1))
		val correspondent = correspondences1.flatten.get(0)
		return VURI::getInstance(correspondent.eResource)
	}

	override unresolveChanges() { true }

	override cleanup() {}

	override createChangePropagationSpecifications() {
		return #[
			new PcmToUmlComponentsChangePropagationSpecification,
			new UmlToPcmComponentsChangePropagationSpecification
		]
	}

	override getVitruvDomains() {
		return #[
			new PcmDomainProvider().domain,
			new UmlDomainProvider().domain
		]
	}

	override protected setup() {
		initializeTestModel
		mylocalRepository = new LocalRepositoryImpl
		theirLocalRepository = new LocalRepositoryImpl
		remoteRepository = new RemoteRepositoryImpl
		val localRepos = #[mylocalRepository, theirLocalRepository]

		localRepos.forEach[addRemoteRepository(remoteRepository)]
		localRepos.forEach[r, i|r.author = Author::createAuthor(AUTHOR_NAMES.get(i))]

		val VersioningVirtualModel newVirtualModel = TestUtil::createVirtualModel(
			"newVMname",
			true,
			vitruvDomains,
			createChangePropagationSpecifications,
			userInteractor
		) as VersioningVirtualModel

		mylocalRepository.virtualModel = virtualModel
		theirLocalRepository.virtualModel = newVirtualModel

		mylocalRepository.addOrigin(mylocalRepository.currentBranch, remoteRepository)
		theirLocalRepository.addOrigin(theirLocalRepository.currentBranch, remoteRepository)
	}

	protected def void initializeTheirVURIs() {
		if (myPCMVURI === null || myUMLVURI === null)
			throw new IllegalStateException('''Initialize VURIs!''')
		theirUMLVURI = myUMLVURI.createVURIByReplacing(MY_MODEL_NAME, THEIR_MODEL_NAME)
		theirPCMVURI = myPCMVURI.createVURIByReplacing(MY_MODEL_NAME, THEIR_MODEL_NAME)
		val rootToRootMap = #{
			myUMLVURI.EMFUri.toFileString -> theirUMLVURI.EMFUri.toFileString,
			myPCMVURI.EMFUri.toFileString -> theirPCMVURI.EMFUri.toFileString
		}
		conflictDetector.addMap(rootToRootMap)
	}

	protected def T getRootElement() {
		return MY_MODEL_NAME.projectModelPath.firstRootElement as T
	}

	protected def String getProjectModelPath(String modelName) {
		'''model/«modelName».«modelFileExtension»'''
	}

}
