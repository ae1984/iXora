/* usrcn1.p
 * MODULE
        Депозитарий
 * DESCRIPTION
        Отчет по счетам сейфовых ячеек.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.1.8.14
 * BASES
        BANK COMM IB
 * AUTHOR
        26.06.2011 id00004
 * CHANGES
        09.12.2011 id00004 добавил выбор режима Просмотр, Полный доступ
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
        03.05.2012 aigul - добавила списание комиссии за ЭЦП
        22.11.2012 berdibekov - главный бухгалтер
		30.01.2013 id00477 - преобразование спец. символов в html сущности
        11.02.2013 zhasulan - ТЗ 1660 убрал поле РНН
        01.10.2013 yerganat - добавил признак резидентства и код страны гражданства для сотрудника
*/



{global.i}
{yes-no.i}
{srvcheck.i}

{sysc.i}
def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

define variable v-depart as char.
define variable v-fault as char.
define variable v-deplist as char.
define variable v-rec  as char init ''.
define variable v-send as char init ''.
define variable v-tem  as char init ''.
define variable v-mess as char init ''.
define variable v-aksk as char.
def var v-sqn as integer.
def var v-comm as char initial "".
def buffer bwebra for webra.
def buffer bsysc for sysc.


  def frame ShowDetail
    webra.director_name      format "x(50)"      label  "Фамилия руководителя      "      skip
    webra.info[1]            format "x(50)"      label  "Имя     руководителя      "      skip
    webra.info[2]            format "x(50)"      label  "Отчество руководителя     "      skip
    webra.director_position  format "x(50)"      label  "Должность руководителя    "      skip
    webra.org_mail           format "x(50)"      label  "E-mail организации        "      skip
    webra.info[3]            format "x(50)"      label  "Фамилия сотрудника        "      skip
    webra.info[4]            format "x(50)"      label  "Имя  сотрудника           "      skip
    webra.info[5]            format "x(50)"      label  "Отчество сотрудника       "      skip
    webra.cln_resident       format "x(50)"      label  "Резидентство сотрудника   "      skip
    webra.info[6]            format "x(50)"      label  "Должность сотрудника      "      skip
    webra.cln_birthdate      format "99/99/9999" label  "Дата рождения             "      skip
    webra.cln_passportnum    format "x(50)"      label  "№ Удостоверения           "      skip
    webra.cln_issuer         format "x(50)"      label  "Орган выдавший            "      skip
    webra.cln_issuerdate                         label  "Дата выдачи               "      skip
    webra.cln_iin            format "x(50)"      label  "ИИН                       "      skip
    webra.cln_citizenship    format "x(50)"      label  "Код страны гражданства    "      skip
    webra.cln_phone          format "x(50)"      label  "Номер телефона            "      skip
    webra.cln_mobile         format "x(50)"      label  "Номер сотового            "      skip
    webra.cln_email          format "x(50)"      label  "E-mail  сотрудника        "      skip
    webra.cln_addres         format "x(50)"      label  "Адрес сотрудника          "      skip
    webra.login              format "x(50)"      label  "Логин сотрудника          "      skip
    usr.ip_trust[20]         format "x(50)"      label  "Признак доступа клиента   "      skip
    webra.info[7]            format "x(50)"      label  "Признак доступа польз-ля  "      skip
    v-comm                   format "x(50)"      label  "Оплата комиссии           "      skip
 with side-labels centered row 6.



