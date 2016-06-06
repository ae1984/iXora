/* upay_import.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        29/08/2012 e.berdibekov
 * BASES
        BANK COMM
*/

{xmlParser.i}

def input parameter Doc as class UPayClass.
def output parameter p-errcode as integer no-undo init 0.
def output parameter p-errdes as char no-undo init ''.

def buffer bt-node for t-node.
def buffer bt1-node for t-node.
def buffer bt2-node for t-node.

def var v-parseErr as char no-undo.
def var Amount as deci.
def var Exp as int.
def var Cur as char.
def var PNameID as char.
def var PValue as char.

def var tmpStatus as integer init 0.

if not Doc:CopyDoc() then do:
 p-errcode = 1.
 p-errdes = "Документ не найден!".
 return.
end.

run parseFileXML(Doc:v-name,output v-parseErr).
if v-parseErr <> '' then do:
 p-errcode = 2.
 p-errdes = "Ошибка parseFileXML".
 return.
end.

unix silent value ("rm " + Doc:v-name).

/*Информация о переводе*/

 find first t-node where t-node.nodeName = 'ALTER_CONTROL' no-lock no-error.
if avail t-node then Doc:UIN = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'TRANSFER_STATUS' no-lock no-error.
if avail t-node then Doc:TransferStatus = integer(t-node.nodeValue). /* 10 - создан, 42 - на выдачу, 65 - аннулирован */


 find first t-node where t-node.nodeName = 'COMMISSUM' no-lock no-error.
