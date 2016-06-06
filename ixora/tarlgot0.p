/* tarlgot0.p
 * MODULE
        Системные настройки
 * DESCRIPTION
        Список кодов комиссий с количеством льготников
        Клиенты по группам льготного обслуживания и клиенты потребкредита показываются по запросу
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-6-3
 * AUTHOR
        18.11.2003 nadejda
 * CHANGES
        17.12.2003 nadejda - добавила pk.i для перекомпиляции
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/

{mainhead.i}
{pk.i new}


def temp-table ttt like tarifex
  field num like tarif.num
  field nr like tarif.nr.

def var l as logical.
def var v-tar as logical.
def var v-name as char.
def var v-sts as logical.
def var v-num like tarif.num.
def var v-nr like tarif.nr.
def var i as integer.
def var v-kol as integer.
def var v-group as logical init no.
def var v-dpk as logical init no.

def frame f-param
  skip(1)
  v-group label "   Показывать клиентов по группам льгот " format "да/нет" "   " skip
  v-dpk   label "   Показывать клиентов потреб. кредит-я " format "да/нет" skip(1)
  with side-labels overlay centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

update v-group v-dpk with frame f-param.


message " Формируется отчет...".

for each tarifex where tarifex.stat = 'r' no-lock break by tarifex.str5:
  if first-of (tarifex.str5) then do:
    find tarif2 where tarif2.str5 = tarifex.str5 
                  and tarif2.stat = 'r' no-lock no-error.
    v-num = tarif2.num.
    v-nr = tarif2.nr1.
  end.

  if not v-group and substr(tarifex.who, 1, 1) = "a" then next.

  if not v-dpk then do:
    find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.cif = tarifex.cif no-lock no-error.
    if avail pkanketa and tarifex.ost = 0 and tarifex.proc = 0 and tarifex.min1 = 0 and tarifex.max1 = 0 then next.
  end.

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
end.



output to rep.txt.

find first cmp no-lock. 
put cmp.name skip(1)
 " Количество клиентов с льготными тарифами по кодам комиссий" skip(1).

if not v-group then 
  put "   - без учета клиентов по группам льготного обслуживания" skip.

if not v-dpk then 
  put "   - без учета клиентов потребительского кредитования" skip.


put skip(1) " на " g-today format "99/99/9999" skip(1).


put " КОД  СЧЕТ Г/К НАИМЕНОВАНИЕ КОМИССИИ               СУММА  ПРОЦЕНТ      МИНИМУМ     МАКСИМУМ  КОГДА УСТ  КТО УСТ" skip
    fill ("-", 112) format "x(112)" skip.


for each ttt no-lock break by ttt.num by ttt.nr by ttt.str5 by ttt.ost by ttt.proc by ttt.min1 by ttt.max1:
  if first-of(ttt.nr) then do:
    find first tarif where tarif.num  = ttt.num and tarif.nr = ttt.nr 
                       and tarif.stat = 'r' no-lock no-error.
    put skip(1) " ГРУППА ТАРИФОВ: " if avail tarif then caps(tarif.pakalp) else "Неизвестная группа тарифов" format "x(40)" skip
        fill ("=", 112) format "x(112)"  skip(1).
  end.
  
  if first-of (ttt.str5) then do:
    find tarif2 where tarif2.str5 = ttt.str5 and tarif2.stat = 'r' no-lock no-error.
    put " "  tarif2.str5 format "x(5)"
        " "  tarif2.kont format "999999"
        " "  tarif2.pakalp format "x(30)"
        " "  tarif2.ost format "z,zzz,zz9.99"
        " "  tarif2.proc format "zz9.9999"
        " "  tarif2.min1 format "z,zzz,zz9.99"
        " "  tarif2.max1 format "z,zzz,zz9.99"
        " "  tarif2.whn  format "99/99/9999"
        " "  tarif2.who  format "x(8)" skip
        fill ("-", 112) format "x(112)" skip.
    v-kol = 0.
  end.

  if first-of (ttt.max1) then i = 0.

  i = i + 1.

  if last-of (ttt.max1) then do:
    put "             " 
        " " "количество льготников  "
        " "  i format "zzzzz9" 
        " "  ttt.ost format "z,zzz,zz9.99"
        " "  ttt.proc format "zz9.9999"
        " "  ttt.min1 format "z,zzz,zz9.99"
        " "  ttt.max1 format "z,zzz,zz9.99" skip.
    v-kol = v-kol + i.
  end.

  if last-of (ttt.str5) then do:
    put skip 
        fill ("-", 50) format "x(112)" skip
        "             " 
        " " "ИТОГО льготников       "
        " "  v-kol format "zzzzz9"  skip
        fill ("=", 112) format "x(112)" skip(1).
  end.
end.

output close.

hide message no-pause.

run menu-prt ("rep.txt").

