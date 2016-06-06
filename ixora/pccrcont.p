/* pccrcont.p
 * MODULE
        Кредитный лимит по ПК и доп.услуги
 * DESCRIPTION
        Формирование кредитного договора и проставление отметки о его подписании
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-2-1
 * AUTHOR
        14.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
        11.09.2013 Lyubov - ТЗ 2066, добавила в выборку из pccstaff0 поиск по CIF
*/

{global.i}

def shared var v-aaa      as char no-undo.
def shared var s-credtype as char init '4' no-undo.
def shared var v-bank     as char no-undo.
def shared var v-cifcod   as char no-undo.

def stream out.
def var v-sel    as int  no-undo.
def var v-infile as char no-undo.
def var v-ofile  as char no-undo.
def var v-ofile1 as char no-undo init 'zayavvv.htm'.
def var v-str    as char no-undo.
def var vnomer   as char no-undo.
def var vpropis  as char no-undo.
def var vpropis1 as char no-undo.
def var vpropkz  as char no-undo.
def var vpropkz1 as char no-undo.
def var dkface   as char no-undo.
def var v-fname  as char no-undo init 'pccredcont1.htm,pccredcont2.htm,'.
def var v-otvlico as char.
def var vpoint like point.point .
def var vdep like ppoint.dep .
def var v-stamp as char.
def var v-dogsgn as char.
def var i as int.

def var v-maillist as char.
def var v-zag      as char.
def var v-text     as char.

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

def var vmonthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".
def var vmonkz as char init
   "ќантар,аќпан,наурыз,сјуір,мамыр,маусым,шілде,тамыз,ќыркїйек,ќазан,ќараша,желтоќсан".

find aaa where aaa.aaa = v-aaa no-lock no-error.
if not available aaa then do:
   message "Данный счет не существует" . pause .
   return.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
vpoint =  integer(ofc.regno / 1000).
vdep = ofc.regno mod 1000.

find ppoint where ppoint.point = vpoint and ppoint.dep = vdep no-lock no-error.
v-stamp = "".
v-dogsgn = "".
if avail ppoint and ppoint.name matches "*СП*" and ppoint.info[5] <> "" and ppoint.info[6] <> "" and ppoint.info[7] <> "" and aaa.sta <> "C" then do:
    v-otvlico = "sp_" + string(ppoint.depart) + "_" + string("1").
    v-stamp = "stamp_" + v-otvlico.
    v-dogsgn = "dogsgn_" + v-otvlico.
    find first codfr where codfr.code = v-otvlico no-lock no-error.
    if not avail codfr or trim(codfr.name[1]) = "" then do:
        v-stamp = "".
        v-dogsgn = "".
    end.
    message v-otvlico. pause.
end.
else do:
    find first sysc where sysc.sysc = "otvlico" no-lock no-error.
    if avail sysc then v-otvlico = sysc.chval.
    else v-otvlico = "1".
end.

