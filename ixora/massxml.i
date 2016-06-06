/* massxml.i
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Заказ в АБН карточек - формирование файла
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24.09.2012 Vera
 * CHANGES
        10.12.2012 id00810 - BaseAddress: Country = KAZ независимо от признака резидент(да/нет)
        25/12/2012 id00810 - перекомпиляция
        28/12/2012 id00810 - ТЗ 1470 - перевыпуск, доп.карты
        17.01.2013 Lyubov  - обработка случаев локировки записей
        17.05.2013 Lyubov  - ТЗ 1470, переделан порядок полей для перевыпуска
        29.08.2013 Lyubov  - ТЗ №2065, если pccounters кто-то держит - выходим
        04/10/2013 galina - ТЗ1470 поменяла формат перевыпуска и выпуска допкарт
        10/10/2013 galina - ТЗ2131 замена недопустимых в xml символов
*/

{bk.i}
{srvcheck.i}

function rep2utf returns char (input v-str as char).
    return replace(replace(replace(replace(replace(replace(replace(replace(v-str,'&','&amp;'),'«','"'),'»','"'),'№','N'),'“','"'),'‘',''),'”','"'),'’','').
end function.

def var file-cntr  as char no-undo format "x(2)".
def var file-date  as char no-undo format "x(3)".
def var file-year  as char no-undo format "x(4)".
def var file-month as char no-undo format "x(2)".
def var file-day   as char no-undo format "x(2)".
def var file-time  as char no-undo format "x(6)".
def var file-name as char no-undo.
def var crlf      as char no-undo.
def var s0        as char no-undo.
def var rcd       as char no-undo.
def var v-arc     as char no-undo.
def var v-applid  as char no-undo.
def var v-nom     as int  no-undo.
def new shared temp-table tmp2
	field namef   like pcstaff0.namef
	field nomdoc  like pcstaff0.nomdoc
    field rez     like pcstaff0.rez
    field aaa     like pcstaff0.aaa
    field crc     as   char
    field issdoc  like pcstaff0.issdoc
    field issdt   like pcstaff0.issdt
    field sname   like pcstaff0.sname
    field fname   like pcstaff0.fname
    field mname   like pcstaff0.mname
    field namelat like pcstaff0.namelat
    field cword   like pcstaff0.cword
    field country like pcstaff0.country
    field birth   like pcstaff0.birth
    field tel1    as char
    field tel2    as char
    field city    as char
    field addr1   as char
    field addr2   as char
    field addr3   as char
    field acode   as char
    field company as char
    field orddep2 as char
    field rnn     like pcstaff0.rnn
    field iin     like pcstaff0.iin
    field ccode   like pcstaff0.ccode
    field cltype  as char
    field pcard   as char
    field expdt   as char
    field prtype  as char
    field prevent as char
    field sup     as logi
    field reason as char.

def stream t.

crlf = chr(13) + chr(10).

procedure Put_header.
    v-nom = 0.
    find pccounters where pccounters.type = "applicat_file" exclusive-lock no-error no-wait.
    if locked pccounters then do:
        message 'Locked pccounters:' pccounters.type string(time,'hh:mm:ss').
        return.
    end.
    if not avail pccounters then
       do:
          create pccounters.
          assign pccounters.type = "applicat_file"
                 pccounters.dat = g-today
                 pccounters.counter = 1.
      end.
    else do:
      if pccounters.dat <> g-today then
      do:
          assign pccounters.dat = g-today
                 pccounters.counter = 1.
      end.
      else pccounters.counter = pccounters.counter + 1.
    end.

    file-cntr = string(pccounters.counter, "99999").
    file-date = string(g-today - date(01,01, year(g-today)) + 1, "999").
    file-year = string(year(g-today), "9999").
    file-month = string(month(g-today), "99").
    file-day = string(day(g-today), "99").
    file-time = string(time, "hh:mm:ss").
    v-applid = substr(file-year,3,2) + string(pccounters.counter, "999").
    release pccounters.

    s0 = "XADVAPL111100_" + file-cntr + "." + file-date.
    file-name = s0.
    output to rpt.xml.

    /* HEADER */
    s0 =
    "<?xml version=""1.0"" encoding=""UTF-8""?>" + crlf +
    "<ApplicationFile>" + crlf +
    "<FileHeader>" + crlf +
    "<FormatVersion>2.0</FormatVersion>" + crlf +
    "<Sender>1111</Sender>" + crlf +
    "<CreationDate>" + file-year + "-" + file-month + "-" + file-day + "</CreationDate>" + crlf +
    "<CreationTime>" + file-time + "</CreationTime>" + crlf +
    "<Number>" + file-cntr + "</Number>" + crlf +
    "<Institution>11" + tmp2.orddep2 + "</Institution>" + crlf +
    "</FileHeader>" + crlf +
    "<ApplicationsList>" + crlf.
    put unformatted s0.
    output close.

