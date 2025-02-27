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
* @description Tests for the Manage Allocations page.
*/
@isTest
private class ALLO_ManageAllocations_TEST {

    /*******************************************************************************************************
    * @description Setup of allocations settings.
    * @param alloset An instance of Allocations_Settings__c custom setting. Calling this method with a null
    * parameter uses default settings.
    * @return void Modifies settings, returns nothing.
    ********************************************************************************************************/
    private static void setupSettings (npsp__Allocations_Settings__c alloset) {
        //set running user to avoid dml issue
        System.runAs(new User(id = UserInfo.getUserId())){
            if (alloset!=null)
                UTIL_CustomSettingsFacade.getAllocationsSettingsForTests(alloset);
            else
                    UTIL_CustomSettingsFacade.getAllocationsSettingsForTests(new npsp__Allocations_Settings__c());

        }
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on an opportunity with no allocations. Adds then deletes a
    * row, then inserts an allocation and verifies the allocation was created properly.
    ********************************************************************************************************/
    static testMethod void testOpp() {
        setupSettings(null);

        Account acc = new Account(Name='foo');
        insert acc;
        Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.id, CloseDate=system.today(), StageName=UTIL_UnitTestData_TEST.getClosedWonStage());
        insert opp;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name='foo');
        insert gau;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(opp.Id);

        system.assertEquals(1,ctrl.listAllo.size(),'The list of allocations should have a single empty allocation.');
        system.assertEquals(null,ctrl.listAllo[0].id,'The allocation should have no Id.');
        system.assertEquals(opp.Id,ctrl.listAllo[0].npsp__Opportunity__c,'The allocation should be attributed to current opportunity.');

        ctrl.rowNumber = 0;
        ctrl.addRow();
        system.assertEquals(2,ctrl.listAllo.size(),'Adding a row increases the size of the allocation list.');

        ctrl.listAllo[0].npsp__Percent__c = 50;
        ctrl.listAllo[0].npsp__General_Accounting_Unit__c = gau.id;
        ctrl.rowNumber = 1;
        ctrl.delRow();
        Test.startTest();
        ctrl.saveClose();
        Test.stopTest();

