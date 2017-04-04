package mir.reactions.reactionsPcmToJava.pcm2ejbJava;

import mir.routines.pcm2ejbJava.RoutinesFacade;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.xbase.lib.Extension;
import org.palladiosimulator.pcm.repository.OperationInterface;
import org.palladiosimulator.pcm.repository.OperationSignature;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractReactionRealization;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.compound.RemoveAndDeleteNonRoot;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;
import tools.vitruv.framework.userinteraction.UserInteracting;

@SuppressWarnings("all")
class DeletedOperationSignatureReaction extends AbstractReactionRealization {
  public DeletedOperationSignatureReaction(final UserInteracting userInteracting) {
    super(userInteracting);
  }
  
  public void executeReaction(final EChange change) {
    RemoveEReference<OperationInterface, OperationSignature> typedChange = ((RemoveAndDeleteNonRoot<OperationInterface, OperationSignature>)change).getRemoveChange();
    OperationInterface affectedEObject = typedChange.getAffectedEObject();
    EReference affectedFeature = typedChange.getAffectedFeature();
    OperationSignature oldValue = typedChange.getOldValue();
    mir.routines.pcm2ejbJava.RoutinesFacade routinesFacade = new mir.routines.pcm2ejbJava.RoutinesFacade(this.executionState, this);
    mir.reactions.reactionsPcmToJava.pcm2ejbJava.DeletedOperationSignatureReaction.ActionUserExecution userExecution = new mir.reactions.reactionsPcmToJava.pcm2ejbJava.DeletedOperationSignatureReaction.ActionUserExecution(this.executionState, this);
    userExecution.callRoutine1(affectedEObject, affectedFeature, oldValue, routinesFacade);
  }
  
  public static Class<? extends EChange> getExpectedChangeType() {
    return RemoveAndDeleteNonRoot.class;
  }
  
  private boolean checkChangeProperties(final EChange change) {
    RemoveEReference<OperationInterface, OperationSignature> relevantChange = ((RemoveAndDeleteNonRoot<OperationInterface, OperationSignature>)change).getRemoveChange();
    if (!(relevantChange.getAffectedEObject() instanceof OperationInterface)) {
    	return false;
    }
    if (!relevantChange.getAffectedFeature().getName().equals("signatures__OperationInterface")) {
    	return false;
    }
    if (!(relevantChange.getOldValue() instanceof OperationSignature)) {
    	return false;
    }
    return true;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (!(change instanceof RemoveAndDeleteNonRoot)) {
    	return false;
    }
    getLogger().debug("Passed change type check of reaction " + this.getClass().getName());
    if (!checkChangeProperties(change)) {
    	return false;
    }
    getLogger().debug("Passed change properties check of reaction " + this.getClass().getName());
    getLogger().debug("Passed complete precondition check of reaction " + this.getClass().getName());
    return true;
  }
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final OperationInterface affectedEObject, final EReference affectedFeature, final OperationSignature oldValue, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.deleteMethodForOperationSignature(oldValue);
    }
  }
}