end procedure.

procedure Put_application.
    v-nom = v-nom + 1.
    output to rpt.xml append.
    s0 =
    "<Application>" + crlf +
    "<RegNumber>"  + v-applid + string(v-nom,'999') + "CLN" +  "</RegNumber>" + crlf +
    "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
    "<ObjectType>Client</ObjectType>" + crlf +
    "<ActionType>Add</ActionType>" + crlf +
    "<Data>" + crlf +
    "<Client>" + crlf +
    "<ClientType>"+ tmp2.cltype + "</ClientType>" + crlf +   /*pr_ pn_*/
    "<ClientInfo>" + crlf +
    "<ClientNumber>" + string(tmp2.aaa) + "</ClientNumber>"  + crlf +
    "<RegNumberType>PASSPORT</RegNumberType>" + crlf +
    "<RegNumber>" + rep2utf(string(tmp2.nomdoc)) + "</RegNumber>" + crlf +
    "<RegNumberDetails>" + string(tmp2.issdt, '99/99/9999') + " " + string(tmp2.issdoc) + "</RegNumberDetails>" + crlf +
    "<ShortName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ShortName>" + crlf +
    "<TaxpayerIdentifier>" + string(tmp2.iin) + "</TaxpayerIdentifier>" + crlf +
    "<FirstName>" + string(tmp2.fname) + "</FirstName>" + crlf +
    "<LastName>" + string(tmp2.sname) + "</LastName>" + crlf +
    "<MiddleName>" + string(tmp2.mname) + "</MiddleName>" + crlf +
    "<SecurityName>" + string(tmp2.cword) + "</SecurityName>" + crlf +
    "<Country>" + string(tmp2.country) + "</Country>" + crlf +
    "<Language>R</Language>"+ crlf +
    "<Position></Position>" + crlf +
    "<CompanyName>" + rep2utf(string(tmp2.company)) + "</CompanyName>" + crlf +
    "<BirthDate>"+ string (year(tmp2.birth), "9999") + "-" + string (month(tmp2.birth), "99") + "-" + string (day(tmp2.birth), "99") + "</BirthDate>" + crlf +
    "<BirthPlace></BirthPlace>" + crlf +
    "</ClientInfo>" + crlf +
    "<PlasticInfo>" + crlf +
    "<FirstName>" + entry(2,tmp2.namelat," ") + "</FirstName>" + crlf +
    "<LastName>" + entry(1,tmp2.namelat," ") + "</LastName>" + crlf +
    "</PlasticInfo>" + crlf +
    "<PhoneList>" + crlf +
    "<Phone>" + crlf +
    "<PhoneType>Home</PhoneType>" + crlf +
    "<PhoneNumber>" + string(tmp2.tel1) + "</PhoneNumber>" + crlf +
    "</Phone>" + crlf +
    "<Phone>" + crlf +
    "<PhoneType>Mobile</PhoneType>" + crlf +
    "<PhoneNumber>" + string(tmp2.tel2) + "</PhoneNumber>" + crlf +
    "</Phone>" + crlf +
    "</PhoneList>" + crlf +
    "<BaseAddress>" + crlf +
    "<Country>" + "KAZ" + "</Country>" + crlf +
    "<City>" + string(tmp2.city) + "</City>" + crlf +
    "<AddressLine1>" + rep2utf(string(tmp2.addr1)) + "</AddressLine1>" + crlf +
    "<AddressLine2></AddressLine2>" + crlf +
    "<AddressLine3>" + string(tmp2.rnn) + "</AddressLine3>" + crlf +
    "<AddressLine4></AddressLine4>" + crlf +
    "</BaseAddress>" + crlf +
    "</Client>" + crlf +
    "</Data>" + crlf +
    "<SubApplList>" + crlf +
    "<Application>" + crlf +
    "<RegNumber>"  + v-applid + string(v-nom,'999') + "CTR1" +  "</RegNumber>" + crlf +
    "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
    "<ObjectType>Contract</ObjectType>" + crlf +
    "<ActionType>Add</ActionType>" + crlf +
    "<Data>" + crlf +
    "<Contract>" + crlf +
    "<Product>" + crlf +
    "<ProductCode1>" + string(tmp2.acode) + "</ProductCode1>" + crlf + /*" + string(Prod) + "*/
    "</Product>" + crlf +
    "</Contract>" + crlf +
    "</Data>" + crlf +
    "<SubApplList>" + crlf +
    "<Application>" + crlf +
    "<RegNumber>" + v-applid + string(v-nom,'999') + "CTR2" + "</RegNumber>" + crlf +
    "<ObjectType>Contract</ObjectType>" + crlf +
    "<ActionType>Add</ActionType>" + crlf +
    "<Data>" + crlf +
    "<Contract>" + crlf +
    "<Product>" + crlf +
    "<ProductCode1>"+ string(tmp2.ccode) + "</ProductCode1>" + crlf +
    "</Product>" + crlf +
    "<ChipScheme>FDFLT_" + string(tmp2.crc) + "</ChipScheme>" + crlf +
    "<RiskFactor>1</RiskFactor>" + crlf +
    "</Contract>" + crlf +
    "</Data>" + crlf +
    "</Application>" + crlf +
    "</SubApplList>" + crlf +
    "</Application>" + crlf +
    "</SubApplList>" + crlf +
    "</Application>" + crlf.
        put unformatted s0.
