/**
 * @description Test data factory providing fluent Builder classes for all SObjects
 *              in this project. Call the static factory methods (anAccount(), aContact(),
 *              etc.) to get a builder, chain setters to override defaults, then call
 *              build() for no-DML or insertRecord() to persist.
 *
 *              Pattern mirrors LogEntryBuilder.cls already in the codebase.
 *
 * Usage examples:
 *   // Minimal — all defaults
 *   Account acc = TestDataFactory.anAccount().insertRecord();
 *
 *   // Custom fields, no DML yet
 *   Account acc = TestDataFactory.anAccount()
 *                     .withName('Acme Corp')
 *                     .withIndustry('Finance')
 *                     .asExternal()
 *                     .build();
 *
 *   // Bulk — 50 contacts linked to an account
 *   List<Contact> cons = TestDataFactory.aContact()
 *                            .withAccountId(acc.Id)
 *                            .insertList(50);
 *
 * @author Salesforce Developer
 * @date 2026-03-18
 */
@isTest
public class TestDataFactory {

    // =========================================================================
    // STATIC FACTORY ENTRY POINTS
    // =========================================================================

    public static AccountBuilder anAccount() {
        return new AccountBuilder();
    }

    public static ContactBuilder aContact() {
        return new ContactBuilder();
    }

    public static StripeTransactionBuilder aStripeTransaction() {
        return new StripeTransactionBuilder();
    }

    public static LogEntryRecordBuilder aLogEntry() {
        return new LogEntryRecordBuilder();
    }


    // =========================================================================
    // INNER BUILDER: Account
    // Custom fields: External_ID__c (Text, ExternalID), Is_External__c (Checkbox)
    // =========================================================================

    public class AccountBuilder {

        private Account record = new Account(
            Name              = 'Test Account',
            Phone             = '555-0100',
            Industry          = 'Technology',
            BillingStreet     = '1 Market St',
            BillingCity       = 'San Francisco',
            BillingState      = 'California',
            BillingPostalCode = '94105',
            BillingCountry    = 'United States',
            External_ID__c    = UUID.randomUUID().toString(),
            Is_External__c    = false
        );

        public AccountBuilder withName(String name) {
            record.Name = name;
            return this;
        }

        public AccountBuilder withPhone(String phone) {
            record.Phone = phone;
            return this;
        }

        public AccountBuilder withWebsite(String website) {
            record.Website = website;
            return this;
        }

        public AccountBuilder withIndustry(String industry) {
            record.Industry = industry;
            return this;
        }

        public AccountBuilder withBillingStreet(String street) {
            record.BillingStreet = street;
            return this;
        }

        public AccountBuilder withBillingCity(String city) {
            record.BillingCity = city;
            return this;
        }

        public AccountBuilder withBillingState(String state) {
            record.BillingState = state;
            return this;
        }

        public AccountBuilder withBillingPostalCode(String postal) {
            record.BillingPostalCode = postal;
            return this;
        }

        public AccountBuilder withBillingCountry(String country) {
            record.BillingCountry = country;
            return this;
        }

        public AccountBuilder withExternalId(String externalId) {
            record.External_ID__c = externalId;
            return this;
        }

        /** Sets Is_External__c = true and generates a fresh UUID External_ID__c */
        public AccountBuilder asExternal() {
            record.Is_External__c = true;
            record.External_ID__c = UUID.randomUUID().toString();
            return this;
        }

        /** Returns the built SObject without any DML */
        public Account build() {
            return record;
        }

        /** Inserts the record and returns it (Id is populated after this call) */
        public Account insertRecord() {
            insert record;
            return record;
        }

        /**
         * Returns a list of count Accounts without DML.
         * Each clone gets a unique Name suffix and a fresh External_ID__c UUID.
         */
        public List<Account> buildList(Integer count) {
            List<Account> results = new List<Account>();
            String baseName = record.Name;
            for (Integer i = 1; i <= count; i++) {
                Account clone = (Account) record.clone(false, false, false, false);
                clone.Name           = baseName + ' ' + i;
                clone.External_ID__c = UUID.randomUUID().toString();
                results.add(clone);
            }
            return results;
        }

        /** Inserts count Accounts and returns them with Ids populated */
        public List<Account> insertList(Integer count) {
            List<Account> results = buildList(count);
            insert results;
            return results;
        }
    }


    // =========================================================================
    // INNER BUILDER: Contact
    // Custom fields: Verified__c (Checkbox), External_ID__c (Text, ExternalID)
    // =========================================================================

    public class ContactBuilder {

        // AccountId is intentionally null — caller sets it via withAccountId()
        // after inserting the parent Account, or passes it as part of the chain.
        private Contact record = new Contact(
            FirstName      = 'Test',
            LastName       = 'User',
            Email          = 'test.user@example.com',
            Phone          = '555-0200',
            Title          = 'Engineer',
            Department     = 'Technology',
            MobilePhone    = '555-0201',
            Verified__c    = false,
            External_ID__c = UUID.randomUUID().toString()
        );

