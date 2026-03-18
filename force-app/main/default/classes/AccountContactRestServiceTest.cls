/**
 * @description Test class for AccountContactRestService.
 *              Uses TestDataFactory and TestContextHelper to eliminate boilerplate.
 *
 *              Why no @testSetup:
 *                - The service creates all records internally.
 *                - Rollback/null-request tests assert zero existing accounts;
 *                  shared setup data would break those assertions.
 *
 * @author Salesforce Developer
 * @date 2025-12-15
 */
@isTest
private class AccountContactRestServiceTest {

    // =========================================================================
    // PRIVATE REQUEST BUILDERS
    // Centralise AccountData / ContactData construction so each test method
    // focuses only on what makes it distinct.
    // =========================================================================

    /** Full request: account with all fields + two contacts */
    private static AccountContactRestService.AccountContactRequest buildFullRequest() {
        AccountContactRestService.AccountContactRequest req =
            new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData acct = new AccountContactRestService.AccountData();
        acct.accountName       = 'Test Account';
        acct.phone             = '555-1234';
        acct.website           = 'www.testaccount.com';
        acct.industry          = 'Technology';
        acct.billingStreet     = '123 Main St';
        acct.billingCity       = 'San Francisco';
        acct.billingState      = 'California';
        acct.billingPostalCode = '94105';
        acct.billingCountry    = 'United States';
        req.accountData = acct;

        AccountContactRestService.ContactData c1 = new AccountContactRestService.ContactData();
        c1.firstName   = 'John';
        c1.lastName    = 'Doe';
        c1.email       = 'john.doe@test.com';
        c1.phone       = '555-1111';
        c1.title       = 'CEO';
        c1.department  = 'Executive';
        c1.mobilePhone = '555-2222';
        c1.isVerified  = true;

        AccountContactRestService.ContactData c2 = new AccountContactRestService.ContactData();
        c2.firstName   = 'Jane';
        c2.lastName    = 'Smith';
        c2.email       = 'jane.smith@test.com';
        c2.phone       = '555-3333';
        c2.title       = 'CTO';
        c2.department  = 'Technology';
        c2.mobilePhone = '555-4444';
        c2.isVerified  = false;

        req.contacts = new List<AccountContactRestService.ContactData>{ c1, c2 };
        return req;
    }

    /** Minimal request: account only (name + phone), no contacts */
    private static AccountContactRestService.AccountContactRequest buildMinimalRequest(String accountName) {
        AccountContactRestService.AccountContactRequest req =
            new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData acct = new AccountContactRestService.AccountData();
        acct.accountName = accountName;
        acct.phone       = '555-9999';
        req.accountData  = acct;

        return req;
    }


    // =========================================================================
    // TEST METHODS
    // =========================================================================

