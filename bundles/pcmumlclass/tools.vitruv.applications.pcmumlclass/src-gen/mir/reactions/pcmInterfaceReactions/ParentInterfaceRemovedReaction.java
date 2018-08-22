package mir.reactions.pcmInterfaceReactions;

import mir.routines.pcmInterfaceReactions.RoutinesFacade;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.xbase.lib.Extension;
import org.palladiosimulator.pcm.repository.OperationInterface;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractReactionRealization;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;

@SuppressWarnings("all")
public class ParentInterfaceRemovedReaction extends AbstractReactionRealization {
  private RemoveEReference<OperationInterface, OperationInterface> removeChange;
  
  private int currentlyMatchedChange;
  
  public ParentInterfaceRemovedReaction(final RoutinesFacade routinesFacade) {
    super(routinesFacade);
  }
  
  public void executeReaction(final EChange change) {
    if (!checkPrecondition(change)) {
    	return;
    }
    org.palladiosimulator.pcm.repository.OperationInterface affectedEObject = removeChange.getAffectedEObject();
    EReference affectedFeature = removeChange.getAffectedFeature();
    org.palladiosimulator.pcm.repository.OperationInterface oldValue = removeChange.getOldValue();
    int index = removeChange.getIndex();
    				
    getLogger().trace("Passed change matching of Reaction " + this.getClass().getName());
    if (!checkUserDefinedPrecondition(removeChange, affectedEObject, affectedFeature, oldValue, index)) {
    	resetChanges();
    	return;
    }
    getLogger().trace("Passed complete precondition check of Reaction " + this.getClass().getName());
    				
    mir.reactions.pcmInterfaceReactions.ParentInterfaceRemovedReaction.ActionUserExecution userExecution = new mir.reactions.pcmInterfaceReactions.ParentInterfaceRemovedReaction.ActionUserExecution(this.executionState, this);
    userExecution.callRoutine1(removeChange, affectedEObject, affectedFeature, oldValue, index, this.getRoutinesFacade());
    
    resetChanges();
  }
  
  private void resetChanges() {
    removeChange = null;
    currentlyMatchedChange = 0;
  }
  
  private boolean matchRemoveChange(final EChange change) {
    if (change instanceof RemoveEReference<?, ?>) {
    	RemoveEReference<org.palladiosimulator.pcm.repository.OperationInterface, org.palladiosimulator.pcm.repository.OperationInterface> _localTypedChange = (RemoveEReference<org.palladiosimulator.pcm.repository.OperationInterface, org.palladiosimulator.pcm.repository.OperationInterface>) change;
    	if (!(_localTypedChange.getAffectedEObject() instanceof org.palladiosimulator.pcm.repository.OperationInterface)) {
    		return false;
    	}
    	if (!_localTypedChange.getAffectedFeature().getName().equals("parentInterfaces__Interface")) {
    		return false;
    	}
    	if (!(_localTypedChange.getOldValue() instanceof org.palladiosimulator.pcm.repository.OperationInterface)) {
    		return false;
    	}
    	this.removeChange = (RemoveEReference<org.palladiosimulator.pcm.repository.OperationInterface, org.palladiosimulator.pcm.repository.OperationInterface>) change;
    	return true;
    }
    
    return false;
  }
  
  public boolean checkPrecondition(final EChange change) {
    if (currentlyMatchedChange == 0) {
    	if (!matchRemoveChange(change)) {
    		resetChanges();
    		return false;
    	} else {
    		currentlyMatchedChange++;
    	}
    }
    
    return true;
  }
  
  private boolean checkUserDefinedPrecondition(final RemoveEReference removeChange, final OperationInterface affectedEObject, final EReference affectedFeature, final OperationInterface oldValue, final int index) {
    boolean _contains = affectedEObject.getParentInterfaces__Interface().contains(oldValue);
    return (!_contains);
  }
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final RemoveEReference removeChange, final OperationInterface affectedEObject, final EReference affectedFeature, final OperationInterface oldValue, final int index, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.removeParentInterfaceFromCorrespondingInterface(affectedEObject, oldValue);
    }
  }
}