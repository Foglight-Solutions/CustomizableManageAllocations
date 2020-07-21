/*
    Copyright (c) 2014, Salesforce.org
    All rights reserved.
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2014
* @group Utilities
* @description Helper class that retrieves custom settings and sets defaults.
* Needs to be "without sharing" so that the Install Script can run it.
*/
public without sharing class UTIL_CustomSettingsFacade {
    public static final String DEFAULT_OPPORTUNITY_CONTACT_ROLE_DONOR = CAO_Constants.OCR_DONOR_ROLE;
    public static final String DEFAULT_OPPORTUNITY_CONTACT_ROLE_SOFT_CREDIT = 'Soft Credit';

    //storing user-level custom settings in-memory to avoid trying to insert/update them
    //twice and thus trigger the "duplicate OwnerId" error
    static npe01__Contacts_And_Orgs_Settings__c contactsSettings;
    static npo02__Households_Settings__c householdsSettings;
    static npsp__Household_Naming_Settings__c householdNamingSettings;
    static npsp__Allocations_Settings__c allocationsSettings;

    //storing org-level custom settings in-memory to avoid slowing down the settings page
    static npe01__Contacts_And_Orgs_Settings__c orgContactsSettings;
    static npo02__Households_Settings__c orgHouseholdsSettings;
    static npsp__Allocations_Settings__c orgAllocationsSettings;
    static npsp__Household_Naming_Settings__c orgHouseholdNamingSettings;


    /*******************************************************************************************************
    * @description Resets specific Custom Settings that are updated after
    *   Record Type Settings have been fixed.
    * @return void
    */
    public static void reloadCustomSettingsOnRecordTypeCleanup() {
        contactsSettings = null;
        householdsSettings = null;
        allocationsSettings = null;

        orgContactsSettings = null;
        orgHouseholdsSettings = null;
        orgAllocationsSettings = null;

    }

    /*******************************************************************************************************
    * @description Returns the default Contacts and Orgs settings.
    * @return npe01__Contacts_And_Orgs_Settings__c Custom settings record for Contacts and Orgs configuration.
    * At the org level, if no user level settings are defined. The ID field should be checked to determine if
    * the returned record already exists or doesn't exist in the database.
    */
    public static npe01__Contacts_And_Orgs_Settings__c getContactsSettings() {
        if(Test.isRunningTest() && contactsSettings == null) {
            contactsSettings = new npe01__Contacts_And_Orgs_Settings__c();
            configContactsSettings(contactsSettings);
        } else if (contactsSettings == null) {
            contactsSettings = npe01__Contacts_And_Orgs_Settings__c.getInstance();
            if(contactsSettings.Id == null)
                contactsSettings = getOrgContactsSettings();
        }
        return contactsSettings;
    }

    /*******************************************************************************************************
    * @description Returns the org-level Contacts and Orgs settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return npe01__Contacts_And_Orgs_Settings__c Org-level settings for Contacts and Orgs.
    */
    public static npe01__Contacts_And_Orgs_Settings__c getOrgContactsSettings() {
        if(orgContactsSettings == null) {
            orgContactsSettings = npe01__Contacts_And_Orgs_Settings__c.getOrgDefaults();
            if(orgContactsSettings.Id == null) {
                configContactsSettings(orgContactsSettings);
                orgContactsSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgContactsSettings;
            }
        }
        return orgContactsSettings;
    }

    /*******************************************************************************************************
    * @description Returns the default Households settings.
    * @return npo02__Households_Settings__c Custom settings record for Households configuration. At the org level,
    * if no user level settings are defined. The ID field should be checked to determine if the returned record
    * already exists or doesn't exist in the database.
    */
    public static npo02__Households_Settings__c getHouseholdsSettings() {
        if(Test.isRunningTest() && householdsSettings == null) {
            householdsSettings = new npo02__Households_Settings__c();
            configHouseholdSettings(householdsSettings);
        } else if (householdsSettings == null) {
            householdsSettings = npo02__Households_Settings__c.getInstance();
            if(householdsSettings.Id == null)
                householdsSettings = getOrgHouseholdsSettings();
        }
        return householdsSettings;
    }

    /*******************************************************************************************************
    * @description Returns the default Allocations settings.
    * @return Allocations_Settings__c Custom settings record for Allocations configuration. At the org level, if no user level
    * settings are defined. The ID field should be checked to determine if the returned record already exists or doesn't exist
    * in the database.
    */
    public static npsp__Allocations_Settings__c getAllocationsSettings() {
        if(Test.isRunningTest() && allocationsSettings == null) {
            allocationsSettings = new npsp__Allocations_Settings__c();
            configAllocationsSettings(allocationsSettings);
        } else if (allocationsSettings == null) {
            allocationsSettings = npsp__Allocations_Settings__c.getInstance();
            if (allocationsSettings.Id == null) {
                allocationsSettings = getOrgAllocationsSettings();
            }
        }
        return allocationsSettings;
    }

    /*******************************************************************************************************
    * @description Returns the org-level Households settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return npo02__Households_Settings__c Org-level settings for Households.
    */
    public static npo02__Households_Settings__c getOrgHouseholdsSettings() {
        if(orgHouseholdsSettings == null) {
            orgHouseholdsSettings = npo02__Households_Settings__c.getOrgDefaults();
            if(orgHouseholdsSettings.Id == null) {
                configHouseholdSettings(orgHouseholdsSettings);
                orgHouseholdsSettings.Setupownerid = UserInfo.getOrganizationId();
                if(!Test.isRunningTest())
                    upsert orgHouseholdsSettings;
            }
        }
        return orgHouseholdsSettings;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Household_Naming_Settings__c The configured settings.
    **/
    public static npsp__Household_Naming_Settings__c getHouseholdNamingSettingsForTests(npsp__Household_Naming_Settings__c mySettings) {
        if(householdNamingSettings == null)
            householdNamingSettings = new npsp__Household_Naming_Settings__c();

        householdNamingSettings.npsp__Household_Name_Format__c = mySettings.npsp__Household_Name_Format__c;
        householdNamingSettings.npsp__Formal_Greeting_Format__c = mySettings.npsp__Formal_Greeting_Format__c;
        householdNamingSettings.npsp__Informal_Greeting_Format__c = mySettings.npsp__Informal_Greeting_Format__c;
        householdNamingSettings.npsp__Name_Connector__c = mySettings.npsp__Name_Connector__c;
        householdNamingSettings.npsp__Name_Overrun__c = mySettings.npsp__Name_Overrun__c;
        householdNamingSettings.npsp__Contact_Overrun_Count__c = mySettings.npsp__Contact_Overrun_Count__c;
        householdNamingSettings.npsp__Implementing_Class__c = mySettings.npsp__Implementing_Class__c;

        orgHouseholdNamingSettings = householdNamingSettings;
        return householdNamingSettings;
    }

    /*******************************************************************************************************
    * @description Returns the org-level Allocation settings. Default org-level settings will be created
    * if none exist. Meant to be called only from settings page and install script.
    * @return Allocations_Settings__c Org-level settings for Allocations.
    */
    public static npsp__Allocations_Settings__c getOrgAllocationsSettings() {
        if (orgAllocationsSettings==null) {
            orgAllocationsSettings = npsp__Allocations_Settings__c.getOrgDefaults();
            if (orgAllocationsSettings.Id == null) {
                configAllocationsSettings(orgAllocationsSettings);
                if(!Test.isRunningTest())
                    upsert orgAllocationsSettings;
            }
        }
        return orgAllocationsSettings;
    }

    /*******************************************************************************************************
     * Private methods that will configure the default org-level custom settings.
     **/
    private static void configContactsSettings(npe01__Contacts_And_Orgs_Settings__c cs) {
        //this setting does nothing, but needs to be extracted from the tests before removing
        cs.npe01__Enable_Opportunity_Contact_Role_Trigger__c = false;
        cs.npe01__Payments_Enabled__c  = true;
        cs.npe01__Opportunity_Contact_Role_Default_role__c = DEFAULT_OPPORTUNITY_CONTACT_ROLE_DONOR;
        cs.npsp__Contact_Role_for_Organizational_Opps__c = DEFAULT_OPPORTUNITY_CONTACT_ROLE_SOFT_CREDIT;
        cs.npe01__Account_Processor__c = CAO_Constants.HH_ACCOUNT_PROCESSOR;
        cs.npsp__Opp_RecTypes_Excluded_for_Payments__c = null;
        cs.npsp__Opp_Types_Excluded_for_Payments__c = null;
        Recordtypeinfo householdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(CAO_Constants.HH_ACCOUNT_PROCESSOR);

        if(householdAccount != null)
            cs.npe01__HH_Account_RecordTypeID__c = householdAccount.getRecordTypeId();
    }

    private static void configHouseholdSettings(npo02__Households_Settings__c hs) {
        String oldProcessor = '';
        //modified to check again the Id instead of the object
        //get the model they used to be in
        Schema.DescribeFieldResult F = Schema.SObjectType.Contact.fields.npo02__SystemHouseholdProcessor__c;
        List<Schema.PicklistEntry> P = F.getPicklistValues();

        for(Schema.PicklistEntry pe : P){
            if (pe.isDefaultValue()){
                if (pe.getValue() == HH_Households.ALL_PROCESSOR){
                    oldProcessor = HH_Households.ALL_PROCESSOR;
                } else if (pe.getValue() == HH_Households.ALL_INDIVIDUALS_PROCESSOR){
                    oldProcessor = HH_Households.ALL_INDIVIDUALS_PROCESSOR;
                } else if (pe.getValue() == HH_Households.NO_HOUSEHOLDS_PROCESSOR){
                    oldProcessor = HH_Households.NO_HOUSEHOLDS_PROCESSOR;
                }
                break;
            }
        }
        //set them up with their old setting in the new settings object
        if (oldProcessor == HH_Households.ALL_PROCESSOR){
            hs.npo02__Household_Rules__c = HH_Households.ALL_PROCESSOR;
        } else if (oldProcessor == HH_Households.ALL_INDIVIDUALS_PROCESSOR){
            hs.npo02__Household_Rules__c = HH_Households.ALL_INDIVIDUALS_PROCESSOR;
        } else if (oldProcessor == HH_Households.NO_HOUSEHOLDS_PROCESSOR){
            hs.npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR;
        } else {
            hs.npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR;
        }

        hs.npo02__Household_Member_Contact_Role__c = CAO_Constants.HH_MEMBER_CONTACT_ROLE;
        hs.npo02__Always_Rollup_to_Primary_Contact__c = false;
        hs.npo02__Enable_Opp_Rollup_Triggers__c = true;
        hs.npo02__Excluded_Account_Opp_Rectypes__c = null;
        hs.npo02__Excluded_Account_Opp_Types__c = null;
        hs.npo02__Excluded_Contact_Opp_Rectypes__c = null;
        hs.npo02__Excluded_Contact_Opp_Types__c = null;
        hs.npo02__Membership_Record_Types__c = null;
        hs.npo02__Rollup_N_Day_Value__c = 365;
        hs.npo02__Membership_Grace_Period__c = 30;
        hs.npo02__Advanced_Household_Naming__c = true;
        hs.npo02__Async_Household_Naming__c = false;
        hs.npo02__Schedule_Job_Limit__c = 25;
        hs.npo02__Household_OCR_Excluded_Recordtypes__c = null;
        hs.npo02__Household_Creation_Excluded_Recordtypes__c = null;
        hs.npo02__Enable_Soft_Credit_Rollups__c = true;
        hs.npo02__Soft_Credit_Roles__c = 'Matched Donor;Soft Credit;Household Member';
        hs.npsp__Matched_Donor_Role__c = 'Matched Donor';
        hs.npo02__Household_Contact_Roles_On__c = true;
        hs.npsp__Seasonal_Addresses_Batch_Size__c = 10;

        // new HH Account model overrides having HH objects
        if (contactsSettings != null && contactsSettings.npe01__Account_Processor__c == CAO_Constants.HH_ACCOUNT_PROCESSOR) {
            hs.npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR;
        }
    }

    public static void configAllocationsSettings(npsp__Allocations_Settings__c allosettings) {
        //disable allocations by default
        allosettings.npsp__Default_Allocations_Enabled__c = false;
        allosettings.npsp__Default__c = null;
        allosettings.npsp__Excluded_Opp_RecTypes__c = null;
        allosettings.npsp__Excluded_Opp_Types__c = null;
        allosettings.npsp__Payment_Allocations_Enabled__c = false;
        allosettings.npsp__Rollup_N_Day_Value__c = 365;
        allosettings.npsp__Use_Fiscal_Year_for_Rollups__c = false;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return npe01__Contacts_And_Orgs_Settings__c The configured settings.
    **/
    public static npe01__Contacts_And_Orgs_Settings__c getContactsSettingsForTests(npe01__Contacts_And_Orgs_Settings__c mySettings) {
        if(contactsSettings == null)
            contactsSettings = new npe01__Contacts_And_Orgs_Settings__c();

        //create our own based on what's passed in from the test
        contactsSettings.npe01__One_to_One_RecordTypeID__c = mySettings.npe01__One_to_One_RecordTypeID__c;
        contactsSettings.npe01__HH_Account_RecordTypeID__c = mySettings.npe01__HH_Account_RecordTypeID__c;
        contactsSettings.npe01__Account_Processor__c = mySettings.npe01__Account_Processor__c;
        contactsSettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c = mySettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c;
        contactsSettings.npe01__Opportunity_Contact_Role_Default_role__c = mySettings.npe01__Opportunity_Contact_Role_Default_role__c;
        contactsSettings.npsp__Contact_Role_for_Organizational_Opps__c = mySettings.npsp__Contact_Role_for_Organizational_Opps__c;
        contactsSettings.npe01__Disable_Account_Model_Trigger__c = mySettings.npe01__Disable_Account_Model_Trigger__c;
        contactsSettings.npe01__Payments_Enabled__c = mySettings.npe01__Payments_Enabled__c;
        contactsSettings.npsp__Opp_RecTypes_Excluded_for_Payments__c = mySettings.npsp__Opp_RecTypes_Excluded_for_Payments__c;
        contactsSettings.npsp__Opp_Types_Excluded_for_Payments__c = mySettings.npsp__Opp_Types_Excluded_for_Payments__c;
        contactsSettings.npsp__Automatic_Campaign_Member_Management__c = mySettings.npsp__Automatic_Campaign_Member_Management__c;
        contactsSettings.npsp__Campaign_Member_Responded_Status__c = mySettings.npsp__Campaign_Member_Responded_Status__c;
        contactsSettings.npsp__Campaign_Member_Non_Responded_Status__c = mySettings.npsp__Campaign_Member_Non_Responded_Status__c;
        contactsSettings.npsp__Organizational_Account_Addresses_Enabled__c = mySettings.npsp__Organizational_Account_Addresses_Enabled__c;
        contactsSettings.npsp__Simple_Address_Change_Treated_as_Update__c = mySettings.npsp__Simple_Address_Change_Treated_as_Update__c;
        contactsSettings.npsp__Household_Account_Addresses_Disabled__c = mySettings.npsp__Household_Account_Addresses_Disabled__c;
        contactsSettings.npsp__Payments_Auto_Close_Stage_Name__c = mySettings.npsp__Payments_Auto_Close_Stage_Name__c;
        contactsSettings.npsp__Honoree_Opportunity_Contact_Role__c = mySettings.npsp__Honoree_Opportunity_Contact_Role__c;
        contactsSettings.npsp__Notification_Recipient_Opp_Contact_Role__c = mySettings.npsp__Notification_Recipient_Opp_Contact_Role__c;
        contactsSettings.npsp__Enforce_Accounting_Data_Consistency__c = mySettings.npsp__Enforce_Accounting_Data_Consistency__c;
        orgContactsSettings = contactsSettings;
        return contactsSettings;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return npo02__Households_Settings__c The configured settings.
    **/
    public static npo02__Households_Settings__c getHouseholdsSettingsForTests(npo02__Households_Settings__c mySettings) {
        if(householdsSettings == null) {
            householdsSettings = new npo02__Households_Settings__c();
        }

        //create our own based on what's passed in from the test
        householdsSettings.npo02__Household_Rules__c = mySettings.npo02__Household_Rules__c;
        householdsSettings.npo02__Household_Contact_Roles_On__c = mySettings.npo02__Household_Contact_Roles_On__c;
        householdsSettings.npo02__Household_Member_Contact_Role__c = mySettings.npo02__Household_Member_Contact_Role__c;
        householdsSettings.npo02__Always_Rollup_to_Primary_Contact__c = mySettings.npo02__Always_Rollup_to_Primary_Contact__c;
        householdsSettings.npo02__Enable_Opp_Rollup_Triggers__c = mySettings.npo02__Enable_Opp_Rollup_Triggers__c;
        householdsSettings.npo02__Excluded_Account_Opp_Rectypes__c = mySettings.npo02__Excluded_Account_Opp_Rectypes__c;
        householdsSettings.npo02__Excluded_Account_Opp_Types__c = mySettings.npo02__Excluded_Account_Opp_Types__c;
        householdsSettings.npo02__Excluded_Contact_Opp_Rectypes__c = mySettings.npo02__Excluded_Contact_Opp_Rectypes__c;
        householdsSettings.npo02__Excluded_Contact_Opp_Types__c = mySettings.npo02__Excluded_Contact_Opp_Types__c;
        householdsSettings.npo02__Membership_Grace_Period__c = mySettings.npo02__Membership_Grace_Period__c;
        householdsSettings.npo02__Rollup_N_Day_Value__c = mySettings.npo02__Rollup_N_Day_Value__c;
        householdsSettings.npo02__Membership_Record_Types__c = mySettings.npo02__Membership_Record_Types__c;
        householdsSettings.npo02__Advanced_Household_Naming__c = mySettings.npo02__Advanced_Household_Naming__c;
        householdsSettings.npo02__Enable_Soft_Credit_Rollups__c = mySettings.npo02__Enable_Soft_Credit_Rollups__c;
        householdsSettings.npo02__Soft_Credit_Roles__c = mySettings.npo02__Soft_Credit_Roles__c;
        householdsSettings.npsp__Matched_Donor_Role__c = mySettings.npsp__Matched_Donor_Role__c;
        householdsSettings.npo02__Household_OCR_Excluded_Recordtypes__c = mySettings.npo02__Household_OCR_Excluded_Recordtypes__c;
        householdsSettings.npo02__Household_Creation_Excluded_Recordtypes__c = mySettings.npo02__Household_Creation_Excluded_Recordtypes__c;
        householdsSettings.npo02__Household_Mailing_List_ID__c = mySettings.npo02__Household_Mailing_List_ID__c;
        householdsSettings.npo02__Schedule_Job_Limit__c = 25;
        householdsSettings.npsp__Use_Dated_Conversion_Rates__c = mySettings.npsp__Use_Dated_Conversion_Rates__c;

        orgHouseholdsSettings = householdsSettings;

        // if the caller explicitly is testing Household objects, make sure we have HH Accounts turned off.
        if (householdsSettings != null && householdsSettings.npo02__Household_Rules__c != HH_Households.NO_HOUSEHOLDS_PROCESSOR) {
            if (contactsSettings != null && contactsSettings.npe01__Account_Processor__c == CAO_Constants.HH_ACCOUNT_PROCESSOR) {
                contactsSettings.npe01__Account_Processor__c = CAO_Constants.ONE_TO_ONE_PROCESSOR;
            }
        }
        return householdsSettings;
    }

    /*******************************************************************************************************
    * @description Creates instance of settings to use in tests. It does not insert it, but all other methods will see these settings
    * as the configured settings.
    * @parameter mySettings Settings instance with the values to set.
    * @return Allocations_Settings__c The configured settings.
    **/
    public static npsp__Allocations_Settings__c getAllocationsSettingsForTests(npsp__Allocations_Settings__c mySettings) {
        if (allocationsSettings == null)
            allocationsSettings = new npsp__Allocations_Settings__c();

        allocationsSettings.npsp__Default_Allocations_Enabled__c = mySettings.npsp__Default_Allocations_Enabled__c;
        allocationsSettings.npsp__Default__c = mySettings.npsp__Default__c;
        allocationsSettings.npsp__Excluded_Opp_RecTypes__c = mySettings.npsp__Excluded_Opp_RecTypes__c;
        allocationsSettings.npsp__Excluded_Opp_Types__c = mySettings.npsp__Excluded_Opp_Types__c;
        allocationsSettings.npsp__Payment_Allocations_Enabled__c = mySettings.npsp__Payment_Allocations_Enabled__c;
        allocationsSettings.npsp__Rollup_N_Day_Value__c = mySettings.npsp__Rollup_N_Day_Value__c;
        allocationsSettings.npsp__Use_Fiscal_Year_for_Rollups__c = mySettings.npsp__Use_Fiscal_Year_for_Rollups__c;
        orgAllocationsSettings = allocationsSettings;
        return allocationsSettings;
    }
}