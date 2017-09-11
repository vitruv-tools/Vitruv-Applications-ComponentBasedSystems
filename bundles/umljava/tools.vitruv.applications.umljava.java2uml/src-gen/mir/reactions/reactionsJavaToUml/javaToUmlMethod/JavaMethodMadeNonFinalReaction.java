package mir.reactions.reactionsJavaToUml.javaToUmlMethod;

import mir.routines.javaToUmlMethod.RoutinesFacade;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.xbase.lib.Extension;
import org.emftext.language.java.members.ClassMethod;
import org.emftext.language.java.modifiers.Final;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractReactionRealization;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;
import tools.vitruv.framework.change.echange.EChange;
import tools.vitruv.framework.change.echange.eobject.DeleteEObject;
import tools.vitruv.framework.change.echange.feature.reference.RemoveEReference;

@SuppressWarnings("all")
class JavaMethodMadeNonFinalReaction extends AbstractReactionRealization {
  private RemoveEReference<ClassMethod, Final> removeChange;
  
  private DeleteEObject<Final> deleteChange;
  
  private int currentlyMatchedChange;
  
  public void executeReaction(final EChange change) {
    if (!checkPrecondition(change)) {
    	return;
    }
    org.emftext.language.java.members.ClassMethod affectedEObject = removeChange.getAffectedEObject();
    EReference affectedFeature = removeChange.getAffectedFeature();
    org.emftext.language.java.modifiers.Final oldValue = removeChange.getOldValue();
    				
    getLogger().trace("Passed complete precondition check of Reaction " + this.getClass().getName());
    				
    mir.routines.javaToUmlMethod.RoutinesFacade routinesFacade = new mir.routines.javaToUmlMethod.RoutinesFacade(this.executionState, this);
    mir.reactions.reactionsJavaToUml.javaToUmlMethod.JavaMethodMadeNonFinalReaction.ActionUserExecution userExecution = new mir.reactions.reactionsJavaToUml.javaToUmlMethod.JavaMethodMadeNonFinalReaction.ActionUserExecution(this.executionState, this);
    userExecution.callRoutine1(affectedEObject, affectedFeature, oldValue, routinesFacade);
    
    resetChanges();
  }
  
  private boolean matchDeleteChange(final EChange change) {
    if (change instanceof DeleteEObject<?>) {
    	DeleteEObject<org.emftext.language.java.modifiers.Final> _localTypedChange = (DeleteEObject<org.emftext.language.java.modifiers.Final>) change;
    	if (!(_localTypedChange.getAffectedEObject() instanceof org.emftext.language.java.modifiers.Final)) {
    		return false;
    	}
    	this.deleteChange = (DeleteEObject<org.emftext.language.java.modifiers.Final>) change;
    	return true;
    }
    
    return false;
  }
  
  private void resetChanges() {
    removeChange = null;
    deleteChange = null;
    currentlyMatchedChange = 0;
  }
  
  private boolean matchRemoveChange(final EChange change) {
    if (change instanceof RemoveEReference<?, ?>) {
    	RemoveEReference<org.emftext.language.java.members.ClassMethod, org.emftext.language.java.modifiers.Final> _localTypedChange = (RemoveEReference<org.emftext.language.java.members.ClassMethod, org.emftext.language.java.modifiers.Final>) change;
    	if (!(_localTypedChange.getAffectedEObject() instanceof org.emftext.language.java.members.ClassMethod)) {
    		return false;
    	}
    	if (!_localTypedChange.getAffectedFeature().getName().equals("annotationsAndModifiers")) {
    		return false;
    	}
    	if (!(_localTypedChange.getOldValue() instanceof org.emftext.language.java.modifiers.Final)) {
    		return false;
    	}
    	this.removeChange = (RemoveEReference<org.emftext.language.java.members.ClassMethod, org.emftext.language.java.modifiers.Final>) change;
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
    	return false; // Only proceed on the last of the expected changes
    }
    if (currentlyMatchedChange == 1) {
    	if (!matchDeleteChange(change)) {
    		resetChanges();
    		checkPrecondition(change); // Reexecute to potentially register this as first change
    		return false;
    	} else {
    		currentlyMatchedChange++;
    	}
    }
    
    return true;
  }
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public void callRoutine1(final ClassMethod affectedEObject, final EReference affectedFeature, final Final oldValue, @Extension final RoutinesFacade _routinesFacade) {
      _routinesFacade.setUmlMethodFinal(affectedEObject, Boolean.valueOf(false));
    }
  }
}
