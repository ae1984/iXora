/* dopdog.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Доп.соглашения пооткрытию 20-тизначных счетов, соотвествующих 9-ти значным
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
        07/05/2009 galina
 * BASES
        BANK
 * CHANGES
        14.05.2009 galina - не выводим допики для гарантий
        18.05.2009 galina - в филиале все Т/С выводим в одном допике
        10/01/2010 galina - поправила название месяцев на каз.языке
        15/01/2010 galina - поменяла формы договоров
        27/01/2010 galina - добавила строку о замене БИК для ЦО
        11/06/2010 galina - выводим доп соглашения по открытым 20-тизначным счетам
        01/09/2011 evseev  - исправил ошибку. если счет закрыт, то не ставить запятой в v-dep
        24/04/2012 evseev  - rebranding.БИК из sysc cleocod
        25/04/2012 evseev  - повтор
*/

{sysc.i}
{global.i}

def var v-clecod as char no-undo.
v-clecod = get-sysc-cha("clecod").

def shared var s-cif like cif.cif.
def var v-dep as char no-undo.
def var v-acc as char no-undo.
def var v-acc2 as char no-undo.
def var v-file as char no-undo.
def var v-podp as char no-undo.
def var v-podp1 as char no-undo.
def var v-bickfiliala as char no-undo.
def var v-bickfilialakz as char no-undo.
def var v-bnkofc as char no-undo.
def var v-bnkofc1 as char no-undo.
def var v-bnkreas as char no-undo.
def var v-bnkreas1 as char no-undo.
def var v-bnkofckz as char no-undo.
def var v-bnkofckz1 as char no-undo.
def var v-bnkreaskz as char no-undo.
def var v-bnkreaskz1 as char no-undo.
def var v-acclist as char no-undo.
def var v-acclistkz as char no-undo.
def var v-suf as char no-undo.
def var v-suf1 as char no-undo.
def var v-day1 as char no-undo.
def var v-day as char no-undo.
def var vr-mes as char no-undo.
def var vr-mes1 as char no-undo.
def var vr-mes2 as char no-undo.
def var v-year1 as char no-undo.
def var v-year as char no-undo.
def var vk-mes as char no-undo.
def var vk-mes1 as char no-undo.
def var vk-mes2 as char no-undo.
def var v-dt as date no-undo.
def var v-acc1 as char no-undo.
def var v-ifile as char no-undo.
def var v-ofile as char no-undo.
def var v-str as char no-undo.
def var i as  integer no-undo.
def var v-aaa9 as char no-undo.
def var v-aaa20 as char no-undo.
def stream v-out.
def buffer bss for sysc.
def buffer bmm for sysc.
def buffer bcit for sysc.
def buffer b-aaa for aaa.

find first cif where cif.cif = s-cif no-lock no-error.
if not avail cif then do:
  message "Ненайден клиент " s-cif view-as alert-box.
  return.
end.

find first aaa where aaa.cif = s-cif /*and aaa.sta <> 'C'*/ and aaa.aaa20 <> '' no-lock no-error.
if not avail aaa then do:
  message "Нет 20-значных счетов соответствующих 9-тизначным!" view-as alert-box.
  return.
end.
v-dep = ''.
v-acc = ''.
v-acc2 = ''.
find last bmm where bmm.sysc = "OURBNK" no-lock no-error.
for each aaa where aaa.cif = s-cif no-lock use-index regdt:
  if /*aaa.sta = 'C' or*/ aaa.aaa20 = '' then next.
  find first lgr where lgr.lgr = aaa.lgr no-lock no-error.
  if not avail lgr then do:
    message "Ненайдена группа счета " + aaa.lgr view-as alert-box.
    return.
  end.
  find first crc where crc.crc = aaa.crc no-lock no-error.
  if not avail crc then do:
    message "Ненайдена валюта " aaa.crc view-as alert-box.
    return.
  end.

  case lgr.led:
    when 'TDA' or when 'CDA' then do:
      if string(aaa.gl) begins "2240" then next.
      /*if v-dep <> '' then v-dep = v-dep + ','.*/
      find first b-aaa where b-aaa.aaa = aaa.aaa20 and b-aaa.sta <> 'C' no-lock no-error.
      if avail b-aaa then do:
         if v-dep <> "" then v-dep = v-dep + ",".
         v-dep = v-dep + aaa.aaa + ' ' + aaa.aaa20 + ' ' + string(aaa.regdt,'99/99/9999').
      end.
    end.
    when 'DDA' or when 'SAV' then do:
      find first b-aaa where b-aaa.aaa = aaa.aaa20 and b-aaa.sta <> 'C' no-lock no-error.
      if avail b-aaa then do:
          find first lon where lon.aaa = aaa.aaa20 and lon.sts <> 'C' no-lock no-error.
          if (not avail lon and bmm.chval = 'TXB00') or (bmm.chval <> 'TXB00') or cif.type = 'B' then do:
            if v-acc <> '' then v-acc = v-acc + ','.
            v-acc = v-acc + aaa.aaa + ' ' + aaa.aaa20 + ' ' + string(aaa.regdt,'99/99/9999') + ' ' + crc.code.
          end.
          if avail lon and bmm.chval = 'TXB00' and cif.type = 'P' then do:
            if v-acc2 <> '' then v-acc2 = v-acc2 + ','.
            v-acc2 = v-acc2 + aaa.aaa + ' ' + aaa.aaa20 + ' ' + string(aaa.regdt,'99/99/9999') + ' ' + crc.code.
          end.
          end.
    end.
  end.
