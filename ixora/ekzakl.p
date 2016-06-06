/* ekzakl.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Заключения
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
def var v-sel      as inte no-undo.
def var v-infile   as char no-undo.
def var v-ofile    as char no-undo.
def var v-str      as char no-undo.
def var vnomer     as char no-undo.
def var vdecis     as char no-undo.
def var v-eps      as deci.
def var v-summax   as deci.
def var v-sumtreb  as deci.
def var v-sumcred  as deci.
def var v-platej   as deci.
def var v-srok     as inte.
def var v-koef     as deci.
def var v-sprcod   as char.
def var v-rate     as deci.
def var v-metam    as char.
def var v-comorg   as deci.
def var v-fine     as char.
def var v-gr       as inte.
def var v-spname   as char.
def var v-day      as inte.
def var v-mon      as inte.
def var v-year     as inte.
def var v-edat     as date.
def var v-comis    as deci.
def var v-maillist as char.
def var i          as inte.

def var vmonthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

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

    run sel2 ("Выберите :", " 1. Заключение ККФ | 2. Заключение МКК | 3. Выход ", output v-sel).
    case v-sel:
        when 1 then do:
            v-infile  = "/data/docs/" + "zaklKKF.htm".
            v-ofile = "Zaklyuch_KKF.htm".
            find first codfr where codfr.codfr = 'clmail' and codfr.code = 'kkfmail' no-lock no-error.
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
            run mail(v-maillist, "FORTEBANK <abpk@fortebank.com>", "Заключение ККФ",
            "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.1 «Анкета клиента» - «Протокола», необходимо рассмотреть заявку на ККФ. Клиент: "
            + pkanketa.name + ", ИИН: " + pkanketa.rnn + ", код клиента: " + pkanketa.cif + ", номер анкеты: " + string(pkanketa.ln)
            + ". Дата поступления задачи:" + string(g-today) + ", " + string(time,"hh:mm:ss") + "Бизнес-процесс: Экспресс кредит", "", "", "").
            message " Письмо секретарю ККФ отправлено! " view-as alert-box.
        end.
        when 2 then do:
            v-infile  = "/data/docs/" + "zaklMKK.htm".
            v-ofile = "Zaklyuch_MKK.htm".
            find first codfr where codfr.codfr = 'clmail' and codfr.code = 'dmomail' no-lock no-error.
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
            run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>","Заключение МКК",
            "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.1 «Анкета клиента» - «Протокола», необходимо рассмотреть заявку на МКК. Клиент: "
            + pkanketa.name + ", ИИН: " + pkanketa.rnn + ", код клиента: " + pkanketa.cif + ", номер анкеты: " + string(pkanketa.ln)
            + ". Дата поступления задачи:" + string(g-today) + ", " + string(time,"hh:mm:ss") + "Бизнес-процесс: Экспресс кредит", "", "", "").
            message " Письмо секретарю МКК отправлено! " view-as alert-box.
        end.
        when 3 then return.
    end.

    output stream out to value(v-ofile).

    find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.

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
        if v-metam = 'аннуитет'                   then assign v-comorg = credhdbk.comann v-gr = 1 v-comis = pkanketa.summa * credhdbk.comann / 100.
        if v-metam = 'дифференцированные платежи' then assign v-comorg = credhdbk.comdif v-gr = 2 v-comis = pkanketa.summa * credhdbk.comdif / 100.
        v-fine = credhdbk.fine.
    end.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'edaytr' no-lock no-error.
    if avail pkanketh then v-day = inte(pkanketh.value1).
    v-year = year(g-today).
    v-mon = month(g-today) + 1.
    if v-mon > 12 then do:
        v-mon = v-mon - 12.
        v-year = v-year + 1.
    end.
    v-edat = date(v-mon,v-day,v-year).

    run erl_ek1(pkanketa.summa,v-srok,pkanketa.rateq,v-gr,g-today,v-edat,v-edat,v-edat,v-comis,0,0,0,0,no,output v-eps).
    v-eps = round(v-eps,1).
    if pkanketa.resdec[1] = 0 then do:
        find current pkanketa exclusive-lock no-error.
        pkanketa.resdec[1] = v-eps.
        find current pkanketa no-lock no-error.
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

            if v-str matches "*vname*" then do:
                v-str = replace (v-str, "vname", pkanketa.name).
                next.
            end.

            if v-str matches "*vbin*" then do:
                v-str = replace (v-str, "vbin", pkanketa.rnn).
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

            if v-str matches "*vstav*" then do:
                v-str = replace (v-str, "vstav", string(pkanketa.rateq)).
                next.
            end.

            if v-str matches "*vaddr1*" then do:
                v-str = replace (v-str, "vaddr1", pcstaff0.addr[1]).
                next.
            end.

            if v-str matches "*vaddr2*" then do:
                v-str = replace (v-str, "vaddr2", pcstaff0.addr[2]).
                next.
            end.

            if v-str matches "*vtel1*" then do:
                v-str = replace (v-str, "vtel1", pcstaff0.tel[1]).
                next.
            end.

            if v-str matches "*vtel2*" then do:
                v-str = replace (v-str, "vtel2", pcstaff0.tel[2]).
                next.
            end.

            if v-str matches "*vmethod*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emetam' no-lock no-error.
                v-str = replace (v-str, "vmethod", pkanketh.value1).
                next.
            end.

            if v-str matches "*vwork*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'ewplc' no-lock no-error.
                v-str = replace (v-str, "vwork", pkanketh.value1).
                next.
            end.

            if v-str matches "*vposit*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'eposit' no-lock no-error.
                v-str = replace (v-str, "vposit", pkanketh.value1).
                next.
            end.

            if v-str matches "*vstpos*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'experl' no-lock no-error.
                v-str = replace (v-str, "vstpos", pkanketh.value1).
                next.
            end.

            if v-str matches "*vstob*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'experlob' no-lock no-error.
                v-str = replace (v-str, "vstob", pkanketh.value1).
                next.
            end.

            if v-str matches "*vspname*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'espsnam' no-lock no-error.
                v-spname = pkanketh.value1.
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'espfnam' no-lock no-error.
                v-spname = v-spname + ' ' + pkanketh.value1.
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'espmnam' no-lock no-error.
                v-spname = v-spname + ' ' + pkanketh.value1.
                v-str = replace (v-str, "vspname", v-spname).
                next.
            end.

            if v-str matches "*vspwork*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'estwplc' no-lock no-error.
                v-str = replace (v-str, "vspwork", pkanketh.value1).
                next.
            end.

            if v-str matches "*vmarsts*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emarsts' no-lock no-error.
                v-str = replace (v-str, "vmarsts", pkanketh.value1).
                next.
            end.

            if v-str matches "*vchild*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'echildl' no-lock no-error.
                v-str = replace (v-str, "vchild", pkanketh.value1).
                next.
            end.

            if v-str matches "*vsvyaz*" then do:
                find first prisv where prisv.rnn = pkanketa.rnn no-lock no-error.
                if avail prisv then v-str = replace (v-str, "vsvyaz", "Да").
                else v-str = replace (v-str, "vsvyaz", "Нет").
                next.
            end.

            if v-str matches "*vgesv*" then do:
                v-str = replace (v-str, "vgesv", string(pkanketa.resdec[1])).
                next.
            end.

            if v-str matches "*vcomorg*" then do:
                v-str = replace (v-str, "vcomorg", string(v-comorg)).
                next.
            end.

            if v-str matches "*vsalary*" then do:
                v-str = replace (v-str, "vsalary", string(pcstaff0.salary)).
                next.
            end.

            if v-str matches "*vspsal*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'espsal' no-lock no-error.
                v-str = replace (v-str, "vspsal", pkanketh.value1).
                next.
            end.

            if v-str matches "*vezhmescr*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'maxpl234' no-lock no-error.
                v-str = replace (v-str, "vezhmescr", pkanketh.rescha[1]).
                next.
            end.

            if v-str matches "*vezhmesbvu*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'plattekob123' no-lock no-error.
                v-str = replace (v-str, "vezhmesbvu", pkanketh.rescha[1]).
                next.
            end.

            if v-str matches "*vobsch*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'ball234' no-lock no-error.
                v-str = replace (v-str, "vobsch", replace(pkanketh.rescha[1],"(OK)","")).
                next.
            end.

            if v-str matches "*vsoot*" then do:
                find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'ball234' no-lock no-error.
                v-str = replace (v-str, "vsoot", string(round(deci(substr(pkanketh.rescha[1],1,index(pkanketh.rescha[1],'(') - 1)) / pcstaff0.salary * 100,2))).
                next.
            end.

            if v-str matches "*vscor*" then do:
                v-str = replace (v-str, "vscor", string(pkanketa.rating)).
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