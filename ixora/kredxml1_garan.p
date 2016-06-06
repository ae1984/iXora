/* kredxml1_garan.p
 * MODULE
        Формирование файла ежедневной выгрузки по гарантиям в Кред бюро
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
        BANK COMM TXB
 * AUTHOR
        21/05/2010 galina
 * CHANGES
        21/07/2011 madiyar - рассылка результата отработки и лога ошибок только на группу fcb@metrocombank.kz
        02/09/2013 galina - ТЗ1918 перекомпиляция
*/

define shared var g-today  as date.
define shared stream m-out.
define shared var v-paket as int.
define shared var v-dogcount as int.
define shared var v-sendmail as int.

def input parameter v-bank as char.

def var v-count as int .
def var v-amount as deci.
def var v-ovcount as int .
def var v-ovamount as deci.
def var v-com as deci.
def var v-class as char.
def var v-find0 as char.

def var v-res as deci.
def var i as integer.
def var k as integer.
def var v-dterror as logi.
def temp-table t-cred
 field ctcode as char
 field fundingtype as char
 field crpurpose as char
 field ctphase as char
 field ctstatus as char
 field stdate as date
 field edate as date
 field class as char
 field colaterall as char
 field colatcrc as char
 field colatamt as char
 field sbfname as char
 field sbsname as char
 field sbfthname as char
 field name as char
 field abbrev as char
 field legform as char
 field sbgender as char
 field sbclass as char
 field residency as char
 field dtbirth as date
 field sbidnum1 as char
 field sbidnum2 as char
 field sbregdt as date
 field cidnum1 as char
 field cidnum2 as char
 field cregdt2 as date
 field cidnum3 as char
 field cregdt3 as date
 field mfname as char
 field msname as char
 field midnum1 as char
 field midnum2 as char
 field mregdt as date
 field addrloc1 as char
 field strname1 as char
 field strname2 as char
 field tel as char
 field tlx as char
 field fax as char
 field pmtper as char
 field tamt as deci
 field crc as char
 field insamt as deci
 field inscount as integer
 field oinscount as integer
 field oinsamt as deci
 field ovinscount as integer
 field ovinsamt as deci
 field intrate as deci
 field gua as char
 field crlimit as deci
 field usedamt as deci
 field benres as integer
 field bentype as integer
 field bennaim as char
 field benfname as char
 field benmname as char
 field benlname as char.

def var v-inscount as integer.
def var v-date as date.

function date_str returns char (input v-date as date) .
   return (string(year(v-date)) + "-" + string(month(v-date),'99') + "-" + string(day(v-date),'99')).
end.


/*процедура определения вида залога по гарантиям, суммы залога, суммы гарантии,*/

def var v-codfr as char.
def var sumzalog as decimal.
def var sumtreb as decimal.
def var vcrc as integer.
Procedure garan.
DEFINE INPUT PARAMETER v-aaa AS char.
def var i1 as integer.
def var i2 as integer.
def var i3 as integer.
def var i4 as integer.
def var i5 as integer.
def var i6 as integer.
def var i7 as integer.
def var i8 as integer.

       for each txb.jl where txb.jl.acc = v-aaa and txb.jl.trx = 'dcl0010' no-lock.
          if string(txb.jl.gl)  begins '6055' then do:
            sumtreb = txb.jl.dam.
            vcrc = txb.jl.crc.
            i2 = index(txb.jl.rem[1], "от").
            i4 = index(txb.jl.rem[2], ":").
            i5 = index(txb.jl.rem[2], "Сумма").
            v-codfr = trim(substr(txb.jl.rem[2],i4 + 2,i5 - i4 - 2)).
            sumzalog = decimal(trim(substr(txb.jl.rem[2],i5 + 6))).
          end.

       end.
end Procedure.
/**/

find last txb.cls where txb.cls.del no-lock no-error.

empty temp-table t-cred.

/*наименование банка для записи в логфайл*/
find first txb.cmp no-lock no-error.


