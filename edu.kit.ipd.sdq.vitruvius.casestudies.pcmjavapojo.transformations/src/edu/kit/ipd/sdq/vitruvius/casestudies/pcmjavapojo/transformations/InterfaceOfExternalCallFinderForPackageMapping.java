package edu.kit.ipd.sdq.vitruvius.casestudies.pcmjavapojo.transformations;

import java.util.Set;

import org.apache.log4j.Logger;
import org.emftext.language.java.members.Method;
import org.somox.gast2seff.visitors.InterfaceOfExternalCallFinding;

import de.uka.ipd.sdq.pcm.repository.BasicComponent;
import de.uka.ipd.sdq.pcm.repository.OperationInterface;
import de.uka.ipd.sdq.pcm.repository.OperationRequiredRole;
import de.uka.ipd.sdq.pcm.repository.OperationSignature;
import de.uka.ipd.sdq.pcm.repository.RequiredRole;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.CorrespondenceInstance;

/**
 * Class realizes a InterfaceOfExternalCallFinding for the simple package mapping
 *
 * @author langhamm
 *
 */
public class InterfaceOfExternalCallFinderForPackageMapping implements InterfaceOfExternalCallFinding {

    private static final Logger logger = Logger.getLogger(InterfaceOfExternalCallFinderForPackageMapping.class
            .getSimpleName());

    private final CorrespondenceInstance correspondenceInstance;
    private final BasicComponent myBasicComponent;

    public InterfaceOfExternalCallFinderForPackageMapping(final CorrespondenceInstance correspondenceInstance,
            final BasicComponent myBasicComponent) {
        this.correspondenceInstance = correspondenceInstance;
        this.myBasicComponent = myBasicComponent;

    }

    /**
     * A InterfacePortOperationTupleis found by finding the corresponding operation signature to the
     * called method. The required role is found by looking at all required roles of the component
     * and return the first one that requires the same interface the operation signature is in.
     * Current limitations: 1) the called method has to be an interface method/a method that
     * directly corresponds to a operation signature, and 2) each interface can only be required
     * once by a given component. Both limitations are, however, OK for the beginning.
     */
    @Override
    public InterfacePortOperationTuple getCalledInterfacePort(final Method calledMethod) {
        final InterfacePortOperationTuple interfacePortOperationTuple = new InterfacePortOperationTuple();
        final OperationSignature opSig = this.queryInterfaceOperation(calledMethod);
        if (null != opSig) {
            interfacePortOperationTuple.signature = opSig;
            final OperationInterface accessedOpIf = opSig.getInterface__OperationSignature();
            for (final RequiredRole requiredRole : this.myBasicComponent.getRequiredRoles_InterfaceRequiringEntity()) {
                if (requiredRole instanceof OperationRequiredRole) {
                    final OperationRequiredRole orr = (OperationRequiredRole) requiredRole;
                    if (orr.getRequiredInterface__OperationRequiredRole().getId().equals(accessedOpIf.getId())) {
                        interfacePortOperationTuple.role = orr;
                        break;
                    }
                }
            }
        }

        return interfacePortOperationTuple;
    }

    private OperationSignature queryInterfaceOperation(final Method invokedMethod) {
        final Set<OperationSignature> correspondingOpSigs = this.correspondenceInstance.getCorrespondingEObjectsByType(
                invokedMethod, OperationSignature.class);
        if (null != correspondingOpSigs && 0 < correspondingOpSigs.size()) {
            return correspondingOpSigs.iterator().next();
        }
        logger.warn("Could not find operation signature for method " + invokedMethod);
        return null;
    }
}