end procedure.

procedure Put_reissue.
v-nom = v-nom + 1.
output to rpt.xml append.
s0 =
"<Application>" + crlf +
"<RegNumber>FB" +  v-applid + string(v-nom,'999') + string(g-today,'99999999') + replace(string(time,'HH:MM:SS'),':','') + "RE" +  "</RegNumber>" + crlf +
"<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
"<ObjectType>Card</ObjectType>" + crlf +
"<ActionType>Update</ActionType>" + crlf +
"<ObjectFor>" + crlf +
/*"<Contract>" + crlf +*/
"<ContractIDT>" + crlf +
"<ContractNumber>" + string(tmp2.pcard) + "</ContractNumber>" + crlf +
"<Client>" + crlf +
"<ClientInfo>" + crlf +
"<ShortName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ShortName>" + crlf +
"</ClientInfo>" + crlf.
if tmp2.reason = '4' then s0 = s0 +
                               "<PlasticInfo>" + crlf +
                               "<FirstName>" + entry(2,tmp2.namelat," ") + "</FirstName>" + crlf +
                               "<LastName>" + entry(1,tmp2.namelat," ") + "</LastName>" + crlf +
                               "</PlasticInfo>" + crlf.

s0 = s0 +
"</Client>" + crlf +
"</ContractIDT>" + crlf +
/*"</Contract>" + crlf +*/
"</ObjectFor>" + crlf +
"<Data>" + crlf +
"<ProduceCard>" + crlf +
/*"<ProductionParms>" + crlf +
"<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +*/
"<DeliveryDprt>11" + string(tmp2.orddep2) + "</DeliveryDprt>" + crlf +
"<ProductionType>" + tmp2.prtype + "</ProductionType>" + crlf +
"<ProductionEvent>" + tmp2.prevent + "</ProductionEvent>" + crlf +
"<CommentText>Adv " + tmp2.prtype + "</CommentText>" + crlf +
/*"<CardExpiry>" + tmp2.expdt + "</CardExpiry>" + crlf +*/
/*"</ProductionParms>" + crlf +*/
"</ProduceCard>" + crlf +
"</Data>" + crlf +
"</Application>" + crlf.
put unformatted s0.
end procedure.

