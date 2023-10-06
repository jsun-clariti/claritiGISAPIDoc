@isTest
private class CSUtilsTest {
    @isTest
    static void testIsNumeric() {
        System.assertEquals(false, CSUtils.isNumeric(null));
        System.assertEquals(false, CSUtils.isNumeric(''));
        System.assertEquals(true, CSUtils.isNumeric('1'));
        System.assertEquals(true, CSUtils.isNumeric('1.0'));
        System.assertEquals(true, CSUtils.isNumeric('01'));
        System.assertEquals(true, CSUtils.isNumeric('.01'));
        System.assertEquals(false, CSUtils.isNumeric('text'));
    }

    @isTest
    static void testIsValidId() {
        System.assertEquals(true, CSUtils.isValidId(null));
        System.assertEquals(false, CSUtils.isValidId('1234'));
        System.assertEquals(false, CSUtils.isValidId('1234567890123456'));

        Contact contact = new Contact();
        contact.LastName = 'Test';
        insert contact;

        System.assertEquals(true, CSUtils.isValidId(contact.Id));
    }

    @isTest
    static void testIsValidEmail() {
        System.assertEquals(true, CSUtils.isValidEmail(null));
        System.assertEquals(true, CSUtils.isValidEmail('test@test.com'));
        System.assertEquals(true, CSUtils.isValidEmail('test+here@test.com'));
        System.assertEquals(false, CSUtils.isValidEmail('test'));
        System.assertEquals(false, CSUtils.isValidEmail('test@test'));
        System.assertEquals(false, CSUtils.isValidEmail('@test'));
        System.assertEquals(false, CSUtils.isValidEmail('@test.com'));
    }

    @isTest
    static void testLeftPad() {
        System.assertEquals(null, CSUtils.leftPad(null, null, null));
        System.assertEquals('1234', CSUtils.leftPad('1234', '0', 4));
        System.assertEquals('0555', CSUtils.leftPad('555', '0', 4));
        System.assertEquals('12345', CSUtils.leftPad('12345', '0', 4));
    }

    @isTest
    static void testRightPad() {
        System.assertEquals(null, CSUtils.rightPad(null, null, null));
        System.assertEquals('1234', CSUtils.rightPad('1234', '0', 4));
        System.assertEquals('5550', CSUtils.rightPad('555', '0', 4));
        System.assertEquals('12345', CSUtils.rightPad('12345', '0', 4));
    }

    @isTest
    static void testToCharacterArray() {
        System.assertEquals(null, CSUtils.toCharacterArray(null));

        List<String> characters = CSUtils.toCharacterArray('abc');
        System.assertEquals('a', characters.get(0));
        System.assertEquals('b', characters.get(1));
        System.assertEquals('c', characters.get(2));
    }

    @isTest
    static void testNullSafeEquals() {
        System.assertEquals(true, CSUtils.nullSafeEquals(null, null));
        System.assertEquals(false, CSUtils.nullSafeEquals(null, 'val'));
        System.assertEquals(false, CSUtils.nullSafeEquals('val', null));
        System.assertEquals(true, CSUtils.nullSafeEquals('val', 'val'));
        System.assertEquals(false, CSUtils.nullSafeEquals('vala', 'valb'));
    }

    @isTest
    static void testJoin() {
        // Set version.
        System.assertEquals('one', CSUtils.join(new Set<String>{ 'one' }, '|'));
        System.assertEquals('one,three,two', CSUtils.join(new Set<String>{ 'one', 'two', 'three' }, ','));

        // SObject version.
        System.assertEquals('Account1', CSUtils.join(new List<sObject>{ new Account(Name = 'Account1') }, 'Name', '|'));
        System.assertEquals(
            'Account1|Account2',
            CSUtils.join(
                new List<sObject>{ new Account(Name = 'Account1'), new Account(Name = 'Account2') },
                'Name',
                '|'
            )
        );
    }

    @isTest
    static void testShuffle() {
        System.assertEquals(null, CSUtils.shuffle(null));
        System.assertNotEquals(null, CSUtils.shuffle(new List<String>{ 'aaa', 'bbb' }));
    }

    @isTest
    static void testQuote() {
        System.assertEquals('""', CSUtils.quote((String) null));
        System.assertEquals('""', CSUtils.quote(''));
        System.assertEquals('"John Doe"', CSUtils.quote('John Doe'));
        System.assertEquals('"This has ""quotes"" embedded."', CSUtils.quote('This has "quotes" embedded.'));

        List<String> quotedValues = CSUtils.quote(new List<String>{ 'John Doe', 'Jane Doe' });
        System.assertNotEquals(null, quotedValues);
        System.assertEquals('"John Doe"', quotedValues.get(0));
        System.assertEquals('"Jane Doe"', quotedValues.get(1));
        System.assertEquals(null, CSUtils.quote((List<String>) null));
    }

