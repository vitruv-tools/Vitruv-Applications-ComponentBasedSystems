package mir.routines.umlToPcm;

import java.io.IOException;
import mir.routines.umlToPcm.RoutinesFacade;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.uml2.uml.Component;
import org.eclipse.uml2.uml.Usage;
import org.palladiosimulator.pcm.repository.BasicComponent;
import org.palladiosimulator.pcm.repository.OperationRequiredRole;
import org.palladiosimulator.pcm.repository.RequiredRole;
import org.palladiosimulator.pcm.repository.impl.RepositoryFactoryImpl;
import tools.vitruv.extensions.dslsruntime.reactions.AbstractRepairRoutineRealization;
import tools.vitruv.extensions.dslsruntime.reactions.ReactionExecutionState;
import tools.vitruv.extensions.dslsruntime.reactions.structure.CallHierarchyHaving;

@SuppressWarnings("all")
public class CreateRequiredRoleRoutine extends AbstractRepairRoutineRealization {
  private RoutinesFacade actionsFacade;
  
  private CreateRequiredRoleRoutine.ActionUserExecution userExecution;
  
  private static class ActionUserExecution extends AbstractRepairRoutineRealization.UserExecution {
    public ActionUserExecution(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy) {
      super(reactionExecutionState);
    }
    
    public EObject getElement1(final Component umlComponent, final Usage umlUsage, final BasicComponent pcmComponent, final OperationRequiredRole pcmRole) {
      return pcmComponent;
    }
    
    public void update0Element(final Component umlComponent, final Usage umlUsage, final BasicComponent pcmComponent, final OperationRequiredRole pcmRole) {
      EList<RequiredRole> _requiredRoles_InterfaceRequiringEntity = pcmComponent.getRequiredRoles_InterfaceRequiringEntity();
      _requiredRoles_InterfaceRequiringEntity.add(pcmRole);
    }
    
    public EObject getCorrepondenceSourcePcmComponent(final Component umlComponent, final Usage umlUsage) {
      return umlComponent;
    }
    
    public EObject getElement2(final Component umlComponent, final Usage umlUsage, final BasicComponent pcmComponent, final OperationRequiredRole pcmRole) {
      return umlUsage;
    }
    
    public EObject getElement3(final Component umlComponent, final Usage umlUsage, final BasicComponent pcmComponent, final OperationRequiredRole pcmRole) {
      return pcmRole;
    }
    
    public void updatePcmRoleElement(final Component umlComponent, final Usage umlUsage, final BasicComponent pcmComponent, final OperationRequiredRole pcmRole) {
      String _name = umlUsage.getName();
      pcmRole.setEntityName(_name);
    }
  }
  
  public CreateRequiredRoleRoutine(final ReactionExecutionState reactionExecutionState, final CallHierarchyHaving calledBy, final Component umlComponent, final Usage umlUsage) {
    super(reactionExecutionState, calledBy);
    this.userExecution = new mir.routines.umlToPcm.CreateRequiredRoleRoutine.ActionUserExecution(getExecutionState(), this);
    this.actionsFacade = new mir.routines.umlToPcm.RoutinesFacade(getExecutionState(), this);
    this.umlComponent = umlComponent;this.umlUsage = umlUsage;
  }
  
  private Component umlComponent;
  
  private Usage umlUsage;
  
  protected void executeRoutine() throws IOException {
    getLogger().debug("Called routine CreateRequiredRoleRoutine with input:");
    getLogger().debug("   Component: " + this.umlComponent);
    getLogger().debug("   Usage: " + this.umlUsage);
    
    BasicComponent pcmComponent = getCorrespondingElement(
    	userExecution.getCorrepondenceSourcePcmComponent(umlComponent, umlUsage), // correspondence source supplier
    	BasicComponent.class,
    	(BasicComponent _element) -> true, // correspondence precondition checker
    	null);
    if (pcmComponent == null) {
    	return;
    }
    registerObjectUnderModification(pcmComponent);
    OperationRequiredRole pcmRole = RepositoryFactoryImpl.eINSTANCE.createOperationRequiredRole();
    notifyObjectCreated(pcmRole);
    userExecution.updatePcmRoleElement(umlComponent, umlUsage, pcmComponent, pcmRole);
    
    // val updatedElement userExecution.getElement1(umlComponent, umlUsage, pcmComponent, pcmRole);
    userExecution.update0Element(umlComponent, umlUsage, pcmComponent, pcmRole);
    
    addCorrespondenceBetween(userExecution.getElement2(umlComponent, umlUsage, pcmComponent, pcmRole), userExecution.getElement3(umlComponent, umlUsage, pcmComponent, pcmRole), "");
    
    postprocessElements();
  }
}