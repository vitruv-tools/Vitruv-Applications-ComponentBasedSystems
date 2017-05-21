package tools.vitruv.applications.umljava.java2uml.tests

import static tools.vitruv.applications.umljava.util.java.JavaTypeUtil.*
import static tools.vitruv.applications.umljava.util.uml.UmlClassifierAndPackageUtil.*
import tools.vitruv.applications.umljava.java2uml.Java2UmlTransformationTest
import static tools.vitruv.applications.umljava.util.java.JavaMemberAndParameterUtil.*
import tools.vitruv.applications.umljava.util.java.JavaVisibility
import org.junit.Before
import static org.junit.Assert.*
import org.eclipse.emf.ecore.util.EcoreUtil
import org.junit.Test
import static tools.vitruv.applications.umljava.testutil.UmlTestUtil.*
import static tools.vitruv.applications.umljava.testutil.TestUtil.*
import org.eclipse.uml2.uml.VisibilityKind
import tools.vitruv.applications.umljava.java2uml.JavaToUmlHelper
import org.emftext.language.java.types.TypesFactory

class JavaToUmlEnumTest extends Java2UmlTransformationTest {
    private static val ENUM_NAME = "EnumName"
    private static val ENUM_RENAME = "EnumRenamed"
    private static val STANDARD_ENUM_NAME = "StandardEnumName"
    private static val ENUM_LITERAL_NAMES_1 = #["RED", "BLUE", "GREEN", "YELLOW", "PURPLE"]
    private static val ENUM_LITERAL_NAMES_2 = #["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]
    private static val CONSTANT_NAME = "CONSTANTNAME"
    private static val OPERATION_NAME = "operationName"
    private static val ATTRIBUTE_NAME = "attributeName"
    private static val TYPECLASS = "TypeClass"
    private static var org.emftext.language.java.classifiers.Enumeration jEnum
    private static val enumConstants1 = createJavaEnumConstantsFromList(ENUM_LITERAL_NAMES_1)
    private static val enumConstants2 = createJavaEnumConstantsFromList(ENUM_LITERAL_NAMES_2)
    
    @Before
    def void before() {
        jEnum = createJavaEnumWithCompilationUnit(ENUM_NAME, JavaVisibility.PUBLIC, enumConstants1)
    }
    
    @Test
    def void testCreateEnum() {
        val enumeration = createJavaEnumWithCompilationUnit(STANDARD_ENUM_NAME, JavaVisibility.PUBLIC, enumConstants2)
        
        val uEnum = getCorrespondingEnum(enumeration)
        assertUmlEnumTraits(uEnum, STANDARD_ENUM_NAME, VisibilityKind.PUBLIC_LITERAL, false, false,
            getUmlRootModel(JavaToUmlHelper.rootModelFile), createUmlEnumLiteralsFromList(ENUM_LITERAL_NAMES_2))
        assertEnumEquals(uEnum, enumeration)
    }
    
    @Test
    def void testRenameEnum() {
        jEnum.name = ENUM_RENAME
        saveAndSynchronizeChanges(jEnum)
        
        val uEnum = getCorrespondingEnum(jEnum)
        assertEquals(ENUM_RENAME, uEnum.name)
        assertEnumEquals(uEnum, jEnum)
    }
    
    @Test
    def void testDeleteEnum() {
        assertNotNull(jEnum)
        val comp = jEnum.containingCompilationUnit

        EcoreUtil.delete(jEnum)
        saveAndSynchronizeChanges(comp)
        val uEnum = getUmlPackagedElementsbyName(JavaToUmlHelper.rootModelFile, org.eclipse.uml2.uml.Enumeration, ENUM_NAME).head
        assertNull(uEnum)
    }
    
    @Test
    def void testAddEnumConstant() {
        jEnum.constants += createJavaEnumConstant(CONSTANT_NAME)
        saveAndSynchronizeChanges(jEnum)
        
        val uEnum = getCorrespondingEnum(jEnum)
        assertUmlEnumHasLiteral(uEnum, createUmlEnumerationLiteral(CONSTANT_NAME))
        assertEnumEquals(uEnum, jEnum)
    }
    
    @Test
    def void testDeleteEnumConstant() {
        EcoreUtil.delete(jEnum.constants.remove(0))
        saveAndSynchronizeChanges(jEnum)
        
        val uEnum = getCorrespondingEnum(jEnum)
        assertUmlEnumDontHaveLiteral(uEnum, createUmlEnumerationLiteral(ENUM_LITERAL_NAMES_1.head))
        assertEnumEquals(uEnum, jEnum)
    }
    
    @Test
    def void testAddEnumMethod() {
        val jMethod = createJavaClassMethod(OPERATION_NAME, TypesFactory.eINSTANCE.createVoid, JavaVisibility.PUBLIC,
            false, false, null)
        jEnum.members += jMethod
        saveAndSynchronizeChanges(jEnum)
        
        val uOperation = getCorrespondingMethod(jMethod)
        val uEnum = getCorrespondingEnum(jEnum)
        assertUmlOperationTraits(uOperation, OPERATION_NAME, VisibilityKind.PUBLIC_LITERAL, null, false,
            false, uEnum, null)
        assertClassMethodEquals(uOperation, jMethod)
    }
    
    @Test
    def void testAddEnumAttribute() {
        val typeClass = createJavaClassWithCompilationUnit(TYPECLASS, JavaVisibility.PUBLIC, false, false)
        val jAttr = createJavaAttribute(ATTRIBUTE_NAME, createNamespaceReferenceFromClassifier(typeClass), JavaVisibility.PRIVATE, false, false)
        jEnum.members += jAttr
        saveAndSynchronizeChanges(jEnum)
        
        val uAttr = getCorrespondingAttribute(jAttr)
        val uTypeClass = getCorrespondingClass(typeClass)
        val uEnum = getCorrespondingEnum(jEnum)
        assertUmlPropertyTraits(uAttr, ATTRIBUTE_NAME, VisibilityKind.PRIVATE_LITERAL, uTypeClass,
            false, false, uEnum, null, null)
        assertAttributeEquals(uAttr, jAttr)
    }
}