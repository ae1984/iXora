/* kb_mko.p
 * MODULE
        Формирование файла для загрузки в Кред бюро базы МКО
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * BASES
        BANK COMM
 * AUTHOR
        31/05/08 marinav
 * CHANGES
        04/02/2010 madiyar - перекомпиляция в связи с добавление поля в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/



{global.i}


def var v-ans as logi.


      v-ans = false.
      message skip " Выгрузить данные в ПКБ по МКО ... ?" skip(1) view-as alert-box buttons yes-no title "" update v-ans.
      if not v-ans then return.


define stream m-out.
output stream m-out to "kred.xml".
/*
put stream m-out unformatted '<?xml version="1.0" encoding="utf-8"?>' skip.
put stream m-out unformatted '<Records>' skip.
*/
put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
put stream m-out unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
put stream m-out unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
put stream m-out unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZv2.xsd">' skip.



def var v-count as int .
def var v-amount as deci.
def var v-com as deci.
def var v-class as char.
def var ourbank as char.


function date_str returns char (input v-date as date) .
   return (string(year(v-date)) + "-" + string(month(v-date),'99') + "-" + string(day(v-date),'99')).
end.


find first cmp no-lock no-error.

hide message no-pause.
message "Обрабатывается филиал  - " cmp.name .

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
ourbank = sysc.chval.

find first sysc where sysc.sysc = '1cb' exclusive-lock no-error.
if not avail sysc then return.


FOR EACH lon where  lon.rdt > 04/10/07 NO-LOCK use-index rdt :

    if lon.lon = 'lon' then next.
 /*
    find first  sub-cod where  sub-cod.sub = 'lon' and  sub-cod.acc =  lon.lon and  sub-cod.d-cod = 'lonkb' no-lock no-error.
    if  sub-cod.ccode ne '01' then next.
 */
    find first pkanketa where pkanketa.bank = ourbank and pkanketa.lon =  lon.lon no-lock no-error.
    if not avail pkanketa then next.

    if  lon.sts =  "C" then do:
       find last  lonres where  lonres.lon =  lon.lon use-index jdt no-lock no-error.
       if not avail  lonres then next.
       if  lonres.jdt < sysc.daval then next.
    end.

    find first  cif where  cif.cif =  lon.cif no-lock no-error.


    if  lon.rdt >= sysc.daval then put stream m-out unformatted '<Contract operation = "1">' skip.
                                   else put stream m-out unformatted '<Contract operation = "2">' skip.

    put stream m-out unformatted "<General>" skip.

    if substring(ourbank,4,2) = '16' then
         put stream m-out unformatted "<ContractCode>" + "00" + lon.lon + "</ContractCode>" skip.
         else
         put stream m-out unformatted "<ContractCode>" + substring(ourbank,4,2) + lon.lon + "</ContractCode>" skip.


    put stream m-out unformatted '<FundingType id = "2"/>' skip.
    put stream m-out unformatted '<CreditPurpose id = "6"/>' skip.

    if  lon.sts ne "C" then  put stream m-out unformatted  '<ContractPhase id = "4"/>' skip.
    else do:
          if  lonres.jdt >=  lon.duedt then put stream m-out unformatted  '<ContractPhase id = "5"/>' skip.
          if  lonres.jdt <  lon.duedt  then put stream m-out unformatted  '<ContractPhase id = "6"/>' skip.
    end.

    put stream m-out unformatted  '<ContractStatus id = "1"/>' skip.

    put stream m-out unformatted  "<StartDate>" date_str( lon.rdt) "</StartDate>" skip.
    put stream m-out unformatted  "<EndDate>" date_str( lon.duedt) "</EndDate>" skip.

    put stream m-out unformatted  "<Classification>" skip.
        find first  sub-cod where  sub-cod.sub = 'lon' and  sub-cod.acc =  lon.lon and  sub-cod.d-cod = 'lnsegm' no-lock no-error.
        if avail  sub-cod then do:
           if  lon.grp = 90 and  sub-cod.ccode = '03' then   v-class = "07".
           else  if  lon.grp = 92 and  sub-cod.ccode = '03' then   v-class = "08".
                 else  if  lon.grp = 90  then   v-class = "05".
                       else if  lon.grp = 92  then   v-class = "06".
        end.
    put stream m-out unformatted '<Text language="en-GB">' v-class '</Text>' skip.
    put stream m-out unformatted '<Text language="ru-RU">' v-class '</Text>' skip.
    put stream m-out unformatted '<Text language="kk-KZ">' v-class '</Text>' skip.
    put stream m-out unformatted "</Classification>" skip.

    put stream m-out unformatted  "<Collaterals>" skip.
    put stream m-out unformatted  '<Collateral typeId = "1">' skip.
    put stream m-out unformatted  '<Value currency="KZT" typeId = "3">0</Value>' skip.
    put stream m-out unformatted  "</Collateral>" skip.
    put stream m-out unformatted  "</Collaterals>" skip.

