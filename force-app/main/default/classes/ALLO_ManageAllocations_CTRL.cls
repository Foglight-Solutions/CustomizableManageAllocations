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
* @group Allocations
* @group-content ../../ApexDocContent/Allocations.htm
* @description Controller for the Manage Allocations page.
*/
public with sharing class ALLO_ManageAllocations_CTRL {

    /** @description The current list of allocations we're managing, as displayed on the page.*/
    public list<npsp__Allocation__c> listAllo {get;set;}
    /** @description If defaults are enabled, the default allocation is here, and not in listAllo. */
    public npsp__Allocation__c defaultAllo {get;set;}
    /** @description The number of allocations in listAllo. */
    public integer listAlloSize {
        get{
            return listAllo.size();
        }
        set;
    }

    public List<Schema.FieldSetMember> fsmlColumns {get; set;}


    /** @description The set of allowed object types this page should be used with */
    private Set<sObjectType> sObjTypesAllowed = new Set<sObjectType> {
            Opportunity.sObjectType,
            Campaign.sObjectType,
            npe03__Recurring_Donation__c.sObjectType,
            npe01__OppPayment__c.sObjectType
    };
    /** @description The sObjectType of the record the button was called from */
    private sObjectType sObjType;
    /** @description List of allocations to delete when the user clicks Save.*/
    public list<npsp__Allocation__c> listAlloForDelete = new list<npsp__Allocation__c>();
    /** @description after successful save set to true to redirect page */
    public Boolean redirect {get; set;}
    /** @description The id of the parent object; Opportunity, Campaign, or Recurring Donation.*/
    public id parentId {get;set;}
    /** @description The parent opportunity, if we're dealing with opportunity allocations.*/
    public Opportunity opp {get;set;}
    /** @description The parent payment, if we're dealing with payment allocations.*/
    public npe01__OppPayment__c payment {get;set;}
    /** @description The parent campaign, if we're dealing with campaign allocations.*/
    public Campaign cam {get;set;}
    /** @description The parent recurring donation, if we're dealing with recurring donation allocations.*/
    public npe03__Recurring_Donation__c rd {get;set;}
    /** @description The amount of the parent opportunity, if these are opportunity allocations.*/
    public decimal parentAmount {get;set;}
    /** @description The allocations settings object. */
    public npsp__Allocations_Settings__c settings {
        get {
            if (settings==null) {
                settings = UTIL_CustomSettingsFacade.getAllocationsSettings();
            }
            return settings;
        }
        set;
    }

    /** @description The page title based on which type of allocation we're using. */
    public string pageTitle {get;set;}
    /** @description The name of the object we're adding allocations to. */
    public string objectName {get;set;}
    /** @description The key prefix for the object, for navigation. */
    public string keyPrefix {get;set;}
    /** @description The API name of the object. */
    public string objectAPIName {get;set;}
    /** @description The API name of the object. */
    public string objectLabelPlural {get;set;}

    /** @description Row number sent back by page for add and delete row methods.*/
    public integer rowNumber {get;set;}

    /**
     * @description The currency symbol or ISO code of the related record or
     * org default
     */
    @TestVisible
    private String currencySymbol;

    /**
     * @description Query of the Parent Records CurrencyIsoCode value to use when retrieving the currency symbol.
     */
    @TestVisible
    private String parentCurrencyCode;


    /** @description Constructor queries for the parent object and the allocations, and fills out attributes.*/
    public ALLO_ManageAllocations_CTRL(ApexPages.StandardSetController ssc) {

        fsmlColumns = FieldSetService.createService().getFieldSetMembers('ManageAllocationsTableFields', 'npsp__Allocation__c');
        parentId = ApexPages.currentPage().getParameters().get('id');
        sObjType = parentId.getSObjectType();
        parentAmount = 0;

        String soql = 'SELECT Id, Name ';
        if (UserInfo.isMultiCurrencyOrganization()) {
            soql += ', CurrencyIsoCode ';
        }
        if (parentId.getSObjectType() == Opportunity.sObjectType) {
            soql += ', Amount FROM Opportunity WHERE Id = :parentId LIMIT 1';
            opp = database.query(soql);

            //pageTitle = Label.npsp.alloManageOppAllocations;
            pageTitle = 'Manage Payment Allocations';

            objectName = opp.Name;

            populateObjectParameters(Opportunity.sObjectType);

            //Opportunities have parent amounts and enforce being below this amount
            if (opp.Amount!=null) {
                parentAmount = opp.Amount;
            }

            if (UserInfo.isMultiCurrencyOrganization()) {
                this.parentCurrencyCode = (String)opp.get('CurrencyIsoCode');
            }
            if (parentAmount==0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.npsp.alloCantAllocateNothing));
            }
        } else if (parentId.getSObjectType() == Campaign.sObjectType) {
            soql += ' FROM Campaign WHERE Id = :parentId LIMIT 1';
            cam = database.query(soql);

            pageTitle = Label.npsp.alloManageCampaignAllocations;
            objectName = cam.Name;
            if (UserInfo.isMultiCurrencyOrganization()) {
                this.parentCurrencyCode = (String)cam.get('CurrencyIsoCode');
            }

            populateObjectParameters(Campaign.sObjectType);

        } else if (parentId.getSObjectType() == npe03__Recurring_Donation__c.sObjectType) {
            soql += ' FROM npe03__Recurring_Donation__c WHERE Id = :parentId LIMIT 1';
            rd = database.query(soql);

            pageTitle = Label.npsp.alloManageRecurringDonationAllocations;
            objectName = rd.Name;
            if (UserInfo.isMultiCurrencyOrganization()) {
                this.parentCurrencyCode = (String)rd.get('CurrencyIsoCode');
            }

            populateObjectParameters(npe03__Recurring_Donation__c.sObjectType);
        } else if (parentId.getSObjectType() == npe01__OppPayment__c.sObjectType) {
            soql += ', npe01__Payment_Amount__c FROM npe01__OppPayment__c WHERE Id = :parentId LIMIT 1';
            payment = database.query(soql);

            //pageTitle = Label.npsp.alloManagePaymentAllocations;
            objectName = payment.Name;
            if (UserInfo.isMultiCurrencyOrganization()) {
                this.parentCurrencyCode = (String)payment.get('CurrencyIsoCode');
            }

            populateObjectParameters(npe01__OppPayment__c.sObjectType);

            if (payment.npe01__Payment_Amount__c!=null) {
                parentAmount = payment.npe01__Payment_Amount__c;
            }
            if (parentAmount==0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, Label.npsp.alloCantAllocateNothing));
            }
        }

        defaultAllo = new npsp__Allocation__c();

        String queryString = 'SELECT ' + getQueryFields(getBaseAllocationFields(), fsmlColumns, false) +
                             'FROM npsp__Allocation__c ' +
                             'WHERE npsp__Opportunity__c = :parentId ' +
                             'OR npsp__Campaign__c = :parentId ' +
                             'OR npsp__Recurring_Donation__c = :parentId ' +
                             'OR npsp__Payment__c = :parentId ';

        listAllo = (List<npsp__Allocation__c>)Database.query(queryString);

        //find default allocation if enabled, remove from list
        if (settings.npsp__Default_Allocations_Enabled__c && (opp!=null || payment!=null)) {
            for (integer i=0; i<listAllo.size(); i++) {
                if (listAllo[i].npsp__General_Accounting_Unit__c == settings.npsp__Default__c) {
                    defaultAllo = listAllo[i];
                    listAllo.remove(i);
                    break;
                }
            }
        }

        if (listAllo.isEmpty())
            addRow();

    }

    /**
     * @description Private default constructor
     */
    @TestVisible
    private ALLO_ManageAllocations_CTRL() {}

    /** @description Adds an empty row to the bottom of the list and refreshes the page.*/
    private void populateObjectParameters(Schema.sObjectType st) {
        DescribeSObjectResult describe = st.getDescribe();
        keyPrefix = describe.getKeyPrefix();
        objectAPIName = describe.getName();
        objectLabelPlural = describe.getLabelPlural();
    }

    /*******************************************************************************************************
    * @description Verify data conditions and add any necessary page messages that need to be rendered on load.
    */
    public void getPageLoadValidationMessages() {
        if (parentAmount == 0 && sObjType == Opportunity.sObjectType) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.npsp.alloCantAllocateNothing));
        } else if (!getIsSupportedObject()) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.npsp.alloObjectUnsupported));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The Manage Allocations button is only supported from a Campaign, Opportunity, Payment or Recurring Donation record.'));
        }
    }

    /*******************************************************************************************************
    * @description Verify the parent object is a supported sObject type for this page
    */
    public boolean getIsSupportedObject() {
        return sObjTypesAllowed.contains(sObjType);
    }

    /**
     * @description Return the currency symbol appropriate for the current
     * user/org/record.  If the org is multi currency enabled, it will use the
     * currency iso code from the related record.  If the org is not multi
     * currency enabled, it will return the symbol for the currency of the org,
     * or the currency iso code if no symbol is known.
     *
     * @return String A currency symbol or currency ISO code
     */
    public String getCurrencySymbol() {
        if (currencySymbol == null && parentCurrencyCode != null) {
            currencySymbol = UTIL_Currency.getInstance().getCurrencySymbol(this.parentCurrencyCode);
        }
        return currencySymbol;
    }

    /** @description Adds an empty row to the bottom of the list and refreshes the page.*/
    public pageReference addRow() {
        npsp__Allocation__c allo = new npsp__Allocation__c();

        if (opp!=null)
            allo.npsp__Opportunity__c = parentId;
        else if (cam!=null)
            allo.npsp__Campaign__c = parentId;
        else if (rd!=null)
            allo.npsp__Recurring_Donation__c = parentId;
        else if (payment!=null)
            allo.npsp__Payment__c = parentId;

        // always add to last row
        listAllo.add(allo);

        return null;
    }

    /** @description Removes a row from the page, and adds to the list for deletion once the user saves.*/
    public pageReference delRow() {
        Boolean hasId = listAllo[rowNumber].id != null;

        //add to deletion list if the allocation has an id
        if (hasId) {
            if (!isDeletable()) {
                addDelExceptionMessage();
                return null;
            }
            listAlloForDelete.add(listAllo[rowNumber]);
        }
        listAllo.remove(rowNumber);

        return null;
    }

    /** @description Saves changes and returns user to parent object detail page.*/
    public pageReference saveClose() {
        list<npsp__Allocation__c> listAlloForInsert = new list<npsp__Allocation__c>();
        list<npsp__Allocation__c> listAlloForUpdate = new list<npsp__Allocation__c>();

        //split into insert and update cases so we can reset recursion flags for each operation
        for (npsp__Allocation__c allo : listAllo) {
            if (allo.id != null) listAlloForUpdate.add(allo);
            else listAlloForInsert.add(allo);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            if (!listAlloForDelete.isEmpty()) {
                //TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.flag.ALLOC, false);
                delete listAlloForDelete;

                //allow user to delete all GAUs and save with one empty GAU
                if (listAllo.size()==1 && listAllo[0].npsp__General_Accounting_Unit__c==null && listAllo[0].npsp__Amount__c==null && listAllo[0].npsp__Percent__c==null)
                    redirect = true;
            }
            if (!listAlloForUpdate.isEmpty()) {
                //TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.flag.ALLOC, false);
                update listAlloForUpdate;
            }
            if (!listAlloForInsert.isEmpty()) {
                //TDTM_ProcessControl.setRecursionFlag(TDTM_ProcessControl.flag.ALLOC, false);
                insert listAlloForInsert;
            }

            redirect = true;
        } catch (Exception e) {
            Database.rollback(sp);

            ApexPages.addMessages(e);
        }
        return null;
    }

    /** @description Discards all changes and returns user to parent object detail page.*/
    public pageReference cancel() {
        pageReference source = new pageReference('/' + parentId);
        return source;
    }

    /** @description Returns the decimal separator character in use for the Users current Locale setting */
    public String getDecimalSeparator() {
        return (1.5).format().subString(1,2);
    }

    /** @description Returns the thousands separator character in use for the Users current Locale setting */
    public String getThousandsSeparator() {
        return (1000).format().subString(1,2);
    }

    private Boolean isDeletable() {
        return UTIL_Describe.getObjectDescribe(('npsp__Allocation__c')).isDeletable();
    }

    private void addDelExceptionMessage() {
        ApexPages.addMessage(
                new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        String.format(
                                'You don\'\'t have the permissions required to delete {0} records.',
                                new String[]{UTIL_Describe.getObjectLabel(('npsp__Allocation__c'))})));
    }


    private static Set<String> getBaseAllocationFields() {

        Set<String> fields = new Set<String> {
            'Id',
            'Name',
            'npsp__Amount__c',
            'npsp__Percent__c',
            'npsp__General_Accounting_Unit__c'
        };

        return fields;
    }

    private static String getQueryFields(Set<String> baseFields, List<Schema.FieldSetMember> fieldSetMembers, Boolean addTrailingComma) {
        String queryString = '';
        Set<String> allFields = new Set<String>();
        allFields.addAll(baseFields);

        if(fieldSetMembers != null) {
            for(Schema.FieldSetMember fsm : fieldSetMembers) {
                allFields.add(fsm.getFieldPath());

                // add lookup object Name field
                if(!Test.isRunningTest()) {
                    if(fsm.getSObjectField().getDescribe().getReferenceTo().size() > 0) {
                        allFields.add(fsm.getFieldPath().replace('__c', '__r').replace('Id', '') + '.Name');
                    }
                }
            }
        }

        if(!allFields.isEmpty()) {
            queryString = String.join(new List<String>(allFields), ', ');
            queryString += addTrailingComma ? ', ' : ' ';
        }
        return queryString;
    }

}