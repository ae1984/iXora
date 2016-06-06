/* ekcrcont.p
 * MODULE
        Экспресс кредиты
 * DESCRIPTION
        Договора
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
        19.11.2013 Lyubov - ТЗ 2214, проставляем номер КД в loncon
*/

{global.i}

def shared var v-cifcod   as char no-undo.
def shared var s-credtype as char.
def shared var v-bank     as char no-undo.
def shared var s-ln       as inte no-undo.

def new shared var s-cif  like cif.cif.
s-cif = v-cifcod.

def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-str    as char no-undo.
def var vnomer  as char no-undo.
def var vdecis  as char no-undo.
def var vmonthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".
def var vmonkz as char init
   "ќантар,аќпан,наурыз,сјуір,мамыр,маусым,шілде,тамыз,ќыркїйек,ќазан,ќараша,желтоќсан".
def var vpropis  as char no-undo.
def var vpropis1 as char no-undo.
def var vpropkz  as char no-undo.
def var vpropkz1 as char no-undo.
def var dkface   as char no-undo.
def var v-otvlico as char.
def var vpoint like point.point .
def var vdep like ppoint.dep .
def var v-stamp as char.
def var v-dogsgn as char.
def var i as int.

def var v-list    as char.
def var v-method  as char.
def var v-goal    as char.
def var v-kmethod as char.
def var v-kgoal   as char.
def var buf       as inte.
def var word      as char.
def var v-day     as inte.
def var v-dd      as inte.
def var v-mon     as inte.
def var v-year    as inte.
def var v-day1    as inte.
def var v-mon1    as inte.
def var v-year1   as inte.
def var v-edat    as date.
def var v-edatnew    as date.
def var v-comorg  as deci.
def var v-comis   as deci.
def var v-metam   as char.
def var v-sprcod  as char.
def var v-eps     as deci.
def var v-srok    as inte.
def var v-gr      as inte.
def var v-nomer   as char.
def var v-ndate   as date.
def var bdate     as date.
def var v-maillist as char.
def var v-sprayzh as char init 'процент;процента;процентов'.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
vpoint =  integer(ofc.regno / 1000).
vdep = ofc.regno mod 1000.

find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
v-stamp = "".
v-dogsgn = "".
if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" then do:
    v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1").
    v-stamp = "stamp_" + v-otvlico.
    v-dogsgn = "dogsgn_" + v-otvlico.
    find first codfr where codfr.code = v-otvlico no-lock no-error.
    if not avail codfr or trim(codfr.name[1]) = "" then do:
        v-stamp = "".
        v-dogsgn = "".
    end.
end.
else do:
    find first sysc where sysc.sysc = "otvlico" no-lock no-error.
    if avail sysc then v-otvlico = sysc.chval.
    else v-otvlico = "1".