/*гарантии*/
FOR EACH txb.aaa where string(txb.aaa.gl) begins "2240" no-lock:

   if txb.aaa.sta <> 'C' and txb.aaa.regdt <> txb.cls.whn then next.
   if txb.aaa.sta = 'C' then do:
     find first txb.sub-cod where txb.sub-cod.sub = 'cif' and txb.sub-cod.acc = txb.aaa.aaa and txb.sub-cod.d-cod = 'clsa' no-lock no-error.
     if not avail txb.sub-cod then next.
     if txb.sub-cod.rdt <> txb.cls.whn then next.
   end.

   find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.aaa.cif no-lock no-error.
   if txb.garan.jh  = 0 then do:
       run savelog( "kredbureau", "Нет проводки по гарантии! Филиал -  " + txb.cmp.addr[1] + " Номер Д/Г " + txb.aaa.aaa).
       v-sendmail = v-sendmail + 1.
       next.
   end.
   create t-cred.

   assign
   t-cred.crpurpose = "7"
   t-cred.ctcode = substring(v-bank,4,2) + txb.aaa.aaa
   t-cred.fundingtype = "8"
   t-cred.ctstatus = "1"
   t-cred.stdate = txb.aaa.regdt
   t-cred.edate = txb.aaa.expdt
   t-cred.class = "Стандартный".


   if txb.aaa.sta ne "C" then  t-cred.ctphase = "4".
   else t-cred.ctphase = "5".


   find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
   if txb.cif.type = 'P' then t-cred.sbclass = "1".
   if txb.cif.type = 'B' and txb.cif.cgr = 403 then t-cred.sbclass = "2".

   assign
      t-cred.tel = txb.cif.tel
      t-cred.tlx = txb.cif.tlx
      t-cred.fax = txb.cif.fax
      t-cred.cidnum3 = trim(txb.cif.ref[8])
      t-cred.cregdt3 = txb.cif.expdt.




   if (v-bank = "TXB16" or v-bank = "TXB00") then t-cred.addrloc1 = "675".
   else do:
       find first txb.codfr where txb.codfr.codfr = 'pkcity0' and txb.codfr.code <> 'msc' no-lock no-error.
        if avail txb.codfr then do:
              if txb.codfr.name[2] = '0' then do:
                 run savelog( "kredbureau", "Не заполнен справочник - Населенные пункты для Кредитного бюро! Филиал -  " + txb.cmp.addr[1] + ", Населеный пункт - " + txb.codfr.name[1]).
                 v-sendmail = v-sendmail + 1.
              end.
              else t-cred.addrloc1 = txb.codfr.name[2].
        end.
   end.

   if txb.cif.type = 'P' or (txb.cif.type = 'B' and txb.cif.cgr = 403) then do:
         assign
           t-cred.dtbirth = txb.cif.expdt
           t-cred.sbfname = entry(2, txb.cif.name, " ")
           t-cred.sbsname = entry(1, txb.cif.name, " ").
         if num-entries( trim(txb.cif.name), ' ' ) > 2 then
           t-cred.sbfthname = entry(1, txb.cif.name, " ").
         else t-cred.sbfthname = "Нет".

         find first txb.sub-cod where txb.sub-cod.sub = 'cln' and txb.sub-cod.acc = txb.aaa.cif and txb.sub-cod.d-cod = 'clnsex' no-lock no-error.
         if avail txb.sub-cod then do:
               if txb.sub-cod.ccode = '01' then t-cred.sbgender = "M".
               else t-cred.sbgender = "F".
         end.
         else do:
           run savelog( "kredbureau", "Отсутствует параметр clnsex ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
           v-sendmail = v-sendmail + 1.
         end.

         if txb.cif.geo = "022" then t-cred.residency = "2".
         if txb.cif.geo = "021" then t-cred.residency = "1".

         assign
           t-cred.sbidnum1 = txb.cif.jss
           t-cred.sbidnum2 = entry(1,txb.cif.pss,' ')
           t-cred.strname1 = trim(txb.cif.addr[1]) + trim(txb.cif.addr[2])
           t-cred.strname2 = trim(txb.cif.item).

         /*************/
         if num-entries(txb.cif.pss,' ') > 1 then do:
            t-cred.sbregdt = date(entry(2,txb.cif.pss,' ')) no-error.
            if error-status:error then do:
               v-dterror = true.
               k = 1.
               repeat:
                  k = k + 1.
                  t-cred.sbregdt = date(entry(k,txb.cif.pss,' ')) no-error.
                  if not (error-status:error) then do: v-dterror = false. leave. end.
                  if k = num-entries(txb.cif.pss,' ')then leave.
                end.
            end.
            if v-dterror = true then do:
               t-cred.sbregdt = date('01.01.2008').
               run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.cif.cif).
               v-sendmail = v-sendmail + 1.
            end.
         end.
         else do:
            run savelog( "kredbureau", "Отсутствует параметр дата выдачи ПАСПОРТ/УДОС ! Филиал " + txb.cmp.addr[1] + ", Клиент - " + txb.cif.cif).
             v-sendmail = v-sendmail + 1.
         end.

         /*************/
   end.

   if (txb.cif.type = 'B' and txb.cif.cgr <> 403) then do:

     t-cred.name = trim(substr(txb.cif.name,1,60)).
     if txb.cif.sname <> "" then t-cred.abbrev = txb.cif.sname.
     else t-cred.abbrev = trim(substr(txb.cif.name,1,60)).

     assign
       t-cred.cidnum1 = txb.cif.jss
       t-cred.cidnum2 = txb.cif.ssn
       t-cred.strname1 = trim(txb.cif.addr[1]).
       if trim(txb.cif.addr[2]) <> "" then t-cred.strname2 = trim(txb.cif.addr[2]).
       else t-cred.strname2 = trim(txb.cif.addr[1]).

     if entry(1,txb.cif.jel,'&') <> "" then
       t-cred.cregdt2 = date(entry(1,txb.cif.jel,'&')).
     else do:
       run savelog( "kredbureau", "Отсутствует дата выдачи ОКПО ! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
     end.

     find kdcif where kdcif.bank = v-bank and comm.kdcif.kdcif = txb.aaa.cif no-lock no-error.
     if avail kdcif then do:
         if kdcif.chief[1] <> '' then do:
             t-cred.msname = trim(entry(1,kdcif.chief[1], ' ')).
           if num-entries(kdcif.chief[1], ' ') > 1 then
             t-cred.mfname = trim(entry(2,kdcif.chief[1], ' ')).
           else do:
              run savelog( "kredbureau", "Отсутствует имя первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
              v-sendmail = v-sendmail + 1.
           end.
         end.
         else do:
            run savelog( "kredbureau", "Отсутствует номер ФИО первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
            v-sendmail = v-sendmail + 1.
         end.

         assign
           t-cred.midnum1 = trim(kdcif.rnn_chief[1])
           t-cred.midnum2 = entry(1,kdcif.docs[1],' ').
           if trim(kdcif.rnn_chief[1]) = '' then do:
              run savelog( "kredbureau", "Отсутствует номер РНН первого руководителя в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
              v-sendmail = v-sendmail + 1.
           end.
           if trim(kdcif.docs[1]) = '' then do:
              run savelog( "kredbureau", "Отсутствует номер и дата выдачи ПАСПОРТ/УДОС первому руководителю в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
              v-sendmail = v-sendmail + 1.
           end.
        if num-entries(kdcif.docs[1],' ') > 1 then t-cred.mregdt = date(entry(2,kdcif.docs[1],' ')).
        else do:
           run savelog( "kredbureau", "Отсутствует дата выдачи ПАСПОРТ/УДОС первому руководителю в кредитном досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
           v-sendmail = v-sendmail + 1.
        end.

        t-cred.legform = kdcif.lnopf.
     end.
     else do:
        run savelog( "kredbureau", "Отсутствует кредитное досье! Филиал " + txb.cmp.addr[1] + ",Клиент - " + txb.aaa.cif).
        v-sendmail = v-sendmail + 1.
     end.
   end.

   t-cred.gua = "GA".
   v-codfr = ''.
   sumzalog = 0.
   sumtreb = 0.


   find first txb.garan where txb.garan.garan = txb.aaa.aaa and txb.garan.cif = txb.aaa.cif no-lock no-error.
   if avail txb.garan then do:
       assign t-cred.benres = txb.garan.benres
              t-cred.bentype = txb.garan.bentype
              t-cred.bennaim = txb.garan.naim
              t-cred.benfname = txb.garan.fname
              t-cred.benmname = txb.garan.mname
              t-cred.benlname = txb.garan.lname.


              find txb.crc where txb.crc.crc = txb.garan.crc no-lock no-error.
              if avail txb.crc then assign t-cred.crc = txb.crc.code
                                           t-cred.colatcrc = txb.crc.code.
              v-codfr = txb.garan.obesp.
              if substr(v-codfr,1,1) = "0" then v-codfr = substr(v-codfr,2).
              case v-codfr:
                    when '1' then v-codfr = '6'.
                    when '2' then v-codfr = '2'.
                    when '3' then v-codfr = '10'.
                    when '5' then v-codfr = '1'.
                    when '6' then v-codfr = '12'.
                    otherwise v-codfr = '4'.
              end.
              assign t-cred.crlimit = txb.garan.sumtreb
                     t-cred.usedamt = txb.garan.sumtreb
                     t-cred.colaterall = v-codfr
                     t-cred.colatamt = string(txb.garan.sumzalog).

   end.
   else do:
       run garan(txb.aaa.aaa).
       find txb.crc where txb.crc.crc = vcrc no-lock no-error.
       if avail txb.crc then assign t-cred.crc = txb.crc.code
                                t-cred.colatcrc = txb.crc.code.
       if substr(v-codfr,1,1) = "0" then v-codfr = substr(v-codfr,2).
       case v-codfr:
            when '1' then v-codfr = '6'.
            when '2' then v-codfr = '2'.
            when '3' then v-codfr = '10'.
            when '5' then v-codfr = '1'.
            when '6' then v-codfr = '12'.
            otherwise v-codfr = '4'.
       end.
       assign t-cred.crlimit = sumtreb
              t-cred.usedamt = sumtreb
              t-cred.colaterall = v-codfr
              t-cred.colatamt = string(sumzalog).
   end.
END.

FOR EACH t-cred:

    if t-cred.stdate >= txb.cls.whn then put stream m-out unformatted '<Contract operation = "1">' skip.
                                     else put stream m-out unformatted '<Contract operation = "2">' skip.

    put stream m-out unformatted "<General>" skip.


    put stream m-out unformatted "<ContractCode>" + t-cred.ctcode + "</ContractCode>" skip.
    put stream m-out unformatted '<FundingType id ="' + t-cred.fundingtype + '"/>' skip.
    put stream m-out unformatted '<CreditPurpose id = "' + t-cred.crpurpose + '"/>' skip.
    put stream m-out unformatted  '<ContractPhase id = "' + t-cred.ctphase + '"/>' skip.
    put stream m-out unformatted  '<ContractStatus id = "' + t-cred.ctstatus + '"/>' skip.
    put stream m-out unformatted  "<StartDate>" date_str(t-cred.stdate) "</StartDate>" skip.
    if t-cred.gua = "GA" and t-cred.edate = ? then put stream m-out unformatted  "<EndDate>1900-01-01</EndDate>" skip.
    else put stream m-out unformatted  "<EndDate>" date_str(t-cred.edate) "</EndDate>" skip.
    put stream m-out unformatted  "<Classification>" skip.
    put stream m-out unformatted '<Text language="ru-RU">' t-cred.class '</Text>' skip.
    put stream m-out unformatted "</Classification>" skip.
    put stream m-out unformatted  "<Collaterals>" skip.
    do i = 1 to num-entries(t-cred.colaterall):
        put stream m-out unformatted  '<Collateral typeId = "' + entry(i,t-cred.colaterall) + '">' skip.
        put stream m-out unformatted  '<Value currency="' + entry(i,t-cred.colatcrc) + '" typeId = "3">' + entry(i,t-cred.colatamt) + '</Value>' skip.
        put stream m-out unformatted  "</Collateral>" skip.
    end.
    put stream m-out unformatted  "</Collaterals>" skip.

/************Заемщик************************************************************************************/

    put stream m-out unformatted  "<Subjects>" skip.
    put stream m-out unformatted  '<Subject roleId="1">' skip.
    put stream m-out unformatted  "<Entity>" skip.
    if t-cred.legform = '' then do:
        put stream m-out unformatted  "<Individual>" skip.
        put stream m-out unformatted  "<FirstName>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbfname '</Text>' skip.
        put stream m-out unformatted  "</FirstName>" skip.
        put stream m-out unformatted  "<Surname>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbsname '</Text>' skip.
        put stream m-out unformatted  "</Surname>" skip.
        put stream m-out unformatted  "<FathersName>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' t-cred.sbfthname '</Text>' skip.
        put stream m-out unformatted  "</FathersName>" skip.
        put stream m-out unformatted  '<Gender>' t-cred.sbgender '</Gender>' skip.
        put stream m-out unformatted  '<Classification id = "' + t-cred.sbclass + '"/>' skip.

        put stream m-out unformatted  '<Residency id = "' t-cred.residency '"/>' skip.
        put stream m-out unformatted  "<DateOfBirth>" date_str(t-cred.dtbirth) "</DateOfBirth>" skip.
        put stream m-out unformatted  '<Citizenship id = "110"/>' skip.

        put stream m-out unformatted  "<Identifications>" skip.
        put stream m-out unformatted  '<Identification typeId = "1" rank = "1">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.sbidnum1,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.

        put stream m-out unformatted  '<Identification typeId = "7" rank = "2">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.sbidnum2,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.sbregdt) "</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.
        put stream m-out unformatted  "</Identifications>" skip.

        put stream m-out unformatted  "<Addresses>" skip.
        put stream m-out unformatted  '<Address typeId = "1" locationId = "' t-cred.addrloc1 '">' skip.
        put stream m-out unformatted  "<StreetName>" skip.
        put stream m-out unformatted '<Text language="ru-RU">' replace(t-cred.strname1,'№','') '</Text>' skip.
        put stream m-out unformatted  "</StreetName>" skip.
        put stream m-out unformatted  "</Address>" skip.

        if trim(t-cred.strname2) ne '' then do:
            put stream m-out unformatted  '<Address typeId = "3" locationId = "' t-cred.addrloc1 '">' skip.
            put stream m-out unformatted  "<StreetName>" skip.
            put stream m-out unformatted '<Text language="ru-RU">' replace(t-cred.strname2,'№','') '</Text>' skip.
            put stream m-out unformatted  "</StreetName>" skip.
            put stream m-out unformatted  "</Address>" skip.
        end.
        put stream m-out unformatted  "</Addresses>" skip.

        put stream m-out unformatted "<Communications>" skip.
        if t-cred.tel <> "" then  put stream m-out unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
        if t-cred.tlx <> "" then  put stream m-out unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
        if t-cred.fax <> "" then  put stream m-out unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.

        put stream m-out unformatted "</Communications>" skip.
        put stream m-out unformatted "<Dependants>" skip.
        put stream m-out unformatted '<Dependant count = "0" typeId = "1"/>' skip.
        put stream m-out unformatted "</Dependants>" skip.

        put stream m-out unformatted  "</Individual>" skip.
    end.

/********************для ЮЛ****************/
    else do:
        put stream m-out unformatted  "<Company>" skip.
        put stream m-out unformatted "<Name>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' replace(t-cred.name,'&','&amp;') '</Text>' skip.
        put stream m-out unformatted "</Name>" skip.
        put stream m-out unformatted '<Status id = "1"/>' skip.
        put stream m-out unformatted "<TradeName>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' replace(t-cred.name,'&','&amp;')  '</Text>' skip.
        put stream m-out unformatted "</TradeName>" skip.
        put stream m-out unformatted "<Abbrevation>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' replace(t-cred.abbrev,'&','&amp;' )'</Text>' skip.
        put stream m-out unformatted  "</Abbrevation>" skip.
        put stream m-out unformatted '<LegalForm id = "' t-cred.legform '"/>' skip.
        put stream m-out unformatted '<Nationality id = "110"/>' skip.
        put stream m-out unformatted '<EconomicActivity id = "1"/>' skip.
    	 put stream m-out unformatted  "<Addresses>" skip.
        /*адрес госрегитсрации*/

        put stream m-out unformatted  '<Address typeId = "4" locationId = "' t-cred.addrloc1 '">' skip.
        put stream m-out unformatted  "<StreetName>" skip.
        put stream m-out unformatted '<Text language="ru-RU">' replace(t-cred.strname1,'№','') '</Text>' skip.
        put stream m-out unformatted  "</StreetName>" skip.
        put stream m-out unformatted  "</Address>" skip.

        put stream m-out unformatted  '<Address typeId = "5" locationId = "' t-cred.addrloc1 '">' skip.
        put stream m-out unformatted  "<StreetName>" skip.
        put stream m-out unformatted '<Text language="ru-RU">' replace(t-cred.strname2,'№','') '</Text>' skip.
        put stream m-out unformatted  "</StreetName>" skip.
        put stream m-out unformatted  "</Address>" skip.
    	put stream m-out unformatted  "</Addresses>" skip.

        put stream m-out unformatted  "<Identifications>" skip.
        put stream m-out unformatted  '<Identification typeId = "1" rank = "1">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.cidnum1,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.

        put stream m-out unformatted  '<Identification typeId = "10" rank = "2">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.cidnum2,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.cregdt2) "</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.

        put stream m-out unformatted  '<Identification typeId = "11" rank = "2">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.cidnum3,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.cregdt3) "</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.
        put stream m-out unformatted  "</Identifications>" skip.


    	put stream m-out unformatted "<Communications>" skip.
        if t-cred.tel <> "" then  put stream m-out unformatted '<Communication typeId = "1">' t-cred.tel '</Communication>'skip.
        if t-cred.tlx <> "" then  put stream m-out unformatted '<Communication typeId = "2">' t-cred.tlx '</Communication>'skip.
        if t-cred.fax <> "" then  put stream m-out unformatted '<Communication typeId = "3">' t-cred.fax '</Communication>'skip.
        put stream m-out unformatted "</Communications>" skip.

        put stream m-out unformatted "<Management>" skip.
        put stream m-out unformatted "<CEO>" skip.
        put stream m-out unformatted "<FirstName>" skip.
        put stream m-out unformatted  '<Text language="ru-RU">' t-cred.mfname '</Text>' skip.
        put stream m-out unformatted "</FirstName>" skip.
        put stream m-out unformatted "<Surname>" skip.
        put stream m-out unformatted '<Text language="ru-RU">' t-cred.msname '</Text>' skip.
        put stream m-out unformatted "</Surname>" skip.

        put stream m-out unformatted  "<Identifications>" skip.
        put stream m-out unformatted  '<Identification typeId = "1" rank = "1">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.midnum1,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>1900-01-01</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.

        put stream m-out unformatted  '<Identification typeId = "7" rank = "2">' skip.
        put stream m-out unformatted  "<Number>" replace(t-cred.midnum2,'№','') "</Number>" skip.
        put stream m-out unformatted  "<RegistrationDate>" date_str(t-cred.mregdt) "</RegistrationDate>" skip.
        put stream m-out unformatted  "</Identification>" skip.
        put stream m-out unformatted  "</Identifications>" skip.

        put stream m-out "</CEO>" skip.
        put stream m-out "</Management>" skip.
        put stream m-out "</Company>" skip.
    end.
/******************/

    put stream m-out unformatted  "</Entity>" skip.
    put stream m-out unformatted  "</Subject>" skip.

    if t-cred.bentype > 0 then do:
        put stream m-out unformatted  '<Subject roleId="12">' skip.
        put stream m-out unformatted  ' <Entity>' skip.

        if t-cred.bentype > 1 then do:
            put stream m-out unformatted '<Individual>' skip.
            put stream m-out unformatted '<FirstName>' skip.
            put stream m-out unformatted '<Text language="ru-RU">' t-cred.benlname '</Text>' skip.
            put stream m-out unformatted '</FirstName>' skip.
            put stream m-out unformatted '<Surname>' skip.
            put stream m-out unformatted '<Text language="ru-RU">' t-cred.benfname '</Text>' skip.
            put stream m-out unformatted '</Surname>' skip.
            put stream m-out unformatted '<FathersName>' skip.
            put stream m-out unformatted '<Text language="ru-RU">' t-cred.benmname '</Text>' skip.
            put stream m-out unformatted '</FathersName>' skip.
            put stream m-out unformatted '<Residency id="' string(t-cred.benres,'9') '" />' skip.
            put stream m-out unformatted '</Individual>' skip.
        end.
        if t-cred.bentype = 1 then do:
            put stream m-out unformatted '<Company>' skip.
            put stream m-out unformatted '<Name>' skip.
            put stream m-out unformatted '<Text language="ru-RU">' t-cred.bennaim '</Text>' skip.
            put stream m-out unformatted '</Name>' skip.
            put stream m-out unformatted '<Residency id="' string(t-cred.benres,'9') '" />' skip.
            put stream m-out unformatted '</Company>' skip.
        end.
        put stream m-out unformatted  '</Entity>' skip.
        put stream m-out unformatted  '</Subject>' skip.
    end.
    put stream m-out unformatted  "</Subjects>" skip.

    put stream m-out unformatted "</General>" skip.

/*********Кредит********************************************************************************************/
    put stream m-out unformatted "<Type>" skip.


    put stream m-out unformatted '<Instalment paymentMethodId = "1" paymentPeriodId = "10">' skip.
    put stream m-out unformatted '<TotalAmount currency = "' t-cred.crc '">' string(t-cred.crlimit) '</TotalAmount>' skip.
    put stream m-out unformatted "<Records>" skip.
    put stream m-out unformatted '<Record accountingDate = "' date_str(g-today) '">' skip.
    put stream m-out unformatted "</Record>" skip.
    put stream m-out unformatted "</Records>" skip.
    put stream m-out unformatted "</Instalment>" skip.

    put stream m-out unformatted "</Type>" skip.

    put stream m-out unformatted "</Contract>" skip.

    v-dogcount = v-dogcount + 1.

    if v-dogcount = 1000 then do:
       put stream m-out unformatted '</Records>' skip.
       output stream m-out close.
       v-find0 = ''.
       input through value( "find /data/log/kred" + string(v-paket) + "garan.xml;echo $?").
        repeat:
         import unformatted v-find0.
       end.
       if v-find0 = "0" then unix silent value("rm /data/log/kred" + string(v-paket) + "garan.xml").
       unix silent cp kredgaran.xml value("/data/log/kred" + string(v-paket) + "garan.xml").

       unix silent koi2utf kredgaran.xml kreditgaran.xml.
       unix silent value ("cb1pump.pl -zip -login=MBuser37 -password=Nastya2211 -method=UploadZippedData2 -file2send=kreditgaran.xml > /data/log/res_garan.xml") .
       run mail('FCB@metrocombank.kz', "METROKOMBANK <abpk@metrobank.kz>", "Результат загрузки файла в КБ " , "" , "1", "", "/data/log/res_garan.xml").

       v-paket = v-paket + 1.
       v-dogcount = 0.
       output stream m-out to "kredgaran.xml".
       put stream m-out unformatted '<?xml version="1.0" encoding="UTF-8" ?>' skip.
       put stream m-out unformatted '<Records xmlns="http://www.datapump.cig.com" ' skip.
       put stream m-out unformatted 'xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" ' skip.
       put stream m-out unformatted 'xs:schemaLocation="http://www.datapump.cig.com SRC_Contract_KZv2.xsd">' skip.

    end.

end.

