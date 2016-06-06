/* tarlgot1.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Список клиентов-льготников с сортировкой по кодам комиссий
        Клиенты по группам льготного обслуживания и клиенты потребкредита показываются по запросу
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
        07.01.2005 saltanat - включила: if avail tarif2.
        05.07.2005 saltanat - Выборка льгот по счетам.
        15.08.2006 ten - оптимизировал
*/

{mainhead.i}
{pk.i new}


def temp-table ttt no-undo like tarifex 
  field name as char
  field sts as logical
  field type as char
  field num like tarif.num
  field nr like tarif.nr
  field kod as char
  field aaa as char
  index main is primary unique  cif aaa kod.

def var l as logical no-undo.
def var v-tar as logical no-undo.
def var v-name as char no-undo.
def var v-sts as logical no-undo. 
def var v-num like tarif.num no-undo.
def var v-nr like tarif.nr no-undo.
def var i as integer no-undo.
def var v-group as logical init no no-undo.
def var v-dpk as logical init no no-undo.
def var v-comiss as char init "ALL" no-undo.


def frame f-param
  skip(1)
  v-group  label "   Показывать клиентов по группам льгот " format "да/нет" "   " skip
  v-dpk    label "   Показывать клиентов потреб. кредит-я " format "да/нет" skip(1)
  v-comiss label "   Показать комиссии по выбранным кодам " format "x(20)" 
    help " Перечислите коды комиссий через запятую или задайте ALL" 
  "  " skip(1)
  with side-labels overlay centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

update v-group v-dpk v-comiss with frame f-param.


message " Формируется отчет...".

for each tarifex where tarifex.stat = 'r' use-index id-stat no-lock break by tarifex.str5:
  if first-of (tarifex.str5) then do:
    find tarif2 where tarif2.str5 = tarifex.str5 
                  and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then do:
       v-num = tarif2.num.
       v-nr = tarif2.nr1.
    end.
  end.

  if v-comiss <> "" and v-comiss <> "ALL" and lookup(tarifex.str5, v-comiss) = 0 then next.

  if not v-group and substr(tarifex.who, 1, 1) = "a" then next.

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
  for each tarifex2 where tarifex2.str5 = tarifex.str5 
                      and tarifex2.cif = tarifex.cif 
                      and tarifex2.stat = 'r' use-index id-str5cifsta no-lock:  
                      
    find first ttt where ttt.cif = tarifex2.cif and ttt.aaa = tarifex2.aaa and ttt.kod = tarifex2.str5 no-lock no-error.
    if not avail ttt then do:
	  create ttt.
	  buffer-copy tarifex2 to ttt.

	  ttt.num = v-num.
	  ttt.nr = v-nr.
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
    if avail cif then v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).

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
 " Клиенты с льготными тарифами по кодам комиссий" skip(1).

if not v-group then 
  put "   - без учета клиентов по группам льготного обслуживания" skip.

if not v-dpk then 
  put "   - без учета клиентов потребительского кредитования" skip.

put skip(1) " на " g-today format "99/99/9999" skip(1)
  " Тип льготного тарифа : " skip
  "   A - клиенты групп льготного обслуживания" skip
  "   P - клиенты потребительского потребительского кредитования" skip
  "   M - льготный тариф установлен менеджером" skip(1).


put "   КОД     СЧЕТ Г/К   НАИМЕНОВАНИЕ КОМИССИИ, КЛИЕНТА       СУММА  ПРОЦЕНТ        МИНИМУМ       МАКСИМУМ  ТИП КОГДА УСТ  КТО УСТ  СЧЕТ КЛ  " skip
    fill ("-", 130) format "x(130)"  skip.


for each ttt no-lock break by ttt.num by ttt.nr by ttt.str5 by ttt.ost by ttt.proc by ttt.min1 by ttt.max1 by ttt.name:
  if first-of(ttt.nr) then do:
    find first tarif where tarif.num  = ttt.num and tarif.nr = ttt.nr 
                       and tarif.stat = 'r' no-lock no-error.
    put skip(1) " ГРУППА ТАРИФОВ: " if avail tarif then caps(tarif.pakalp) else "Неизвестная группа тарифов" format "x(40)" skip
        fill ("=", 130) format "x(130)" skip(1).
  end.
  
  if first-of (ttt.str5) then do:
    find tarif2 where tarif2.str5 = ttt.str5 and tarif2.stat = 'r' no-lock no-error.
    if avail tarif2 then 
    put "   "  tarif2.str5 format "x(5)"
        "   "  tarif2.punkt format "x(8)"
        "    "  tarif2.kont format "999999"
        " "  tarif2.pakalp format "x(30)"
        " "  tarif2.ost format "zzz,zzz,zz9.99"
        " "  tarif2.proc format "zz9.9999"
        " "  tarif2.min1 format "zzz,zzz,zz9.99"
        " "  tarif2.max1 format "zzz,zzz,zz9.99"
        "      "  tarif2.whn  format "99/99/9999"
        " "  tarif2.who  format "x(8)" skip
        fill ("-", 130) format "x(130)" skip.

    v-tar = no.
  end.

  if first-of (ttt.max1) then i = 0.

  if i = 0 and v-tar then 
      put skip "-----------------------" skip(1).

  i = i + 1.


  put i format "zzzzz9" 
      " "  ttt.sts format "рабч/закр"
      " "  caps(ttt.cif) format "x(6)"
      " "  ttt.name format "x(30)"
      " "  ttt.ost format "zzz,zzz,zz9.99"
      " "  ttt.proc format "zz9.9999"
      " "  ttt.min1 format "zzz,zzz,zz9.99"
      " "  ttt.max1 format "zzz,zzz,zz9.99"
      "   " ttt.type format "x"
      "  "  ttt.whn  format "99/99/9999"
      " "  substr(ttt.who, 2)  format "x(8)"
      "  " ttt.aaa format "x(9)" skip.

  v-tar = yes.

  if last-of (ttt.str5) then
    put skip fill ("-", 130) format "x(130)" skip(1).
end.

output close.

hide message no-pause.

run menu-prt ("rep.txt").