    /**
     * @description Test successful creation of Account with multiple Contacts
     */
    @isTest
    static void testCreateAccountWithContacts_Success() {
        TestContextHelper.setupRestContext();

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(buildFullRequest());
        Test.stopTest();

        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertNotEquals(null, result.account, 'Account info should not be null');
        System.assertNotEquals(null, result.account.accountId, 'Account ID should not be null');
        System.assertNotEquals(null, result.account.externalId, 'Account External ID should not be null');
        System.assertEquals(2, result.contacts.size(), 'Should have 2 contacts');

        for (AccountContactRestService.ContactInfo ci : result.contacts) {
            System.assertNotEquals(null, ci.contactId,  'Contact ID should not be null');
            System.assertNotEquals(null, ci.email,      'Email should not be null');
            System.assertNotEquals(null, ci.externalId, 'Contact External ID should not be null');
        }

        List<Account> accounts = [SELECT Id, External_ID__c FROM Account WHERE Name = 'Test Account'];
        System.assertEquals(1, accounts.size(), 'One account should be created');
        System.assertEquals(result.account.accountId,  accounts[0].Id,             'Account IDs should match');
        System.assertEquals(result.account.externalId, accounts[0].External_ID__c, 'External IDs should match');

        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :accounts[0].Id];
        System.assertEquals(2, contacts.size(), 'Two contacts should be created');
    }

    /**
     * @description Test successful creation of Account without Contacts
     */
    @isTest
    static void testCreateAccountWithoutContacts_Success() {
        TestContextHelper.setupRestContext();

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(buildMinimalRequest('Solo Account'));
        Test.stopTest();

        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertNotEquals(null, result.account.accountId, 'Account ID should not be null');
        System.assertEquals(0, result.contacts.size(), 'Should have no contacts');

        System.assertEquals(1,
            [SELECT COUNT() FROM Account WHERE Name = 'Solo Account'],
            'One account should be created');
    }

    /**
     * @description Test null request data validation
     */
    @isTest
    static void testCreateAccount_NullRequestData() {
        TestContextHelper.setupRestContext();

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(null);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.message.contains('Request data cannot be null'),
            'Error message should indicate null request');
        System.assertEquals(0, [SELECT COUNT() FROM Account], 'No accounts should be created');
    }

    /**
     * @description Test missing account data validation
     */
    @isTest
    static void testCreateAccount_MissingAccountData() {
        TestContextHelper.setupRestContext();

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(
                new AccountContactRestService.AccountContactRequest()
            );
        Test.stopTest();

        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.message.contains('Account data is required'),
            'Error message should indicate missing account data');
        System.assertEquals(0, [SELECT COUNT() FROM Account], 'No accounts should be created');
    }

    /**
     * @description Test contact creation failure and account rollback.
     *              Simulates an oversized email to force a DmlException on contacts,
     *              which should roll back the already-inserted Account.
     */
    @isTest
    static void testCreateAccount_ContactFailureRollback() {
        TestContextHelper.setupRestContext();

        AccountContactRestService.AccountContactRequest req =
            buildMinimalRequest('Test Rollback Account');

        AccountContactRestService.ContactData badContact = new AccountContactRestService.ContactData();
        badContact.firstName = 'Test';
        badContact.email     = 'a'.repeat(80) + '@' + 'b'.repeat(80) + '.com'; // email too long
        req.contacts = new List<AccountContactRestService.ContactData>{ badContact };

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(req);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Operation should fail due to contact error');

        System.assertEquals(0,
            [SELECT COUNT() FROM Account WHERE Name = 'Test Rollback Account'],
            'Account should be rolled back');
        System.assertEquals(0, [SELECT COUNT() FROM Contact], 'No contacts should be created');
    }

    /**
     * @description Test response structure for account and contact info
     */
    @isTest
    static void testResponseStructure() {
        TestContextHelper.setupRestContext();

        AccountContactRestService.AccountContactRequest req =
            buildMinimalRequest('Structure Test Account');

        AccountContactRestService.ContactData c = new AccountContactRestService.ContactData();
        c.firstName = 'Test';
        c.lastName  = 'User';
        c.email     = 'test@example.com';
        req.contacts = new List<AccountContactRestService.ContactData>{ c };

        Test.startTest();
        AccountContactRestService.AccountContactResponse result =
            AccountContactRestService.createAccountContact(req);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals(true, result.success, 'Success flag should be true');
        System.assertNotEquals(null, result.message, 'Message should not be null');

        System.assertNotEquals(null, result.account,             'Account should not be null');
        System.assertNotEquals(null, result.account.accountId,   'Account ID should be populated');
        System.assertNotEquals(null, result.account.externalId,  'Account External ID should be populated');

        System.assertNotEquals(null, result.contacts, 'Contacts list should not be null');
        System.assertEquals(1, result.contacts.size(), 'Should have one contact');

        AccountContactRestService.ContactInfo ci = result.contacts[0];
        System.assertNotEquals(null, ci.contactId,               'Contact ID should be populated');
        System.assertEquals('test@example.com', ci.email,        'Email should match');
        System.assertNotEquals(null, ci.externalId,              'Contact External ID should be populated');
    }

    /**
     * @description Test contact with all fields populated
     */
    @isTest
    static void testCreateContact_AllFields() {
        TestContextHelper.setupRestContext();

        AccountContactRestService.AccountContactRequest req =
            buildMinimalRequest('Full Fields Account');

        AccountContactRestService.ContactData c = new AccountContactRestService.ContactData();
        c.firstName   = 'Complete';
        c.lastName    = 'Contact';
        c.email       = 'complete@test.com';
        c.phone       = '555-1234';
        c.title       = 'Manager';
        c.department  = 'Sales';
        c.mobilePhone = '555-5678';
        c.isVerified  = true;
        req.contacts = new List<AccountContactRestService.ContactData>{ c };

        Test.startTest();
        AccountContactRestService.createAccountContact(req);
        Test.stopTest();

        Contact con = [
            SELECT FirstName, LastName, Email, Phone, Title, Department,
                   MobilePhone, Verified__c, External_ID__c
            FROM Contact
            WHERE Email = 'complete@test.com'
        ];

        System.assertEquals('Complete',          con.FirstName,    'First name should match');
        System.assertEquals('Contact',           con.LastName,     'Last name should match');
        System.assertEquals('complete@test.com', con.Email,        'Email should match');
        System.assertEquals('555-1234',          con.Phone,        'Phone should match');
        System.assertEquals('Manager',           con.Title,        'Title should match');
        System.assertEquals('Sales',             con.Department,   'Department should match');
        System.assertEquals('555-5678',          con.MobilePhone,  'Mobile phone should match');
        System.assertEquals(true,                con.Verified__c,  'Verified should be true');
        System.assertNotEquals(null,             con.External_ID__c, 'External ID should be populated');
    }
}
