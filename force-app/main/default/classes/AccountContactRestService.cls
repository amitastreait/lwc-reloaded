/**
 * @description Custom Apex REST Service to create Account and Contact records
 * @author - Amit Singh
 * @date 2025-12-14
 */
@RestResource(urlMapping='/api/accountcontact/*')
global without sharing class AccountContactRestService {

  /**
   * @description HTTP POST method to create Account and Contact records
   * @param requestData - AccountContactRequest wrapper containing account and contact data
   * @return AccountContactResponse - Response wrapper with success status and created record IDs
   */
    @HttpPost
    global static AccountContactResponse createAccountContact(AccountContactRequest requestData) {
        AccountContactResponse response = new AccountContactResponse();
        Savepoint sp = Database.setSavepoint();
        // System.debug( JSON.serializePretty(requestData) );
        try {
            // Validate input
            if (requestData == null) {
                throw new RestServiceException('Request data cannot be null');
            }
            
            if (requestData.accountData == null) {
                throw new RestServiceException('Account data is required');
            }
            
            // Create Account
            Account newAccount = new Account();
            newAccount.Name = requestData.accountData.accountName;
            newAccount.Phone = requestData.accountData.phone;
            newAccount.Website = requestData.accountData.website;
            newAccount.Industry = requestData.accountData.industry;
            newAccount.BillingStreet = requestData.accountData.billingStreet;
            newAccount.BillingCity = requestData.accountData.billingCity;
            newAccount.BillingState = requestData.accountData.billingState;
            newAccount.BillingPostalCode = requestData.accountData.billingPostalCode;
            newAccount.BillingCountry = requestData.accountData.billingCountry;
            newAccount.External_ID__c = UUID.randomUUID().toString();
            newAccount.Is_External__c = true;
            insert as system newAccount;

            // Set account info in response
            response.account = new AccountInfo();
            response.account.accountId = newAccount.Id;
            response.account.externalId = newAccount.External_ID__c;
            
            // Create Contacts if provided
            List<Contact> contactsToInsert = new List<Contact>();
            if (requestData.contacts != null && !requestData.contacts.isEmpty()) {
                for (ContactData contactData : requestData.contacts) {
                    Contact newContact = new Contact();
                    newContact.AccountId = newAccount.Id;
                    newContact.FirstName = contactData.firstName;
                    newContact.LastName = contactData.lastName;
                    newContact.Email = contactData.email;
                    newContact.Phone = contactData.phone ?? contactData.contactPhone;
                    newContact.Title = contactData.title;
                    newContact.Department = contactData.department;
                    newContact.MobilePhone = contactData.mobilePhone;
                    newContact.Verified__c = contactData.isVerified != null ? contactData.isVerified : false;
                    newContact.External_ID__c = UUID.randomUUID().toString();
                    contactsToInsert.add(newContact);
                }

                // Insert contacts - if this fails, account will be rolled back
                try {
                    insert as system contactsToInsert;
                } catch (DmlException e) {
                    // Rollback account creation as well
                    Database.rollback(sp);
                    throw new RestServiceException('Failed to create contacts. Account creation has been rolled back. Error: ' + e.getDmlMessage(0));
                }

                // Collect Contact information
                for (Contact con : contactsToInsert) {
                    ContactInfo contactInfo = new ContactInfo();
                    contactInfo.contactId = con.Id;
                    contactInfo.email = con.Email;
                    contactInfo.externalId = con.External_ID__c;
                    response.contacts.add(contactInfo);
                }
            }
            
            // Build success response
            response.success = true;
            response.message = 'Successfully created Account' + (contactsToInsert.isEmpty() ? '' : ' and ' + contactsToInsert.size() + ' Contact(s)');
            
        } catch (DmlException e) {
            Database.rollback(sp);
            response.success = false;
            response.message = 'Database error: ' + e.getDmlMessage(0);
            response.errorDetails = e.getStackTraceString();
        } catch (RestServiceException e) {
            Database.rollback(sp);
            response.success = false;
            response.message = e.getMessage();
        } catch (Exception e) {
            Database.rollback(sp);
            response.success = false;
            response.message = 'Unexpected error: ' + e.getMessage();
            response.errorDetails = e.getStackTraceString();
        }
        
        return response;
    }


    /**
    * @description Request wrapper class for Account and Contact data
    */
    global class AccountContactRequest {
        public AccountData accountData;
        public List<ContactData> contacts;
    }
    
    /**
    * @description Wrapper class for Account data
    */
    global class AccountData {
        public String accountName;
        public String phone;
        public String website;
        public String industry;
        public String billingStreet;
        public String billingCity;
        public String billingState;
        public String billingPostalCode;
        public String billingCountry;
    }
    
    /**
    * @description Wrapper class for Contact data
    */
    global class ContactData {
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String contactPhone;
        public String title;
        public String department;
        public String mobilePhone;
        public Boolean isVerified;
    }
    
    /**
    * @description Response wrapper class
    */
    global class AccountContactResponse {
        public Boolean success;
        public String message;
        public AccountInfo account;
        public List<ContactInfo> contacts;
        public String errorDetails;

        public AccountContactResponse() {
            this.success = false;
            this.contacts = new List<ContactInfo>();
        }
    }

    /**
    * @description Account information wrapper
    */
    global class AccountInfo {
        public String accountId;
        public String externalId;
    }

    /**
    * @description Contact information wrapper
    */
    global class ContactInfo {
        public String contactId;
        public String email;
        public String externalId;
    }
    
    /**
    * @description Custom exception class for REST service
    */
    public class RestServiceException extends Exception {}
}