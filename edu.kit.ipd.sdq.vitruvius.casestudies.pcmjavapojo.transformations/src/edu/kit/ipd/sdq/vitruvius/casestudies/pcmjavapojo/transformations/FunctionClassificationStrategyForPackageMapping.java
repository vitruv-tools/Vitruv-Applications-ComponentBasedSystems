package edu.kit.ipd.sdq.vitruvius.casestudies.pcmjavapojo.transformations;

import java.util.Set;

import org.apache.log4j.Logger;
import org.emftext.language.java.members.ClassMethod;
import org.emftext.language.java.members.Method;
import org.somox.gast2seff.visitors.AbstractFunctionClassificationStrategy;

import de.uka.ipd.sdq.pcm.repository.BasicComponent;
import de.uka.ipd.sdq.pcm.repository.OperationSignature;
import edu.kit.ipd.sdq.vitruvius.casestudies.pcmjava.seffstatements.code2seff.BasicComponentFinding;
import edu.kit.ipd.sdq.vitruvius.framework.contracts.datatypes.CorrespondenceInstance;

/**
 * FunctionClassificationStrategy for the simple package mapping Strategy.
 *
 * @author langhamm
 *
 */
public class FunctionClassificationStrategyForPackageMapping extends AbstractFunctionClassificationStrategy {

    private static final Logger logger = Logger.getLogger(FunctionClassificationStrategyForPackageMapping.class
            .getSimpleName());

    private final BasicComponentFinding basicComponentFinding;
    private final CorrespondenceInstance correspondenceInstance;
    private final BasicComponent myBasicComponent;

    public FunctionClassificationStrategyForPackageMapping(final BasicComponentFinding basicComponentFinding,
            final CorrespondenceInstance ci, final BasicComponent myBasicComponent) {
        this.basicComponentFinding = basicComponentFinding;
        this.correspondenceInstance = ci;
        this.myBasicComponent = myBasicComponent;
    }

    /**
     * A call is an external call if the call's destination is an interface method that corresponds
     * to an OperationSignature, or if the calls destination is outside of the own component.
     */
    @Override
    protected boolean isExternalCall(final Method method) {
        final Set<OperationSignature> correspondingSignatures = this.correspondenceInstance
                .getCorrespondingEObjectsByType(method, OperationSignature.class);
        if (null != correspondingSignatures && !correspondingSignatures.isEmpty()) {
            return true;
        }
        if (method instanceof ClassMethod) {
            final BasicComponent basicComponent = this.basicComponentFinding.findBasicComponentForMethod(method,
                    this.correspondenceInstance);
            if (null == basicComponent || basicComponent.getId().equals(this.myBasicComponent.getId())) {
                return false;
            }
            return true;
        }
        return false;
    }

    /**
     * The call is a library call if the method that is called does not belong to any
     * BasicComponent.
     */
    @Override
    protected boolean isLibraryCall(final Method method) {
        final BasicComponent basicComponentOfMethod = this.basicComponentFinding.findBasicComponentForMethod(method,
                this.correspondenceInstance);
        if (null == basicComponentOfMethod) {
            return true;
        }
        if (basicComponentOfMethod.getId().equals(this.myBasicComponent.getId())) {
            return false;
        }
        logger.warn("The destination of a call to the method " + method
                + " is another component than the source component. This should not happen in isLibraryCall.");
        return true;
    }

}