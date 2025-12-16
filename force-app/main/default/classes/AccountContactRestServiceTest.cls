/**
 * @description Test class for AccountContactRestService
 * @author Salesforce Developer
 * @date 2025-12-15
 */
@isTest
private class AccountContactRestServiceTest {

    /**
     * @description Test successful creation of Account with multiple Contacts
     */
    @isTest
    static void testCreateAccountWithContacts_Success() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Prepare request data
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        // Account data
        AccountContactRestService.AccountData accountData = new AccountContactRestService.AccountData();
        accountData.accountName = 'Test Account';
        accountData.phone = '555-1234';
        accountData.website = 'www.testaccount.com';
        accountData.industry = 'Technology';
        accountData.billingStreet = '123 Main St';
        accountData.billingCity = 'San Francisco';
        accountData.billingState = 'California';
        accountData.billingPostalCode = '94105';
        accountData.billingCountry = 'United States';
        requestData.accountData = accountData;

        // Contact data
        List<AccountContactRestService.ContactData> contacts = new List<AccountContactRestService.ContactData>();

        AccountContactRestService.ContactData contact1 = new AccountContactRestService.ContactData();
        contact1.firstName = 'John';
        contact1.lastName = 'Doe';
        contact1.email = 'john.doe@test.com';
        contact1.phone = '555-1111';
        contact1.title = 'CEO';
        contact1.department = 'Executive';
        contact1.mobilePhone = '555-2222';
        contact1.isVerified = true;
        contacts.add(contact1);

        AccountContactRestService.ContactData contact2 = new AccountContactRestService.ContactData();
        contact2.firstName = 'Jane';
        contact2.lastName = 'Smith';
        contact2.email = 'jane.smith@test.com';
        contact2.phone = '555-3333';
        contact2.title = 'CTO';
        contact2.department = 'Technology';
        contact2.mobilePhone = '555-4444';
        contact2.isVerified = false;
        contacts.add(contact2);

        requestData.contacts = contacts;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // Assertions
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertNotEquals(null, result.account, 'Account info should not be null');
        System.assertNotEquals(null, result.account.accountId, 'Account ID should not be null');
        System.assertNotEquals(null, result.account.externalId, 'Account External ID should not be null');
        System.assertEquals(2, result.contacts.size(), 'Should have 2 contacts');

        // Verify contact info structure
        for (AccountContactRestService.ContactInfo contactInfo : result.contacts) {
            System.assertNotEquals(null, contactInfo.contactId, 'Contact ID should not be null');
            System.assertNotEquals(null, contactInfo.email, 'Email should not be null');
            System.assertNotEquals(null, contactInfo.externalId, 'Contact External ID should not be null');
        }

        // Verify database records
        List<Account> accounts = [SELECT Id, Name, External_ID__c FROM Account WHERE Name = 'Test Account'];
        System.assertEquals(1, accounts.size(), 'One account should be created');
        System.assertEquals(result.account.accountId, accounts[0].Id, 'Account IDs should match');
        System.assertEquals(result.account.externalId, accounts[0].External_ID__c, 'External IDs should match');

