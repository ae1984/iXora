/*vcletter .p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Письма в адрес клиента
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
        26/08/2009 galina
 * BASES
        BANK COMM
 * CHANGES
        10.01.2012 aigul - поиск только по ПС
        23.11.2012 damir - реализована С.З. от 19.11.2012. Корректировка.
        27.12.2012 damir - Исправлена ошибка в коде. Поиск в таблице comm.vccontrs.
*/
{global.i}

def input parameter p-ltrtype as integer.
def input parameter p-cif like cif.cif.
def input parameter p-contrnum as char.
def input parameter p-cifname as char.
def input parameter p-rmz as char.

def var v-psnum as char.
def var v-partner as char.
def var v-contrnum as char.
def var v-ofc as char.
def var v-str as char.
def var v-plsummch as char.
def var v-plsumm as char.
def var v-plsumm1 as char.
def var v-crc1 as char.
def var v-crc2 as char.
def var v-pl as char.
def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.

def var v-exist as char.

if p-ltrtype <> 4 then find first vccontrs where trim(vccontrs.ctnum) = trim(p-contrnum) and vccontrs.cif = p-cif no-lock no-error.

if not avail vccontrs and p-ltrtype <> 4 then do:
    message "Контракт не найден!" view-as alert-box.
    return.
end.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then  v-ofc = ofc.name.

if p-ltrtype <> 4 then do:
    v-contrnum = vccontrs.ctnum + " от " + string(vccontrs.ctdate, "99/99/9999").
    if vccontrs.cttype <> "1" and p-ltrtype = 2 then do:
        message "Тип конракта без паспорта сделки!" view-as alert-box.
        return.
    end.
    if vccontrs.cttype = "1" and vccontrs.sts <> "C" and p-ltrtype = 2  then do:
        message "Паспорт сделки не закрыт!" view-as alert-box.
        return.
    end.
    if vccontrs.cttype = "1" then do:
        find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = "01" no-lock no-error.
        if p-ltrtype = 2 and not avail vcps then do:
            message "Нет паспорта сделки!" view-as alert-box.
            return.
        end.
        if not avail vcps then v-psnum = "".
        else do:
            if p-ltrtype = 3 then v-psnum = " (паспорт сделки " + vcps.dnnum + string(vcps.num) + " от " + string(vcps.dndate,'99/99/9999') + ")" .
            else v-psnum = " паспорт сделки " + vcps.dnnum + string(vcps.num) + " от " + string(vcps.dndate,'99/99/9999').
        end.
    end.
    find first vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
    if not avail vcpartner then v-partner = "".
    else v-partner = vcpartners.formasob + " " +  vcpartner.name.

    if p-ltrtype = 3 then do:
        find first vcdocs where (vcdocs.dntype = '03' or vcdocs.dntype = '02') and vcdocs.contract = vccontrs.contract no-lock no-error.
        if not avail vcdocs then do:
            message "По данному конракту не было платежей!" view-as alert-box.
            return.
        end.
        for each vcdocs where (vcdocs.dntype = '03' or vcdocs.dntype = '02') and vcdocs.contract = vccontrs.contract no-lock:
            find first ncrc where ncrc.crc = vcdocs.pcrc no-lock no-error.
            if not avail ncrc then message "Нет такой валюты! " + string(vcdocs.pcrc) view-as alert-box.
            v-plsummch = replace(trim(string(vcdocs.sum, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
            run Sm-vrd (vcdocs.sum, output v-plsumm).
            run Sm-vrd (deci(entry(2,v-plsummch,'.')), output v-plsumm1).

            run sm-wrdcrc (substr(v-plsummch, 1, length(v-plsummch) - 3),
            substr(v-plsummch, length(v-plsummch) - 1),
            vcdocs.pcrc, output v-crc1, output v-crc2).

            v-pl = v-pl + string(vcdocs.dndate,'99/99/9999') + " - " + v-plsummch + " " + ncrc.code + " (" + v-plsumm + " " + v-crc1 + " " +
            v-plsumm1 + " " + v-crc2 + ");<BR>".
        end.
        v-pl = substr(v-pl,1,length(v-pl) - 5) + ".".
    end.
end.
if p-ltrtype = 4 then do:
    find first remtrz where remtrz.remtrz = p-rmz no-lock no-error.
    if not avail remtrz then message "Ненайден платеж " + remtrz.remtrz view-as alert-box.
    find first ncrc where ncrc.crc = remtrz.tcrc no-lock no-error.
    if not avail ncrc then message "Нет такой валюты! " + string(remtrz.tcrc) view-as alert-box.
    v-partner = trim(entry(1,remtrz.ord,'/')).
    v-plsummch = replace(trim(string(remtrz.amt, "->>>,>>>,>>>,>>>,>>>,>>9.99")), ",", " ").
    run Sm-vrd (remtrz.amt, output v-plsumm).
    run Sm-vrd (deci(entry(2,v-plsummch,'.')), output v-plsumm1).
    run sm-wrdcrc (substr(v-plsummch, 1, length(v-plsummch) - 3),
    substr(v-plsummch, length(v-plsummch) - 1),
    remtrz.tcrc, output v-crc1, output v-crc2).
    v-pl = v-plsummch + " " + ncrc.code + " (" + v-plsumm + " " + v-crc1 + " " + v-plsumm1 + " " + v-crc2 + ");<BR>".
end.

v-ofile  = "/data/docs/vcletter" + string(p-ltrtype) + ".htm".
v-infile = "vcletter.htm".
output stream v-out to value(v-infile).
/********/

input from value(v-ofile).
repeat:
import unformatted v-str.
v-str = trim(v-str).

repeat:
    if v-str matches "*v-clname*" then do:
        v-str = replace (v-str, "v-clname", p-cifname).
        next.
    end.

    if p-ltrtype <> 2 then do:
      if v-str matches "*v-contrnum*" then do:
         v-str = replace (v-str, "v-contrnum", v-contrnum).
         next.
      end.
      if v-str matches "*v-partner*" then do:
         v-str = replace (v-str, "v-partner", v-partner).
         next.
      end.
    end.
    if v-str matches "*v-psnum*" then do:
        v-str = replace (v-str, "v-psnum", v-psnum).
        next.
    end.
    if p-ltrtype = 3 then do:
      if v-str matches "*v-plsumm*" then do:
         v-str = replace (v-str, "v-plsumm", v-pl).
         next.
      end.
    end.
    if p-ltrtype = 4 then do:
      if v-str matches "*v-summ*" then do:
         v-str = replace (v-str, "v-summ", v-pl).
         next.
      end.
    end.
    if v-str matches "*v-ofc*" then do:
        v-str = replace (v-str, "v-ofc", v-ofc).
        next.
    end.
    leave.
end. /* repeat */

put stream v-out unformatted v-str skip.
end. /* repeat */
input close.
/********/


output stream v-out close.
output stream v-out to value(v-infile) append.
output stream v-out close.
unix silent value("cptwin " + v-infile + " winword").
unix silent value("rm -r " + v-infile).

