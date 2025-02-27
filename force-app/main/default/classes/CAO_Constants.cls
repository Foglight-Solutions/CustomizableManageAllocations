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
* @date 2011 (1.x)
* @group Accounts
* @description Constants and helper methods used for common settings in npe01: account model, default contact role, etc.
*/
public with sharing class CAO_Constants {

    /*******************************************************************************************************
    * @description One-to-One value for system processor field
    */
    public static final String ONE_TO_ONE_PROCESSOR = 'One-to-One';

    /*******************************************************************************************************
    * @description One-to-One org type value
    */
    public static final String ONE_TO_ONE_ORGANIZATION_TYPE = 'One-to-One Individual';

    /*******************************************************************************************************
    * @description Individual Bucket value for system processor field
    */
    public static final String BUCKET_PROCESSOR = 'Individual';

    /*******************************************************************************************************
    * @description Individual Bucket org type value
    */
    public static final String BUCKET_ORGANIZATION_TYPE = 'Bucket Individual';

    /*******************************************************************************************************
    * @description Individual Bucket Account name
    */
    public static String BUCKET_ACCOUNT_NAME = 'Individual';

    /*******************************************************************************************************
    * @description Household Account value for system processor field
    */
    public static final String HH_ACCOUNT_PROCESSOR = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account org type value
    */
    public static final String HH_ACCOUNT_TYPE = 'Household Account';

    /*******************************************************************************************************
    * @description Household Account value for the standard Type field
    */
    public static final String HH_TYPE = 'Household';

    /*******************************************************************************************************
    * @description A contact's firstname to use in test code.
    */
    public static  String CONTACT_FIRSTNAME_FOR_TESTS = 'test';

    /*******************************************************************************************************
    * @description A contact's lastname to use in test code.
    */
    public static  String CONTACT_LASTNAME_FOR_TESTS = 'Contact_forTests';

    /*******************************************************************************************************
    * @description A contact's email to use in test code.
    */
    public static  String CONTACT_EMAIL_FOR_TESTS = 'junk@test.net';

    /*******************************************************************************************************
    * @description A contact's preferred email to use in test code.
    */
    public static  String CONTACT_PREFERRED_EMAIL_FOR_TESTS = 'Work';

    /*******************************************************************************************************
    * @description A contact's phone number to use in test code.
    */
    public static  String CONTACT_PHONE_FOR_TESTS = '206-777-8888';

    /*******************************************************************************************************
    * @description A contact's preferred phone to use in test code.
    */
    public static  String CONTACT_PREFERRED_PHONE_FOR_TESTS = 'Work';

    /*******************************************************************************************************
    * @description The name to use for the Individual Bucket Account in test code.
    */
    public static  String INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS = 'IndividualAccountNameForTests';

//    /*******************************************************************************************************
//    * @description The suffix to use in System.Assert for the household name
//    */
//    public static String HH_NAME_SUFFIX = ' ' + System.Label.npo02.DefaultHouseholdName;
//
//    /*******************************************************************************************************
//    * @description The name connector to use in System.Assert for the household name
//    */
//    public static String HH_NAME_CONNECTOR = ' ' + System.Label.npo02.HouseholdNameConnector + ' ';

    /*******************************************************************************************************
    * @description The api name of the "Donor" OCR role
    */
    public static final String OCR_DONOR_ROLE = 'Donor';

    /*******************************************************************************************************
    * @description The api name of the "Household Member" OCR role for Soft Credits
    */
    public static final String HH_MEMBER_CONTACT_ROLE = 'Household Member';

    /*******************************************************************************************************
    * @description The suffix to use in System.Assert for the household name
    */
    public static String HH_NAME_SUFFIX = ' ' + System.Label.npo02.DefaultHouseholdName;

}