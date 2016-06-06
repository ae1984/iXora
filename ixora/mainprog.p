/* mainprog.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Автоматическая рассылка отчетов
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
        --/--/2011 damir
 * BASES
        BANK COMM
 * CHANGES
        03.10.2011 damir - убрал rep2-2.
        24.10.2011 damir - добавил rep4-1.
        25.10.2011 damir - добавил rep5-1.
        16.11.2011 damir - увеличил время.
        27.01.2012 damir - перекомпиляция.
        28.02.2012 damir - отчет "Анализ процентной маржи" должен приходить 1 - го числа...
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        04.07.2012 damir - добавил valpozsv,FileExist. Сохранение данных по Валютной позиции.
        13.07.2012 damir - добавил дополнительный промежуток времени запуска отчета Валютной позиции.
        23.07.2012 damir - убрал рассылку отчета "Концентрация клиентской депозитной базы ЮЛ и ФЛ".
        01.08.2012 damir - добавил проверку по дате запуска отчета Валютной позиции.
        26.04.2013 damir - Оптимизация кода.
*/

{global.i}
{comm-txb.i}

def var v-proc as char.
def var v-weekbeg as inte. /*первый день недели*/
def var v-weekend as inte. /*последний день недели*/
def var v-day as inte.
def var s-yes as logi format "да/нет" init no.
def var v-DAYS as date.
def var v-recid as RECID.

def new shared var RepPath as char init "/data/reports/valpoz/".
def new shared var RepName as char.
def new shared var v-statusRep as logi. /*Статус запуска отчета*/
def new shared var v-mailRep as char. /*Адресаты получателей рассылки*/

def buffer b-mailofc for mailofc.

v-day = weekday(today).

/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then do:
    v-weekbeg = sysc.inval.
end.
else v-weekbeg = 2.
/*******************************************************************************************/

/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then do:
    v-weekend = sysc.inval.
end.
else v-weekend = 6.
/*******************************************************************************************/

/************************определение - рабочий день или нет ********************************/
function Getdatests returns logi(input dt as date):
    def var s-bday as logi.
    find hol where hol.hol = dt no-lock no-error.
    if not available hol and weekday(dt) ge v-weekbeg and  weekday(dt) le v-weekend then s-bday = yes.
    else s-bday = no.
    return s-bday.
end function.
/*******************************************************************************************/
function FileExist returns log (input v-name as char).
    def var v-result as char init "".

    input through value ("cat " + v-name + " &>/dev/null || (NO)").
    repeat:
        import unformatted v-result.
    end.
    if v-result = "" then return true.
    else return false.
end function.
/*******************************************************************************************/

if v-day = 2 then s-yes = yes.  /*Пн*/
else if v-day = 3 then do:      /*Вт*/
    if Getdatests(today - 1) = no then s-yes = yes.
    else s-yes = no.
end.
else if v-day = 4 then do:      /*Ср*/
    if Getdatests(today - 2) = no and Getdatests(today - 1) = no then s-yes = yes.
    else s-yes = no.
end.
else if v-day = 5 then do:      /*Чт*/
    if Getdatests(today - 3) = no and Getdatests(today - 2) = no and Getdatests(today - 1) = no then s-yes = yes.
    else s-yes = no.
end.
else if v-day = 6 then do:      /*Пт*/
    if Getdatests(today - 4) = no and Getdatests(today - 3) = no and Getdatests(today - 2) = no and
    Getdatests(today - 1) = no then s-yes = yes.
    else s-yes = no.
end.

