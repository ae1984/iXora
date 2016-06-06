/* ekprot.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Протокола
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3-2-7-1
 * AUTHOR
        11.11.2013 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def shared var v-cifcod   as char no-undo.
def shared var s-credtype as char.
def shared var v-bank     as char no-undo.
def shared var s-ln       as inte no-undo.

def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var vnomer  as char no-undo.
def var vdecis  as char no-undo.
def var vmonthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-summax as deci.
def var v-sumtreb as deci.
def var v-sumcred as deci.
def var v-platej as deci.
def var v-srok as inte.
def var v-koef as deci.
def var v-sprcod as char.
def var v-rate as deci.
def var v-metam as char.
def var v-comorg as deci.
def var v-fine as char.
def var v-maillist as char.
def var i          as inte.

find first codfr where codfr.codfr = 'clmail' and codfr.code = 'mofmail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
end.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.credtype = '10' and pkanketa.ln = s-ln no-lock no-error.
if avail pkanketa then do:

    if pkanketa.sts <> '110' then do:
        message 'Статус анкеты не соответствует вынесению на Кредитный Комитет!' view-as alert-box.
        return.
    end.

    if pkanketa.sts = '111' then do:
        message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
        return.
    end.

    run sel2 ("Выберите :", " 1. Протокол ККФ | 2. Протокол МКК | 3. Выход ", output v-sel).
    case v-sel:
        when 1 then do:
            v-infile  = "/data/docs/" + "protKKF.htm".
            v-ofile = "Protokol_KKF.htm".
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>","Протокол ККФ",
            "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.2 «Контроль МОФ» - «Информация по протоколу», необходимо выбрать решение, ввести номер и дату Протокола. Клиент: "
            + pkanketa.name + ", ИИН: " + pkanketa.rnn + ", код клиента: " + pkanketa.cif + ", номер анкеты: " + string(pkanketa.ln)
            + ". Дата поступления задачи:" + string(g-today) + ", " + string(time,"hh:mm:ss") + "Бизнес-процесс: Экспресс кредит", "", "", "").
            message " Письмо сотруднику МОФ отправлено! " view-as alert-box.
        end.
        when 2 then do:
            v-infile  = "/data/docs/" + "protMKK.htm".
            v-ofile = "Protokol_MKK.htm".
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>","Протокол МКК",
            "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.2 «Контроль МОФ» - «Информация по протоколу», необходимо выбрать решение, ввести номер и дату Протокола. Клиент: "
            + pkanketa.name + ", ИИН: " + pkanketa.rnn + ", код клиента: " + pkanketa.cif + ", номер анкеты: " + string(pkanketa.ln)
            + ". Дата поступления задачи:" + string(g-today) + ", " + string(time,"hh:mm:ss") + "Бизнес-процесс: Экспресс кредит", "", "", "").
            message " Письмо сотруднику МОФ отправлено! " view-as alert-box.
        end.
        when 3 then return.
    end.

    output stream out to value(v-ofile).

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'esroktr' no-lock no-error.
    if avail pkanketh then v-srok = inte(pkanketh.value1).

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'eratrew' no-lock no-error.
    if avail pkanketh then v-rate = deci(pkanketh.value1).

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emetam' no-lock no-error.
    if avail pkanketh then v-metam = pkanketh.value1.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'evidfin' no-lock no-error.
    if avail pkanketh then do:
        if pkanketh.value1 = 'кредит' then v-sprcod = '1,2,3,4'.
        if pkanketh.value1 = 'рефинансирование' then v-sprcod = '5,6,7,8,9,10,11,12,13,14,15,16,17'.
        find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
        find first hdbkcif where can-do(v-sprcod,hdbkcif.hdbkcod) and ((not pcstaff0.cifb begins 'TXB' and hdbkcif.cif = pcstaff0.cifb) or hdbkcif.cif = 'OURBNK') and not hdbkcif.del and hdbkcif.con no-lock no-error.
        find first credhdbk where credhdbk.hdbkcod = hdbkcif.hdbkcod no-lock no-error.
        if v-metam = 'аннуитет' then v-comorg = credhdbk.comann.
        if v-metam = 'дифференцированные платежи' then v-comorg = credhdbk.comdif.
        v-fine = credhdbk.fine.
    end.

    input from value(v-infile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*vnomer*" then do:
                if pkanketa.rescha[1]  = '' then
                vnomer = substr(v-bank,4) + 'ЭК-' + string(year(today),'9999') + '-' + string(month(today),'99') + '/' + string(day(today),'99') + '-' + string(pkanketa.ln).
                else vnomer = pkanketa.rescha[1].
                v-str = replace (v-str, "vnomer", vnomer).
                next.
            end.

            if v-str matches "*vregion*" then do:
                find first cmp no-lock no-error.
                v-str = replace (v-str, "vregion", cmp.name).
                next.
            end.

            if v-str matches "*vday*" then do:
                v-str = replace (v-str, "vday", '«' + string(day(today),'99') + '»').
                next.
            end.

            if v-str matches "*vmonth*" then do:
                v-str = replace (v-str, "vmonth", entry(month(today),vmonthname)).
                next.
            end.

            if v-str matches "*vyear*" then do:
                v-str = replace (v-str, "vyear", substr(string(year(today),'9999'),3)).
                next.
            end.

            if v-str matches "*vcity*" then do:
                find first cmp no-lock no-error.
                v-str = replace (v-str, "vcity", trim(trim(substr(cmp.addr[1],index(cmp.addr[1],',') + 2,index(substr(cmp.addr[1],index(cmp.addr[1],',') + 2),",")), 'г.'),',')).
                next.
            end.

            /*if v-str matches "*vdecision*" then do:
                if pkanketa.rating = 0 then vdecis = 'Одобрить предоставление Экспресс кредита на следующих условиях:'.
                if pkanketa.rating < 0 then vdecis = 'Отказать в предоставлении Экспресс кредита на следующих условиях:'.
                v-str = replace (v-str, "vdecision", vdecis).
                next.
            end.*/

            if v-str matches "*vname*" then do:
                v-str = replace (v-str, "vname", pkanketa.name).
                next.
            end.

            if v-str matches "*viin*" then do:
                v-str = replace (v-str, "viin", pkanketa.rnn).
                next.
            end.

            if v-str matches "*vball*" then do:
                v-str = replace (v-str, "vball", '«' + string(pkanketa.rating) + '»').
                next.
            end.

            if v-str matches "*vsum*" then do:
                v-str = replace (v-str, "vsum", string(pkanketa.summa)).
                next.
            end.

            if v-str matches "*vsrok*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'esroktr' no-lock no-error.
                v-str = replace (v-str, "vsrok", pkanketh.value1).
                next.
            end.

            if v-str matches "*vgodst*" then do:
                v-str = replace (v-str, "vgodst", string(pkanketa.rateq)).
                next.
            end.

            if v-str matches "*vgoal*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'evidfin' no-lock no-error.
                if pkanketh.value1 = 'кредит' then v-str = replace (v-str, "vgoal", 'Потребительские цели').
                else v-str = replace (v-str, "vgoal", 'Рефинансирование').
                next.
            end.

            if v-str matches "*vmet*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emetam' no-lock no-error.
                v-str = replace (v-str, "vmet", pkanketh.value1).
                next.
            end.

            if v-str matches "*vcom*" then do:
                v-str = replace (v-str, "vcom", string(v-comorg)).
                next.
            end.

            if v-str matches "*vfine*" then do:
                v-str = replace (v-str, "vfine", v-fine).
                next.
            end.

            leave.
        end. /* repeat */

        put stream out unformatted v-str skip.
    end. /* repeat */
    input close.
    /********/
    output stream out close.

    unix silent value("cptwin " + v-ofile + " winword").
    unix silent value("rm -r " + v-ofile).
end.