/************Заемщик************************************************************************************/

    put stream m-out unformatted  "<Subjects>" skip.
    put stream m-out unformatted  '<Subject roleId="1">' skip.
    put stream m-out unformatted  "<Entity>" skip.
    put stream m-out unformatted  "<Individual>" skip.
    put stream m-out unformatted  "<FirstName>" skip.
    put stream m-out unformatted  '<Text language="ru-RU">' entry(2,  cif.name, " " ) '</Text>' skip.
    put stream m-out unformatted  "</FirstName>" skip.
    put stream m-out unformatted  "<Surname>" skip.
    put stream m-out unformatted  '<Text language="ru-RU">' entry(1,  cif.name, " " ) '</Text>' skip.
    put stream m-out unformatted  "</Surname>" skip.
    put stream m-out unformatted  "<FathersName>" skip.
    if entry(3,  cif.name, ' ' ) <> '' then
       put stream m-out unformatted  '<Text language="ru-RU">' entry(3,  cif.name, " " ) '</Text>' skip.
    else
       put stream m-out unformatted  '<Text language="ru-RU"> Нет </Text>' skip.
    put stream m-out unformatted  "</FathersName>" skip.

    find first  sub-cod where  sub-cod.sub = 'cln' and  sub-cod.acc =  lon.cif and  sub-cod.d-cod = 'clnsex' no-lock no-error.
    if avail  sub-cod then do:
                         if  sub-cod.ccode = '01' then   put stream m-out unformatted  "<Gender>M</Gender>" skip.
                                                     else   put stream m-out unformatted  "<Gender>F</Gender>" skip.
                     end.
                     else run savelog( "kredbureau", "Отсутствует параметр clnsex ! Клиент - " +  lon.cif).

    find first  sub-cod where  sub-cod.sub = 'lon' and  sub-cod.acc =  lon.lon and  sub-cod.d-cod = 'lnsegm' no-lock no-error.
    if avail  sub-cod then do:
                         if  sub-cod.ccode = '03' then put stream m-out unformatted  '<Classification id = "2"/>' skip.
                                                     else put stream m-out unformatted  '<Classification id = "1"/>' skip.
                     end.
                     else run savelog( "kredbureau", "Отсутствует параметр lnsegm ! Клиент - " +  lon.cif).

    put stream m-out unformatted  '<Residency id = "1"/>' skip.
    put stream m-out unformatted  "<DateOfBirth>" date_str( cif.expdt) "</DateOfBirth>" skip.
    put stream m-out unformatted  '<Citizenship id = "110"/>' skip.

    put stream m-out unformatted  "<Identifications>" skip.
    put stream m-out unformatted  '<Identification typeId = "1" rank = "1">' skip.
    put stream m-out unformatted  "<Number>"  cif.jss "</Number>" skip.
    put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
    put stream m-out unformatted  "</Identification>" skip.

    put stream m-out unformatted  '<Identification typeId = "7" rank = "2">' skip.
    put stream m-out unformatted  "<Number>"  cif.pss "</Number>" skip.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and
                            pkanketh.kritcod = "dtpas" no-lock no-error.
    put stream m-out unformatted  "<RegistrationDate>" date_str(date(pkanketh.value1)) "</RegistrationDate>" skip.
    put stream m-out unformatted  "</Identification>" skip.
    put stream m-out unformatted  "</Identifications>" skip.


    put stream m-out unformatted  "<Addresses>" skip.

    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and
                      pkanketh.kritcod = "city1" no-lock no-error.
    find first  codfr where  codfr.codfr = 'pkcity0' and  codfr.code = pkanketh.value1 no-lock no-error.
    if avail  codfr then put stream m-out unformatted  '<Address typeId = "1" locationId = "'  codfr.name[2] '">' skip.
                       else put stream m-out unformatted  '<Address typeId = "1" locationId = "675">' skip.
    put stream m-out unformatted  "<StreetName>" skip.
    put stream m-out unformatted '<Text language="ru-RU">' trim( cif.addr[1]) + trim( cif.addr[2]) '</Text>' skip.
    put stream m-out unformatted  "</StreetName>" skip.
    put stream m-out unformatted  "</Address>" skip.

    if trim( cif.item) ne '' then do:
        put stream m-out unformatted  '<Address typeId = "3" locationId = "675">' skip.
        put stream m-out unformatted  "<StreetName>" skip.
        put stream m-out unformatted '<Text language="ru-RU">' trim( cif.item) '</Text>' skip.
        put stream m-out unformatted  "</StreetName>" skip.
        put stream m-out unformatted  "</Address>" skip.
    end.
    put stream m-out unformatted  "</Addresses>" skip.

    put stream m-out unformatted "<Communications>" skip.
    if  cif.tel <> "" or   cif.tlx <> "" or   cif.fax <> "" then do:
       if  cif.tel <> "" then  put stream m-out unformatted '<Communication typeId = "1">'  cif.tel '</Communication>'skip.
       if  cif.tlx <> "" then  put stream m-out unformatted '<Communication typeId = "2">'  cif.tlx '</Communication>'skip.
       if  cif.fax <> "" then  put stream m-out unformatted '<Communication typeId = "3">'  cif.fax '</Communication>'skip.
    end.
    put stream m-out unformatted "</Communications>" skip.

    put stream m-out unformatted "<Dependants>" skip.
    put stream m-out unformatted '<Dependant count = "0" typeId = "1"/>' skip.
    put stream m-out unformatted "</Dependants>" skip.

    put stream m-out unformatted  "</Individual>" skip.
    put stream m-out unformatted  "</Entity>" skip.
    put stream m-out unformatted  "</Subject>" skip.
    put stream m-out unformatted  "</Subjects>" skip.

    put stream m-out unformatted "</General>" skip.