end.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.credtype = '10' and pkanketa.ln = s-ln no-lock no-error.
if avail pkanketa then do:

    if pkanketa.sts = '111' then do:
        message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
        return.
    end.

    if pkanketa.lon = '' and pkanketa.aaa = '' then do:
        message ' Не открыты счета! ' view-as alert-box.
        return.
    end.

    find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.iin = pkanketa.rnn and pcstaff0.sts = 'OK' no-lock no-error.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'emetam' no-lock no-error.
    if avail pkanketh then do:
        v-metam = pkanketh.value1.
        if v-metam = 'дифференцированные платежи' then
        assign v-method  = 'методом дифференцированных платежей (погашение Кредита равными долями)'
               v-kmethod = 'сараланєан тґлемдер јдісімен (теѕ їлестермен)'.

        if pkanketh.value1 = 'аннуитет' then
        assign v-method  = 'аннуитетным методом (погашение равными платежами)'
               v-kmethod = 'аннуитетті јдіспен (теѕ тґлемдермен)'.
    end.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'evidfin' no-lock no-error.
    if avail pkanketh then do:
        if pkanketh.value1 = 'кредит' then
        assign v-sprcod = '1,2,3,4'
               v-goal   = 'на потребительские цели'
               v-kgoal  = 'тўтынушылыќ маќсаттарєа'.
        if pkanketh.value1 = 'рефинансирование' then
        assign v-sprcod = '5,6,7,8,9,10'
               v-goal   = 'на рефинансирование задолженности Заемщика по Кредиту, полученному в ' + pkanketa.rescha[5]
               v-kgoal  = pkanketa.rescha[5] + ' алєан Несие бойынша Ќарыз алушыныѕ берешегін ќайта ќаржыландыруєа'.
        find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
        find first hdbkcif where can-do(v-sprcod,hdbkcif.hdbkcod) and ((not pcstaff0.cifb begins 'TXB' and hdbkcif.cif = pcstaff0.cifb) or (pcstaff0.cifb begins 'TXB' and hdbkcif.cif = 'OURBNK')) and not hdbkcif.del and hdbkcif.con no-lock no-error.
        find first credhdbk where credhdbk.hdbkcod = hdbkcif.hdbkcod no-lock no-error.
        if v-metam = 'аннуитет' then assign v-comorg = pkanketa.summa * credhdbk.comann / 100 v-gr = 1 v-comis = credhdbk.comann.
        if v-metam = 'дифференцированные платежи' then assign v-comorg = pkanketa.summa * credhdbk.comdif / 100 v-gr = 2 v-comis = credhdbk.comdif.
    end.

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'esroktr' no-lock no-error.
    if avail pkanketh then v-srok = inte(pkanketh.value1).

    find first pkanketh where pkanketh.bank = v-bank and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = 'edaytr' no-lock no-error.
    if avail pkanketh then v-day = inte(pkanketh.value1).

    if pkanketa.resdat[1] = ? then bdate = g-today.
    else bdate = pkanketa.resdat[1].

    v-year = year(bdate).
    v-mon = month(bdate).
    v-edat = date(v-mon,v-day,v-year).
    if v-edat - bdate < 15 then do:
        v-mon = month(bdate) + 1.
        if v-mon > 12 then do:
            v-mon = v-mon - 12.
            v-year = v-year + 1.
        end.
        v-edat = date(v-mon,v-day,v-year).
    end.
    v-edatnew = date(v-mon,v-day,v-year).
    if v-edat - bdate < 15 then do:
        v-mon = v-mon + 1.
        if v-mon > 12 then do:
            v-mon = v-mon - 12.
            v-year = v-year + 1.
        end.
        v-edat = date(v-mon,v-day,v-year).
        if v-edat - bdate > 45 then v-edat = v-edatnew.
    end.

    v-year1 = year(bdate).
    v-mon1 = month(bdate) + v-srok.
    if v-mon1 > 12 then do:
        do i = 1 to v-mon1 / 12:
            v-year1 = v-year1 + 1.
        end.
    end.
    if v-mon1 mod 12 <> 0 then v-mon1 = v-mon1 - trunc(v-mon1 / 12 , 0) * 12.
    else v-mon1 = 12.
    v-dd = day(bdate).
    v-ndate = date(v-mon1,v-dd,v-year1) no-error.
    repeat while error-status:error :
        v-dd = v-dd - 1.
        v-ndate = date(v-mon1,v-dd,v-year1) no-error.
    end.

    vnomer = substr(v-bank,4) + 'ЭК-' + string(year(g-today),'9999') + '-' + string(month(g-today),'99') + '/' + string(day(g-today),'99') + '-' + string(pkanketa.ln).
    if pkanketa.rescha[1] = '' then do:
        find current pkanketa exclusive-lock no-error.
        pkanketa.rescha[1] = vnomer.
        /*pkanketa.resdat[1] = g-today.*/
        find current pkanketa no-lock no-error.

        find first loncon where loncon.lon = pkanketa.lon exclusive-lock no-error.
        loncon.lcnt = vnomer.
        find current loncon no-lock no-error.
    end.

    repeat:
        run sel2 ("Выберите :", " 1. Сформировать и распечатать документы | 2. Сформировать и распечатать доп. к КД | 3. Отметка о подписании Договора и Графика | 4. Выход ", output v-sel).
        case v-sel:
            when 1 then do:
                /* график погашения */
                run erl_ek1(pkanketa.summa,v-srok,pkanketa.rateq,v-gr,bdate,v-edat,v-edat,v-edat,v-comorg,0,0,0,0,yes,output v-eps).
                v-eps = round(v-eps,1).
                if pkanketa.resdec[1] = 0 then do:
                    find current pkanketa exclusive-lock no-error.
                    pkanketa.resdec[1] = v-eps.
                    find current pkanketa no-lock no-error.
                end.
                run cif-kart(0). /* карточка с образцами подписей */
                v-list = 'ekacc.htm;'.
                if pcstaff0.cifb begins 'TXB' then v-list = v-list + 'ekcontstf.htm'.
                else v-list = v-list + 'ekcrcontcl.htm'.
            end.
            when 2 then do:
                v-list = 'ekdopdog.htm'.
            end.
            when 3 then do:
                if pkanketa.docdt <> ? and pkanketa.duedt <> ? then message ' Отметка о подписнии договора уже проставлена ' view-as alert-box.
                else message ' Поставить отметку о подписнии договора? ' view-as alert-box question buttons yes-no title "" update v-ans as logi.
                if v-ans then do:
                    find current pkanketa exclusive-lock no-error.
                    pkanketa.docdt = g-today.
                    pkanketa.duedt = v-ndate.
                    find current pkanketa no-lock no-error.

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
                        v-str = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 3.2.7.2 «Контроль Миддл Офиса» - «Информация по кредитному досье». Клиент: "
                              + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                              + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln)  + ". Дата поступления задачи: "
                              + string(today) + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
                        run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", 'Информация по кредитному досье',v-str, "", "","").
                    end.
                end.
            end.
            when 4 then return.
        end.
        do i = 1 to num-entries(v-list,';'):
            v-infile  = "/data/docs/" + entry(i,v-list,';').
            v-ofile = "AccountContract" + string(i) + ".htm".

            output stream out to value(v-ofile).
            input from value(v-infile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*vnomer*" then do:
                        v-str = replace (v-str, "vnomer", pkanketa.rescha[1]).
                        next.
                    end.

                    if v-str matches "*vday*" then do:
                        v-str = replace (v-str, "vday", string(day(g-today),'99')).
                        next.
                    end.

                    if v-str matches "*vmonth*" then do:
                        v-str = replace (v-str, "vmonth", entry(month(g-today),vmonthname)).
                        next.
                    end.

                    if v-str matches "*vmontkz*" then do:
                        v-str = replace (v-str, "vmontkz", entry(month(g-today),vmonkz)).
                        next.
                    end.

                    if v-str matches "*vyear*" then do:
                        v-str = replace (v-str, "vyear", substr(string(year(g-today),'9999'),3)).
                        next.
                    end.

                    if v-str matches "*vcity*" then do:
                        find first sysc where sysc.sysc = "citi" no-lock no-error.
                        v-str = replace (v-str, "vcity", sysc.chval).
                        next.
                    end.

                    if v-str matches "*vcitkz*" then do:
                        find first sysc where sysc.sysc = "kcity" no-lock no-error.
                        if not avail sysc then find first sysc where sysc.sysc = "citi" no-lock no-error.
                        v-str = replace (v-str, "vcitkz", sysc.chval).
                        next.
                    end.

                    if v-str matches "*vname*" then do:
                        v-str = replace (v-str, "vname", pkanketa.name).
                        next.
                    end.

                    if v-str matches "*vaaa*" then do:
                        v-str = replace (v-str, "vaaa", pkanketa.aaa).
                        next.
                    end.

                    if v-str matches "*vcomp*" then do:
                        if pcstaff0.cifb begins 'TXB' then v-str = replace (v-str, "vcomp", "AO ForteBank").
                        else do:
                            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                            v-str = replace (v-str, "vcomp", trim(cif.prefix + ' ' + cif.name)).
                        end.
                        next.
                    end.

                    if v-str matches "*vcomis*" then do:
                        v-str = replace (v-str, "vcomis", string(v-comis)).
                        next.
                    end.

                    if v-str matches "*vbin1*" then do:
                        v-str = replace (v-str, "vbin1", pkanketa.rnn).
                        next.
                    end.

                    if v-str matches "*nday*" then do:
                        v-str = replace (v-str, "nday", string(day(v-ndate))).
                        next.
                    end.

                    if v-str matches "*nyear*" then do:
                        v-str = replace (v-str, "nyear", string(year(v-ndate))).
                        next.
                    end.

                    if v-str matches "*nmonth*" then do:
                        v-str = replace (v-str, "nmonth", entry(month(v-ndate),vmonthname)).
                        next.
                    end.

                    if v-str matches "*nmonkz*" then do:
                        v-str = replace (v-str, "nmonkz", entry(month(v-ndate),vmonkz)).
                        next.
                    end.

                    if v-str matches "*daytr*" then do:
                        v-str = replace (v-str, "daytr", string(v-day)).
                        next.
                    end.

                    if v-str matches "*votvfc*" then do:
                        find first codfr where codfr.codfr = "DKKOGO" and codfr.code = v-otvlico no-lock no-error.
                        v-str = replace (v-str, "votvfc", codfr.name[1]).
                        next.
                    end.

                    if v-str matches "*vkotvfc*" then do:
                        find first codfr where codfr.codfr = "DKKOGOKZ" and codfr.code = v-otvlico no-lock no-error.
                        v-str = replace (v-str, "vkotvfc", codfr.name[1]).
                        next.
                    end.

                    if v-str matches "*vdover*" then do:
                        find first codfr where codfr.codfr = "DKOSN" and codfr.code = v-otvlico no-lock no-error.
                        v-str = replace (v-str, "vdover", codfr.name[1]).
                        next.
                    end.

                    if v-str matches "*vkdover*" then do:
                        find first codfr where codfr.codfr = "DKOSNKZ" and codfr.code = v-otvlico no-lock no-error.
                        v-str = replace (v-str, "vkdover", codfr.name[1]).
                        next.
                    end.

                    if v-str matches "*dkface*" then do:
                        find first codfr where codfr.codfr = "DKFACE" and codfr.code = v-otvlico no-lock no-error.
                        v-str = replace (v-str, "dkface", codfr.name[1]).
                        next.
                    end.

                    if v-str matches "*vgoal*" then do:
                        v-str = replace (v-str, "vgoal", v-goal).
                        next.
                    end.

                    if v-str matches "*vkgoal*" then do:
                        v-str = replace (v-str, "vkgoal", v-kgoal).
                        next.
                    end.

                    if v-str matches "*vbin2*" then do:
                        find first sysc where sysc = 'BNKBIN' no-lock no-error.
                        v-str = replace (v-str, "vbin2", sysc.chval).
                        next.
                    end.

                    if v-str matches "*vaddr1*" then do:
                        v-str = replace (v-str, "vaddr1", pcstaff0.addr[1]).
                        next.
                    end.

                    if v-str matches "*vaddr2*" then do:
                        find first cmp no-lock no-error.
                        v-str = replace (v-str, "vaddr2", cmp.addr[1]).
                        next.
                    end.

                    if v-str matches "*vtel1*" then do:
                        v-str = replace (v-str, "vtel1", pcstaff0.tel[1] + ', ' + pcstaff0.tel[2]).
                        next.
                    end.

                    if v-str matches "*vtel2*" then do:
                        find first cmp no-lock no-error.
                        v-str = replace (v-str, "vtel2", cmp.tel).
                        next.
                    end.

                    if v-str matches "*cday*" then do:
                        v-str = replace (v-str, "cday", string(day(pkanketa.docdt),"99")).
                        next.
                    end.

                    if v-str matches "*cmonk*" then do:
                        v-str = replace (v-str, "cmonk", entry(month(pkanketa.docdt),vmonthname)).
                        next.
                    end.

                    if v-str matches "*cmont*" then do:
                        v-str = replace (v-str, "cmont", entry(month(pkanketa.docdt),vmonkz)).
                        next.
                    end.

                    if v-str matches "*cyear*" then do:
                        v-str = replace (v-str, "cyear", string(year(pkanketa.docdt),"99")).
                        next.
                    end.

                    if v-str matches "*vnomdoc*" then do:
                        v-str = replace (v-str, "vnomdoc", pcstaff0.nomdoc).
                        next.
                    end.

                    if v-str matches "*vissdoc*" then do:
                        v-str = replace (v-str, "vissdoc", string(pcstaff0.issdt,'99.99.9999')).
                        next.
                    end.

                    if v-str matches "*vmethod*" then do:
                        v-str = replace (v-str, "vmethod", v-method).
                        next.
                    end.

                    if v-str matches "*vkmethod*" then do:
                        v-str = replace (v-str, "vkmethod", v-kmethod).
                        next.
                    end.

                    if v-str matches "*vstav*" then do:
                        v-str = replace (v-str, "vstav", string(pkanketa.rateq)).
                        next.
                    end.

                    if v-str matches "*vstpr*" then do:
                        run Sm-vrd(pkanketa.rateq, output vpropis).
                        if index(string(pkanketa.rateq),'.') > 0 then do:
                            run Sm-vrd(int(substr(string(pkanketa.rateq),index(string(pkanketa.rateq),'.') + 1)), output vpropis1).
                            v-str = replace (v-str, "vstpr", lc(vpropis) + ' целых ' + lc(vpropis1) + ' десятых процента').
                        end.
                        else do:
                            if length(string(pkanketa.rateq)) = 2 and pkanketa.rateq > 20 then buf = (pkanketa.rateq mod 10).
                            else buf = pkanketa.rateq.
                            case buf:
                                when 1 then
                                    word = "процент".
                                when 2 or when 3 or when 4 then
                                    word = "процента".
                                otherwise
                                    word = "процентов".
                            end case.
                            v-str = replace (v-str, "vstpr", lc(vpropis) + ' ' + word).
                        end.
                        next.
                    end.

                    if v-str matches "*vkstpr*" then do:
                        run Sm-vrd-KZ(pkanketa.rateq, 0, output vpropkz).
                        if index(vpropkz,',') > 0 then do:
                            vpropkz = substr(vpropkz, 1, index(vpropkz,',') - 2).
                            run Sm-vrd-KZ(int(substr(string(pkanketa.rateq),index(string(pkanketa.rateq),'.') + 1)), 0, output vpropkz1).
                            v-str = replace (v-str, "vkstpr", lc(vpropkz) + ' бїтін оннан ' + lc(vpropkz1) + 'пайыз').
                        end.
                        else v-str = replace (v-str, "vkstpr", lc(vpropkz) + 'пайыз').
                        next.
                    end.

                    if v-str matches "*vgesv*" then do:
                        v-str = replace (v-str, "vgesv", string(pkanketa.resdec[1])).
                        next.
                    end.

                    if v-str matches "*vgspr*" then do:
                        run Sm-vrd(pkanketa.resdec[1], output vpropis).
                        if index(string(pkanketa.resdec[1]),'.') > 0 then do:
                            run Sm-vrd(int(substr(string(pkanketa.resdec[1]),index(string(pkanketa.resdec[1]),'.') + 1)), output vpropis1).
                            v-str = replace (v-str, "vgspr", lc(vpropis) + ' целых ' + lc(vpropis1) + ' десятых процента').
                        end.
                        else do:
                            if length(string(pkanketa.resdec[1])) = 2 and pkanketa.resdec[1] > 20 then buf = (pkanketa.resdec[1] mod 10).
                            else buf = pkanketa.resdec[1].
                            case buf:
                                when 1 then
                                    word = "процент".
                                when 2 or when 3 or when 4 then
                                    word = "процента".
                                otherwise
                                    word = "процентов".
                            end case.
                            v-str = replace (v-str, "vgspr", lc(vpropis) + ' ' + word).
                        end.
                        next.
                    end.

                    if v-str matches "*vkgspr*" then do:
                        run Sm-vrd-KZ(pkanketa.resdec[1], 0, output vpropkz).
                        if index(vpropkz,',') > 0 then do:
                            vpropkz = substr(vpropkz, 1, index(vpropkz,',') - 2).
                            run Sm-vrd-KZ(int(substr(string(pkanketa.resdec[1]),index(string(pkanketa.resdec[1]),'.') + 1)), 0, output vpropkz1).
                            v-str = replace (v-str, "vkgspr", lc(vpropkz) + ' бїтін оннан ' + lc(vpropkz1) + 'пайыз').
                        end.
                        else v-str = replace (v-str, "vkgspr", lc(vpropkz) + 'пайыз').
                        next.
                    end.

                    if v-str matches "*vsrok*" then do:
                        v-str = replace (v-str, "vsrok", string(v-srok)).
                        next.
                    end.

                    if v-str matches "*vksrpr*" then do:
                        run Sm-vrd-KZ(v-srok, 0, output vpropkz).
                        v-str = replace (v-str, "vksrpr", lc(vpropkz)).
                        next.
                    end.

                    if v-str matches "*vsrpr*" then do:
                        run Sm-vrd(v-srok, output vpropis).
                        v-str = replace (v-str, "vsrpr", lc(vpropis)).
                        next.
                    end.

                    if v-str matches "*vsum*" then do:
                        v-str = replace (v-str, "vsum", string(pkanketa.summa)).
                        next.
                    end.

                    if v-str matches "*vsprop*" then do:
                        run Sm-vrd(pkanketa.summa, output vpropis).
                        v-str = replace (v-str, "vsprop", lc(vpropis)).
                        next.
                    end.

                    if v-str matches "*vskprop*" then do:
                        run Sm-vrd-KZ(pkanketa.summa, 0, output vpropkz).
                        v-str = replace (v-str, "vskprop", lc(vpropkz)).
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
    end.
end.