/*id00477 - преобразование спец. символов в html сущности*/
function info_name_replacer returns char (input info_name as char).

	info_name = replace (info_name, "&", "&amp;").
	info_name = replace (info_name, ">", "&gt;").
	info_name = replace (info_name, "<", "&lt;").
	info_name = replace (info_name, """", "&quot;").
	info_name = replace (info_name, "'", "&apos;").
	return(info_name).

end function.


find last bsysc where bsysc.sysc = 'ourbnk' no-lock no-error.

define buffer b-ofc for ofc.

define query q1 for webra.

def browse b1 query q1 no-lock
  display
      webra.login label 'Логин'
      webra.cif label 'CIF-код' format 'x(35)'
  with 9 down separators single title " КОНТРОЛЬ ОРГАНИЗАЦИЙ ".

define frame f1
   b1 help "ENTER - детали, F1 - Акцепт, F8 - Отказ, F4 - Выход"
with row 2 centered.


on "return" of browse b1 do:
  find last usr where usr.cif = webra.cif no-lock no-error.
  if webra.comm = yes then v-comm = "Оплачена со счета".
  if webra.comm = no then v-comm = "Комиссия не оплачена".
  displ webra.director_name
        webra.info[1]
        webra.info[2]
        webra.director_position
        webra.org_mail
        webra.info[3]
        webra.info[4]
        webra.info[5]
        webra.info[6]
        webra.cln_resident
        webra.cln_birthdate
        webra.cln_passportnum
        webra.cln_issuer
        webra.cln_issuerdate
        webra.cln_iin
        webra.cln_citizenship
        webra.cln_phone
        webra.cln_mobile
        webra.cln_email
        webra.cln_addres
        webra.login
        usr.ip_trust[20]
        webra.info[7]
        v-comm
with frame ShowDetail.


end.

on "go" of browse b1
do:
    if yes-no ("ВНИМАНИЕ", "Акцептовать и произвести экспорт в сервис 'Администратор ИБ'?")
    then do:
        find last cif where cif.cif = webra.cif no-lock no-error.
        if not avail cif then do:
          message "Не найден CIF-код клиента продолжение невозможно" .
          return.
        end.
        find last usr where usr.cif = webra.cif no-lock no-error.

        run savelog ("webra", webra.login +  " АКЦЕПТ " +  " Менеджер: "  + g-ofc + " Дата операционная: " + string(g-today) +  " Дата текущая"  + string(today) +  " Время: " + string(time, "hh:mm:ss")) .

        find last bwebra where bwebra.login = webra.login and bwebra.txb = webra.txb exclusive-lock.
        /*  find last bwebra where bwebra.login = webra.login exclusive-lock. */
        bwebra.contrl  = 0.
        v-sqn =  next-value(msgid).

        /******Отправка в СОНИК*******************************/

        DEFINE VARIABLE ptpsession AS HANDLE.
        DEFINE VARIABLE messageH AS HANDLE.
        run jms/ptpsession.p persistent set ptpsession ("-h localhost -s 5162 ").

        if isProductionServer() then RUN setBrokerURL IN ptpsession ("tcp://172.16.3.5:2507").
        else RUN setBrokerURL IN ptpsession ("tcp://172.16.2.77:2507").

        run setUser in ptpsession ('SonicClient').
        run setPassword in ptpsession ('SonicClient').
        RUN beginSession IN ptpsession.
        run createXMLMessage in ptpsession (output messageH).

        RUN setStringProperty IN messageH ("TYPE", "CLIENT").

        run setText in messageH ("<?xml version=""1.0"" encoding=""UTF-8""?>").
        run appendText in messageH ("<organization message_id=""" + string(v-sqn) + """>").

        run appendText in messageH ("<info name=""" + info_name_replacer (trim(cif.prefix + " " + trim(replace(replace (cif.name, "'", ""), '"', ''))))   + """>").
        run appendText in messageH ("<ext_id>" + cif.cif + "</ext_id>").
        run appendText in messageH ("<contract_num>" + string(usr.id) + "</contract_num>").
        run appendText in messageH ("<contract_date>" +  string(substr(string(cif.regdt),1,2))  + '.' + string(substr(string(cif.regdt),4,2)) + '.' + string(year(cif.regdt)) + "</contract_date>").
        run appendText in messageH ("<address>" + string(trim(replace(replace((cif.addr[1]), "'", ""), '"', ''))) +  "</address>").
        find last sysc where sysc.sysc = "citi" no-lock no-error.
        run appendText in messageH ("<city>" + string(sysc.chval) +   "</city>").
        run appendText in messageH ("<phone>" + string(cif.tel) +  "</phone>").
        run appendText in messageH ("<fax>" + string(cif.fax) +  "</fax>").
        run appendText in messageH ("<email>" + string(webra.org_mail) +  "</email>").

        def var KOF as char.
        select substr(cif.geo,3,1) + sub-cod.ccode into KOF from cif,sub-cod
                where cif.cif=usr.cif
                and sub-cod.sub="cln"
                and cif.cif=sub-cod.acc
                and sub-cod.d-cod="secek".

        run appendText in messageH ("<code>" + KOF +  "</code>").

        if substr(cif.geo,3,1) = "1" then
            run appendText in messageH ("<is_resident>1</is_resident>").
        else
            run appendText in messageH ("<is_resident>0</is_resident>").

        find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnbk' no-lock no-error.
        if avail sub-cod then do:
            run appendText in messageH ("<responsible_person>" + string(sub-cod.rcode) +  "</responsible_person>").
        end.
        else do:
            find first sub-cod where sub-cod.acc = cif.cif and sub-cod.sub = 'cln' and sub-cod.d-cod = 'clnchf' no-lock no-error.
            if avail sub-cod then do:
                run appendText in messageH ("<responsible_person>" + string(sub-cod.rcode) +  "</responsible_person>").
            end.
            else do:
                run appendText in messageH ("<responsible_person> Не определен </responsible_person>").
            end.
        end.

        run appendText in messageH ("<lock_word> Не задано </lock_word>").
        run appendText in messageH ("<comments>" + string(cif.attn) + "</comments>").
        run appendText in messageH ("<certificate>" + cif.ref[8] + "</certificate>").
        run appendText in messageH ("<certificate_issuer>" + webra.cer_issuer  + "</certificate_issuer>").
        run appendText in messageH ("<certificate_issue_date>" + string(substr(string(webra.cert_issuer_date),1,2)) + '.' + string(substr(string(webra.cert_issuer_date),4,2)) + '.' + string(year(date(webra.cert_issuer_date)))  + "</certificate_issue_date>").
        run appendText in messageH ("<director_name>" + webra.director_name + " " +  webra.info[1] + " " +  webra.info[2] +  "</director_name>").
        run appendText in messageH ("<director_position>" + webra.director_position + "</director_position>").
        run appendText in messageH ("<bin>" + webra.bin  + "</bin>").
        run appendText in messageH ("</info>").

        run appendText in messageH ("<accounts>").
        def var v-cpool as logical.
        v-cpool = false.
        find last cashpool where cashpool.isgo = false and cashpool.cif = cif.cif no-lock no-error.
        if avail cashpool then do:
            message "Компания является филиальной компанией Кэш-пуллинга"  view-as alert-box question buttons yes-no title "" update v-cpool .
        end.
        if v-cpool = true then do:
           message "подключение филиальных компаний запрещено"  view-as alert-box question  title "" .
           return.
        end.
        if v-cpool = false then do:

            for each aaa where aaa.cif = cif.cif  no-lock:
                if length(aaa.aaa) < 15 then next.
                find last lgr where lgr.lgr = aaa.lgr no-lock.
                if lgr.led = "DDA" or lgr.led = "SAV" or lgr.led = "CDA" or lgr.led = "TDA" then do:
                    run appendText in messageH ("<account code=""" + string(aaa.aaa) + """>").
                    if lgr.led = "SAV" then
                        run appendText in messageH ("<type>1</type>").
                    else
                        run appendText in messageH ("<type>0</type>").

                    find last crc where crc.crc = aaa.crc no-lock no-error.
                    run appendText in messageH ("<currency>" + crc.code + "</currency>").
                    run appendText in messageH ("<create_date>" + string(substr(string(aaa.regdt),1,2)) + '.' + string(substr(string(aaa.regdt),4,2)) + '.' + string(year(aaa.regdt))  + "</create_date>").

                    if aaa.sta = "C" then
                       run appendText in messageH ("<status>0</status>").
                    else
                       run appendText in messageH ("<status>1</status>").

                    find sysc where sysc.sysc = "clecod" no-lock no-error.
                    if not avail sysc then do:  message "В настройках не найден БИК банка". end.

                    run appendText in messageH ("<bic>" + v-clecod + "</bic>").
                    run appendText in messageH ("<comments>Не задано</comments>").
                    run appendText in messageH ("</account>").
                end.
            end.

            /*КЭШПУЛЛИНГ==============================================================*/
            /*КЭШПУЛЛИНГ==============================================================*/
            /*КЭШПУЛЛИНГ==============================================================*/
            /*for each cashpool where cashpool.cif = cif.cif and cashpool.isgo = true and cashpool.cifgo = "" no-lock: */
            for each  cashpool where cashpool.cifgo = cif.cif and cashpool.isgo = false   no-lock:
                for each aaa where aaa.aaa = cashpool.acc  no-lock:
                    if length(aaa.aaa) < 15 then next.
                    find last lgr where lgr.lgr = aaa.lgr no-lock.
                    if lgr.led = "DDA" or lgr.led = "SAV" or lgr.led = "CDA" or lgr.led = "TDA" then do:
                        run appendText in messageH ("<account code=""" + string(aaa.aaa) + """>").
                        if lgr.led = "SAV" then
                            run appendText in messageH ("<type>1</type>").
                        else
                            run appendText in messageH ("<type>0</type>").
                        find last crc where crc.crc = aaa.crc no-lock no-error.
                        run appendText in messageH ("<currency>" + crc.code + "</currency>").
                        run appendText in messageH ("<create_date>" + string(substr(string(aaa.regdt),1,2)) + '.' + string(substr(string(aaa.regdt),4,2)) + '.' + string(year(aaa.regdt))  + "</create_date>").

                        if aaa.sta = "C" then
                           run appendText in messageH ("<status>0</status>").
                        else
                           run appendText in messageH ("<status>1</status>").

                        find sysc where sysc.sysc = "clecod" no-lock no-error.
                        if not avail sysc then do:  message "В настройках не найден БИК банка". end.

                        run appendText in messageH ("<bic>" + v-clecod + "</bic>").
                        run appendText in messageH ("<comments>Не задано</comments>").
                        run appendText in messageH ("</account>").
                     end.
                end.
            end.
            /*КЭШПУЛЛИНГ==============================================================*/
            /*КЭШПУЛЛИНГ==============================================================*/
            /*КЭШПУЛЛИНГ==============================================================*/
        end.

        run appendText in messageH ("</accounts>").

        run appendText in messageH ("<employee>").
        run appendText in messageH ("<login>"       + webra.login + "</login>").
        run appendText in messageH ("<last_name>"   + webra.info[3] + "</last_name>").
        run appendText in messageH ("<first_name>"  + webra.info[4] + "</first_name>").
        run appendText in messageH ("<middle_name>" + webra.info[5] + "</middle_name>").
        run appendText in messageH ("<position>"    + webra.info[6] + "</position>").
        run appendText in messageH ("<birth_date>"    + string(substr(string(webra.cln_birthdate),1,2)) + '.' + string(substr(string(webra.cln_birthdate),4,2)) + '.' + string(year(webra.cln_birthdate))  + "</birth_date>").
        run appendText in messageH ("<id_number>"    + webra.cln_passportnum + "</id_number>").
        run appendText in messageH ("<id_issuer>"    + webra.cln_issuer + "</id_issuer>").
        run appendText in messageH ("<id_issue_date>" + string(substr(string(webra.cln_issuerdate),1,2)) + '.' + string(substr(string(webra.cln_issuerdate),4,2)) + '.' + string(year(date(webra.cln_issuerdate)))  +    "</id_issue_date>").
        run appendText in messageH ("<iin>"    + webra.cln_iin + "</iin>").
        run appendText in messageH ("<phones>"    + webra.cln_phone + "</phones>").
        run appendText in messageH ("<mobile>"    + webra.cln_mobile + "</mobile>").
        run appendText in messageH ("<emails>"    + webra.cln_email + "</emails>").
        run appendText in messageH ("<addresss>"    + webra.cln_addres + "</addresss>").

        if webra.info[7] = 'режим <ПОЛНЫЙ ДОСТУП>' then
            run appendText in messageH ("<authtype>2</authtype>").
        else
            run appendText in messageH ("<authtype>1</authtype>").

        if webra.cln_resident = 'резидент' then
            run appendText in messageH ("<is_resident>1</is_resident>").
        else
            run appendText in messageH ("<is_resident>0</is_resident>").

        run appendText in messageH ("<citizenship>"    + webra.cln_citizenship + "</citizenship>").
        run appendText in messageH ("</employee>").
        run appendText in messageH ("</organization>").

        RUN sendToQueue IN ptpsession ("CLIENTS", messageH, ?, ?, ?).
        /*       RUN sendToQueue IN ptpsession ("test", messageH, ?, ?, ?).   */

        RUN deleteMessage IN messageH.
        RUN deleteSession IN ptpsession.



        /******END Отправка в СОНИК*******************************/

        open query q1 for each webra where webra.contrl = 1 and webra.txb = bsysc.chval.

    end.
end.

on "clear" of browse b1
do:

   if yes-no ("ВНИМАНИЕ", "Отклонить данного клиента?")
   then do:
        find last bwebra where bwebra.login = webra.login and bwebra.txb = webra.txb exclusive-lock.
        bwebra.contrl  = 0.

        run savelog ("webra", bwebra.login +  " ОТКАЗ " +  " Менеджер: "  + g-ofc + " Дата операционная: " + string(g-today) +  " Дата текущая"  + string(today) +  " Время: " + string(time, "hh:mm:ss")) .
        open query q1 for each webra where webra.contrl = 1 and webra.txb = bsysc.chval.
   end.
end.

on 'end-error' of browse b1 hide frame f1.


open query q1 for each webra where webra.contrl = 1 and webra.txb = bsysc.chval.
enable all with frame f1.
wait-for window-close of frame f1 focus browse b1.


