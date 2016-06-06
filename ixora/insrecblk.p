/* insrecblk.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Обработка отзывов РПРО
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
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
       14/12/2009 galina - подтверждаем повторное принятие отзыва
       21/01/2010 galina - поменяла алгоритм определния статуса документа
       12/05/2011 evseev - поиск счетов по филиалам
       08/06/2011 evseev - переход на ИИН/БИН
       23/06/2011 evseev - изменил команду на unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file).
       24/06/2011 evseev - добавил пробел между комментом и unix silent
       09/09/2011 evseev - исправил проблему подтягивания города из cmp
       13.03.2013 evseev - tz-1759

*/
{chbin.i}
def shared var g-today  as date.
def shared var g-ofc    like ofc.ofc.
def var s-aaa as char.
def var v-docnum as char.
def var v-mt100out  as char no-undo.
def var v-exist1    as char no-undo.

def var op_kod      as char no-undo.
def var v-fsum      like aas.fsum.
def var v-docdat    like aas.docdat.
def var v-knp       like aas.knp.
def var v-kbk       like aas.kbk.
def var t-sum       as decimal.
def var v-knaaa     like aaa.aaa.
def var v-who       like aas.who.
def var v-whn       like aas.whn.
def var v-ofc1      as char.
def var v-jhink     like jh.jh.
def var v-summ      as deci no-undo.
def var s-vcourbank as char.
def var v-usrglacc  as char.
def var vparam2     as char.
def var d-SumOfPlat as decimal.
def var vdel        as char initial "^".
def var rcode       as inte.
def var rdes        as char.
def var v-stat      like insrec.stat no-undo.
def var v-kref      as char no-undo.
def var v-counter   as int no-undo.
def var v-text      as char no-undo.
def var v-bankbik   as char no-undo.
def var v-kol       as int no-undo.
def var v-file      as char no-undo.

def var v-maillist as char no-undo.
def var v-mailmessage as char.

def var v-aaalist as char.
def var v-reflist as char.
def buffer b-insrec for insrec.
def var i as integer no-undo.
def var j as integer no-undo.
def var k as integer no-undo.
def buffer b-cif for cif.
def stream mt400.


def var v-bank as char no-undo.
def var v-isfindaaa as logical no-undo.
def var v-sta like aaa.sta no-undo.
def var vbin as char no-undo.
def var v-cifname as char no-undo.
def var v-lgr as char no-undo.

{comm-txb.i}
{get-dep.i}
run savelog('insrecblk','88. ' ).
def var v-term as char.
find first sysc where sysc.sysc = 'lbeks' no-lock no-error .
if not avail sysc then do:
   if g-ofc <> "superman" then message "Не найден параметр lbeks в sysc!" view-as alert-box.
   else run log_write("Не найден параметр lbeks в sysc!").
   return.
end.
v-term = sysc.chval.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then return.
s-vcourbank = trim(sysc.chval).

v-aaalist = ''.
v-reflist = ''.

run savelog('insrecblk','105. ' ).
for each insrec where insrec.stat = '' no-lock:
    find first insin where insin.ref eq insrec.insref no-lock no-error.

    if not avail insin then do transaction  :
        find first b-insrec where b-insrec.insref = insrec.insref exclusive-lock.
        b-insrec.stat = "20".

        next.
    end.
    if insin.bank <> s-vcourbank then next.

    if (trim(insrec.insnum) <> trim(insin.numr)) or (insrec.insdt <> insin.dtr) then do transaction :
        find first b-insrec where b-insrec.insref = insrec.insref exclusive-lock.
        b-insrec.stat = "20".

        next.
    end.

    if insin.mnu eq "returned" then v-stat = "13".
    if insin.mnu eq "recall" then v-stat = "01".

    if insin.mnu ne "returned" and insin.mnu ne "recall" and insin.stat = 1 then do:
       run getstatforinsrec (insrec.insref, output v-stat).

       if v-stat = '01' then do:
          run delaasofins (insrec.insref).

          /* помечаем как отозванный (insin.mnu) */

           if insin.mnu = "blk"  then do transaction:
              find current insin exclusive-lock no-error.
              insin.mnu = "recall".
              find current insin no-lock.
           end.

       end. /*v-stat = '01'*/
    end.
    if v-stat <> '' then do:
      find first b-insrec where b-insrec.insref = insrec.insref no-lock.
      if  b-insrec.stat = '' then do transaction:
        find current b-insrec exclusive-lock.
        b-insrec.stat = v-stat.
        find current b-insrec no-lock.
        if v-stat <> 'err' then do:
          if v-reflist <> '' then v-reflist = v-reflist + ','.
          v-reflist = v-reflist + insrec.ref.
        end.
      end.
    end.

end.
run savelog('insrecblk','157. ' + v-reflist ).

