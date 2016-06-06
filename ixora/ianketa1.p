/* ianketa1.p
 * MODULE
        Потребкредит
 * DESCRIPTION
        Обработка интернет-анкет, пре-гцвп
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
        20/05/2005 madiyar
 * CHANGES
        27/05/2005 madiyar - Временно добавил свой ящик для тестирования
        23/06/2005 madiyar - номер анкеты еще сбрасывается по почте Головлевой Насте
        10/08/2005 madiyar - всем, независимо от рез-та, отправляется стандартное сообщение
        16/08/2005 madiyar - добавил адрес в список рассылки
        11/11/2005 madiyar - отказ по несовпадению РНН - только в Алматы
        13/01/2006 madiyar - справочник в sysc'е - список адресов для рассылки
        28/02/2006 madiyar - анкеты через казпочту
        03/05/2006 madiyar - подправил обработку казпочтовых анкет
        18/08/2006 madiyar - казпочта - не обрабатывался критерий рнн, поэтому проходили заявки по клиентам с непогашенным кредитом
        18/10/2006 madiyar - выключил обработку критерия aist
        24/04/2007 madiyar - веб-анкеты
        18/09/2007 madiyar - немножко изменил передачу сообщений об ошибках (fmsg)
*/


{global.i}
{pk.i}
{sysc.i}
{pk-sysc.i}

define shared var v-email as char.
define shared var v-maillist as char.

define shared temp-table t-anket like pkanketh.
def var v-refus as char no-undo init ''.
def var v-refusname as char no-undo init ''.
define shared var v-fmsg as char no-undo init ''.

def var v-newsts as char no-undo init "80".
def var v-str as char no-undo.
def var v-type as char no-undo.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

v-type = pkanketa.id_org.
if v-type = "inet" then v-newsts = "77".
else
if v-type = "wclient" then v-newsts = "80".

{pkkritlib.i}

for each t-anket:
    delete t-anket.
end.

for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln no-lock:
  create t-anket.
  buffer-copy pkanketh to t-anket.
end.

/* Если записи для сообщений нет - создадим */
/*
find first pkkrit where pkkrit.kritcod = "fmsg" no-lock no-error.
if avail pkkrit then do:
    find first t-anket where t-anket.kritcod = pkkrit.kritcod no-error.
    if not avail t-anket then do:
      create t-anket.
      assign t-anket.bank = s-ourbank
             t-anket.credtype = s-credtype
             t-anket.ln = int(pkkrit.ln)
             t-anket.kritcod = pkkrit.kritcod
             t-anket.value1 = trim(pkkrit.res[2]).
    end.
end.
*/

for each pkkrit where pkkrit.priz = "1" and lookup (s-credtype, pkkrit.credtype) > 0 use-index kritcod no-lock:
    
    /*
    if pkanketa.id_org = "kazpost" then if pkkrit.kritcod <> "rnn" and pkkrit.kritcod <> "sik" then next.
    */
    if lookup(pkkrit.kritcod, "gcvpres,commentary") > 0 then next.
    
    find first t-anket where t-anket.kritcod = pkkrit.kritcod no-lock no-error.
    if avail t-anket then run value(pkkrit.proc) (t-anket.kritcod).
    
    if v-refus <> '' then leave.
  
end.


do transaction:

    for each pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln:
        delete pkanketh.
    end.
    
    for each t-anket:
        create pkanketh.
        buffer-copy t-anket to pkanketh.
        pkanketh.ln = s-pkankln.
    end.
    
    if v-refus <> '' then v-newsts = '00'.
    find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.kritcod = "fmsg" no-error.
    if avail pkanketh then do:
        if v-fmsg <> '' then pkanketh.rescha[1] = v-fmsg.
        if v-refus <> '' then do:
            find first bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = v-refus no-lock no-error.
            if avail bookcod then assign pkanketh.value2 = trim(bookcod.name) v-refusname = trim(bookcod.name).
        end. /* if v-refus <> '' */
    end. /* if avail pkanketh */
    
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln exclusive-lock.
    pkanketa.sts = v-newsts.
    pkanketa.refusal = v-refus.
    find current pkanketa no-lock.
    
    if v-refus <> '' then do:
        v-str = s-ourbank + ", анкета " + string(s-pkankln) + " " + pkanketa.name + ", sts=" + v-newsts + "\nпричины отказа=" + v-refus + " " + v-refusname.
        if v-fmsg <> '' then do:
            v-str = v-str + "\n".
            do i = 1 to num-entries(v-fmsg,"|"):
                v-str = v-str + "\n" + entry(i,v-fmsg,"|").
            end.
        end. /* if v-fmsg <> '' */
        if v-maillist <> '' then run mail(
                                         v-maillist,
                                         "METROBANK <abpk@metrobank.kz>",
                                         "Интернет-анкета " + pkanketa.id_org,
                                         v-str, "1", "", ""
                                         ).
        if v-email <> '' then do:
            if v-type = "inet" then run mail(
                                            v-email,
                                            "METROBANK <abpk@metrobank.kz>",
                                            "Интернет-анкета " + pkanketa.id_org,
                                            v-str, "1", "", ""
                                            ).
            else if v-type = "wclient" then run mail(
                                                    v-email,
                                                    "METROBANK <abpk@metrobank.kz>",
                                                    "Интернет-анкета",
                                                    "Свяжитесь, пожалуйста, с менеджером отдела кредитования ТОО ""МКО ""Народный Кредит"".\n\nВнимание! Данная заявка действительна в течение 5 рабочих дней.",
                                                    "1", "", ""
                                                    ).
        end.
    end. /* if v-refus <> '' */
end. /* transaction */