end.

find last cmp no-lock no-error.


find bss where bss.sysc = "bnkadr" no-lock no-error.
if num-entries(bss.chval,"|") > 13 then
v-bickfilialakz = entry(14, bss.chval,"|") + ", " .
v-bickfilialakz = v-bickfilialakz + "СТТН " + cmp.addr[2] + ", ЖИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " .

if num-entries(bss.chval,"|") > 10 then
v-bickfilialakz = v-bickfilialakz +  entry(11, bss.chval,"|").
v-bickfiliala = cmp.name + ", " + "РНН " + cmp.addr[2] + ", ИИК " + get-sysc-cha ("bnkiik") + ", БИК " + get-sysc-cha ("clecod") + ", " + cmp.addr[1].

if bmm.chval = "TXB00" then assign v-bickfilialakz = "" v-bickfiliala = "".


find last bcit where bcit.sysc = "citi" no-lock no-error.



if bmm.chval = "TXB00" then do:

    find last sysc where sysc.sysc = "ODFACE" no-lock no-error.
    if avail sysc then do:

      v-bnkofc = entry(2,sysc.chval) + ' ' + entry(1,sysc.chval).
      v-podp = entry(3,sysc.chval).

    end.

    find last sysc where sysc.sysc = "ODSUFF" no-lock no-error.
    if avail sysc then v-suf = sysc.chval.

    find last sysc where sysc.sysc = "ODFACEKZ" no-lock no-error.
    if avail sysc then v-bnkofckz = entry(2,sysc.chval) + ' ' + entry(1,sysc.chval).

    find last sysc where sysc.sysc = "ODOSN" no-lock no-error.
    if avail sysc then v-bnkreas = sysc.chval.

    find last sysc where sysc.sysc = "ODOSNKZ" no-lock no-error.
    if avail sysc then v-bnkreaskz = sysc.chval.

    find last sysc where sysc.sysc = "DKOSN" no-lock no-error.
    if avail sysc then v-bnkreas1 = sysc.chval.

    find last sysc where sysc.sysc = "DKOSNKZ" no-lock no-error.
    if avail sysc then v-bnkreaskz1 = sysc.chval.

    find last sysc where sysc.sysc = "DKPODP" no-lock no-error.
    if avail sysc then v-podp1 = sysc.chval.

    find last sysc where sysc.sysc = "DKFACE" no-lock no-error.
    if avail sysc then v-bnkofc1 = entry(2,sysc.chval) + ' ' + entry(1,sysc.chval).

    find last sysc where sysc.sysc = "DKFACEKZ" no-lock no-error.
    if avail sysc then v-bnkofckz1 = entry(2,sysc.chval) + ' ' + entry(1,sysc.chval).

    find last sysc where sysc.sysc = "DKSUFF" no-lock no-error.
    if avail sysc then v-suf1 = sysc.chval.