procedure Put_applicationS.
    v-nom = v-nom + 1.
    output to rpt.xml append.
    s0 = ''.
    find first pccards where pccards.aaa  = tmp2.aaa and pccards.sts <> 'Closed' and pccards.sup = no no-lock no-error.
    if avail pccards then do:
        if pccards.iin = tmp2.iin then
        s0 =
          "<Application>" + crlf +
          "<RegNumber>" + v-applid + string(v-nom,'999') + "CTR" + "</RegNumber>" + crlf +
          "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
          "<ObjectType>Contract</ObjectType>" + crlf +
          "<ActionType>Add</ActionType>" + crlf +
/*          "<RegNumber>" + v-applid + string(v-nom,'999') + "CTR" + "</RegNumber>" + crlf +*/
          "<ObjectFor>" + crlf +
          /*"<Contract>" + crlf +*/
          "<ContractIDT>" + crlf +
/*          "<Client>" + crlf +
          "<ClientIDT>" + crlf +
          "<ShortName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ShortName>" + crlf +
          "</ClientIDT>" + crlf +
          "</Client>" + crlf +*/
          "<ContractNumber>" + string(tmp2.aaa) + "</ContractNumber>" + crlf +
          /*"</ContractIDT>" + crlf +*/
          /*"</Contract>" + crlf +*/
          "<Client>" + crlf +
          /*"<ClientIDT>" + crlf +*/
          "<ClientInfo>" + crlf +
          "<ShortName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ShortName>" + crlf +
          /*"</ClientIDT>" + crlf +*/
          "</ClientInfo>" + crlf +
          "</Client>" + crlf +
          "</ContractIDT>" + crlf +
          "</ObjectFor>" + crlf +
          "<Data>" + crlf +
          "<Contract>" + crlf +
/*          "<Currency>" + string(tmp2.crc) + "</Currency>" + crlf +
          "<ContractName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ContractName>" + crlf +*/
          "<Product>" + crlf +
          "<ProductCode1>" + string(tmp2.ccode) + "</ProductCode1>" + crlf +
          "</Product>" + crlf +
/*          "<ChipScheme>DFLT_" + string(tmp2.crc) + "</ChipScheme>" + crlf +*/
          "<ChipScheme>FDFLT_" + string(tmp2.crc) + "</ChipScheme>" + crlf +
          "<RiskFactor>1</RiskFactor>" + crlf +