        list<npsp__Allocation__c> queryAllo = [SELECT Id, npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Opportunity__c=:opp.id];
        system.assertEquals(1,queryAllo.size(),'The single allocation should be saved.');
        system.assertEquals(4,queryAllo[0].npsp__Amount__c,'The amount should be calculated based on the percent.');
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on a campaign with two allocations. Adds a new allocation,
    * deletes an existing one, and verifies the results.
    ********************************************************************************************************/
    @isTest static void testCam() {
        setupSettings(null);

        npsp__General_Accounting_Unit__c campaigngau = new npsp__General_Accounting_Unit__c(Name='foo');
        insert campaigngau;
        Campaign cam = new Campaign(Name='Foo', IsActive=true);
        insert cam;

        list<npsp__Allocation__c> alloForInsert = new list<npsp__Allocation__c>();
        npsp__Allocation__c percentAllo = new npsp__Allocation__c(npsp__Campaign__c=cam.id, npsp__Percent__c = 50, npsp__General_Accounting_Unit__c = campaigngau.id);
        alloForInsert.add(percentAllo);
        npsp__Allocation__c amountAllo = new npsp__Allocation__c(npsp__Campaign__c=cam.id, npsp__Amount__c = 4, npsp__General_Accounting_Unit__c = campaigngau.id);
        alloForInsert.add(amountAllo);
        insert alloForInsert;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(cam.Id);

        system.assertEquals(2,ctrl.listAllo.size(),'The list of allocations should have two current campaign allocations.');

        ctrl.addRow();
        system.assertEquals(3,ctrl.listAllo.size(),'Adding a row increases the size of the allocation list.');

        //delete the first allocation on the list
        ctrl.rowNumber = 0;
        ctrl.delRow();

        ctrl.listAllo[1].npsp__Amount__c = 5;
        ctrl.listAllo[1].npsp__General_Accounting_Unit__c = campaigngau.id;
        Test.startTest();
        ctrl.saveClose();
        Test.stopTest();

        list<npsp__Allocation__c> queryAllo = [SELECT Id, npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Campaign__c=:cam.id];
        system.assertEquals(2,queryAllo.size(),'2 allocations should be saved, one original allocation should be deleted.');
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on a recurring with two allocations. Adds a new allocation,
    * deletes an existing one, and verifies the results.
    ********************************************************************************************************/
    @isTest static void testRD() {
        setupSettings(null);

        Account acc = new Account(Name='foo');
        insert acc;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'foo');
        insert gau;
        npe03__Recurring_Donation__c rd = new TEST_RecurringDonationBuilder()
                .withInstallmentPeriodYearly()
                .withDateEstablished(Date.newInstance(1984,01,29))
                .withAccount(acc.Id)
                .withAmount(20)
                .withScheduleTypeMultiplyValue()
                .withOpenEndedStatusOpen()
                .build();
        insert rd;

        list<npsp__Allocation__c> alloForInsert = new list<npsp__Allocation__c>();
        npsp__Allocation__c percentAllo = new npsp__Allocation__c(npsp__Recurring_Donation__c = rd.id, npsp__Percent__c = 50, npsp__General_Accounting_Unit__c = gau.id);
        alloForInsert.add(percentAllo);
        npsp__Allocation__c amountAllo = new npsp__Allocation__c(npsp__Recurring_Donation__c = rd.id, npsp__Amount__c = 10, npsp__General_Accounting_Unit__c = gau.id);
        alloForInsert.add(amountAllo);
        insert alloForInsert;

        Integer oppCnt = [SELECT Count() FROM Opportunity WHERE npe03__Recurring_Donation__c = :rd.Id];
        system.assertNotEquals(0, oppCnt, 'There should be at least one installment Opportunity');
        system.assertEquals(oppCnt * 2, [SELECT Count() FROM npsp__Allocation__c WHERE npsp__Opportunity__r.npe03__Recurring_Donation__c = :rd.Id],
                'There should be two Allocations per Installment Opportunity');

        ALLO_ManageAllocations_CTRL ctrl = setUpController(rd.Id);

        system.assertEquals(2,ctrl.listAllo.size(),'The list of allocations should have two current campaign allocations.');

        ctrl.addRow();
        system.assertEquals(3,ctrl.listAllo.size(),'Adding a row increases the size of the allocation list.');

        //delete the first allocation on the list
        ctrl.rowNumber = 0;
        ctrl.delRow();

        ctrl.listAllo[1].npsp__Amount__c = 5;
        ctrl.listAllo[1].npsp__General_Accounting_Unit__c = gau.id;
        Test.startTest();
        ctrl.saveClose();
        Test.stopTest();

        list<npsp__Allocation__c> queryAllo = [SELECT Id, npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Recurring_Donation__c=:rd.id];
        system.assertEquals(2,queryAllo.size(),'2 allocations should be saved on the recurring donation; one original allocation should be deleted.');

        system.assertEquals(oppCnt * 2, [SELECT Count() FROM npsp__Allocation__c WHERE npsp__Opportunity__r.npe03__Recurring_Donation__c = :rd.Id],
                'There should still be two Allocations per Installment Opportunity');
    }

    /*********************************************************************************************************
    @description
        Test save rollback when an exception occurs
    verify:
        The transaction is completely rolled back and there is no partial commit
    **********************************************************************************************************/
    private static testMethod void testSaveRollsBackAllDmlsOnError() {
        setupSettings(null);

        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'gau');
        Campaign campaign = new Campaign(Name = 'TestCampaign', IsActive = true);
        insert new sObject[] { gau, campaign };

        npsp__Allocation__c[] allocations = new npsp__Allocation__c[]{
                new npsp__Allocation__c(npsp__Campaign__c = campaign.Id, npsp__Amount__c = 100, npsp__General_Accounting_Unit__c = gau.Id),
                new npsp__Allocation__c(npsp__Campaign__c = campaign.Id, npsp__Amount__c = 200, npsp__General_Accounting_Unit__c = gau.Id),
                new npsp__Allocation__c(npsp__Campaign__c = campaign.Id, npsp__Amount__c = 300, npsp__General_Accounting_Unit__c = gau.Id)
        };
        insert allocations;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(campaign.Id);

        System.assertEquals(allocations.size(), ctrl.listAllo.size(), 'Allocations in the controller should match existing records: ' + ctrl.listAllo);

