/* lndebtr.p
 * MODULE
        Кредитование
 * DESCRIPTION
        Формирование списка должников на сегодня
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
        07/09/2005 madiyar
 * BASES
        bank, comm
 * CHANGES
        08/09/2005 madiyar - добавление в черный список
        28/09/2005 madiyar - today -> g-today
        28/10/2005 madiyar - {pk0.i}
        02/11/2005 madiyar - списанные кредиты тоже в списке
        03/11/2005 madiyar - списанные кредиты все-таки опять не попали, исправил
        10/02/2006 madiyar - переделал расчет дней просрочки (не по графикам, а по проводкам)
        17/03/2006 madiyar - обработка случая, когда % на просрочку не переносились, но 9 уровень не пустой (начисление на 7)
        05/10/2006 madiyar - добавил уровни 4 и 5
        18/02/2009 madiyar - штрафы всегда в тенге, исправил
        04/02/2010 madiyar - заполнение поля comdolg в таблице londebt
        08/02/2010 madiyar - перекомпиляция
*/

{global.i}
{pk0.i}

define var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if avail sysc then s-ourbank = trim(sysc.chval).

def var v-bal as deci no-undo extent 5.
def var v-bal_spis as deci no-undo extent 2.
def var v-bal_com as deci no-undo.
def var tempost as deci no-undo.
def var tempdt as date no-undo.
def var dat_wrk as date no-undo.
def var v-dt as date no-undo.
find last cls where cls.del no-lock no-error. /* последний рабочий день перед today */
dat_wrk = cls.whn.

def temp-table t-londebt no-undo like londebt.

def temp-table t-lonres no-undo
  field jdt as date
  field dc as char
  field sum as deci
  index idx is primary jdt descending.

for each lon no-lock:

  if lon.opnamt <= 0 then next.
  run lonbalcrc('lon',lon.lon,g-today,"7,4,9,13,14",yes,lon.crc,output v-bal_spis[1]).
  run lonbalcrc('lon',lon.lon,g-today,"5,16,30",yes,1,output v-bal_spis[2]).
  v-bal_com = 0.
  for each bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = lon.aaa no-lock:
      v-bal_com = v-bal_com + bxcif.amount.
  end.
  if v-bal_spis[1] + v-bal_spis[2] + v-bal_com <= 0 then next.

  run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal[1]).
  run lonbalcrc('lon',lon.lon,g-today,"4,9,10",yes,lon.crc,output v-bal[2]).
  run lonbalcrc('lon',lon.lon,g-today,"5,16",yes,1,output v-bal[3]).
  run lonbalcrc('lon',lon.lon,g-today,"13,14",yes,lon.crc,output v-bal[4]).
  run lonbalcrc('lon',lon.lon,g-today,"30",yes,1,output v-bal[5]).

  if v-bal[1] + v-bal[2] + v-bal[3] + v-bal[4] + v-bal[5] + v-bal_com > 0 then do:

    create t-londebt.
    t-londebt.cif = lon.cif.
    t-londebt.lon = lon.lon.
    t-londebt.crc = lon.crc.
    t-londebt.grp = lon.grp.
    find first sub-cod where sub-cod.sub = "cln" and sub-cod.acc = lon.cif and sub-cod.d-cod = "secek" no-lock no-error.
    if avail sub-cod then do:
      if sub-cod.ccode = '9' then t-londebt.urfiz = 1.
      else t-londebt.urfiz = 0.
    end.
    t-londebt.od = v-bal[1].
    t-londebt.prc = v-bal[2].
    t-londebt.penalty = v-bal[3].
    t-londebt.comdolg = v-bal_com.

    find first bxcif where bxcif.cif = lon.cif and bxcif.type = "195" and bxcif.aaa = lon.aaa no-lock no-error.
    if avail bxcif then t-londebt.days_com = g-today - bxcif.whn.

    /* дней просрочки */
    if t-londebt.od > 0 then do:
        empty temp-table t-lonres.
        for each lonres where lonres.lon = lon.lon and (lonres.lev = 7) no-lock:
            create t-lonres.
            t-lonres.jdt = lonres.jdt.
            t-lonres.dc = lonres.dc.
            t-lonres.sum = lonres.amt.
        end.
        tempost = t-londebt.od.
        for each t-lonres no-lock:
            if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
            else tempost = tempost + t-lonres.sum.
            if tempost <= 0 then do:
                t-londebt.days_od = g-today - t-lonres.jdt.
                leave.
            end.
        end.
    end.

    if t-londebt.prc > 0 then do:
        for each t-lonres: delete t-lonres. end.
        for each lonres where lonres.lon = lon.lon and (lonres.lev = 9) no-lock:
            create t-lonres.
            t-lonres.jdt = lonres.jdt.
            t-lonres.dc = lonres.dc.
            t-lonres.sum = lonres.amt.
        end.
        tempost = t-londebt.prc.
        for each t-lonres no-lock:
            if t-lonres.dc = 'D' then tempost = tempost - t-lonres.sum.
            else tempost = tempost + t-lonres.sum.
            if tempost <= 0 then do:
                t-londebt.days_prc = g-today - t-lonres.jdt.
                leave.
            end.
        end.
        if t-londebt.days_prc = 0 then do:
            find last histrxbal where histrxbal.subled = "lon" and histrxbal.acc = lon.lon and histrxbal.level = 9
                                      and histrxbal.dam - histrxbal.cam <= 0 no-lock no-error.
            if avail histrxbal then v-dt = histrxbal.dt.
            else v-dt = 01/01/1000.
            find first histrxbal where histrxbal.subled = "lon" and histrxbal.acc = lon.lon and histrxbal.level = 9
                                       and histrxbal.dt > v-dt no-lock no-error.
            if avail histrxbal then t-londebt.days_prc = g-today - histrxbal.dt.
        end.
    end.

    find first londebt where londebt.lon = lon.lon no-lock no-error.
    if avail londebt then t-londebt.resdat = londebt.resdat.
    else t-londebt.resdat = g-today.

  end.

end. /* for each lon */

/* перенос */
for each londebt:
    delete londebt.
end.

for each t-londebt:

  create londebt.
  buffer-copy t-londebt to londebt.

  /* черный список */
  if not(t-londebt.grp = 90 or t-londebt.grp = 92) or (t-londebt.days_od <= 30 and t-londebt.days_prc <= 30) then next.

  find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.lon = londebt.lon no-lock no-error.
  if not avail pkanketa then next.

  find first pkbadlst where pkbadlst.rnn = pkanketa.rnn no-lock no-error.
  if avail pkbadlst then next.

  create pkbadlst.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "lname" no-lock no-error.
  if avail pkanketh then pkbadlst.lname = pkanketh.value1.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fname" no-lock no-error.
  if avail pkanketh then pkbadlst.fname = pkanketh.value1.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "mname" no-lock no-error.
  if avail pkanketh then pkbadlst.mname = pkanketh.value1.
  find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "bdt" no-lock no-error.
  if avail pkanketh then do:
    pkbadlst.bdt = date(pkanketh.value1).
    pkbadlst.ybdt = year(date(pkanketh.value1)).
  end.
  assign pkbadlst.rnn = pkanketa.rnn
         pkbadlst.docnum = pkanketa.docnum
         pkbadlst.note = "Просрочка более 30 дней"
         pkbadlst.source = "int"
         pkbadlst.bank = s-ourbank
         pkbadlst.sts = "A"
         pkbadlst.rdt = g-today
         pkbadlst.rwho = g-ofc.

end. /* for each t-londebt */