        List<Contact> createdContacts = [SELECT Id, Email, External_ID__c FROM Contact WHERE AccountId = :accounts[0].Id];
        System.assertEquals(2, createdContacts.size(), 'Two contacts should be created');
    }

    /**
     * @description Test successful creation of Account without Contacts
     */
    @isTest
    static void testCreateAccountWithoutContacts_Success() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Prepare request data with only account
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData accountData = new AccountContactRestService.AccountData();
        accountData.accountName = 'Solo Account';
        accountData.phone = '555-9999';
        requestData.accountData = accountData;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // Assertions
        System.assertEquals(true, result.success, 'Operation should be successful');
        System.assertNotEquals(null, result.account, 'Account info should not be null');
        System.assertNotEquals(null, result.account.accountId, 'Account ID should not be null');
        System.assertEquals(0, result.contacts.size(), 'Should have no contacts');

        // Verify database
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Solo Account'];
        System.assertEquals(1, accounts.size(), 'One account should be created');
    }

    /**
     * @description Test null request data validation
     */
    @isTest
    static void testCreateAccount_NullRequestData() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(null);
        Test.stopTest();

        // Assertions
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.message.contains('Request data cannot be null'), 'Error message should indicate null request');

        // Verify no records created
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(0, accounts.size(), 'No accounts should be created');
    }

    /**
     * @description Test missing account data validation
     */
    @isTest
    static void testCreateAccount_MissingAccountData() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Create request with null account data
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // Assertions
        System.assertEquals(false, result.success, 'Operation should fail');
        System.assert(result.message.contains('Account data is required'), 'Error message should indicate missing account data');

        // Verify no records created
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(0, accounts.size(), 'No accounts should be created');
    }

    /**
     * @description Test contact creation failure and account rollback
     * Note: This test simulates a scenario where contact insertion might fail
     */
    @isTest
    static void testCreateAccount_ContactFailureRollback() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Prepare request data
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData accountData = new AccountContactRestService.AccountData();
        accountData.accountName = 'Test Rollback Account';
        requestData.accountData = accountData;

        // Create contact with invalid data (missing required LastName will be handled by our code)
        List<AccountContactRestService.ContactData> contacts = new List<AccountContactRestService.ContactData>();
        AccountContactRestService.ContactData contact1 = new AccountContactRestService.ContactData();
        contact1.firstName = 'Test';
        // Intentionally not setting lastName - but this might not fail in all orgs
        // So we'll test with email format that's too long
        contact1.email = 'a'.repeat(80) + '@' + 'b'.repeat(80) + '.com'; // Email too long
        contacts.add(contact1);

        requestData.contacts = contacts;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // The response should indicate failure
        System.assertEquals(false, result.success, 'Operation should fail due to contact error');

        // Verify rollback - no account should be created
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'Test Rollback Account'];
        System.assertEquals(0, accounts.size(), 'Account should be rolled back');

        // Verify no contacts created
        List<Contact> createdContacts = [SELECT Id FROM Contact];
        System.assertEquals(0, createdContacts.size(), 'No contacts should be created');
    }

    /**
     * @description Test response structure for account and contact info
     */
    @isTest
    static void testResponseStructure() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Prepare minimal request
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData accountData = new AccountContactRestService.AccountData();
        accountData.accountName = 'Structure Test Account';
        requestData.accountData = accountData;

        List<AccountContactRestService.ContactData> contacts = new List<AccountContactRestService.ContactData>();
        AccountContactRestService.ContactData contact1 = new AccountContactRestService.ContactData();
        contact1.firstName = 'Test';
        contact1.lastName = 'User';
        contact1.email = 'test@example.com';
        contacts.add(contact1);
        requestData.contacts = contacts;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // Verify response structure
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertEquals(true, result.success, 'Success flag should be true');
        System.assertNotEquals(null, result.message, 'Message should not be null');

        // Verify AccountInfo structure
        System.assertNotEquals(null, result.account, 'Account should not be null');
        System.assertNotEquals(null, result.account.accountId, 'Account ID should be populated');
        System.assertNotEquals(null, result.account.externalId, 'Account External ID should be populated');

        // Verify ContactInfo structure
        System.assertNotEquals(null, result.contacts, 'Contacts list should not be null');
        System.assertEquals(1, result.contacts.size(), 'Should have one contact');
        AccountContactRestService.ContactInfo contactInfo = result.contacts[0];
        System.assertNotEquals(null, contactInfo.contactId, 'Contact ID should be populated');
        System.assertEquals('test@example.com', contactInfo.email, 'Email should match');
        System.assertNotEquals(null, contactInfo.externalId, 'Contact External ID should be populated');
    }

    /**
     * @description Test contact with all fields populated
     */
    @isTest
    static void testCreateContact_AllFields() {
        // Setup REST context
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/api/accountcontact/';
        request.httpMethod = 'POST';
        RestContext.request = request;
        RestContext.response = response;

        // Prepare request with all contact fields
        AccountContactRestService.AccountContactRequest requestData = new AccountContactRestService.AccountContactRequest();

        AccountContactRestService.AccountData accountData = new AccountContactRestService.AccountData();
        accountData.accountName = 'Full Fields Account';
        requestData.accountData = accountData;

        List<AccountContactRestService.ContactData> contacts = new List<AccountContactRestService.ContactData>();
        AccountContactRestService.ContactData contact1 = new AccountContactRestService.ContactData();
        contact1.firstName = 'Complete';
        contact1.lastName = 'Contact';
        contact1.email = 'complete@test.com';
        contact1.phone = '555-1234';
        contact1.title = 'Manager';
        contact1.department = 'Sales';
        contact1.mobilePhone = '555-5678';
        contact1.isVerified = true;
        contacts.add(contact1);
        requestData.contacts = contacts;

        Test.startTest();
        AccountContactRestService.AccountContactResponse result = AccountContactRestService.createAccountContact(requestData);
        Test.stopTest();

        // Verify contact fields
        List<Contact> createdContacts = [
            SELECT Id, FirstName, LastName, Email, Phone, Title, Department, MobilePhone, Verified__c, External_ID__c
            FROM Contact
            WHERE Email = 'complete@test.com'
        ];

        System.assertEquals(1, createdContacts.size(), 'One contact should be created');
        Contact con = createdContacts[0];
        System.assertEquals('Complete', con.FirstName, 'First name should match');
        System.assertEquals('Contact', con.LastName, 'Last name should match');
        System.assertEquals('complete@test.com', con.Email, 'Email should match');
        System.assertEquals('555-1234', con.Phone, 'Phone should match');
        System.assertEquals('Manager', con.Title, 'Title should match');
        System.assertEquals('Sales', con.Department, 'Department should match');
        System.assertEquals('555-5678', con.MobilePhone, 'Mobile phone should match');
        System.assertEquals(true, con.Verified__c, 'Verified should be true');
        System.assertNotEquals(null, con.External_ID__c, 'External ID should be populated');
    }
}