        //delete two Allocations
        ctrl.rowNumber = 0;
        ctrl.delRow();
        ctrl.delRow();
        System.assertEquals(1, ctrl.listAllo.size(), 'Two Allocations should be deleted: ' + ctrl.listAllo);

        //update an Allocation
        ctrl.listAllo[0].npsp__Amount__c = 1000;

        //add a new Allocation
        ctrl.rowNumber = 1;
        ctrl.addRow();
        ctrl.listAllo[1].npsp__Percent__c = 200; //cause the Allocation insert to fail
        ctrl.listAllo[1].npsp__General_Accounting_Unit__c = gau.id;

        Test.startTest();
        PageReference retPage = ctrl.saveClose();
        Test.stopTest();

        System.assertEquals(null, retPage, 'The return page on the error should be null');

        Map<Id, npsp__Allocation__c> actualAllocationsById = new Map<Id, npsp__Allocation__c>([SELECT npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Campaign__c = :campaign.id]);
        System.assertEquals(allocations.size(), actualAllocationsById.size(), 'The Allocations should be unchanged: ' + actualAllocationsById.values());

        for (npsp__Allocation__c alloc : allocations) {
            npsp__Allocation__c actual = actualAllocationsById.get(alloc.Id);

            System.assertEquals(alloc.npsp__Amount__c, actual.npsp__Amount__c, 'Allocation Amount should be unchanged: ' + actual);
        }
    }

    /*********************************************************************************************************
    @description
        Test re-saving of Allocations after an error is fixed
    verify:
        Records are saved as expected
    **********************************************************************************************************/
    private static testMethod void testResaveSucceedsWhenErrorIsFixed() {
        setupSettings(null);

        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'gau');
        Campaign campaign = new Campaign(Name = 'TestCampaign', IsActive = true);
        insert new sObject[] { gau, campaign };

        npsp__Allocation__c[] allocations = new npsp__Allocation__c[]{
                new npsp__Allocation__c(npsp__Campaign__c = campaign.Id, npsp__Amount__c = 100, npsp__General_Accounting_Unit__c = gau.Id)
        };
        insert allocations;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(campaign.Id);

        System.assertEquals(allocations.size(), ctrl.listAllo.size(), 'Allocations in the controller should match existing records: ' + ctrl.listAllo);

        ctrl.listAllo[0].npsp__Amount__c = 1000;

        ctrl.rowNumber = 0;
        ctrl.addRow();
        ctrl.listAllo[1].npsp__Amount__c = 2000;
        ctrl.listAllo[1].npsp__General_Accounting_Unit__c = gau.id;

        ctrl.rowNumber = 1;
        ctrl.addRow();
        ctrl.listAllo[2].npsp__Percent__c = 200; //cause the Allocation insert to fail
        ctrl.listAllo[2].npsp__General_Accounting_Unit__c = gau.id;

        PageReference retPage = ctrl.saveClose();
        System.assertEquals(null, retPage, 'The return page on the error should be null');

        Map<Id, npsp__Allocation__c> actualAllocationsById = new Map<Id, npsp__Allocation__c>([SELECT npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Campaign__c = :campaign.id]);
        System.assertEquals(allocations.size(), actualAllocationsById.size(), 'The Allocations should be unchanged: ' + actualAllocationsById.values());

        //fix the error
        ctrl.listAllo[2].npsp__Percent__c = 20;

        Test.startTest();
        retPage = ctrl.saveClose();
        Test.stopTest();

        System.assert(ctrl.redirect, 'The page redirect should be set to true. Page messages: ' + ApexPages.getMessages());

        actualAllocationsById = new Map<Id, npsp__Allocation__c>([SELECT npsp__Percent__c, npsp__Amount__c FROM npsp__Allocation__c WHERE npsp__Campaign__c = :campaign.id]);
        System.assertEquals(3, actualAllocationsById.size(), 'New Allocations should be created: ' + actualAllocationsById.values());
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on a general allocation and verifies an
    * error is thrown when the page action to getPageLoadValidationmessages is called.
    ********************************************************************************************************/
    @isTest
    private static void testUnsupportedObject() {
        setupSettings(null);

        Account acc = new Account(Name='foo');
        insert acc;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'foo');
        insert gau;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(gau.Id);
        ctrl.getPageLoadValidationMessages();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorFound = false;
        for (Apexpages.Message msg : msgs){
            if (msg.getDetail().contains('The Manage Allocations button is only supported from a Campaign, Opportunity, Payment or Recurring Donation record.')) errorFound = true;
        }
        System.assert(errorFound);
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on an opportunity and verifies an
    * error is not thrown when the page action to getPageLoadValidationmessages is called.
    ********************************************************************************************************/
    @isTest
    private static void testSupportedObject() {
        setupSettings(null);

        Account acc = new Account(Name='foo');
        insert acc;
        Opportunity opp = new Opportunity(Name='foo', Amount = 8, AccountID=acc.id, CloseDate=system.today(), StageName= UTIL_UnitTestData_TEST.getClosedWonStage());
        insert opp;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'foo');
        insert gau;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(opp.Id);
        ctrl.getPageLoadValidationMessages();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorFound = false;
        for (Apexpages.Message msg : msgs){
            if (msg.getDetail().contains('The Manage Allocations button is only supported from a Campaign, Opportunity, Payment or Recurring Donation record.')) errorFound = true;
        }
        System.assert(!errorFound);
    }

    /*******************************************************************************************************
    * @description Runs manage allocations page on an opportunity with no amount and verifies an
    * error is thrown when the page action to getPageLoadValidationmessages is called.
    ********************************************************************************************************/
    @isTest
    private static void testOppNoAmount() {
        setupSettings(null);

        Account acc = new Account(Name='foo');
        insert acc;
        Opportunity opp = new Opportunity(Name='foo', AccountID=acc.id, CloseDate=system.today(), StageName= UTIL_UnitTestData_TEST.getClosedWonStage());
        insert opp;
        npsp__General_Accounting_Unit__c gau = new npsp__General_Accounting_Unit__c(Name = 'foo');
        insert gau;

        ALLO_ManageAllocations_CTRL ctrl = setUpController(opp.Id);
        ctrl.getPageLoadValidationMessages();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean errorFound = false;
        for (Apexpages.Message msg : msgs){
            if (msg.getDetail().contains(Label.npsp.alloCantAllocateNothing)) errorFound = true;
        }
        System.assert(errorFound);
    }

    /**
     * @description getCurrencySymbol() should return the appropriate currency
     * symbol as returned by UTIL_Currency
     */
    @isTest
    private static void testGetCurrencySymbolCallsUtilCurrency() {

        Test.startTest();

        UTIL_Currency_TEST.UtilCurrencyMock mock = new UTIL_Currency_TEST.UtilCurrencyMock();
        mock.getCurrencySymbolReturn = 'FOO';
        UTIL_Currency.instance = mock;

        ALLO_ManageAllocations_CTRL controller = new ALLO_ManageAllocations_CTRL();
        controller.parentCurrencyCode = 'FOO';
        controller.parentId = UTIL_UnitTestData_TEST.MOCK_ACCOUNT_ID;

        System.assertEquals(
                'FOO',
                controller.getCurrencySymbol()
        );
    }

    /**
     * @description getCurrencySymbol() should returned a cached currency
     * symbol, if it has been set
     */
    @isTest
    private static void testGetCurrencySymbolReturnsCachedSymbol() {
        ALLO_ManageAllocations_CTRL controller = new ALLO_ManageAllocations_CTRL();
        controller.currencySymbol = 'FOO';

        System.assertEquals(
                'FOO',
                controller.getCurrencySymbol()
        );
    }

    /** @description test the methods to retreive the currency separator characters */
    @isTest
    private static void testGetSeparators() {
        ALLO_ManageAllocations_CTRL controller = new ALLO_ManageAllocations_CTRL();
        system.AssertNotEquals(null, controller.getDecimalSeparator());
        system.AssertNotEquals(null, controller.getThousandsSeparator());
    }

    // Helpers
    ///////////

    /**
     * @description Creates the Manage Allocations controller
     * @param Id An RD/Campaign/Opportunity Id
     * @return ALLO_ManageAllocations_CTRL The controller
     */
    private static ALLO_ManageAllocations_CTRL setUpController(Id sobjId) {
        Test.setCurrentPage(Page.ManageAllocations);
        ApexPages.currentPage().getParameters().put('id', sobjId);

        return new ALLO_ManageAllocations_CTRL(
                new ApexPages.StandardSetController(new List<npsp__Allocation__c>())
        );
    }
}