if v-reflist <> '' then do:

    v-mt100out = "/data/export/insarc/" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99") + "/".
    input through value( "find " + v-mt100out + ";echo $?").
    repeat:
        import unformatted v-exist1.
    end.
    if v-exist1 <> "0" then do:
        unix silent value ("mkdir " + v-mt100out).
        unix silent value("chmod 777 " + v-mt100out).
    end.

    do transaction:
        find first pksysc where pksysc.sysc = "insnum" no-lock no-error.
        if avail pksysc then v-counter = pksysc.inval + 1.
        else do:
            run savelog( "insps", "insrecall: Ошибка определения текущего значения счетчика сообщений!").
            return.
        end.

        find first pksysc where pksysc.sysc = "insnum" exclusive-lock no-error.
        if avail pksysc then pksysc.inval = v-counter.
        find current pksysc no-lock.
    end.

    /* формирование ответного сообщения по полученным отзывам инкассовых распоряжений */
    v-file = 'INS' + string(v-counter, "9999999999999") + ".txt".
    v-kref = string(v-counter, "999999").

    output stream mt400 to value(v-file).

    v-text = "\{1:F01K054700000000010" + v-kref + "\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{2:I998KNALOG000000N2020\}".
    put stream mt400 unformatted v-text skip.

    v-text = "\{4:".
    put stream mt400 unformatted v-text skip.

    v-text = ":20:INS" + string(v-counter, "9999999999999").
    put stream mt400 unformatted v-text skip.

    v-text = ":12:400".
    put stream mt400 unformatted v-text skip.

    v-text = ":77E:FORMS/PAR/" + string(year(g-today) mod 1000,'99') + string(month(g-today),'99') + string(day(g-today),'99') + entry(1, string(time, "hh:mm"), ":") + entry(2, string(time, "hh:mm"), ":") + "/Подт.получ. отзыва расп.о приост.расх.".
    put stream mt400 unformatted v-text skip.

    {sysc.i}
    v-bankbik = get-sysc-cha("clecod").

    v-text = "/BANK/" + v-bankbik.
    put stream mt400 unformatted v-text skip.

    v-kol = 0.

    v-mailmessage = ''.
    run savelog('insrecblk','217. ' ).
    do i = 1 to num-entries(v-reflist) transaction:
        find first insrec where insrec.ref = entry(i,v-reflist) no-lock no-error.
        if avail insrec then do:
            if v-bin then v-text = "//07/" + insrec.bin + "/" + string(insrec.num) + "/" + string(year(insrec.dt) mod 1000,'99') + string(month(insrec.dt),'99') + string(day(insrec.dt),'99') + "/"+ insrec.ref + "/" + insrec.stat.
            else v-text = "//07/" + insrec.jss + "/" + string(insrec.num) + "/" + string(year(insrec.dt) mod 1000,'99') + string(month(insrec.dt),'99') + string(day(insrec.dt),'99') + "/"+ insrec.ref + "/" + insrec.stat.
            put stream mt400 unformatted v-text skip.
            v-kol = v-kol + 1.
            if v-mailmessage <> '' then v-mailmessage = v-mailmessage + "\n\n".
            if v-bin then v-mailmessage = v-mailmessage + insrec.filename + " Отзыв расп.=" + string(insrec.num) + " БИН=" + insrec.bin + " N Расп.=" + string(insrec.insnum).
            else v-mailmessage = v-mailmessage + insrec.filename + " Отзыв расп.=" + string(insrec.num) + " РНН=" + insrec.jss + " N Расп.=" + string(insrec.insnum).
            run savelog('insrecblk','288. ' + entry(i,v-reflist)).
            find first insin where insin.ref eq insrec.insref no-lock no-error.
            if avail insin then do:
                do j = 1 to num-entries(insin.iik):
                   run savelog('insrecblk','232. ' + entry(i,v-reflist) + " " + entry(j,insin.iik)).
                   run findaaa(entry(j,insin.iik),insin.bank1, output v-bank, output v-isfindaaa, output v-sta, output vbin, output v-cifname, output v-lgr).
                   if v-isfindaaa then do:
                       run savelog('insrecblk','235. ' + entry(i,v-reflist)).
                       if lookup (v-lgr , "138,139,140,143,144,145") > 0 then do:
                           run mail("DPC@fortebank.com", "METROCOMBANK <abpk@fortebank.com>", "Прием отзыва РПРО ",
                               insrec.filename + " Отзыв расп.=" + string(insrec.num) + " БИН=" + insrec.bin + " N Расп.=" + string(insrec.insnum) + " счет=" + entry(j,insin.iik)
                               , "1", "", "").
                       end.
                   end.
                end.
            end.
            run savelog('insrecblk','244. ' + entry(i,v-reflist)).

            create inshist.
            assign inshist.outfile = "RINS" + string(v-counter, "999999999")
                inshist.insref = insrec.ref
                inshist.rdt = g-today
                inshist.rtm = time.
        end.
    end.

    v-text = "/TOTAL/" + string(v-kol).
    put stream mt400 unformatted v-text skip.

    v-text = "-\}".
    put stream mt400 unformatted v-text skip.

    output stream mt400 close.

    run savelog('insrecblk','262. ' ).
    unix silent value("scp -q " + v-file + " Administrator@db01:" + v-term + "IN/" + v-file). /* положили в терминал для отправки */
    unix silent value("mv " + v-file + " " + v-mt100out). /* положили в архив отправленных */

end.

def var v-city as char.
if v-mailmessage <> '' then do:
    find first sysc where sysc.sysc = "inkmail" no-lock no-error.
    if avail sysc and trim(sysc.chval) <> '' then do:
        do i = 1 to num-entries(sysc.chval):
            if trim(entry(i,sysc.chval)) <> '' then do:
                if v-maillist <> '' then v-maillist = v-maillist + ','.
                v-maillist = v-maillist + trim(entry(i,sysc.chval)) + "@fortebank.com".
            end.
        end. /* do i = 1 */
        if v-maillist <> '' then do:
            find first cmp no-lock no-error.
            if avail cmp then do:
               v-city = "".
               if entry(2,cmp.addr[1]) matches "*г.*" then v-city = entry(2,cmp.addr[1]).
                  else. if entry(3,cmp.addr[1]) matches "*г.*" then v-city = entry(3,cmp.addr[1]).
               v-mailmessage = v-city + "\n\n" + v-mailmessage.
               run mail(v-maillist, "METROCOMBANK <abpk@fortebank.com>", "Прием отзывов РПРО " + v-city, v-mailmessage, "1", "", "").
            end.
        end.
    end.
end. /* if v-mailmessage <> '' */