/*          "<PlasticInfo>" + crlf +
          "<FirstName>" + entry(2,tmp2.namelat," ") +  "</FirstName>" + crlf +
          "<LastName>" + entry(1,tmp2.namelat," ") +  "</LastName>" + crlf +
          "</PlasticInfo>" + crlf +*/
          "</Contract>" + crlf +
          "</Data>"  + crlf +
          /*"<SubApplList>" + crlf +
          "<Application>" + crlf +*/
        /*  "<RegNumber>" + v-applid + string(v-nom,'999') + "CARD" +  "</RegNumber>" + crlf +*/
 /*         "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
          "<ObjectType>Card</ObjectType>" + crlf +
          "<ActionType>Add</ActionType>" + crlf +
          "<RegNumber>" + v-applid + string(v-nom,'999') + "CARD" +  "</RegNumber>" + crlf +
          "<Data>" + crlf +
          "<ProduceCard>" + crlf +
          "<DeliveryDprt>11" + string(tmp2.orddep2) + "</DeliveryDprt>" + crlf +
          "<ProductionType>PlasticAndPIN</ProductionType>" + crlf +
          "<ProductionEvent>NCRD</ProductionEvent>" + crlf +
          "</ProduceCard>" + crlf +
          "</Data>" + crlf +
          "</Application>" + crlf +
          "</SubApplList>" + crlf +*/
          "</Application>" + crlf.
        else do:
            find first pcstaff0 where pcstaff0.cif = pccards.cif and pcstaff0.aaa = pccards.aaa and pcstaff0.iin = pccards.iin no-lock no-error.
            s0 =
            "<Application>" + crlf +
            "<RegNumber>"  + v-applid + string(v-nom,'999') + "CLN" +  "</RegNumber>" + crlf +
            "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
            "<ObjectType>Client</ObjectType>" + crlf +
            "<ActionType>Add</ActionType>" + crlf +
            "<Data>" + crlf +
            "<Client>" + crlf +
            "<ClientType>"+ tmp2.cltype + "</ClientType>" + crlf +   /*pr_ pn_*/
            "<ClientInfo>" + crlf +
            "<ClientNumber>" + string(tmp2.iin) + "</ClientNumber>"  + crlf + /*client nuber должен быть уникален?*/
            "<RegNumberType>PASSPORT</RegNumberType>" + crlf +
            "<RegNumber>" + rep2utf(string(tmp2.nomdoc)) + "</RegNumber>" + crlf +
            "<RegNumberDetails>" + string(tmp2.issdt, '99/99/9999') + " " + string(tmp2.issdoc) + "</RegNumberDetails>" + crlf +
            "<ShortName>" + string(tmp2.sname) + " " + substring(tmp2.fname,1,1) + "." + substring(tmp2.mname,1,1) + "." + "</ShortName>" + crlf +
            "<TaxpayerIdentifier>" + string(tmp2.iin) + "</TaxpayerIdentifier>" + crlf +
            "<FirstName>" + string(tmp2.fname) + "</FirstName>" + crlf +
            "<LastName>" + string(tmp2.sname) + "</LastName>" + crlf +
            "<MiddleName>" + string(tmp2.mname) + "</MiddleName>" + crlf +
            "<SecurityName>" + string(tmp2.cword) + "</SecurityName>" + crlf +
            "<Country>" + string(tmp2.country) + "</Country>" + crlf +
            "<Language>R</Language>" + crlf +
            "<Position></Position>" + crlf +
            "<CompanyName>" + rep2utf(string(tmp2.company)) + "</CompanyName>" + crlf +
            "<BirthDate>"+ string (year(tmp2.birth), "9999") + "-" + string (month(tmp2.birth), "99") + "-" + string (day(tmp2.birth), "99") + "</BirthDate>" + crlf +
            "<BirthPlace></BirthPlace>" + crlf +
            "</ClientInfo>" + crlf +
            "<PlasticInfo>" + crlf +
            "<FirstName>" + entry(2,tmp2.namelat," ") + "</FirstName>" + crlf +
            "<LastName>" + entry(1,tmp2.namelat," ") + "</LastName>" + crlf +
            "</PlasticInfo>" + crlf +
            "<PhoneList>" + crlf +
            "<Phone>" + crlf +
            "<PhoneType>Home</PhoneType>" + crlf +
            "<PhoneNumber>" + string(tmp2.tel1) + "</PhoneNumber>" + crlf +
            "</Phone>" + crlf +
            "<Phone>" + crlf +
            "<PhoneType>Mobile</PhoneType>" + crlf +
            "<PhoneNumber>" + string(tmp2.tel2) + "</PhoneNumber>" + crlf +
            "</Phone>" + crlf +
            "</PhoneList>" + crlf +
            "<BaseAddress>" + crlf +
            "<Country>" + "KAZ" + "</Country>" + crlf +
            "<City>" + string(tmp2.city) + "</City>" + crlf +
            "<AddressLine1>" + rep2utf(string(tmp2.addr1)) + "</AddressLine1>" + crlf +
            "<AddressLine2></AddressLine2>" + crlf +
            "<AddressLine3>" + string(tmp2.rnn) + "</AddressLine3>" + crlf +
            "<AddressLine4></AddressLine4>" + crlf +
            "</BaseAddress>" + crlf +
            "</Client>" + crlf +
            "</Data>" + crlf +
            "<SubApplList>" + crlf +
            "<Application>" + crlf +
            "<RegNumber>"  + v-applid + string(v-nom,'999') + "CTR1" +  "</RegNumber>" + crlf +
            "<OrderDprt>11" + string(tmp2.orddep2) + "</OrderDprt>" + crlf +
            "<ObjectType>Contract</ObjectType>" + crlf +
            "<ActionType>Add</ActionType>" + crlf +
            "<ObjectFor>" + crlf +
            "<ContractIDT>" + crlf +
            "<ContractNumber>" + string(tmp2.aaa) + "</ContractNumber>" + crlf +
            "<Client>" + crlf +
            "<ClientInfo>" + crlf +
            "<ShortName>" + (if avail pcstaff0 then (string(pcstaff0.sname) + " " + substring(pcstaff0.fname,1,1) + "." + substring(pcstaff0.mname,1,1) + ".") else '')  + "</ShortName>" + crlf +
            "</ClientInfo>" + crlf +
            "</Client>" + crlf +
            "</ContractIDT>" + crlf +
            "</ObjectFor>" + crlf +
            "<Data>" + crlf +
            "<Contract>" + crlf +
            "<Product>" + crlf +
            "<ProductCode1>" + string(tmp2.ccode) + "</ProductCode1>" + crlf +
            "</Product>" + crlf +
            "<ChipScheme>FDFLT_" + string(tmp2.crc) + "</ChipScheme>" + crlf +
            "<RiskFactor>1</RiskFactor>" + crlf +
            "</Contract>" + crlf +
            "</Data>" + crlf +
            "</Application>" + crlf +
            "</SubApplList>" + crlf +
            "</Application>" + crlf.
        end.
        if s0 <> '' then put unformatted s0.
    end.