/*********Кредит********************************************************************************************/
    put stream m-out unformatted "<Type>" skip.
    put stream m-out unformatted '<Instalment paymentMethodId = "1" paymentPeriodId = "2">' skip.
    put stream m-out unformatted '<TotalAmount currency = "KZT">' string( lon.opnamt) '</TotalAmount>' skip.

        v-com = 0.
        find first  tarifex2 where  tarifex2.aaa =  lon.aaa and  tarifex2.cif =  lon.cif and  tarifex2.str5 = "195" and  tarifex2.stat = 'r' no-lock no-error.
        if avail  tarifex2 then v-com =  tarifex2.ost.

           find first  lnsch where  lnsch.lnn =  lon.lon and  lnsch.f0 > 0 and  lnsch.stdat >= g-today no-lock no-error.
           if avail  lnsch then do:
              find first  lnsci where  lnsci.lni =  lon.lon and  lnsci.f0 > 0 and  lnsci.idat >= g-today no-lock no-error.
              if avail  lnsci then  do:
                      if  lnsch.stdat >  lnsci.idat then put stream m-out unformatted '<InstalmentAmount currency = "KZT">' string( lnsci.iv-sc) '</InstalmentAmount>' skip.
                      if  lnsch.stdat <  lnsci.idat then put stream m-out unformatted '<InstalmentAmount currency = "KZT">' string( lnsch.stval + v-com) '</InstalmentAmount>' skip.
                      if  lnsch.stdat =  lnsci.idat then put stream m-out unformatted '<InstalmentAmount currency = "KZT">' string( lnsci.iv-sc +  lnsch.stval + v-com) '</InstalmentAmount>' skip.
              end.
              else put stream m-out unformatted '<InstalmentAmount currency = "KZT">' string( lnsch.stval + v-com) '</InstalmentAmount>' skip.
           end.
           else put stream m-out unformatted '<InstalmentAmount currency = "KZT">0</InstalmentAmount>' skip.

    put stream m-out unformatted "<InstalmentCount>" string(pkanketa.srok) "</InstalmentCount>" skip.
    put stream m-out unformatted "<Records>" skip.
    put stream m-out unformatted '<Record accountingDate = "' date_str(g-today) '">' skip.

    v-count = 0. v-amount = 0.
    for each  lnsch where  lnsch.lnn =  lon.lon and  lnsch.f0 > 0 and  lnsch.stdat >= g-today no-lock .
        v-count = v-count + 1.
        v-amount = v-amount +  lnsch.stval.
    end.
    find first  londebt where  londebt.lon =  lon.lon no-lock no-error.
    if avail  londebt then do:
       v-count  = v-count + trunc( londebt.days_od / 30 + 1, 0).
       v-amount = v-amount +  londebt.od.
    end.
    put stream m-out unformatted "<OutstandingInstalmentCount>" string(v-count) "</OutstandingInstalmentCount>" skip.
    put stream m-out unformatted '<OutstandingAmount currency = "KZT">' string(v-amount) '</OutstandingAmount>' skip.

    v-count = 0. v-amount = 0.
    for each  lonres where  lonres.lon =  lon.lon and  lonres.lev = 7 and  lonres.dc = 'D' no-lock use-index jdt.
        v-count = v-count + 1.
        v-amount = v-amount +  lonres.amt.
    end.
    put stream m-out unformatted "<OverdueInstalmentCount>" string(v-count) "</OverdueInstalmentCount>" skip.
    put stream m-out unformatted '<OverdueAmount currency = "KZT">' string(v-amount) '</OverdueAmount>' skip.
    put stream m-out unformatted "<InterestRate>" string( lon.prem) "</InterestRate>" skip.

    put stream m-out unformatted "</Record>" skip.
    put stream m-out unformatted "</Records>" skip.
    put stream m-out unformatted "</Instalment>" skip.
    put stream m-out unformatted "</Type>" skip.

    put stream m-out unformatted "</Contract>" skip.


end.

    put stream m-out unformatted '</Records>' skip.
    output stream m-out close.
       unix silent cp kred.xml value("/data/log/kred_mko.xml").
       unix silent koi2utf kred.xml kredit.xml.

       unix silent value ("cb1pump.pl -zip -login=MBuser01 -password=MBuser01  -method=UploadZippedData2 -file2send=kredit.xml > /data/log/res.xml") .
       run mail('support@metrobank.kz', "MKO NK <abpk@metrobank.kz>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res.xml").


unix silent value("chmod 777 /data/log/kred_mko.xml; chmod 777 /data/log/res.xml").


find first sysc where sysc.sysc = '1cb' no-error.
if sysc.daval ne g-today then sysc.daval = g-today.