if avail t-node then Doc:Comission = decimal(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'AMOUNT' no-lock no-error.
if avail t-node then Doc:PayAmount = decimal(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'COMMIS1' no-lock no-error.
if avail t-node then Doc:SenderComission = decimal(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'COMMIS3' no-lock no-error.
if avail t-node then Doc:ReceiverComission = decimal(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'TRANSFER_COMMENT' no-lock no-error.
if avail t-node then Doc:TransferMessage = cp-convert(t-node.nodeValue).


/*Информация получателя*/

 find first t-node where t-node.nodeName = 'REGIONTO' no-lock no-error.
if avail t-node then Doc:ToCountry =  Doc:GetISO3166(Doc:IdToAlpha(t-node.nodeValue)). /* Страна получения */

 find first t-node where t-node.nodeName = 'RECEIVER_FIRSTNAME' no-lock no-error.
if avail t-node then Doc:PayeeFname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'RECEIVER_LASTNAME' no-lock no-error.
if avail t-node then Doc:PayeeSname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'RECEIVER_MIDDLENAME' no-lock no-error.
if avail t-node then Doc:PayeeMname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'RECEIVER_TYPE' no-lock no-error.
if avail t-node then  do: if integer(t-node.nodeValue) > 0 then Doc:PayeeIsResident = 19. else Doc:PayeeIsResident = 29. end.


/*Документ*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCID' no-lock no-error.
if avail t-node then Doc:PayeeCType = Doc:DocType(t-node.nodeValue). /*Тип документа*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCNUMBER' no-lock no-error.
if avail t-node then Doc:PayeeCNumber = cp-convert(t-node.nodeValue).          /*Номер документа*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCSERIES' no-lock no-error.
if avail t-node then Doc:PayeeSerialNumber = cp-convert(t-node.nodeValue). /*Серия документа*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCWHOM' no-lock no-error.
if avail t-node then Doc:PayeeIssuer = cp-convert(t-node.nodeValue).  /*Орган выдачи документа*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCWHEN' no-lock no-error.
if avail t-node then Doc:PayeeIssueDate = t-node.nodeValue. /*Дата выдачи*/

/**/
 find first t-node where t-node.nodeName = 'RECEIVER_PHONE' no-lock no-error.
if avail t-node then Doc:PayeePhone = cp-convert(t-node.nodeValue). /*Телефон*/

 find first t-node where t-node.nodeName = 'RECEIVER_BIRTHDATE' no-lock no-error.
if avail t-node then Doc:PayeeBirthDate = t-node.nodeValue. /*Дата рождения*/

 find first t-node where t-node.nodeName = 'REAL_ADDRESS' no-lock no-error.
if avail t-node then Doc:PayeeAddress = cp-convert(t-node.nodeValue). /*Адрес*/


 find first t-node where t-node.nodeName = 'RECEIVER_INN' no-lock no-error.
if avail t-node then Doc:PayeeINN = cp-convert(t-node.nodeValue). /*ИИН*/

 find first t-node where t-node.nodeName = 'RECEIVER_KPP' no-lock no-error.
if avail t-node then Doc:PayeeKNP = cp-convert(t-node.nodeValue). /*КНП*/

 find first t-node where t-node.nodeName = 'RECEIVER_BANKNAME' no-lock no-error.
if avail t-node then Doc:PayeeMessage = cp-convert(t-node.nodeValue). /*Отделение банка*/
/*
 find first t-node where t-node.nodeName = 'RECEIVER_BANKACCOUNT' no-lock no-error.
if avail t-node then Doc:PayeeAccount = t-node.nodeValue. */ /*Счет*/


/*************************************************************************************************************/
/* Фактический получатель */

 find first t-node where t-node.nodeName = 'REAL_FIRSTNAME' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeFname = cp-convert(t-node.nodeValue). end.

 find first t-node where t-node.nodeName = 'REAL_LASTNAME' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeSname = cp-convert(t-node.nodeValue). end.

 find first t-node where t-node.nodeName = 'REAL_MIDDLENAME' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeMname = cp-convert(t-node.nodeValue). end.

 find first t-node where t-node.nodeName = 'REAL_TYPE' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then do: if integer(t-node.nodeValue) > 0 then Doc:PayeeIsResident = 19. else Doc:PayeeIsResident = 29. end. end.

 find first t-node where t-node.nodeName = 'REAL_DOCEXP' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "1899-12-30" then Doc:receiver_docexp = t-node.nodeValue. end. /*Срок действия*/

 find first t-node where t-node.nodeName = 'REAL_DOCID' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:PayeeCType = Doc:DocType(t-node.nodeValue). end. /*Тип документа*/

 find first t-node where t-node.nodeName = 'REAL_DOCNUMBER' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeCNumber = cp-convert(t-node.nodeValue). end.         /*Номер документа*/

 find first t-node where t-node.nodeName = 'REAL_DOCSERIES' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeSerialNumber = cp-convert(t-node.nodeValue). end. /*Серия документа*/

 find first t-node where t-node.nodeName = 'REAL_DOCWHOM' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeeIssuer = cp-convert(t-node.nodeValue). end. /*Орган выдачи документа*/

 find first t-node where t-node.nodeName = 'REAL_DOCWHEN' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "1899-12-30" then Doc:PayeeIssueDate = t-node.nodeValue. end. /*Дата выдачи*/


 find first t-node where t-node.nodeName = 'REAL_PHONE' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:PayeePhone = cp-convert(t-node.nodeValue). end. /*Телефон*/

 find first t-node where t-node.nodeName = 'REAL_BIRTHDATE' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "1899-12-30" then  Doc:PayeeBirthDate = t-node.nodeValue. end. /*Дата рождения*/


 find first t-node where t-node.nodeName = 'RECEIVER_REGIONID' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:ToCountry =  Doc:GetISO3166(Doc:IdToAlpha(t-node.nodeValue)). end.

 find first t-node where t-node.nodeName = 'REAL_REGIONID' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:ToCountry =  Doc:GetISO3166(Doc:IdToAlpha(t-node.nodeValue)). end.

 find first t-node where t-node.nodeName = 'REALAMOUNT' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:PayAmount = decimal(t-node.nodeValue). end.

 find first t-node where t-node.nodeName = 'REAL_PAIDAMOUNT' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:PaydAmount = decimal(t-node.nodeValue). end.


/*************************************************************************************************************/
/*Информация отправителя*/

 find first t-node where t-node.nodeName = 'FROM_COUNTRY' no-lock no-error.
if avail t-node then Doc:FromCountry = Doc:GetISO3166(Doc:IdToAlpha(t-node.nodeValue)). /* Страна отправления */

 find first t-node where t-node.nodeName = 'SENDER_FIRSTNAME' no-lock no-error.
if avail t-node then Doc:PayerFname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'SENDER_LASTNAME' no-lock no-error.
if avail t-node then Doc:PayerSname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'SENDER_MIDDLENAME' no-lock no-error.
if avail t-node then Doc:PayerMname = cp-convert(t-node.nodeValue).

 find first t-node where t-node.nodeName = 'SENDER_TYPE' no-lock no-error.
if avail t-node then do: if integer(t-node.nodeValue) > 0 then Doc:PayerIsResident = 19. else Doc:PayerIsResident = 29. end. /*Признак резидентности отправителя.1 - резидент, 0 - не резидент, Пусто - не указано*/



/*Документ*/

 find first t-node where t-node.nodeName = 'SENDER_DOCID' no-lock no-error.
if avail t-node then Doc:PayerCType = Doc:DocType(t-node.nodeValue). /*Тип документа*/

 find first t-node where t-node.nodeName = 'SENDER_DOCNUMBER' no-lock no-error.
if avail t-node then Doc:PayerCNumber = cp-convert(t-node.nodeValue).    /*Номер документа*/

 find first t-node where t-node.nodeName = 'SENDER_DOCSERIES' no-lock no-error.
if avail t-node then Doc:PayerSerialNumber = cp-convert(t-node.nodeValue).     /*Серия документа*/

 find first t-node where t-node.nodeName = 'SENDER_DOCWHOM' no-lock no-error.
if avail t-node then Doc:PayerIssuer = cp-convert(t-node.nodeValue).  /*Орган выдачи документа*/

 find first t-node where t-node.nodeName = 'SENDER_DOCWHEN' no-lock no-error.
if avail t-node then Doc:PayerIssueDate = t-node.nodeValue. /*Дата выдачи*/


/**/
 find first t-node where t-node.nodeName = 'SENDER_PHONE' no-lock no-error.
if avail t-node then Doc:PayerPhone = cp-convert(t-node.nodeValue).       /*Телефон*/

 find first t-node where t-node.nodeName = 'SENDER_BIRTHDATE' no-lock no-error.
if avail t-node then Doc:PayerBirthDate = t-node.nodeValue.       /*Дата рождения*/

 find first t-node where t-node.nodeName = 'SENDER_ADDRESS' no-lock no-error.
if avail t-node then Doc:PayerAddress = cp-convert(t-node.nodeValue).       /*Адрес*/


/***************************************************************/
/* поля по ТЗ-1313 */
 find first t-node where t-node.nodeName = 'CURRENCY_ID' no-lock no-error.
if avail t-node then Doc:PayCRC = Doc:GetCRCcode(Doc:IdToCurrency(t-node.nodeValue)). /*Валюта перевода*/

 find first t-node where t-node.nodeName = 'REALCURRENCY' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:PayCRC = Doc:GetCRCcode(Doc:IdToCurrency(t-node.nodeValue)). end. /*Валюта перевода*/

 find first t-node where t-node.nodeName = 'REAL_PAIDCURR' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" and t-node.nodeValue <> "0" then Doc:PaydCRC = Doc:GetCRCcode(Doc:IdToCurrency(t-node.nodeValue)). end. /*Валюта перевода*/

 find first t-node where t-node.nodeName = 'SENDER_PROFESSION' no-lock no-error.
if avail t-node then Doc:sender_proffession = cp-convert(t-node.nodeValue). /*РНН отправителя*/

 find first t-node where t-node.nodeName = 'REAL_PROFESSION' no-lock no-error.
if avail t-node then Doc:receiver_proffession = cp-convert(t-node.nodeValue). /*РНН получателя*/

 find first t-node where t-node.nodeName = 'SENDER_BIRTHPLACE' no-lock no-error.
if avail t-node then Doc:sender_birthPlace = cp-convert(t-node.nodeValue). /*Место рождения отправителя*/

 find first t-node where t-node.nodeName = 'REAL_BIRTHPLACE' no-lock no-error.
if avail t-node then Doc:receiver_birthPlace = cp-convert(t-node.nodeValue). /*Место рождения отправителя*/

 find first t-node where t-node.nodeName = 'SENDER_STATE' no-lock no-error.
if avail t-node then Doc:sender_state = cp-convert(t-node.nodeValue). /*Область отправителя*/

 find first t-node where t-node.nodeName = 'REAL_STATE' no-lock no-error.
if avail t-node then Doc:receiver_state = cp-convert(t-node.nodeValue). /*Область получателя*/

 find first t-node where t-node.nodeName = 'SENDER_CITY' no-lock no-error.
if avail t-node then Doc:sender_city = cp-convert(t-node.nodeValue). /*Город отправителя*/

 find first t-node where t-node.nodeName = 'REAL_CITY' no-lock no-error.
if avail t-node then Doc:receiver_city = cp-convert(t-node.nodeValue). /*Город получателя*/

 find first t-node where t-node.nodeName = 'SENDER_STREET' no-lock no-error.
if avail t-node then Doc:sender_street = cp-convert(t-node.nodeValue). /*Улица отправителя*/

 find first t-node where t-node.nodeName = 'REAL_STREET' no-lock no-error.
if avail t-node then Doc:receiver_street = cp-convert(t-node.nodeValue). /*Улица получателя*/

 find first t-node where t-node.nodeName = 'SENDER_HOUSE' no-lock no-error.
if avail t-node then Doc:sender_house = cp-convert(t-node.nodeValue). /*Дом отправителя*/

 find first t-node where t-node.nodeName = 'REAL_HOUSE' no-lock no-error.
if avail t-node then Doc:receiver_house = cp-convert(t-node.nodeValue). /*Дом получателя*/

 find first t-node where t-node.nodeName = 'SENDER_FLAT' no-lock no-error.
if avail t-node then Doc:sender_flat = cp-convert(t-node.nodeValue). /*Кв. отправителя*/

 find first t-node where t-node.nodeName = 'REAL_FLAT' no-lock no-error.
if avail t-node then Doc:receiver_flat = cp-convert(t-node.nodeValue). /*Кв. получателя*/

 find first t-node where t-node.nodeName = 'SENDER_ZIP' no-lock no-error.
if avail t-node then Doc:sender_zip = cp-convert(t-node.nodeValue). /*Индекс отправителя*/

 find first t-node where t-node.nodeName = 'REAL_ZIP' no-lock no-error.
if avail t-node then Doc:receiver_zip = cp-convert(t-node.nodeValue). /*Индекс получателя*/

 find first t-node where t-node.nodeName = 'RECEIVER_ACCOUNT' no-lock no-error.
if avail t-node then do: Doc:receiver_account = t-node.nodeValue. Doc:PayeeAccount = t-node.nodeValue. end. /*Счет получателя*/

 find first t-node where t-node.nodeName = 'SENDER_DOCEXP' no-lock no-error.
if avail t-node then Doc:sender_docexp = t-node.nodeValue. /*Срок действия*/

 find first t-node where t-node.nodeName = 'RECEIVER_DOCEXP' no-lock no-error.
if avail t-node then Doc:receiver_docexp = t-node.nodeValue. /*Срок действия*/

 find first t-node where t-node.nodeName = 'REAL_DOCEXP' no-lock no-error.
if avail t-node then do: if t-node.nodeValue <> ? and t-node.nodeValue <> "" then Doc:receiver_docexp = t-node.nodeValue. end. /*Срок действия*/

 find first t-node where t-node.nodeName = 'REAL_COUNTRYCODE' no-lock no-error.
if avail t-node then Doc:receiver_country = Doc:GetISO3166(Doc:CodeToAlpha(t-node.nodeValue)). /* Гражданство получателя */

 find first t-node where t-node.nodeName = 'SENDER_COUNTRYCODE' no-lock no-error.
if avail t-node then Doc:sender_country = Doc:GetISO3166(Doc:CodeToAlpha(t-node.nodeValue)). /* Гражданство отправителя */

if Doc:FromCountry <> 'KZ' then Doc:PayerIsResident = 29.

/* if not Doc:CheckDoc() then do: p-errcode = 25. p-errdes = "Неверный статус документа!". return. end. */

if p-errcode > 0 then p-errdes = "Ошибка обработки xml!".