run sel2 ("Выберите :", " 1. Печать договора | 2. Отметка о подписании договора/доп. согл. | 3. Выход ", output v-sel).
case v-sel:
    when 1 then do:
        i = 1.
        do i = 1 to 2:
            v-infile  = "/data/docs/" + entry(i,v-fname,',').
            v-ofile = "CreditContrant.htm".

            output stream out to value(v-ofile).

            find first pcstaff0 where pcstaff0.aaa = v-aaa and pcstaff0.cif = v-cifcod and pcstaff0.sts = 'OK' no-lock no-error.
            find first pkanketa where pkanketa.bank = v-bank and pkanketa.aaa = pcstaff0.aaa and pkanketa.credtype = s-credtype no-lock no-error.
            if  pkanketa.sts = '110' then do:
                message ' Просим рассмотреть заявку в Нестандартном процессе! ' view-as alert-box.
                return.
            end.
            if pkanketa.rescha[1] = '' then do:
                message ' Не распечатано решение о финансировании! ' view-as alert-box.
                return.
            end.
            else do:
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
                            v-str = replace (v-str, "vday", string(day(today),'99')).
                            next.
                        end.

                        if v-str matches "*vmonth*" then do:
                            v-str = replace (v-str, "vmonth", entry(month(today),vmonthname)).
                            next.
                        end.

                        if v-str matches "*vmonkz*" then do:
                            v-str = replace (v-str, "vmonkz", entry(month(today),vmonkz)).
                            next.
                        end.

                        if v-str matches "*vyear*" then do:
                            v-str = replace (v-str, "vyear", substr(string(year(today),'9999'),3)).
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

                        if v-str matches "*vsumlim*" then do:
                            v-str = replace (v-str, "vsumlim", string(pkanketa.summa)).
                            next.
                        end.

                        if v-str matches "*vcomp*" then do:
                            find first cif where cif.cif = pcstaff0.cifb no-lock no-error.
                            v-str = replace (v-str, "vcomp", cif.prefix + ' ' + cif.name).
                            next.
                        end.

                        if v-str matches "*vgesv*" then do:
                            v-str = replace (v-str, "vgesv", string(pkanketa.rateq)).
                            next.
                        end.

                        if v-str matches "*vpropis*" then do:
                            run Sm-vrd(pkanketa.rateq, output vpropis).
                            run Sm-vrd(int(substr(string(pkanketa.rateq),index(string(pkanketa.rateq),'.') + 1)), output vpropis1).
                            v-str = replace (v-str, "vpropis", lc(vpropis) + ' целых ' + lc(vpropis1) + ' десятых процента').
                            next.
                        end.

                        if v-str matches "*vpropkz*" then do:
                            run Sm-vrd-KZ(pkanketa.rateq, 0, output vpropkz).
                            vpropkz = substr(vpropkz, 1, index(vpropkz,',') - 2).
                            run Sm-vrd-KZ(int(substr(string(pkanketa.rateq),index(string(pkanketa.rateq),'.') + 1)), 0, output vpropkz1).
                            v-str = replace (v-str, "vpropkz", lc(vpropkz) + ' бїтін оннан ' + lc(vpropkz1) + 'пайыз').
                            next.
                        end.

                        if v-str matches "*vaaa*" then do:
                            v-str = replace (v-str, "vaaa", pcstaff0.aaa).
                            next.
                        end.

                        if v-str matches "*viin*" then do:
                            v-str = replace (v-str, "viin", pcstaff0.iin).
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

                        if v-str matches "*vschdt*" then do:
                            find first aaa where aaa.aaa = v-aaa no-lock no-error.
                            v-str = replace (v-str, "vschdt", string(aaa.regdt,'99.99.9999')).
                            next.
                        end.

                        if v-str matches "*vcmpname*" then do:
                            find first cmp no-lock no-error.
                            v-str = replace (v-str, "vcmpname", cmp.name).
                            next.
                        end.

                        if v-str matches "*vnomdoc*" then do:
                            find first cmp no-lock no-error.
                            v-str = replace (v-str, "vnomdoc", pcstaff0.nomdoc).
                            next.
                        end.

                        if v-str matches "*vissdoc*" then do:
                            find first cmp no-lock no-error.
                            v-str = replace (v-str, "vissdoc", string(pcstaff0.issdt)).
                            next.
                        end.

                        if v-str matches "*vaddr*" then do:
                            find first cmp no-lock no-error.
                            v-str = replace (v-str, "vaddr", pcstaff0.addr[1]).
                            next.
                        end.

                        leave.
                    end. /* repeat */

                    put stream out unformatted v-str skip.
                end. /* repeat */
                input close.
                /********/
            end.
            output stream out close.
            output stream out to value(v-ofile1).
            input from value(v-ofile).
            repeat:
                import unformatted v-str.
                v-str = trim(v-str).
                repeat:
                    if v-str matches "*</body>*" then do:
                        v-str = replace(v-str,"</body>","").
                        next.
                    end.
                    if v-str matches "*</html>*" then do:
                        v-str = replace(v-str,"</html>","").
                        next.
                    end.
                    else v-str = trim(v-str).
                    leave.
                end.
                put stream out unformatted v-str skip.
            end.
            input close.
            output stream out close.
            unix silent value("cptwin " + v-ofile1 + " winword").
            unix silent value("rm -f " + v-ofile).
            unix silent value("rm -f " + v-ofile1).
        end.
        if pkanketa.docdt = ? then do:
            find current pkanketa exclusive-lock no-error.
            pkanketa.sts   = '12'.
            find current pkanketa no-lock no-error.
        end.

    end.
    when 2 then do:
        find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = '4' and pkanketa.aaa = v-aaa no-lock no-error.
        if avail pkanketa and pkanketa.docdt = ? and pkanketa.sts = '12' then do:
            message ' Поставить отметку о подписани кредитного договора? ' view-as alert-box buttons yes-no title '' update choice as logical.
            if choice then do:
                find current pkanketa exclusive-lock no-error.
                pkanketa.docdt = today.
                pkanketa.sts   = '20'.
                find current pkanketa no-lock no-error.

                find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.aaa = v-aaa no-lock no-error.
                v-zag = 'Отметка о подписании КД'.
                v-text = "Здравствуйте! Вам назначена задача в АБС iXora в п.м. 16-2-3-1 'Контроль МИДЛ-ОФИСА'. Клиент: "
                      + pcstaff0.cif + ", " + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                      + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ". Дата поступления задачи: " + string(today) + ', ' + string(time,'hh:mm:ss')
                      + ". Бизнес-процесс: Установление кредитного лимита".
                run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-text, "", "","").
            end.
        end.
        else if pkanketa.docdt <> ? then message ' Отметка о подписании кредитного договора уже поставлена! ' view-as alert-box.
        else message ' Не были распечаны договора! ' view-as alert-box.
    end.
    when 3 then return.
end.