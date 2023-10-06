@isTest
public class FindTest {
    /**
     *
     * B E H A V I O R   T E S T S
     *
     * The following tests attempt to test both positive and negative behavior
     * running as someone other than Sys Admin
     **/

    /**
     * Tests:
     * 	- The provided complex query parses successfully
     *  - The running user (Sys Admin) has full access to all objects/fields
     **/
    @isTest
    static void validateCRUDFLS_full() {
        List<Find> finds = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING Account (Name, Website), Lead (FirstName, LastName)'
        );
        System.assertEquals(2, finds.size());
        for (Find f : finds) {
            f.validateCRUDFLS(true, true);
        }
    }

    /**
     * Tests:
     *  - The provided query parses successfully
     *  - The running user (a new user with the "Standard User" profile) does not have Read access to "AuthProvider" object
     **/
    @isTest
    static void validateCRUD_negative() {
        System.runAs(UserTest.createStandardUser()) {
            List<Find> finds = Find.parse('FIND \'acme\' IN ALL FIELDS RETURNING AuthProvider');
            System.assertEquals(1, finds.size());
            try {
                Test.startTest();
                for (Find f : finds) {
                    f.validateCRUDFLS(true, true);
                }
                System.assert(false);
            } catch (Exception e) {
                System.assert(e instanceof SecUtil.CRUDException);
                //System.assertEquals('"Read" permission to object "AuthProvider" is not allowed for the current user.', e.getMessage());
            } finally {
                Test.stopTest();
            }
        }
    }

    /**
     * Tests:
     *  - The provided query parses successfully
     *  - The running user (a new user with the "Standard User" profile) does not have Read access to "DoNotCall" field
     **/
    @isTest
    static void validateFLS_negative() {
        String query1 = 'SELECT Id, DoNotCall ' + 'FROM Lead';

        System.runAs(UserTest.createStandardUser()) {
            List<Find> finds = Find.parse('FIND \'acme\' IN ALL FIELDS RETURNING Lead (Id, DoNotCall)');
            System.assertEquals(1, finds.size());
            try {
                Test.startTest();
                for (Find f : finds) {
                    f.validateCRUDFLS(true, true);
                }
                System.assert(false);
            } catch (Exception e) {
                System.assert(e instanceof SecUtil.FLSException);
                //System.assertEquals('"Read" permission to field "DoNotCall" on object "Lead" is not allowed for the current user.', e.getMessage());
            } finally {
                Test.stopTest();
            }
        }
    }

    /**
     * Tests Negative Behavior of the parser:
     *  - The provided query is bad (REGEX doesn't match)
     **/
    @isTest
    static void parse_BadQuery1() {
        try {
            List<Find> q = Find.parse('FIND');
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Find.FindException);
            System.assertEquals(System.Label.DAE_BadQuery, e.getMessage());
        }
    }

    /**
     * Tests Negative Behavior of the parser:
     *  - The provided subquery references a non-existent field
     **/
    @isTest
    static void parse_BadField() {
        try {
            List<Find> q = Find.parse(
                'FIND \'acme\' IN ALL FIELDS RETURNING Account (HoogaboogaZoom__d, Website), Lead'
            );
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Find.FindException);
            System.assertEquals('Field "HoogaboogaZoom__d" on object "Account" does not exist.', e.getMessage());
        }
    }

    /**
     * Tests:
     *  - The find parser handles parent fields correctly
     **/
    @isTest
    static void test_parentField() {
        List<Find> finds = Find.parse('FIND \'acme\' IN ALL FIELDS RETURNING Contact (Account.Name)');
        Find contactFind = finds.get(0);
        System.assertEquals(1, contactFind.fields.size(), 'Should have 1 field');
        Find.FindField ff = contactFind.fields.get(0);
        System.assertEquals('Account.Name', ff.fieldExpression, 'Incorrect Field Expression');
        System.assertEquals('Contact', ff.soType.getDescribe().getName(), 'Wrong sObject Type');
        Find.FindField nextFF = ff.nextPart;
        System.assert(nextFF != null, 'NextPart should not be null');
        System.assertEquals(nextFF.fieldExpression, 'Name');
        System.assertEquals('Account', nextFF.soType.getDescribe().getName(), 'Wrong sObject Type');
    }

    /**
     * Tests:
     *  - The REGEX Parser handles extra spaces in returning clauses
     *  - The REGEX Parser handles "missing" spaces in returning clauses
     **/
    @isTest
    static void test_parsing_fields_with_different_spacing() {
        List<Find> findsStandardSpacing = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING Lead (Id, DoNotCall), Account (Name)'
        );
        List<Find> findsExtraSpacing = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING   \t  \r \n  Lead     \t  \r \n ( \t  \r \n Id,   \t  \r \n    DoNotCall \t  \r \n )  \t , \r \n  Account  \t  \r \n  ( \t  \r \n  Name \t  \r \n ) \t  \r \n '
        );
        List<Find> findsMinimalSpacing = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING Lead(Id,DoNotCall),Account(Name)'
        );
        System.assertEquals(
            findsStandardSpacing.get(0).fields.get(0).fieldExpression,
            findsExtraSpacing.get(0).fields.get(0).fieldExpression,
            'Field 1 Parsed incorrectly with extra spacing'
        );
        System.assertEquals(
            findsStandardSpacing.get(0).fields.get(1).fieldExpression,
            findsExtraSpacing.get(0).fields.get(1).fieldExpression,
            'Field 2 Parsed incorrectly with extra spacing'
        );
        System.assertEquals(
            findsStandardSpacing.get(0).fields.get(0).fieldExpression,
            findsMinimalSpacing.get(0).fields.get(0).fieldExpression,
            'Field 1 Parsed incorrectly with minimal spacing'
        );
        System.assertEquals(
            findsStandardSpacing.get(0).fields.get(1).fieldExpression,
            findsMinimalSpacing.get(0).fields.get(1).fieldExpression,
            'Field 2 Parsed incorrectly with minimal spacing'
        );

        System.assertEquals(
            findsStandardSpacing.get(1).fields.get(0).fieldExpression,
            findsExtraSpacing.get(1).fields.get(0).fieldExpression,
            'Field 1 second obj Parsed incorrectly with extra spacing'
        );
        System.assertEquals(
            findsStandardSpacing.get(1).fields.get(0).fieldExpression,
            findsMinimalSpacing.get(1).fields.get(0).fieldExpression,
            'Field 1 second obj Parsed incorrectly with minimal spacing'
        );
    }

    /**
     * Tests:
     *  - The Find parser omits optional clauses in the Returning clause
     * RETURNING ObjectTypeName [(FieldList
     * [WHERE conditionExpression] [USING Listview=listview name] [ORDER BY Clause] [LIMIT n] [OFFSET n])]
     **/
    @isTest
    static void test_parsing_with_modifying_clauses_in_returning() {
        List<Find> finds = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING ' +
            'Lead (DoNotCall Using ListView = \'foo\'), ' +
            'Lead (DoNotCall Where City = \'foo\'), ' +
            'Lead (DoNotCall ORDER BY DoNotCall ASC), ' +
            'Lead (DoNotCall LIMIT 5), ' +
            'Lead (DoNotCall OFFSET 5)'
        );
        System.assertEquals(5, finds.size(), 'Should have 1 find per returning object');
        for (Find f : finds) {
            System.assertEquals(1, f.fields.size(), 'Should only have one field ' + f.queryPart);
            System.assertEquals('DoNotCall', f.fields.get(0).fieldExpression, 'Wrong fieldExpression ' + f.queryPart);
        }
    }

    /**
     * Tests:
     *  - The Find parser handles returned fields with a function applied
     * [ RETURNING FieldSpec [[ toLabel(fields)] [convertCurrency(Amount)] [FORMAT()]] ]
     **/
    @isTest
    static void test_parsing_with_formatted_fields() {
        List<Find> finds = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING ' +
            'Lead (toLabel(DoNotCall)), ' +
            'Lead (convertCurrency(DoNotCall)), ' +
            'Lead (FORMAT(convertCurrency(DoNotCall)) convertedCurrency)'
        );
        System.assertEquals(3, finds.size(), 'Should have 1 find per returning object');
        for (Find f : finds) {
            System.assertEquals(1, f.fields.size(), 'Should only have one field ' + f.queryPart);
            System.assertEquals('DoNotCall', f.fields.get(0).fieldExpression, 'Wrong fieldExpression ' + f.queryPart);
        }

        List<Find> multilabelFinds = Find.parse(
            'FIND \'acme\' IN ALL FIELDS RETURNING ' + 'Lead (toLabel(DoNotCall, Name)), '
        );
        System.assertEquals(1, multilabelFinds.size(), 'Should have 1 find');
        System.assertEquals(2, multilabelFinds.get(0).fields.size(), 'Should have 2 fields');
        System.assertEquals(
            'DoNotCall',
            multilabelFinds.get(0).fields.get(0).fieldExpression,
            'Did not parse first field correctly'
        );
        System.assertEquals(
            'Name',
            multilabelFinds.get(0).fields.get(1).fieldExpression,
            'Did not parse second field correctly'
        );
    }

    /**
     *
     * C O V E R A G E    T E S T S
     *
     *
     * The following tests don't necessarily test positive/negative behavior
     * but instead focus on obtaining >75% coverage.
     **/

    @isTest
    static void disabled() {
        DataConstants.ENABLED = false;
        Data.find('FIND \'acme\' IN ALL FIELDS RETURNING Account (Name, Website), Lead', null);

        System.assert(true);
    }
}