if v-day >= v-weekbeg and v-day <= v-weekend then do: /*если день входит в рабочую неделю*/
    if Getdatests(today) = yes then do:
        if string(time,"HH:MM:SS") >= "08:20:00" and string(time,"HH:MM:SS") <= "18:00:00" then do: /*запускаются все программы*/
            for each mailofc no-lock break by mailofc.proc:
                v-recid = RECID(mailofc). v-proc = "". v-statusRep = no. v-mailRep = "".
                if trim(mailofc.proc) = "rep1-1" then do: /*Отчет за день*/
                    v-proc = trim(mailofc.proc). v-statusRep = mailofc.sts. v-mailRep = trim(mailofc.mail).
                    if mailofc.date <> today then do:
                        run value(v-proc).
                        for each b-mailofc where RECID(b-mailofc) = v-recid exclusive-lock: b-mailofc.date = today. b-mailofc.tim = time. end.
                        for each b-mailofc no-lock: end.
                    end.
                end.
                if trim(mailofc.proc) = "rep2-1" then do: /*Концентрация клиентской депозитной базы ЮЛ и ФЛ*/
                    v-proc = trim(mailofc.proc). v-statusRep = mailofc.sts. v-mailRep = trim(mailofc.mail).
                    if s-yes and mailofc.date <> today then do:
                        run value(v-proc).
                        mailofc:
                        for each b-mailofc where RECID(b-mailofc) = v-recid exclusive-lock: b-mailofc.date = today. b-mailofc.tim = time. end.
                        for each b-mailofc no-lock: end.
                    end.
                end.
                if trim(mailofc.proc) = "rep5-1" then do: /*Просроченная задолженность и штрафы*/
                    v-proc = trim(mailofc.proc). v-statusRep = mailofc.sts. v-mailRep = trim(mailofc.mail).
                    if mailofc.date <> today then do:
                        run value(v-proc).
                        for each b-mailofc where RECID(b-mailofc) = v-recid exclusive-lock: b-mailofc.date = today. b-mailofc.tim = time. end.
                        for each b-mailofc no-lock: end.
                    end.
                end.
            end.
        end.
        if (string(time,"HH:MM:SS") >= "17:30:00" and string(time,"HH:MM:SS") <= "17:31:00") or (string(time,"HH:MM:SS") >= "18:30:00" and
        string(time,"HH:MM:SS") <= "18:31:00") or (string(time,"HH:MM:SS") >= "19:30:00" and string(time,"HH:MM:SS") <= "19:31:00") then do:
            for each mailofc no-lock break by mailofc.proc:
                v-recid = RECID(mailofc). v-proc = "". v-statusRep = no. v-mailRep = "".
                if mailofc.proc = "rep4-1" then do: /*Уведомление о неакцептованных документах - Валютный контроль*/
                    v-proc = trim(mailofc.proc). v-statusRep = mailofc.sts. v-mailRep = trim(mailofc.mail).
                    run value(v-proc).
                    for each b-mailofc where RECID(b-mailofc) = v-recid exclusive-lock: b-mailofc.date = today. b-mailofc.tim = time. end.
                    for each b-mailofc no-lock: end.
                end.
            end.
        end.
        if string(time,"HH:MM:SS") >= "18:00:00" and string(time,"HH:MM:SS") <= "21:00:00" then do:
            do transaction:
                find first dayrep where dayrep.day = today no-lock no-error.
                if not avail dayrep then do:
                    create dayrep.
                    dayrep.day = today.
                    dayrep.weekday = string(v-day).
                end.
                else leave.
            end.
        end.
    end.
end.
if day(today) = 1 then do:
    if string(time,"HH:MM:SS") >= "08:20:00" and string(time,"HH:MM:SS") <= "18:00:00" then do:
        for each mailofc no-lock break by mailofc.proc:
            v-recid = RECID(mailofc). v-proc = "". v-statusRep = no. v-mailRep = "".
            if mailofc.proc = "rep3-1" then do: /*Анализ процентной маржи*/
                v-proc = trim(mailofc.proc). v-statusRep = mailofc.sts. v-mailRep = trim(mailofc.mail).
                if today <> mailofc.date then do:
                    run value(v-proc).
                    for each b-mailofc where RECID(b-mailofc) = v-recid exclusive-lock: b-mailofc.date = today. b-mailofc.tim = time. end.
                    for each b-mailofc no-lock: end.
                end.
            end.
        end.
    end.
end.

/*Валютная позиция*/
/*---------------------------------------------------------------------------------------------------------------------------------*/
if month(g-today) = 1 then v-DAYS = date(12,20,year(g-today) - 1).
else v-DAYS = date(month(g-today) - 1,20,year(g-today)).
if (string(time,"HH:MM:SS") >= "19:00:00" and string(time,"HH:MM:SS") <= "23:00:00") or (string(time,"HH:MM:SS") >= "00:00:00" and
string(time,"HH:MM:SS") <= "08:50:00") or (string(time,"HH:MM:SS") >= "12:00:00" and string(time,"HH:MM:SS") <= "15:00:00") then do:
    for each cls where cls.whn >= v-DAYS and cls.whn <= g-today - 1 no-lock break by cls.whn:
        RepName = "valpoz_" + replace(string(cls.whn,"99/99/9999"),"/","-") + ".rep".
        if not FileExist(RepPath + RepName) then do:
            run valpozsv(cls.whn,"CRCPOS").
        end.
    end.
end.
/*---------------------------------------------------------------------------------------------------------------------------------*/