        public ContactBuilder withFirstName(String firstName) {
            record.FirstName = firstName;
            return this;
        }

        public ContactBuilder withLastName(String lastName) {
            record.LastName = lastName;
            return this;
        }

        public ContactBuilder withEmail(String email) {
            record.Email = email;
            return this;
        }

        public ContactBuilder withPhone(String phone) {
            record.Phone = phone;
            return this;
        }

        public ContactBuilder withTitle(String title) {
            record.Title = title;
            return this;
        }

        public ContactBuilder withDepartment(String dept) {
            record.Department = dept;
            return this;
        }

        public ContactBuilder withMobilePhone(String mobile) {
            record.MobilePhone = mobile;
            return this;
        }

        /** Sets Verified__c = true */
        public ContactBuilder verified() {
            record.Verified__c = true;
            return this;
        }

        public ContactBuilder withAccountId(Id accountId) {
            record.AccountId = accountId;
            return this;
        }

        public ContactBuilder withExternalId(String externalId) {
            record.External_ID__c = externalId;
            return this;
        }

        public Contact build() {
            return record;
        }

        public Contact insertRecord() {
            insert record;
            return record;
        }

        /**
         * Returns a list of count Contacts without DML.
         * Each clone gets a unique LastName suffix, unique Email, and fresh External_ID__c.
         */
        public List<Contact> buildList(Integer count) {
            List<Contact> results = new List<Contact>();
            String baseLastName = record.LastName;
            for (Integer i = 1; i <= count; i++) {
                Contact clone = (Contact) record.clone(false, false, false, false);
                clone.LastName      = baseLastName + ' ' + i;
                clone.Email        = 'test.user' + i + '@example.com';
                clone.External_ID__c = UUID.randomUUID().toString();
                results.add(clone);
            }
            return results;
        }

        public List<Contact> insertList(Integer count) {
            List<Contact> results = buildList(count);
            insert results;
            return results;
        }
    }


    // =========================================================================
    // INNER BUILDER: StripePaymentTransaction__c
    // Required fields: Amount__c, Status__c, Stripe_Transaction_ID__c
    // =========================================================================

    public class StripeTransactionBuilder {

        private StripePaymentTransaction__c record = new StripePaymentTransaction__c(
            Amount__c               = 99.99,
            Status__c               = 'succeeded',
            Stripe_Transaction_ID__c = 'pi_test_' + UUID.randomUUID().toString()
        );

        // --- Required field setters ---

        public StripeTransactionBuilder withAmount(Decimal amount) {
            record.Amount__c = amount;
            return this;
        }

        public StripeTransactionBuilder withStatus(String status) {
            record.Status__c = status;
            return this;
        }

        public StripeTransactionBuilder withStripeTransactionId(String txnId) {
            record.Stripe_Transaction_ID__c = txnId;
            return this;
        }

        // --- Optional field setters ---

        public StripeTransactionBuilder withCustomerName(String name) {
            record.Customer_Name__c = name;
            return this;
        }

        public StripeTransactionBuilder withCustomerPhone(String phone) {
            record.CustomerPhone__c = phone;
            return this;
        }

        public StripeTransactionBuilder withPaymentMethodId(String pmId) {
            record.Payment_Method_ID__c = pmId;
            return this;
        }

        public StripeTransactionBuilder withDetails(String details) {
            record.Details__c = details;
            return this;
        }

        public StripeTransactionBuilder withBillingAddressLine1(String line1) {
            record.BillingAddressLine1__c = line1;
            return this;
        }

        public StripeTransactionBuilder withBillingAddressLine2(String line2) {
            record.BillingAddressLine2__c = line2;
            return this;
        }

        public StripeTransactionBuilder withBillingStreet(String street) {
            record.Billing_Street__c = street;
            return this;
        }

        public StripeTransactionBuilder withBillingCity(String city) {
            record.Billing_City__c = city;
            return this;
        }

        public StripeTransactionBuilder withBillingState(String state) {
            record.Billing_State__c = state;
            return this;
        }

        public StripeTransactionBuilder withBillingCountry(String country) {
            record.Billing_Country__c = country;
            return this;
        }

        public StripeTransactionBuilder withBillingPostalCode(String postal) {
            record.BillingPostalCode__c = postal;
            return this;
        }

        public StripePaymentTransaction__c build() {
            return record;
        }

        public StripePaymentTransaction__c insertRecord() {
            insert record;
            return record;
        }

        /**
         * Returns a list of count transactions without DML.
         * Each clone gets a unique Stripe_Transaction_ID__c.
         */
        public List<StripePaymentTransaction__c> buildList(Integer count) {
            List<StripePaymentTransaction__c> results = new List<StripePaymentTransaction__c>();
            for (Integer i = 1; i <= count; i++) {
                StripePaymentTransaction__c clone =
                    (StripePaymentTransaction__c) record.clone(false, false, false, false);
                clone.Stripe_Transaction_ID__c = 'pi_test_' + i + '_' + UUID.randomUUID().toString();
                results.add(clone);
            }
            return results;
        }

