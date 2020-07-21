/*
    Copyright (c) 2018, Salesforce.org
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
* @date 2018
* @group API
* @group-content ../../ApexDocContent/API.htm
* @description
*/
@istest(IsParallel=True)
private class RD2_Constants_TEST {

    static testMethod void test_rd2_constants() {
        System.AssertEquals(RD2_Constants.INSTALLMENT_PERIOD_YEARLY,RD2_Constants.INSTALLMENT_PERIOD_YEARLY);
        System.AssertEquals(RD2_Constants.INSTALLMENT_PERIOD_MONTHLY,RD2_Constants.INSTALLMENT_PERIOD_MONTHLY);
        System.AssertEquals(RD2_Constants.INSTALLMENT_PERIOD_WEEKLY,RD2_Constants.INSTALLMENT_PERIOD_WEEKLY);
        System.AssertEquals(RD2_Constants.INSTALLMENT_PERIOD_FIRST_AND_FIFTEENTH,RD2_Constants.INSTALLMENT_PERIOD_FIRST_AND_FIFTEENTH);
        System.AssertEquals(RD2_Constants.INSTALLMENT_PERIOD_DAILY,RD2_Constants.INSTALLMENT_PERIOD_DAILY);
        System.AssertEquals(RD2_Constants.DAY_OF_MONTH_FIRST,RD2_Constants.DAY_OF_MONTH_FIRST);
        System.AssertEquals(RD2_Constants.DAY_OF_MONTH_FIFTEENTH,RD2_Constants.DAY_OF_MONTH_FIFTEENTH);
        System.AssertEquals(RD2_Constants.DAY_OF_MONTH_LAST_DAY,RD2_Constants.DAY_OF_MONTH_LAST_DAY);
        System.AssertEquals(RD2_Constants.STATUS_ACTIVE,RD2_Constants.STATUS_ACTIVE);
        System.AssertEquals(RD2_Constants.STATUS_LAPSED,RD2_Constants.STATUS_LAPSED);
        System.AssertEquals(RD2_Constants.STATUS_CLOSED,RD2_Constants.STATUS_CLOSED);
        System.AssertEquals(RD2_Constants.RECURRING_TYPE_OPEN,RD2_Constants.RECURRING_TYPE_OPEN);
        System.AssertEquals(RD2_Constants.RECURRING_TYPE_FIXED,RD2_Constants.RECURRING_TYPE_FIXED);
        System.AssertEquals(RD2_Constants.FIXED_TYPE_CLOSED_REASON,RD2_Constants.FIXED_TYPE_CLOSED_REASON);
        System.AssertEquals(RD2_Constants.allInstallmentPeriods,RD2_Constants.allInstallmentPeriods);
        System.AssertEquals(RD2_Constants.DEFAULT_INSTALLMENT_FREQUENCY,RD2_Constants.DEFAULT_INSTALLMENT_FREQUENCY);
        System.AssertEquals(RD2_Constants.DEFAULT_NEXT_DONATION_DATE_MATCH_RANGE_DAYS,RD2_Constants.DEFAULT_NEXT_DONATION_DATE_MATCH_RANGE_DAYS);
    }
}