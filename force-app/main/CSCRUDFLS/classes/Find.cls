/**
 * Provides a mechanism for parsing and representing SOSL queries.
 * <p>
 * This class uses REGEX to parse a SOSL query. This works pretty well
 * so far, but it has some shortcomings.
 */
public with sharing class Find {
    private static final Pattern P1 = Pattern.compile(
        '(?i)FIND.+?RETURNING\\s+(.+?)(?:\\s+WITH|\\s+LIMIT|\\s+UPDATE|$)'
    );
    // Matches the Returning object and the text within the outermost parentheses. The last parentheses remains, and is stripped in code
    // for instance 'RETURNING Lead (FORMAT(convertCurrency(DoNotCall)) convertedCurrency)'
    // returns 'Lead' in Group 1 and 'FORMAT(convertCurrency(DoNotCall)) convertedCurrency)' in Group 2
    private static final Pattern P2 = Pattern.compile(
        '(?i)(\\w+)(?:\\s*\\((([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\)))?(?:,\\s*)?'
    );
    // Matches the keywords that can come after the fields list in the Returning clauses
    private static final String DELIMITING_PATTERN = '(?i)(?:\\s+WHERE\\s+|\\s+LIMIT\\s+|\\s+OFFSET\\s+|\\s+USING\\s+|\\s+ORDER BY\\s+)';

    private String fullQuery;
    @TestVisible
    private String queryPart;
    private FindFrom fromObj;
    @TestVisible
    private List<FindField> fields;

    /**
     * Validate the CRUD and FLS for this find.
     * <p>
     *
     * @param validateCRUD Specifiying true will validate the user has READ access to all objects referenced by the query
     * @param validateFLS Specifying true will validate that the user has READ access to all fields referenced by the query
     * @throws Data.CRUDException If the user doesn't have READ access to any object referenced by the query.
     * @throws Data.FLSException If the user doesn't have READ access to any field referenced by the query.
     */
    public void validateCRUDFLS(Boolean validateCRUD, Boolean validateFLS) {
        if (DataConstants.ENABLED && (validateCRUD || validateFLS)) {
            if (validateCRUD) {
                this.fromObj.validateCRUD();
            }
            if (validateFLS) {
                for (FindField ff : this.fields) {
                    ff.validateFLS();
                }
            }
        }
    }

    /**
     * Factory method for parsing a SOSL string into multiple Find instances.
     *
     * @param query A string of the SOSL Query
     * @return List<Find> A collection of Find instances, 1 for each object defined in the "RETURNING" statement.
     * @throws Data.FindException If the SOSL query cannot be parsed.
     */
    public static List<Find> parse(String query) {
        LimitsSnapshot ls = new LimitsSnapshot('Query_parse');

        List<Find> finds = new List<Find>();

        if (!DataConstants.ENABLED) {
            return finds;
        }

        query = query.normalizeSpace();

        Matcher m1 = P1.matcher(query);
        if (m1.matches()) {
            String s2 = m1.group(1);
            System.debug(DataConstants.LOGGING_LEVEL, s2);

            Matcher m2 = p2.matcher(s2);
            while (m2.find()) {
                String part = m2.group(0);
                String obj = m2.group(1);
                String flds = m2.group(2);
                System.debug(DataConstants.LOGGING_LEVEL, part);
                System.debug(DataConstants.LOGGING_LEVEL, obj);
                System.debug(DataConstants.LOGGING_LEVEL, flds);

                DescribeCache describe = DescribeCache.getDescribeCache(obj);

                Find f = new Find();
                f.queryPart = part;
                f.fullQuery = query;
                f.fromObj = new FindFrom(describe);
                f.fields = new List<FindField>();

                if (flds != null) {
                    // Get the returning fields list before any optional clauses in the returning sObject then strip all spaces
                    // and the trailing parentheses that remains from the P2 match
                    flds = flds.split(DELIMITING_PATTERN, 2).get(0).deleteWhitespace().removeEnd(')');
                    for (String fld : flds.split(',')) {
                        f.fields.add(parseFieldExpression(fld, describe));
                    }
                }

                finds.add(f);
            }
        } else {
            System.debug(DataConstants.LOGGING_LEVEL, 'Bad query: ' + query);
            throw new FindException(System.Label.DAE_BadQuery);
        }

        ls.toLog(LoggingLevel.WARN);
        return finds;
    }

    /**
     * This method should recursively call itself, validating each field until it reaches the last field in the expression
     * It should only throw an exception if the field is inaccessible
     * Example fieldExpression (field on the OpportunityContactRole): Opportunity.Account.Name
     * This method should test that the user has access to the following fields:
     * 			- OpportunityContactRole.OpportunityId
     * 			- Opportunity.AccountId
     * 			- Account.Name
     *
     * @param fld A field to be returned of the SOSL Query
     * @param describe The DescribeCache instance to use
     * @return A FindField instance constructed from the fieldExpression String passed in
     * @throws Data.FindException If the requested field cannot be found
     */
    private static FindField parseFieldExpression(String fld, DescribeCache describe) {
        FindField ff;

        // If the field contains a parenthesis, it is a function, strip the function and get just the name part
        // within the outermost ( and innermost )
        // EX: 'toLabel(Company, RecordType.Name)' => ['toLabel(Company', 'RecordType.Name)'] => ['Company', 'RecordType.Name'] OR
        // 'FORMAT(convertCurrency(amount)) convertedCurrency' => 'amount'
        if (fld.contains('(')) {
            fld = fld.substringAfterLast('(');
        }
        if (fld.contains(')')) {
            fld = fld.substringBefore(')');
        }

        String fieldPart = fld.substringBefore('.'); // this is about 25% faster than a String.split/list approach and 40% less heap

        Schema.DescribeFieldResult dfr = describe.getFieldDescribe(fieldPart);

        if (dfr == null) {
            throw new FindException(
                String.format(System.Label.DAE_FieldDoesNotExist, new List<String>{ fld, describe.objectName })
            );
        }

        FindField nextPart;
        if (fld.contains('.')) {
            nextPart = parseFieldExpression(
                fld.substringAfter('.'),
                DescribeCache.getDescribeCache(dfr.getReferenceTo()[0])
            );
        }

        ff = new FindField(dfr, describe.objectToken, fld, nextPart);

        return ff;
    }

    /** An object representing exceptions when parsing SOSL queries */
    public class FindException extends Exception {
    }

    /**
     * Represents a field referenced in a SOSL query.
     * <p>
     */
    public class FindField {
        /** The DescribeFieldResult for this field */
        public Schema.DescribeFieldResult fieldDescribe { get; private set; }
        /** The SObjectType that this field lives on */
        public Schema.SObjectType soType { get; private set; }
        /** The field expression for this field. Example "Contact.Account.Name" */
        public String fieldExpression { get; private set; }
        /**
         * The FindField for the next part of the field expression
         *<p>
         * If this FindField instance is for "Contact", then the next part would
         * be for "Account", and it in turn would have a nextPart for "Name".
         */
        public FindField nextPart { get; private set; }

        public FindField(
            Schema.DescribeFieldResult fieldDescribe,
            Schema.SObjectType soType,
            String fieldExpression,
            FindField nextPart
        ) {
            this.fieldDescribe = fieldDescribe;
            this.soType = soType;
            this.fieldExpression = fieldExpression;
            this.nextPart = nextPart;
        }

        /**
         * Validates the FLS for this field.
         * <p>
         * This method recursively calls itself if the instance has a nextPart defined.
         *
         * @throws Data.FLSException If the user doesn't have READ access to any field referenced by the query.
         */
        public void validateFLS() {
            System.debug(
                DataConstants.LOGGING_LEVEL,
                'Validating field "' +
                fieldExpression +
                '"" on sobject "' +
                soType +
                '"'
            );

            SecUtil.checkFLS(DataConstants.SecurityOperation.READ, soType.getDescribe(), this.fieldDescribe);

            if (nextPart != null) {
                nextPart.validateFLS();
            }
        }
    }

    /**
     * Represents a RETURNING object in a SOSL query.
     * <p>
     */
    public class FindFrom {
        private DescribeCache sotDescribe;

        public FindFrom(DescribeCache sotDescribe) {
            this.sotDescribe = sotDescribe;
        }

        public void validateCRUD() {
            System.debug(DataConstants.LOGGING_LEVEL, 'Validating sobject "' + sotDescribe.objectName + '"');

            SecUtil.checkCRUD(DataConstants.SecurityOperation.READ, sotDescribe);
        }
    }
}