    @isTest
    static void testSingleQuote() {
        System.assertEquals('\'\'', CSUtils.singleQuote((String) null));
        System.assertEquals('\'\'', CSUtils.singleQuote(''));
        System.assertEquals('\'John Doe\'', CSUtils.singleQuote('John Doe'));
        System.assertEquals(
            '\'This has \\\'quotes\\\' embedded.\'',
            CSUtils.singleQuote('This has \'quotes\' embedded.')
        );

        List<String> quotedValues = CSUtils.singleQuote(new List<String>{ 'John Doe', 'Jane Doe' });
        System.assertNotEquals(null, quotedValues);
        System.assertEquals('\'John Doe\'', quotedValues.get(0));
        System.assertEquals('\'Jane Doe\'', quotedValues.get(1));
        System.assertEquals(null, CSUtils.quote((List<String>) null));
    }

    @isTest
    static void testFormatDate() {
        System.assertEquals(null, CSUtils.formatDate(null, null));

        Date d1 = Date.newInstance(2009, 4, 6);
        System.assertEquals('2009-04-06', CSUtils.formatDate(d1, 'yyyy-MM-dd'));

        Date d2 = Date.newInstance(2009, 10, 22);
        System.assertEquals('2009/10/22', CSUtils.formatDate(d2, 'yyyy/MM/dd'));
    }

    @isTest
    static void testFormatDateTimeUTC() {
        System.assertEquals(null, CSUtils.formatDateTimeUTC(null));
        System.assertEquals('2010-04-06T00:00:00Z', CSUtils.formatDateTimeUTC(DateTime.newInstanceGmt(2010, 4, 6)));
    }

    @isTest
    static void testConvertDateTimeToDate() {
        // Test positive scenario.
        DateTime dt = DateTime.newInstance(2009, 4, 6);
        Date d = CSUtils.convertDateTimeToDate(dt);

        System.assertEquals(2009, d.year());
        System.assertEquals(4, d.month());
        System.assertEquals(6, d.day());

        // Test negative scenario.
        dt = null;
        d = CSUtils.convertDateTimeToDate(dt);

        System.assertEquals(null, d);
    }

    @isTest
    static void testGetSFDCDateTime() {
        // Positive
        Integer unixTime = 1611100800;
        Datetime sfdxTime = CSUtils.getSFDCDateTime(unixTime);
        System.assertEquals(Datetime.newInstanceGmt(2021, 1, 20), sfdxTime);

        // Negative
        sfdxTime = CSUtils.getSFDCDateTime(null);
        System.assertEquals(null, sfdxTime);
    }

    @isTest
    static void testGetUnixTimeStamp() {
        // Positive
        Datetime sfdxTime = Datetime.newInstanceGmt(2021, 1, 20);
        Integer unixTime = CSUtils.getUnixTimeStamp(sfdxTime);
        System.assertEquals(1611100800, unixTime);

        // Negative
        unixTime = CSUtils.getUnixTimeStamp(null);
        System.assertEquals(null, unixTime);
    }

    @isTest
    static void testGetRecordTypeIdByLabel() {
        System.assertEquals(null, CSUtils.getRecordTypeIdByLabel('Account', 'Test'));
        System.assertNotEquals(null, CSUtils.getRecordTypeIdByLabel('Account', 'Master'));
    }

    @isTest
    static void testGetRecordTypeIdByDevName() {
        System.assertEquals(null, CSUtils.getRecordTypeIdByDevName('Account', 'Test'));
        System.assertNotEquals(null, CSUtils.getRecordTypeIdByDevName('Account', 'Master'));
    }

    @isTest
    static void testGetObjectMetadata() {
        System.assertEquals(null, CSUtils.getObjectMetadata(null));
        Schema.DescribeSObjectResult res = CSUtils.getObjectMetadata('Account');
        System.assert(res.getName() == 'Account');
        System.assert(CSUtils.getObjectMetadata('Account') != null);
    }

    @isTest
    static void testGetFieldMetadata() {
        Schema.DescribeFieldResult dfr = CSUtils.getFieldMetadata('Account', 'Name');
        System.assert(dfr != null);
        System.assert(dfr.getName() == 'Name');
    }

    @isTest
    static void testGetPicklistValues() {
        System.assertNotEquals(null, CSUtils.getPicklistValues('Account', 'Industry', true));
        System.assert(CSUtils.getPicklistValues('Account', 'Industry', true).size() > 0, 'Industry exists');
    }

    @isTest
    static void testGetPicklistDefaultValue() {
        CSUtils.getPicklistDefaultValue('Account', 'Industry');
    }