end.
else do:
 find first codfr where codfr.codfr = 'DKFACE' and codfr.code = '1' no-lock no-error.
 if avail codfr then v-bnkofc = entry(2,codfr.name[1]) + ' ' + entry(1,codfr.name[1]).
 find first codfr where codfr.codfr = 'DKFACEKZ'  and codfr.code = '1' no-lock no-error.
 if avail codfr then v-bnkofckz = entry(2,codfr.name[1]) + ' ' + entry(1,codfr.name[1]).
 find first codfr where codfr.codfr = 'DKPODP'  and codfr.code = '1' no-lock no-error.
 if avail codfr then v-podp = codfr.name[1].
 find first codfr where codfr.codfr = 'DKOSN' and codfr.code = '1' no-lock no-error.
 if avail codfr then v-bnkreas = codfr.name[1].
 find first codfr where codfr.codfr = 'DKOSNKZ' and codfr.code = '1' no-lock no-error.
 if avail codfr then v-bnkreaskz = codfr.name[1].

 find first codfr where codfr.codfr = 'DKSUFF' and codfr.code = '1' no-lock no-error.
 if avail codfr then v-suf =  codfr.name[1].
end.

if v-dep <> '' then do:


  run defdts(g-today, output vr-mes2, output vk-mes2).
  v-ofile = 'dsdop.htm'.

  if cif.type = "B" then do:
    if bmm.chval = "TXB00" then  v-ifile = '/data/export/dsurofdop.htm'.
    else v-ifile = '/data/export/dsurfildop.htm'.
  end.
  if cif.type = "P" then do:
    if bmm.chval = "TXB00" then  v-ifile = '/data/export/dsfizofdop.htm'.
    else v-ifile = '/data/export/dsfizfildop.htm'.
  end.
  message v-dep. pause.
  do i = 1 to num-entries(v-dep):
    run defdts(date(entry(3,entry(i,v-dep),' ')), output vr-mes, output vk-mes).
    v-aaa20 =  entry(2,entry(i,v-dep),' ').
    v-aaa9 = entry(1,entry(i,v-dep),' ').
    v-day1 = string(day(date(entry(3,entry(i,v-dep),' '))),'99').
    v-year1 = string(year(date(entry(3,entry(i,v-dep),' '))),'9999').

   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*day1*" then do:
              v-str = replace (v-str, "day1", v-day1).
              next.
           end.
           if v-str matches "*month1*" then do:
              v-str = replace (v-str, "month1", vr-mes).
              next.
           end.
           if v-str matches "*mnkz1*" then do:
              v-str = replace (v-str, "mnkz1", vk-mes).
              next.
           end.

           if v-str matches "*year1*" then do:
              v-str = replace (v-str, "year1", v-year1).
              next.
           end.
           if v-str matches "*city*" then do:
              v-str = replace (v-str, "city", bcit.chval ).
              next.
           end.
           if v-str matches "*day2*" then do:
              v-str = replace (v-str, "day2", string(day(g-today),'99')).
              next.
           end.
           if v-str matches "*month2*" then do:
              v-str = replace (v-str, "month2", vr-mes2 ).
              next.
           end.
           if v-str matches "*mnkz2*" then do:
              v-str = replace (v-str, "mnkz2", vk-mes2 ).
              next.
           end.

           if v-str matches "*year2*" then do:
              v-str = replace (v-str, "year2", string(year(g-today),'9999')).
              next.
           end.
           if v-str matches "*bnkofc*" then do:
              v-str = replace (v-str, "bnkofc", v-bnkofc ).
              next.
           end.
           if v-str matches "*bnkfacekz*" then do:
              v-str = replace (v-str, "bnkfacekz", v-bnkofckz ).
              next.
           end.

           if v-str matches "*bnkreas*" then do:
              v-str = replace (v-str, "bnkreas", v-bnkreas).
              next.
           end.
           if v-str matches "*bnkrskz*" then do:
              v-str = replace (v-str, "bnkrskz", v-bnkreaskz).
              next.
           end.
           if v-str matches "*aaa9*" then do:
              v-str = replace (v-str, "aaa9", v-aaa9).
              next.
           end.
           if v-str matches "*aaa20*" then do:
              v-str = replace (v-str, "aaa20", v-aaa20).
              next.
           end.

           if v-str matches "*danniefil*" then do:
              v-str = replace (v-str, "danniefil", v-bickfiliala).
              next.
           end.
           if v-str matches "*bickfilialakz*" then do:
              v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
              next.
           end.

           if v-str matches "*dirdeprt*" then do:
              v-str = replace (v-str, "dirdeprt", v-podp).
              next.
           end.

           if v-str matches "*clname*" then do:
              if cif.type = "B" then v-str = replace (v-str, "clname", cif.pref + ' ' + cif.name).
              else v-str = replace (v-str, "clname", cif.name).
              next.
           end.
           if v-str matches "*claddr*" then do:
              v-str = replace (v-str, "claddr", cif.addr[1] + ' ' + cif.addr[2]).
              next.
           end.
           if v-str matches "*clpass*" then do:
              v-str = replace (v-str, "clpass", cif.pss).
              next.
           end.
           if v-str matches "*clrnn*" then do:
              v-str = replace (v-str, "clrnn", cif.jss).
              next.
           end.

           if v-str matches "*cltel*" then do:
              v-str = replace (v-str, "cltel", cif.tel ).
              next.
           end.
           if v-str matches "*clfax*" then do:
              v-str = replace (v-str, "clfax", cif.fax).
              next.
           end.