end procedure.

procedure Put_footer.
    output to rpt.xml append.
    s0 =
    "</ApplicationsList>" + crlf +
    "</ApplicationFile>" + crlf.
    put unformatted s0.
    output close.
end procedure.

procedure Copyfile.
    unix silent value("koi2utf rpt.xml" +  " " + file-name).
    if isProductionServer() then do:
        input through value("scp " + file-name + " Administrator@fs01.metrobank.kz:" + "D:\\\\euraz\\\\Cards\\\\Out\\\\;echo $?").
    end.
    else do:
        input through value("scp " + file-name + " Administrator@fs01.metrobank.kz:" + "D:\\\\euraz\\\\Cards\\\\Out\\\\test\\\\;echo $?").

    end.

    repeat:
        import unformatted rcd.
    end.
    if rcd <> "0" then message "Ошибка копирования файла \n" + file-name + "\n" + rcd.

    v-arc = "/data/export/pc/".
    input through value( "find " + v-arc + ";echo $?").
    repeat:
        import unformatted rcd.
    end.
    if rcd <> "0" then do:
        unix silent value ("mkdir " + v-arc).
        unix silent value ("chmod 777 " + v-arc).
    end.

    v-arc = "/data/export/pc/" + string(year(g-today),"9999") + string(month(g-today),"99") + string(day(g-today),"99") + "/".
    input through value( "find " + v-arc + ";echo $?").
    repeat:
        import unformatted rcd.
    end.
    if rcd <> "0" then do:
        unix silent value ("mkdir " + v-arc).
        unix silent value ("chmod 777 " + v-arc).
    end.
    unix silent value('cp ' + file-name + ' ' + v-arc).

    message " ФАЙЛ " + file-name  + " ОТПРАВЛЕН!" skip(1) view-as alert-box title "О Т П Р А В К А".
end.