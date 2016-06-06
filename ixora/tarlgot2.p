/* tarlgot2.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Список клиентов-льготников с сортировкой по кодам клиентов
        Клиенты по группам льготного обслуживания и клиенты потребкредита не показываются
 * RUN
        главное меню
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        9-1-2-6-3
 * AUTHOR
        17.11.2003 nadejda
 * CHANGES
        17.12.2003 nadejda - добавила pk.i для перекомпиляции
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        05.07.2005 saltanat - Выборка льгот по счетам.
        30.03.2012 id00810 - проверка наличия cif
*/

{mainhead.i}
{pk.i new}


def temp-table ttt like tarifex
  field name as char
  field sts as logical
  field type as char
  field num like tarif.num
  field kod as char
  field aaa as char
  field nr like tarif.nr
  index main is primary unique name cif kod aaa.

def var l as logical.
def var v-tar as logical.
def var v-name as char.
def var v-sts as logical.
def var v-num like tarif.num.
def var v-nr like tarif.nr.
def var i as integer.

def var v-group as logical init no.
def var v-dpk as logical init no.
def var v-clnsts as integer init 3.

def frame f-param
  skip(1)
  v-group  label "  Показывать тарифы по группам льгот " format "да/нет" "   " skip
  v-dpk    label "  Показывать клиентов потреб.кредит. " format "да/нет" "  " skip(1)
  v-clnsts label "   1) Юрлица    2) Физлица    3) все " format "9"
    help " Укажите номер параметра"
  skip(1)
  with side-labels overlay centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

update v-group v-dpk v-clnsts with frame f-param.

message " Формируется отчет...".

for each tarifex where tarifex.stat = 'r' no-lock break by tarifex.str5:
  if first-of (tarifex.str5) then do:
    find first tarif2 where tarif2.str5 = tarifex.str5 and tarif2.stat = 'r' no-lock no-error.
    if not avail tarif2 then next.
    v-num = tarif2.num.
    v-nr = tarif2.nr1.
  end.

  find cif where cif.cif = tarifex.cif  no-lock no-error.
  if not avail cif then next.

  if not v-group and substr(tarifex.who, 1, 1) = "a" then next.

  find sub-cod where sub-cod.sub = "cln" and sub-cod.d-cod = "clnsts" and sub-cod.acc = tarifex.cif no-lock no-error.
  if ((not avail sub-cod or sub-cod.ccode = "0") and v-clnsts = 2) or
     ((not avail sub-cod or sub-cod.ccode = "1") and v-clnsts = 1) then next.

  find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = tarifex.cif no-lock no-error.
  if not v-dpk and
     avail pkanketa and
     tarifex.ost = 0 and
     tarifex.proc = 0 and
     tarifex.min1 = 0 and
     tarifex.max1 = 0 then next.

/*
  find first tarif2 where tarif2.str5 = tarifex.str5 no-lock no-error.
  if (tarifex.ost = tarif2.ost and
      tarifex.proc = tarif2.proc and
      tarifex.min1 = tarif2.min1 and
      tarifex.max1 = tarif2.max1) then next.
*/

  create ttt.
  buffer-copy tarifex to ttt.

  ttt.num = v-num.
  ttt.nr = v-nr.
  ttt.kod = tarifex.str5.

  if substr(tarifex.who, 1, 1) = "a" then ttt.type = "A".
  else
    if avail pkanketa then ttt.type = "P".
                      else ttt.type = "M".

  /* 05/07/05 saltanat - Если у клиента есть льготы по счету, то берем тариф по счету */
  for each tarifex2 where tarifex2.cif = tarifex.cif
                      and tarifex2.str5 = tarifex.str5
                      and tarifex2.stat = 'r' no-lock:

    find first ttt where ttt.cif = tarifex2.cif and ttt.aaa = tarifex2.aaa and ttt.kod = tarifex2.str5 no-lock no-error.
    if not avail ttt then do:
	  create ttt.
	  buffer-copy tarifex2 to ttt.

	  ttt.num = v-num.
	  ttt.nr  = v-nr.
	  ttt.kod = tarifex2.str5.
	  ttt.aaa = tarifex2.aaa.

	  if substr(tarifex2.who, 1, 1) = "a" then ttt.type = "A".
	  else
	    if avail pkanketa then ttt.type = "P".
    	                  else ttt.type = "M".
	end.
   end. /* tarifex2 */
end.

for each ttt break by ttt.cif:
  if first-of(ttt.cif) then do:
    find cif where cif.cif = ttt.cif no-lock no-error.
    v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).

    find first aaa where aaa.cif = ttt.cif and aaa.sta <> "c" and
         can-find (lgr where lgr.lgr = aaa.lgr and lgr.led <> "ODA" no-lock) no-lock no-error.
    if avail aaa then v-sts = yes.
    else do:
      find first lon where lon.cif = ttt.cif and
           can-find (first trxbal where trxbal.sub = "lon" and
                           trxbal.acc = lon.lon and
                           trxbal.cam <> trxbal.dam and
                           trxbal.lev <> 11 and trxbal.lev <> 9 no-lock) no-lock no-error.
      v-sts = avail lon.
    end.
  end.
  ttt.name = v-name.
  ttt.sts = v-sts.
end.





output to rep.txt.

find first cmp no-lock.
put cmp.name skip(1)
 " Клиенты с льготными тарифами" skip.

if not v-group then
  put "   - без учета клиентов по группам льготного обслуживания" skip.

if not v-dpk then
  put "   - без учета клиентов потребительского кредитования" skip.

put skip(1) " на " g-today format "99/99/9999" skip(1)
  " Тип льготного тарифа : " skip
  "   A - группа льготного обслуживания" skip
  "   P - клиенты потребительского потребительского кредитования" skip
  "   M - льготный тариф установлен менеджером" skip(1).


put "    КОД   ПУНКТ    СЧЕТ ГК НАИМЕНОВАНИЕ КОМИССИИ                   СУММА  ПРОЦЕНТ        МИНИМУМ       МАКСИМУМ ТИП КОГДА УСТ  КТО УСТ  СЧЕТ КЛ" skip
    fill ("-", 125) format "x(125)" skip.


for each ttt no-lock break by ttt.name by ttt.cif by ttt.str5:

  if first-of (ttt.cif) then do:
    put " "   caps(ttt.cif) format "x(6)"
        "   " ttt.sts format "рабч/закр"
        "   "  ttt.name format "x(30)" skip
        "-----------------------" skip.
    i = 0.
  end.

  i = i + 1.

  find first tarif2 where tarif2.str5 = ttt.kod and tarif2.stat = "r" no-lock no-error.
  if not avail tarif2 then next.

  put i format "zz9"
      " "  ttt.str5 format "x(4)"
      " "  tarif2.punkt format "x(8)"
      " "  ttt.kont format "999999"
      " "  tarif2.pakalp format "x(30)"
      " "  ttt.ost format "zzz,zzz,zz9.99"
      " "  ttt.proc format "zz9.9999"
      " "  ttt.min1 format "zzz,zzz,zz9.99"
      " "  ttt.max1 format "zzz,zzz,zz9.99"
      "  " ttt.type format "x"
      "  " ttt.whn  format "99/99/9999"
      " "  substr(ttt.who, 2)  format "x(8)"
      " "  ttt.aaa format "x(9)" skip.

  v-tar = yes.

  if last-of (ttt.cif) then
    put skip fill ("-", 125) format "x(125)" skip(1).
end.

output close.

hide message no-pause.

run menu-prt ("rep.txt").