/*           if v-str matches "*bik*" then do:
              v-str = replace (v-str, "bik", get-sysc-cha ("clecod")).
              next.
           end.*/
           if v-str matches "*bik*" then do:
              v-str = replace (v-str, "bik", v-clecod).
              next.
           end.

           if v-str matches "*fbic*" then do:
              /*if bmm.chval <> "TXB00" then*/ v-str = replace (v-str, "fbic", '"' + get-sysc-cha ("clecod") + '"').
              /*else v-str = replace (v-str, "fbic", '"________"').*/
              next.
           end.

           if v-str matches "*cluradd*" then do:
              v-str = replace (v-str, "cluradd", cif.addr[1] ).
              next.
           end.
           if v-str matches "*clfadd*" then do:
              v-str = replace (v-str, "clfadd", cif.addr[2] ).
              next.
           end.
           if v-str matches "*suf*" then do:
              v-str = replace (v-str, "suf", v-suf ).
              next.
           end.
           leave.
         end.
         put stream v-out unformatted v-str skip.
      end.
    input close.
    output stream v-out close.
    unix silent cptwin value(v-ofile) winword.
  end.
end.
v-acclist = ''.
v-acclistkz = ''.
if v-acc <> '' then do:

  do i = 1 to num-entries(v-acc):
     run defdts(date(entry(3,entry(i,v-acc),' ')), output vr-mes, output vk-mes).
     if i = 1 then do:
       v-dt = date(entry(3,entry(i,v-acc),' ')).
       v-acc1 = entry(2,entry(i,v-acc),' ').
     end.
     else do:
       if v-dt > date(entry(3,entry(i,v-acc),' ')) then do:
         v-dt = date(entry(3,entry(i,v-acc),' ')).
         v-acc1 = entry(1,entry(i,v-acc),' ').
       end.
     end.
     v-day =  string(day(date(entry(3,entry(i,v-acc),' '))),'99').
     v-year = string(year(date(entry(3,entry(i,v-acc),' '))),'9999').

     v-acclist = v-acclist + 'ИИК ' + entry(1,entry(i,v-acc),' ') + ', валюта счета ' + entry(4,entry(i,v-acc),' ') + ', дата открытия по Договору "' + v-day + '" ' + vr-mes + ' ' + v-year + ' г., Дополнительный номер: ' + entry(2,entry(i,v-acc),' ') + ';<br>'.
     v-acclistkz = v-acclistkz + 'ЖСК ' + entry(1,entry(i,v-acc),' ') + ', шот валютасы ' + entry(4,entry(i,v-acc),' ') + ', Шарт бойынша ашу куні "' + v-day + '" ' + vk-mes + ' ' + v-year + ' ж., Ќосымша нґмір: ' + entry(2,entry(i,v-acc),' ') + ';<br>'.
  end.

  run defdts(v-dt, output vr-mes1, output vk-mes1).
  v-day1 =  string(day(v-dt),'99').
  v-year1 = string(year(v-dt),'9999').
  v-ofile = 'tsdop.htm'.
  run defdts(g-today, output vr-mes2, output vk-mes2).
  if cif.type = "B" then do:
    if cif.cgr = 403  then do:
      if bmm.chval = "TXB00" then
         v-ifile = '/data/export/tsipofdop.htm'.
      else v-ifile = '/data/export/tsipfildop.htm'.
    end.
    else do:
      if bmm.chval = "TXB00" then do:
        /*if num-entries(v-acc) = 1 then v-ifile = '/data/export/tsurofdop.htm'.
        else */ v-ifile = '/data/export/tsurofdop2.htm'.
      end.
      else do:
        /*if num-entries(v-acc) = 1 then v-ifile = '/data/export/tsurfildop.htm'.
        else*/ v-ifile = '/data/export/tsurfildop2.htm'.
      end.
    end.
  end.
  if cif.type = "P" then do:
   if bmm.chval = "TXB00" then do:
     /*if num-entries(v-acc) = 1 then v-ifile = '/data/export/tsfizofdop.htm'.
     else*/ v-ifile = '/data/export/tsfizofdop2.htm'.
   end.
   else do:
     /*if num-entries(v-acc) = 1 then v-ifile = '/data/export/tsfizfildop.htm'.
     else*/ v-ifile = '/data/export/tsfizfildop2.htm'.
   end.
  end.
   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*day1*" then do:
              v-str = replace (v-str, "day1", v-day1).
              next.
           end.
           if v-str matches "*month1*" then do:
              v-str = replace (v-str, "month1", vr-mes1 ).
              next.
           end.
           if v-str matches "*mnkz1*" then do:
              v-str = replace (v-str, "mnkz1", vk-mes1 ).
              next.
           end.

           if v-str matches "*year1*" then do:
              v-str = replace (v-str, "year1", v-year1).
              next.
           end.
           if v-str matches "*city*" then do:
              v-str = replace (v-str, "city", bcit.chval ).
              next.
           end.
           if v-str matches "*day2*" then do:
              v-str = replace (v-str, "day2", string(day(g-today),'99')).
              next.
           end.
           if v-str matches "*month2*" then do:
              v-str = replace (v-str, "month2", vr-mes2 ).
              next.
           end.
           if v-str matches "*mnkz2*" then do:
              v-str = replace (v-str, "mnkz2", vk-mes2 ).
              next.
           end.

           if v-str matches "*year2*" then do:
              v-str = replace (v-str, "year2", string(year(g-today),'9999')).
              next.
           end.
           if v-str matches "*bnkofc*" then do:
              v-str = replace (v-str, "bnkofc", v-bnkofc ).
              next.
           end.
           if v-str matches "*bnkfacekz*" then do:
              v-str = replace (v-str, "bnkfacekz", v-bnkofckz ).
              next.
           end.

           if v-str matches "*bnkreas*" then do:
              v-str = replace (v-str, "bnkreas", v-bnkreas).
              next.
           end.
           if v-str matches "*bnkrskz*" then do:
              v-str = replace (v-str, "bnkrskz", v-bnkreaskz).
              next.
           end.
           if v-str matches "*acclist*" then do:
              v-str = replace (v-str, "acclist", v-acclist).
              next.
           end.
           if v-str matches "*aaalistkz*" then do:
              v-str = replace (v-str, "aaalistkz", v-acclistkz).
              next.
           end.

           if v-str matches "*danniefil*" then do:
              v-str = replace (v-str, "danniefil", v-bickfiliala).
              next.
           end.
           if v-str matches "*bickfilialakz*" then do:
              v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
              next.
           end.

           if v-str matches "*dirdeprt*" then do:
              v-str = replace (v-str, "dirdeprt", v-podp).
              next.
           end.

           if v-str matches "*clname*" then do:
              if cif.type = "B" then v-str = replace (v-str, "clname", cif.pref + ' ' + cif.name).
              else v-str = replace (v-str, "clname", cif.name).
              next.
           end.
           if v-str matches "*claddr*" then do:
              v-str = replace (v-str, "claddr", cif.addr[1] + ' ' + cif.addr[2]).
              next.
           end.
           if v-str matches "*clpass*" then do:
              v-str = replace (v-str, "clpass", cif.pss).
              next.
           end.
           if v-str matches "*clrnn*" then do:
              v-str = replace (v-str, "clrnn", cif.jss).
              next.
           end.

           if v-str matches "*cltel*" then do:
              v-str = replace (v-str, "cltel", cif.tel ).
              next.
           end.
           if v-str matches "*clfax*" then do:
              v-str = replace (v-str, "clfax", cif.fax).
              next.
           end.
           if v-str matches "*bik*" then do:
              v-str = replace (v-str, "bik", v-clecod).
              next.
           end.
           if v-str matches "*fbic*" then do:
              /*if bmm.chval <> "TXB00" then*/ v-str = replace (v-str, "fbic", '"' + get-sysc-cha ("clecod") + '"').
              /*else v-str = replace (v-str, "fbic", '"________"').*/
              next.
           end.
           if v-str matches "*acc*" then do:
              v-str = replace (v-str, "acc", v-acc1 ).
              next.
           end.
           if v-str matches "*clreg*" then do:
              v-str = replace (v-str, "clreg", cif.ref[8] ).
              next.
           end.

           if v-str matches "*cluradd*" then do:
              v-str = replace (v-str, "cluradd", cif.addr[1] ).
              next.
           end.

           if v-str matches "*clfadd*" then do:
              v-str = replace (v-str, "clfadd", cif.addr[2] ).
              next.
           end.
           if v-str matches "*suf*" then do:
              v-str = replace (v-str, "suf", v-suf ).
              next.
           end.

           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.

   unix silent cptwin value(v-ofile) winword.