    @isTest
    static void testGetPicklistAsSelectOptions() {
        System.assertNotEquals(null, CSUtils.getPicklistAsSelectOptions('Account', 'Industry', true));
    }

    @isTest
    static void testGetTextFieldLength() {
        System.assert(CSUtils.getTextFieldLength('Account', 'Name') != 0);
    }

    @isTest
    static void testGetObjectNameFromId() {
        System.assertEquals(null, CSUtils.getObjectNameFromId(null));

        try {
            Account account = new Account();
            account.Name = 'Test';
            insert account;
            System.assertEquals('Account', CSUtils.getObjectNameFromId(account.Id));
        } catch (Exception e) {
            // Org has custom validation(s) preventing the record from
            // inserting and thus this test from running. Ignore exception.
        }

        try {
            Contact contact = new Contact();
            contact.FirstName = 'Test';
            contact.LastName = 'Test';
            insert contact;
            System.assertEquals('Contact', CSUtils.getObjectNameFromId(contact.Id));
        } catch (Exception e) {
            // Org has custom validation(s) preventing the record from
            // inserting and thus this test from running. Ignore exception.
        }

        try {
            Opportunity opportunity = new Opportunity();
            opportunity.Name = 'Test';
            opportunity.StageName = 'Prospecting';
            opportunity.CloseDate = Date.today();
            insert opportunity;
            System.assertEquals('Opportunity', CSUtils.getObjectNameFromId(opportunity.Id));
        } catch (Exception e) {
            // Org has custom validation(s) preventing the record from
            // inserting and thus this test from running. Ignore exception.
        }

        try {
            Lead lead = new Lead();
            lead.LastName = 'Test';
            lead.Company = 'Test';
            insert lead;
            System.assertEquals('Lead', CSUtils.getObjectNameFromId(lead.Id));
        } catch (Exception e) {
            // Org has custom validation(s) preventing the record from
            // inserting and thus this test from running. Ignore exception.
        }
    }

    @isTest
    static void testFifteenCharacterId() {
        System.assertEquals(null, CSUtils.fifteenCharacterId(null));
        System.assertEquals('01234', CSUtils.fifteenCharacterId('01234')); // 5 characters
        System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234')); // 15 characters
        System.assertEquals('012345678901234', CSUtils.fifteenCharacterId('012345678901234567')); // 18 characters
    }

    @isTest
    static void testFieldValuesDifferent() {
        // Test String field.
        Contact contactA = new Contact();
        contactA.FirstName = 'Test';

        Contact contactB = new Contact();
        contactB.FirstName = 'Test';

        System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

        contactB.FirstName = 'Test 2';

        System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'FirstName' }));

        // Test Boolean field.
        contactA = new Contact();
        contactA.DoNotCall = false;

        contactB = new Contact();
        contactB.DoNotCall = false;

        System.assertEquals(false, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));

        contactB.DoNotCall = true;

        System.assertEquals(true, CSUtils.fieldValuesDifferent(contactA, contactB, new Set<String>{ 'DoNotCall' }));
    }

    @isTest
    static void testSendEmail() {
        CSUtils.sendEmail(new List<String>{ 'test@test.com' }, 'test', 'test message');
    }

    @isTest
    static void testDayOfWeek() {
        system.assertEquals('Monday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 23)));
        system.assertEquals('Tuesday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 24)));
        system.assertEquals('Wednesday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 25)));
        system.assertEquals('Thursday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 26)));
        system.assertEquals('Friday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 27)));
        system.assertEquals('Saturday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 28)));
        system.assertEquals('Sunday', CSUtils.dayOfWeek(date.newInstance(2015, 3, 29)));
    }

    @isTest
    static void testSelectStar() {
        String soql = CSUtils.selectStar('Opportunity', true);
        system.assertNotEquals(null, soql);
        system.assertEquals(true, soql.contains('Id'));
    }

    @IsTest
    public static void testIsFieldAvailable() {
        // Test data setup
        String objectName = 'Account'; // Replace this with the API name of the object
        String existingFieldName = 'Name'; // Replace this with an existing API field name on the Account object
        String nonExistingFieldName = 'Non_Existent_Field__c'; // Replace this with a non-existing API field name

        // Perform the test
        Test.startTest();
        Boolean isExistingFieldAvailable = CSUtils.isFieldAvailable(objectName, existingFieldName);
        Boolean isNonExistingFieldAvailable = CSUtils.isFieldAvailable(objectName, nonExistingFieldName);
        Test.stopTest();

        // Assert the results
        System.assertEquals(true, isExistingFieldAvailable, 'Existing field should be available');
        System.assertEquals(false, isNonExistingFieldAvailable, 'Non-existing field should not be available');
    }
}