        public List<StripePaymentTransaction__c> insertList(Integer count) {
            List<StripePaymentTransaction__c> results = buildList(count);
            insert results;
            return results;
        }
    }


    // =========================================================================
    // INNER BUILDER: Log_Entry__c
    // Named LogEntryRecordBuilder to avoid collision with prod LogEntryBuilder.cls
    // which builds the LogEntry POJO (not the SObject).
    // Log_Level__c is a restricted picklist: FATAL, ERROR, WARN, INFO, DEBUG, TRACE
    // =========================================================================

    public class LogEntryRecordBuilder {

        private Log_Entry__c record = new Log_Entry__c(
            Log_Level__c = 'INFO',
            Message__c   = 'Test log message'
        );

        public LogEntryRecordBuilder withLevel(String level) {
            record.Log_Level__c = level;
            return this;
        }

        public LogEntryRecordBuilder withMessage(String message) {
            record.Message__c = message;
            return this;
        }

        public LogEntryRecordBuilder withClassName(String className) {
            record.Class_Name__c = className;
            return this;
        }

        public LogEntryRecordBuilder withMethodName(String methodName) {
            record.Method_Name__c = methodName;
            return this;
        }

        public LogEntryRecordBuilder withApplicationName(String appName) {
            record.Application_Name__c = appName;
            return this;
        }

        public LogEntryRecordBuilder withCategory(String category) {
            record.Category__c = category;
            return this;
        }

        public LogEntryRecordBuilder withSubCategory(String subCategory) {
            record.Sub_Category__c = subCategory;
            return this;
        }

        public LogEntryRecordBuilder withEnvironment(String env) {
            record.Environment__c = env;
            return this;
        }

        public LogEntryRecordBuilder withTransactionId(String txnId) {
            record.Transaction_ID__c = txnId;
            return this;
        }

        public LogEntryRecordBuilder withRequestId(String requestId) {
            record.Request_Id__c = requestId;
            return this;
        }

        public LogEntryRecordBuilder withSessionId(String sessionId) {
            record.Session_ID__c = sessionId;
            return this;
        }

        public LogEntryRecordBuilder withExceptionType(String exType) {
            record.Exception_Type__c = exType;
            return this;
        }

        public LogEntryRecordBuilder withStackTrace(String stackTrace) {
            record.Stack_Trace__c = stackTrace;
            return this;
        }

        public LogEntryRecordBuilder withRecordId(String recordId) {
            record.Record_ID__c = recordId;
            return this;
        }

        public LogEntryRecordBuilder withObjectType(String objectType) {
            record.Object_Type__c = objectType;
            return this;
        }

        public LogEntryRecordBuilder withTags(String tags) {
            record.Tags__c = tags;
            return this;
        }

        public LogEntryRecordBuilder withUserContext(String userContext) {
            record.User_Context__c = userContext;
            return this;
        }

        public LogEntryRecordBuilder withVersion(String version) {
            record.Version__c = version;
            return this;
        }

        public LogEntryRecordBuilder withRetentionDays(Integer days) {
            record.Retention_Days__c = days;
            return this;
        }

        public LogEntryRecordBuilder withCpuTimeMs(Integer ms) {
            record.CPU_Time_Ms__c = ms;
            return this;
        }

        public LogEntryRecordBuilder withHeapSizeKb(Integer kb) {
            record.Heap_Size_KB__c = kb;
            return this;
        }

        public LogEntryRecordBuilder withMemoryUsageKb(Integer kb) {
            record.Memory_Usage_KB__c = kb;
            return this;
        }

        public LogEntryRecordBuilder withSoqlQueriesUsed(Integer count) {
            record.SOQL_Queries_Used__c = count;
            return this;
        }

        public LogEntryRecordBuilder withDmlStatementsUsed(Integer count) {
            record.DML_Statements_Used__c = count;
            return this;
        }

        public LogEntryRecordBuilder withProcessingTimeMs(Integer ms) {
            record.Processing_Time_Ms__c = ms;
            return this;
        }

        public LogEntryRecordBuilder withLineNumber(Integer line) {
            record.Line_Number__c = line;
            return this;
        }

        /** Sets Is_Archived__c = true */
        public LogEntryRecordBuilder archived() {
            record.Is_Archived__c = true;
            return this;
        }

        public Log_Entry__c build() {
            return record;
        }

        public Log_Entry__c insertRecord() {
            insert record;
            return record;
        }

        /**
         * Returns a list of count Log_Entry__c records without DML.
         * Each clone gets a unique Message__c suffix.
         */
        public List<Log_Entry__c> buildList(Integer count) {
            List<Log_Entry__c> results = new List<Log_Entry__c>();
            String baseMessage = record.Message__c;
            for (Integer i = 1; i <= count; i++) {
                Log_Entry__c clone = (Log_Entry__c) record.clone(false, false, false, false);
                clone.Message__c = baseMessage + ' ' + i;
                results.add(clone);
            }
            return results;
        }

        public List<Log_Entry__c> insertList(Integer count) {
            List<Log_Entry__c> results = buildList(count);
            insert results;
            return results;
        }
    }
}
