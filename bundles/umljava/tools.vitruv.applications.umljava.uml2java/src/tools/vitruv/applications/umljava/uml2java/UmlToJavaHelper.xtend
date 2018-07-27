package tools.vitruv.applications.umljava.uml2java

import java.util.ArrayList
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Optional
import org.eclipse.uml2.uml.PrimitiveType
import org.eclipse.uml2.uml.Type
import org.emftext.language.java.classifiers.ClassifiersFactory
import org.emftext.language.java.classifiers.ConcreteClassifier
import org.emftext.language.java.containers.CompilationUnit
import org.emftext.language.java.members.Field
import org.emftext.language.java.types.TypeReference
import org.emftext.language.java.types.TypesFactory
import tools.vitruv.applications.umljava.util.java.JavaVisibility
import tools.vitruv.framework.userinteraction.UserInteractionOptions.WindowModality

import static tools.vitruv.applications.umljava.util.java.JavaMemberAndParameterUtil.*
import static tools.vitruv.applications.umljava.util.java.JavaStandardType.*
import static tools.vitruv.applications.umljava.util.java.JavaTypeUtil.*
import static tools.vitruv.domains.java.util.JavaModificationUtil.*

import static extension tools.vitruv.applications.umljava.util.java.JavaContainerAndClassifierUtil.*
import tools.vitruv.framework.userinteraction.UserInteractor

/**
 * A helper class that contains util functions which depends on
 * the correspondence model or userinteracting.
 * 
 * @author Fei
 */
class UmlToJavaHelper {
    
	private new() {
	}
    
    
    def static TypeReference createTypeReferenceAndUpdateImport(Type dType, ConcreteClassifier cType, CompilationUnit compUnit, UserInteractor userInteractor) {
    	createTypeReferenceAndUpdateImport(dType, Optional.of(cType), compUnit, userInteractor)
    }
    
    /**
 	 * Creates a Java-NamespaceClssifierReference if cType != null and adds a
 	 * import if cType's class is not in the same package as the compilation unit.
 	 * 
     * Creates a PrimitiveType if dType != null && cType == null
     * Creates Void if both Types are null
     * If none of the above cases apply, dType is a unknown type. it will create a Java-NamespaceClassifierReference
     * out of a dummy Java-Class with the name of dtype. The user will be requested to check
     * these circumstances.
     * 
     * @param dType uml-DataType
     * @param cType java-ConcreteClassifier
     * @param compUnit the compilation unit of the class in which this type reference is created
     * @param userInteractor needed to show info messages for the user
     * @return the java type reference that fits dType or cType
     */
	def static TypeReference createTypeReferenceAndUpdateImport(Type dType, Optional<? extends ConcreteClassifier> cType, CompilationUnit compUnit, UserInteractor userInteractor) {
		if (dType === null && !cType.present) {
		    return TypesFactory.eINSTANCE.createVoid();
		} else if (cType.present) {
		    val namespaceOftype = cType.get.javaNamespace.join
		    if (!namespaceOftype.equals(compUnit.javaNamespace.join)) {
		        compUnit.imports += createJavaClassImport(namespaceOftype)
		    }
	        return createNamespaceReferenceFromClassifier(cType.get);
	    } else if (dType instanceof PrimitiveType) {
	        return mapToJavaPrimitiveType(dType);
	    } else {// dType is not null and not primitive, but a unknown Classifier.
	        val dClass = ClassifiersFactory.eINSTANCE.createClass;
	        dClass.name = dType.name;
	        userInteractor.showMessage("Added unknown Type " + dType + " in " +  compUnit.name + ". Please check the validity of imports.")
	        return createNamespaceReferenceFromClassifier(dClass)
		}
	} 
	
	/**
	 * Returns the corresponding Java-PrimitiveType by checking the given Uml-PrimitiveType's name.
	 * (Case-sensitive)
	 * Returns null if no corresponding Java-PrimitiveType could be found.
	 */
	def static TypeReference mapToJavaPrimitiveType(PrimitiveType pType) {
	    try {
	        createJavaPrimitiveType(pType.name)
	    } catch (IllegalArgumentException i){
	        return null
	    }
	}
	
	/**
	 * Prompts a message to the user that allows him to choose a collection datatype.
	 * 
	 * @param userInteractor the userInteractor to prompt the message
	 * @return the selected name of the collection datatype by the user
	 */
    def static letUserSelectCollectionTypeName(UserInteractor userInteractor) {
        var List<Class<?>> collectionDataTypes = new ArrayList
        collectionDataTypes += #[ArrayList, LinkedList, HashSet]
        val List<String> collectionDataTypeNames = new ArrayList<String>(collectionDataTypes.size)
        for (collectionDataType : collectionDataTypes) {
            collectionDataTypeNames.add(collectionDataType.name)
        }
        val String selectTypeMsg = "Select a Collectiontype for the association end"
        val int selectedType = userInteractor.singleSelectionDialogBuilder.message(selectTypeMsg)
            .choices(collectionDataTypeNames).windowModality(WindowModality.MODAL).startInteraction()
        val Class<?> selectedClass = collectionDataTypes.get(selectedType)
        return selectedClass.name
    }
    
    /**
     * Creates a getter for the attribute and adds it t its class.
     * 
     * @param jAttribute the attribute for which a getter should be created
     */
    def static createGetterForAttribute(Field jAttribute) {
        val jGetter = createJavaGetterForAttribute(jAttribute, JavaVisibility.PUBLIC)
        (jAttribute.eContainer as org.emftext.language.java.classifiers.Class).members += jGetter
    }
    
    /**
     * Creates a setter for the attribute and adds it to its class.
     * 
     * @param jAttribute the attribute for which a getter should be created
     */
    def static createSetterForAttribute(Field jAttribute) {
        val jSetter = createJavaSetterForAttribute(jAttribute, JavaVisibility.PUBLIC)
        (jAttribute.eContainer as org.emftext.language.java.classifiers.Class).members += jSetter
    }
    
    
    /**
     * Displays the given message with the userInteractor.
     * 
     * @param userInteractor the userInteractor to display the message.
     * @param message the message to display
     */
    def static void showMessage(UserInteractor userInteractor, String message) {
        userInteractor.notificationDialogBuilder.message(message).windowModality(WindowModality.MODAL)
            .startInteraction()
    }
	
}