end.

v-acclist = ''.
v-acclistkz = ''.
if v-acc2 <> '' and bmm.chval = "TXB00" then do:

  do i = 1 to num-entries(v-acc2):
     run defdts(date(entry(3,entry(i,v-acc2),' ')), output vr-mes, output vk-mes).
     if i = 1 then do:
       v-dt = date(entry(3,entry(i,v-acc2),' ')).
       v-acc1 = entry(2,entry(i,v-acc2),' ').
     end.
     else do:
       if v-dt > date(entry(3,entry(i,v-acc2),' ')) then do:
         v-dt = date(entry(3,entry(i,v-acc2),' ')).
         v-acc1 = entry(1,entry(i,v-acc2),' ').
       end.
     end.
     v-day =  string(day(date(entry(3,entry(i,v-acc2),' '))),'99').
     v-year = string(year(date(entry(3,entry(i,v-acc2),' '))),'9999').

     v-acclist = v-acclist + 'ИИК ' + entry(1,entry(i,v-acc2),' ') + ', валюта счета ' + entry(4,entry(i,v-acc2),' ') + ', дата открытия по Договору "' + v-day + '" ' + vr-mes + ' ' + v-year + ' г., Дополнительный номер: ' + entry(2,entry(i,v-acc2),' ') + ';<br>'.
     v-acclistkz = v-acclistkz + 'ЖСК ' + entry(1,entry(i,v-acc2),' ') + ', шот валютасы ' + entry(4,entry(i,v-acc2),' ') + ', Шарт бойынша ашу куні "' + v-day + '" ' + vk-mes + ' ' + v-year + ' ж., Ќосымша нґмір: ' + entry(2,entry(i,v-acc2),' ') + ';<br>'.
  end.

  run defdts(v-dt, output vr-mes1, output vk-mes1).
  v-day1 =  string(day(v-dt),'99').
  v-year1 = string(year(v-dt),'9999').
  v-ofile = 'tsdop.htm'.
  run defdts(g-today, output vr-mes2, output vk-mes2).
  if cif.type = "B" then do:
    if cif.cgr = 403  then  v-ifile = '/data/export/tsipofdoppk.htm'.
    else do:
     /* if num-entries(v-acc2) = 1 then v-ifile = '/data/export/tsurofdoppk.htm'.
      else*/ v-ifile = '/data/export/tsurofdoppk2.htm'.
    end.
  end.
  if cif.type = "P" then do:
     /*if num-entries(v-acc2) = 1 then v-ifile = '/data/export/tsfizofdoppk.htm'.
     else*/ v-ifile = '/data/export/tsfizofdoppk2.htm'.
  end.
   output stream v-out to value(v-ofile).
   input from value(v-ifile).
      repeat:
         import unformatted v-str.
         v-str = trim(v-str).
         repeat:
           if v-str matches "*day1*" then do:
              v-str = replace (v-str, "day1", v-day1).
              next.
           end.
           if v-str matches "*month1*" then do:
              v-str = replace (v-str, "month1", vr-mes1 ).
              next.
           end.
           if v-str matches "*mnkz1*" then do:
              v-str = replace (v-str, "mnkz1", vk-mes1 ).
              next.
           end.

           if v-str matches "*year1*" then do:
              v-str = replace (v-str, "year1", v-year1).
              next.
           end.
           if v-str matches "*city*" then do:
              v-str = replace (v-str, "city", bcit.chval ).
              next.
           end.
           if v-str matches "*day2*" then do:
              v-str = replace (v-str, "day2", string(day(g-today),'99')).
              next.
           end.
           if v-str matches "*month2*" then do:
              v-str = replace (v-str, "month2", vr-mes2 ).
              next.
           end.
           if v-str matches "*mnkz2*" then do:
              v-str = replace (v-str, "mnkz2", vk-mes2 ).
              next.
           end.

           if v-str matches "*year2*" then do:
              v-str = replace (v-str, "year2", string(year(g-today),'9999')).
              next.
           end.
           if v-str matches "*bnkofc*" then do:
              v-str = replace (v-str, "bnkofc", v-bnkofc1 ).
              next.
           end.
           if v-str matches "*bnkfacekz*" then do:
              v-str = replace (v-str, "bnkfacekz", v-bnkofckz1 ).
              next.
           end.

           if v-str matches "*bnkreas*" then do:
              v-str = replace (v-str, "bnkreas", v-bnkreas1).
              next.
           end.
           if v-str matches "*bnkrskz*" then do:
              v-str = replace (v-str, "bnkrskz", v-bnkreaskz1).
              next.
           end.
           if v-str matches "*acclist*" then do:
              v-str = replace (v-str, "acclist", v-acclist).
              next.
           end.
           if v-str matches "*aaalistkz*" then do:
              v-str = replace (v-str, "aaalistkz", v-acclistkz).
              next.
           end.

           if v-str matches "*danniefil*" then do:
              v-str = replace (v-str, "danniefil", v-bickfiliala).
              next.
           end.
           if v-str matches "*bickfilialakz*" then do:
              v-str = replace (v-str, "bickfilialakz", v-bickfilialakz).
              next.
           end.

           if v-str matches "*dirdeprt*" then do:
              v-str = replace (v-str, "dirdeprt", v-podp1).
              next.
           end.

           if v-str matches "*clname*" then do:
              if cif.type = "B" then v-str = replace (v-str, "clname", cif.pref + ' ' + cif.name).
              else v-str = replace (v-str, "clname", cif.name).
              next.
           end.
           if v-str matches "*claddr*" then do:
              v-str = replace (v-str, "claddr", cif.addr[1] + ' ' + cif.addr[2]).
              next.
           end.
           if v-str matches "*clpass*" then do:
              v-str = replace (v-str, "clpass", cif.pss).
              next.
           end.
           if v-str matches "*clrnn*" then do:
              v-str = replace (v-str, "clrnn", cif.jss).
              next.
           end.

           if v-str matches "*cltel*" then do:
              v-str = replace (v-str, "cltel", cif.tel ).
              next.
           end.
           if v-str matches "*clfax*" then do:
              v-str = replace (v-str, "clfax", cif.fax).
              next.
           end.
           if v-str matches "*bik*" then do:
              v-str = replace (v-str, "bik", v-clecod).
              next.
           end.
           if v-str matches "*fbic*" then do:
              /*if bmm.chval <> "TXB00" then*/ v-str = replace (v-str, "fbic", '"' + get-sysc-cha ("clecod") + '"').
              /*else v-str = replace (v-str, "fbic", '"________"').*/
              next.
           end.
           if v-str matches "*acc*" then do:
              v-str = replace (v-str, "acc", v-acc1 ).
              next.
           end.
           if v-str matches "*clreg*" then do:
              v-str = replace (v-str, "clreg", cif.ref[8] ).
              next.
           end.

           if v-str matches "*cluradd*" then do:
              v-str = replace (v-str, "cluradd", cif.addr[1] ).
              next.
           end.

           if v-str matches "*clfadd*" then do:
              v-str = replace (v-str, "clfadd", cif.addr[2] ).
              next.
           end.
           if v-str matches "*suf*" then do:
              v-str = replace (v-str, "suf", v-suf ).
              next.
           end.

           leave.
         end.

      put stream v-out unformatted v-str skip.
      end.
   input close.
   output stream v-out close.
   unix silent cptwin value(v-ofile) winword.
end.

procedure defdts:
def input parameter p-dt as date.
def output parameter p-datastr as char.
def output parameter p-datastrkz as char.

def var v-monthname as char init
   "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".

def var v-monthnamekz as char init
   "&#1179;а&#1187;тар,а&#1179;пан,наурыз,с&#1241;уiр,мамыр,маусым,шiлде,тамыз,&#1179;ырк&#1199;йек,&#1179;азан,&#1179;араша,желто&#1179;сан".
p-datastr = entry(month(p-dt), v-monthname).
p-datastrkz = entry(month(p-dt), v-monthnamekz).

end.

